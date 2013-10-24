package de.conterra.smaad.inspiretm;

import org.apache.commons.httpclient.DefaultHttpMethodRetryHandler;
import org.apache.commons.httpclient.methods.GetMethod;
import org.apache.commons.httpclient.params.HttpMethodParams;
import org.apache.log4j.Logger;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.InputSource;

import javax.servlet.ServletException;
import javax.xml.namespace.NamespaceContext;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathExpressionException;
import javax.xml.xpath.XPathFactory;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.UnsupportedEncodingException;
import java.util.Iterator;

/**
 * Specialization of the TransformationServlet. It can be used to wrap a CIM catalogue and adds the functionality
 * to request the original MD_Metadata record via GetRepositoryItem when full results are requested.
 */
public class InspireServlet extends TransformationServlet implements NamespaceContext {
    private final Logger LOGGER = Logger.getLogger(TransformationServlet.class);

    private final static String PREFIX_GMD = "gmd";
    private final static String PREFIX_GCO = "gco";
    private final static String PREFIX_CSW = "csw";

    private final static String NS_GMD = "http://www.isotc211.org/2005/gmd";
    private final static String NS_GCO = "http://www.isotc211.org/2005/gco";
    private final static String NS_CSW = "http://www.opengis.net/cat/csw/2.0.2";
    private final static String XPATH_RESOURCE_METADATA =
            "//*[@objectType = 'urn:ogc:def:ebRIM-ObjectType:OGC-I15::ElementaryDataset' or " +
            "@objectType = 'urn:ogc:def:ebRIM-ObjectType:OGC-I15::ServiceMetadata' or " +
            "@objectType = 'urn:ogc:def:ebRIM-ObjectType:OGC-I15::DatasetCollection' or " +
            "@objectType = 'urn:ogc:def:ebRIM-ObjectType:OGC-I15::Application']";

    private final DocumentBuilderFactory documentBuilderFactory = DocumentBuilderFactory.newInstance();
    private final XPathFactory xPathFactory = XPathFactory.newInstance();
    private final TransformerFactory transformerFactory = TransformerFactory.newInstance();

    @Override
    public void init() throws ServletException {
        super.init();
        documentBuilderFactory.setNamespaceAware(true);
    }

    @Override
    protected void transformResponse(TransformationEngine engine, ByteArrayInputStream response,
                                     ByteArrayOutputStream transformedResponse) throws ExceptionReport {
        XPath mdPath = xPathFactory.newXPath();
        mdPath.setNamespaceContext(this);

        // we need to call GetRepositoryItem for every element set name, because the result
        // just contains the resource metadata
/*
        String elementSet = null;
        try {
            elementSet = mdPath.evaluate("//csw:ElementSetName",
                    new InputSource(new ByteArrayInputStream(engine.getOriginalRequest())));
        } catch (XPathExpressionException e) {
            LOGGER.error("Error evaluating XPath", e);
            throw new ExceptionReport("Error evaluating XPath", e);
        }

        if (! "full".equals(elementSet)) {
            super.transformResponse(engine, response, transformedResponse);
            return;
        }
*/
        DocumentBuilder builder;
        Document responseDoc;
        try {
            builder = documentBuilderFactory.newDocumentBuilder();
            responseDoc = builder.parse(response);
        } catch (Exception e) {
            LOGGER.error("Error parsing the response document from remote CSW", e);
            throw new ExceptionReport("Error parsing the response document from remote CSW", e);
        }

        NodeList mdNodes;
        try {
            // with the @id of *Metadata repository object, request original MD_Metadata via GetRepositoryItem
            Element searchResults = (Element) mdPath.evaluate("//csw:SearchResults", responseDoc, XPathConstants.NODE);
            if (searchResults == null) {
                // something unexpected, likely a fault
                response.reset();
                super.transformResponse(engine, response, transformedResponse);
                return;
            }
            mdNodes = (NodeList) mdPath.evaluate(XPATH_RESOURCE_METADATA, responseDoc, XPathConstants.NODESET);
            for (int i = 0; i < mdNodes.getLength(); i++) {
                Node mdNode = mdNodes.item(i);
                String fileId = mdPath.evaluate("@id", mdNode);
                insertMetadata(searchResults, fileId);
            }
            // now remove all rim nodes from the results
            NodeList nl = searchResults.getChildNodes();
            for (int i = nl.getLength() - 1; i > 0; i--) {
                Node n = nl.item(i);
                if (n.getNodeType() == Node.ELEMENT_NODE && !(n.getLocalName().equals("MD_Metadata") ||
                        n.getLocalName().equals("Record") || n.getLocalName().equals("SummaryRecord") ||
                        n.getLocalName().equals("BriefRecord"))) {
                    searchResults.removeChild(n);
                }
            }
        } catch (XPathExpressionException e) {
            LOGGER.error("Error evaluating XPath", e);
            throw new ExceptionReport("Error evaluating XPath", e);
        }
        catch (Throwable t) {
            LOGGER.error("Error evaluating XPath", t);
            throw new ExceptionReport("Error evaluating XPath", t);
        }

        transformedResponse.reset();
        try {
            Transformer transformer = transformerFactory.newTransformer();
            ByteArrayOutputStream bout = new ByteArrayOutputStream();
            transformer.transform(new DOMSource(responseDoc), new StreamResult(bout));
            super.transformResponse(engine, new ByteArrayInputStream(bout.toByteArray()), transformedResponse);
        } catch (Exception e) {
            LOGGER.error("Error serializing response document to XML", e);
            throw new ExceptionReport("Error serializing response document to XML", e);
        }
    }

    /**
     * Requests an MD_Metadata record via GetRepositoryItem from the CIM catalogue and adds it to the search results.
     * @param searchResults the searchResults element of the response
     * @param id @id of the extrinsic object
     * @throws ExceptionReport
     */
    private void insertMetadata(Node searchResults, String id) throws ExceptionReport {
        if (id == null || id.isEmpty()) {
            return;
        }
        GetMethod method = new GetMethod(getTargetServiceUrl() +
                "?service=CSW-ebRIM&version=2.0.2&request=GetRepositoryItem&Id=" + id);
        method.getParams().setParameter(HttpMethodParams.RETRY_HANDLER,
                new DefaultHttpMethodRetryHandler(3, false));

        Document getRepResponse = null;

        // send request
        try {
            int statusCode = getClient().executeMethod(method);
            checkResponseCode(statusCode);
            byte[] targetResponse = method.getResponseBody();
            if (LOGGER.isDebugEnabled()) {
                try {
                    LOGGER.debug("Received response from target service:");
                    LOGGER.debug(new String(targetResponse, "utf-8"));
                } catch (UnsupportedEncodingException e) {
                    LOGGER.error(e);
                }
            }
            getRepResponse = documentBuilderFactory.newDocumentBuilder().parse(new ByteArrayInputStream(targetResponse));
        } catch (Exception e) {
            if (e instanceof ExceptionReport) {
                throw (ExceptionReport) e;
            }
            LOGGER.error("Error in GetRepositoryItem request", e);
            throw new ExceptionReport("Error in GetRepositoryItem request", e);
        }
        if (getRepResponse != null) {
            Node importedNode = searchResults.getOwnerDocument().importNode(getRepResponse.getDocumentElement(), true);
            searchResults.appendChild(importedNode);
        }
    }

    // NamespaceContext interface
    public String getNamespaceURI(String prefix) {
        if (PREFIX_GMD.equals(prefix)) {
            return NS_GMD;
        }
        else if (PREFIX_GCO.equals(prefix)) {
            return NS_GCO;
        }
        else if (PREFIX_CSW.equals(prefix)) {
            return NS_CSW;
        }
        return null;
    }

    public String getPrefix(String namespaceURI) {
        if (NS_GMD.equals(namespaceURI)) {
            return PREFIX_GMD;
        }
        else if (NS_GCO.equals(namespaceURI)) {
            return PREFIX_GCO;
        }
        else if (NS_CSW.equals(namespaceURI)) {
            return PREFIX_CSW;
        }
        return null;
    }

    public Iterator getPrefixes(String namespaceURI) {
        return null;
    }
}

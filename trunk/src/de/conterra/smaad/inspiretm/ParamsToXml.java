package de.conterra.smaad.inspiretm;

import org.w3c.dom.DOMImplementation;
import org.w3c.dom.Document;
import org.w3c.dom.Element;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.TransformerException;
import java.util.Iterator;
import java.util.Map;

/**
 * Transforms servlet parameters to an XML representation for further stylesheet processing.
 * The structure of the XML is:
 * <parameters>
 *  <parameter>
 *      <name>parameter_name_1</name>
 *      <value>parameter_value_1</value>
 *  </parameter>
 * ...
 * </parameters>
 * Author: Udo Einspanier, con terra GmbH
 */
public class ParamsToXml {
    // namespace for the new elements
    private final static String NS = "urn:aadd40b1-c384-41a1-bb5f-b9730a90daae";

    /**
     * Transforms a map of parameters to a DOM representation. Parameter names are then lower-case.
     * @param params the parameters
     * @return a DOM representation
     * @throws ExceptionReport
     */
    public Document asDom(Map params) throws ExceptionReport {
        Document doc;
        try {
            DocumentBuilderFactory lFactory = DocumentBuilderFactory.newInstance();
            lFactory.setNamespaceAware(true);
            DocumentBuilder builder = lFactory.newDocumentBuilder();
            DOMImplementation domImpl = builder.getDOMImplementation();
            doc = domImpl.createDocument(NS, "tmp:parameters", null);
        } catch (ParserConfigurationException e) {
            throw new ExceptionReport("Parser configuration exception", e);
        }
        // add parameters
        for (Iterator iter = params.keySet().iterator(); iter.hasNext(); ) {
            String key = (String) iter.next();
            Element paramElement = doc.createElementNS(NS, "tmp:parameter");
            Element nameElement = doc.createElementNS(NS, "tmp:name");
            Element valueElement = doc.createElementNS(NS, "tmp:value");
            nameElement.setTextContent(key.toLowerCase());

            // servlet parameters have String[] as values
            String[] values = (String[]) params.get(key);
            if (values != null && values.length > 0) {
                valueElement.setTextContent(values[0]);
            }
            doc.getDocumentElement().appendChild(paramElement);
            paramElement.appendChild(nameElement);
            paramElement.appendChild(valueElement);
        }
        return doc;
    }

    /**
     * Transforms a map of parameters to a byte array.
     * @param params the parameters
     * @return XML representation as bytes
     * @throws ExceptionReport
     */
    public byte[] asByteArray(Map params) throws ExceptionReport {
        try {
            return Util.asByteArray(asDom(params));
        } catch (TransformerException e) {
            throw new ExceptionReport("TransformerException with empty transformer, check XSLT libs", e);
        }
    }
}

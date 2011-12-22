package de.conterra.smaad.inspiretm;

import org.xml.sax.InputSource;

import javax.xml.namespace.NamespaceContext;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.transform.*;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;
import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathExpression;
import javax.xml.xpath.XPathExpressionException;
import javax.xml.xpath.XPathFactory;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.StringReader;
import java.util.Iterator;

public class Test {
    static String request = "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:xsd=\"http://userguide.axis2.apache.org/xsd\">\n" +
            "   <soapenv:Header/>\n" +
            "   <soapenv:Body>\n" +
            "                <csw:GetRecords maxRecords=\"10\" outputFormat=\"application/xml\"\n" +
            "outputSchema=\"http://www.isotc211.org/2005/gmd\" resultType=\"results\"\n" +
            "service=\"CSW\" startPosition=\"1\" version=\"2.0.2\"\n" +
            "xmlns:apiso=\"http://www.opengis.net/cat/csw/apiso/1.0\"\n" +
            "xmlns:csw=\"http://www.opengis.net/cat/csw/2.0.2\"\n" +
            "xmlns:gmd=\"http://www.isotc211.org/2005/gmd\"\n" +
            "xmlns:rim=\"urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0\"\n" +
            "xmlns:ogc=\"http://www.opengis.net/ogc\">\n" +
            "                        <csw:Query typeNames=\"rim:ExtrinsicObject\">\n" +
            "                                <csw:ElementSetName>full</csw:ElementSetName>\n" +
            "<!--\n" +
            "                                <csw:Constraint version=\"1.1.0\">\n" +
            "                                        <ogc:Filter\n" +
            "xmlns:ogc=\"http://www.opengis.net/ogc\">\n" +
            "\t   <ogc:PropertyIsLike escapeChar=\"!\" singleChar=\"?\" wildCard=\"*\">\n" +
            "\t\t   <ogc:PropertyName>isoap:title</ogc:PropertyName>\n" +
            "\t\t   <ogc:Literal>wms</ogc:Literal>\n" +
            "\t\t</ogc:PropertyIsLike>\n" +
            "\n" +
            "                                        </ogc:Filter>\n" +
            "                                </csw:Constraint>\n" +
            "-->\n" +
            "                        </csw:Query>\n" +
            "                </csw:GetRecords>\n" +
            "   </soapenv:Body>\n" +
            "</soapenv:Envelope>";

    static String request2 = "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:xsd=\"http://userguide.axis2.apache.org/xsd\">\n" +
            "   <soapenv:Header/>\n" +
            "   <soapenv:Body>\n" +
            "                <csw:GetRecords maxRecords=\"10\" outputFormat=\"application/xml\"\n" +
            "outputSchema=\"http://www.isotc211.org/2005/gmd\" resultType=\"results\"\n" +
            "service=\"CSW\" startPosition=\"1\" version=\"2.0.2\"\n" +
            "xmlns:apiso=\"http://www.opengis.net/cat/csw/apiso/1.0\"\n" +
            "xmlns:csw=\"http://www.opengis.net/cat/csw/2.0.2\"\n" +
            "xmlns:gmd=\"http://www.isotc211.org/2005/gmd\"\n" +
            "xmlns:ogc=\"http://www.opengis.net/ogc\">\n" +
            "                        <csw:Query typeNames=\"gmd:MD_Metadata\">\n" +
            "                                <csw:ElementSetName>full</csw:ElementSetName>\n" +
            "                                <csw:Constraint version=\"1.1.0\">\n" +
            "                                        <ogc:Filter\n" +
            "xmlns:ogc=\"http://www.opengis.net/ogc\">\n" +
            "\t   <ogc:PropertyIsLike escapeChar=\"!\" singleChar=\"?\" wildCard=\"*\">\n" +
            "\t\t   <ogc:PropertyName>isoap:title</ogc:PropertyName>\n" +
            "\t\t   <ogc:Literal>msg</ogc:Literal>\n" +
            "\t\t</ogc:PropertyIsLike>\n" +
            "<!--\n" +
            "<ogc:Or>\n" +
            "  <ogc:Not>\n" +
            "    <ogc:PropertyIsNull>\n" +
            "      <ogc:PropertyName>apiso:Classification</ogc:PropertyName>\n" +
            "    </ogc:PropertyIsNull>\n" +
            "  </ogc:Not>\n" +
            "  <ogc:And>\n" +
            "    <ogc:Not>\n" +
            "      <ogc:PropertyIsNull>\n" +
            "        <ogc:PropertyName>apiso:AccessConstraints</ogc:PropertyName>\n" +
            "      </ogc:PropertyIsNull>\n" +
            "    </ogc:Not>\n" +
            "    <ogc:Not>\n" +
            "      <ogc:PropertyIsEqualTo>\n" +
            "        <ogc:PropertyName>apiso:AccessConstraints</ogc:PropertyName>\n" +
            "        <ogc:Literal>otherRestrictions</ogc:Literal>\n" +
            "      </ogc:PropertyIsEqualTo>\n" +
            "    </ogc:Not>\n" +
            "  </ogc:And>\n" +
            "</ogc:Or>\n" +
            "\t<ogc:PropertyIsBetween>\n" +
            "\t\t<ogc:PropertyName>gmd:CreationDate</ogc:PropertyName>\n" +
            "\t\t<ogc:LowerBoundary>\n" +
            "\t\t\t<ogc:Literal>2005-11-01</ogc:Literal>\n" +
            "\t\t</ogc:LowerBoundary>\n" +
            "\t\t<ogc:UpperBoundary>\n" +
            "\t\t\t<ogc:Literal>2006-01-28</ogc:Literal>\n" +
            "\t\t</ogc:UpperBoundary>\n" +
            "\t</ogc:PropertyIsBetween>\n" +
            "\n" +
            "<ogc:Or>\n" +
            "  <ogc:Not>\n" +
            "    <ogc:PropertyIsNull>\n" +
            "      <ogc:PropertyName>apiso:Classification</ogc:PropertyName>\n" +
            "    </ogc:PropertyIsNull>\n" +
            "  </ogc:Not>\n" +
            "  <ogc:And>\n" +
            "    <ogc:Not>\n" +
            "      <ogc:PropertyIsNull>\n" +
            "        <ogc:PropertyName>apiso:AccessConstraints</ogc:PropertyName>\n" +
            "      </ogc:PropertyIsNull>\n" +
            "    </ogc:Not>\n" +
            "    <ogc:Not>\n" +
            "      <ogc:PropertyIsEqualTo>\n" +
            "        <ogc:PropertyName>apiso:AccessConstraints</ogc:PropertyName>\n" +
            "        <ogc:Literal>otherRestrictions</ogc:Literal>\n" +
            "      </ogc:PropertyIsEqualTo>\n" +
            "    </ogc:Not>\n" +
            "  </ogc:And>\n" +
            "</ogc:Or>\n" +
            "-->\n" +
            "                                        </ogc:Filter>\n" +
            "                                </csw:Constraint>\n" +
            "                        </csw:Query>\n" +
            "                </csw:GetRecords>\n" +
            "   </soapenv:Body>\n" +
            "</soapenv:Envelope>";

    private final static String PREFIX_GMD = "gmd";
    private final static String PREFIX_GCO = "gco";
    private final static String PREFIX_CSW = "csw";

    private final static String NS_GMD = "http://www.isotc211.org/2005/gmd";
    private final static String NS_GCO = "http://www.isotc211.org/2005/gco";
    private final static String NS_CSW = "http://www.opengis.net/cat/csw/2.0.2";

    public static void main(String[] args) {
        XPathFactory xPathFactory = XPathFactory.newInstance();
        XPath mdPath = xPathFactory.newXPath();
        mdPath.setNamespaceContext(new NamespaceContext() {
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
        });
        String elementSet = null;
        try {
//            XPathExpression expression = mdPath.compile("//csw:ElementSetName");
//            InputSource source = new InputSource(new ByteArrayInputStream(request2.getBytes()));
//            elementSet = expression.evaluate(source);
            elementSet = mdPath.evaluate("//csw:ElementSetName",
                    new InputSource(new ByteArrayInputStream(request.getBytes())));
        } catch (XPathExpressionException e) {
            e.printStackTrace();
        }
        System.out.println("" + elementSet);
    }

    public static void main_2(String[] args) throws Exception {
        TransformerFactory transformerFactory = TransformerFactory.newInstance();
        Templates templates = transformerFactory.newTemplates(new StreamSource(Test.class.getResourceAsStream("/cimep2isoapRequest.xsl")));
        Transformer transformer = templates.newTransformer();
        transformer.setErrorListener(new ErrorListener() {
            public void warning(TransformerException exception) throws TransformerException {
                System.out.println("warning: " + exception.getMessage());
            }

            public void error(TransformerException exception) throws TransformerException {
                System.out.println("error");
            }

            public void fatalError(TransformerException exception) throws TransformerException {
                System.out.println("fatal");
            }
        });
        ByteArrayOutputStream bout = new ByteArrayOutputStream();
        transformer.transform(new StreamSource(new StringReader(request)), new StreamResult(bout));
        System.out.println("" + new String(bout.toByteArray()));
    }
}

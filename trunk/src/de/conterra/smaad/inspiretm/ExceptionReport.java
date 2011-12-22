package de.conterra.smaad.inspiretm;

import org.w3c.dom.Document;
import org.w3c.dom.Element;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.TransformerException;

/**
 * Thrown by OWS services. Includes methods to serialize as XML.
 * Author: Udo Einspanier, con terra GmbH
 */
public class ExceptionReport extends Exception {
    public final static String CODE_UNSPECIFIED = "Unspecified";
    public final static String NS_OWS = "http://www.opengis.net/ows";

    private final static DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();

    private String code = CODE_UNSPECIFIED;

    /**
     * Constructor.
     * @param msg message
     * @param code code
     */
    public ExceptionReport(String msg, String code) {
        this(msg, code, null);
    }

    /**
     * Constructor.
     * @param msg the message
     */
    public ExceptionReport(String msg) {
        this(msg, CODE_UNSPECIFIED);
    }

    /**
     * Constructor.
     * @param rootCause root cause
     */
    public ExceptionReport(Throwable rootCause) {
        this("Exception during service execution", rootCause);
    }

    /**
     * Constructor.
     * @param msg message
     * @param rootCause root cause
     */
    public ExceptionReport(String msg, Throwable rootCause) {
        this(msg, CODE_UNSPECIFIED, rootCause);
    }

    /**
     * Constructor.
     * @param msg message
     * @param code code
     * @param rootCause root cause
     */
    public ExceptionReport(String msg, String code, Throwable rootCause) {
        super(msg, rootCause);
        setCode(code);
    }

    /**
     * Returns the code.
     * @return code
     */
    public String getCode() {
        return code;
    }

    /**
     * Sets the code
     * @param code code
     */
    public void setCode(String code) {
        this.code = code;
    }

    /**
     * Serializes this exception to DOM.
     * @return DOM document
     */
    public Document asDocument() {
        DocumentBuilder builder = null;
        try {
            builder = factory.newDocumentBuilder();
        } catch (ParserConfigurationException e) {
            throw new RuntimeException("ParserConfigurationException, check XML libs", e);
        }
        Document doc = builder.newDocument();
        Element exrep = doc.createElementNS(NS_OWS, "ExceptionReport");
        doc.appendChild(exrep);
        exrep.setAttribute("version", "1.0.0");
        Element ex = doc.createElementNS(NS_OWS, "Exception");
        ex.setAttribute("code", getCode());
        exrep.appendChild(ex);
        Element extext = doc.createElementNS(NS_OWS, "ExceptionText");
        if (getMessage() != null) {
            extext.setTextContent(getMessage() == null ? "Unspecified server error" : getMessage());
        }
        ex.appendChild(extext);
        return doc;
    }

    /**
     * Serializes this exception to XML.
     * @return XML as byte array
     */
    public byte[] asByteArray() {
        try {
            return Util.asByteArray(asDocument());
        } catch (TransformerException e) {
            throw new RuntimeException("TransformerException with empty transformer, check XSLT libs", e);
        }
    }
}

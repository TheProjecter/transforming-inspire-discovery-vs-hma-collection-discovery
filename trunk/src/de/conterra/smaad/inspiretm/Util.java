package de.conterra.smaad.inspiretm;

import org.w3c.dom.Document;

import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import java.io.ByteArrayOutputStream;
import java.util.Map;

/**
 * Utility class.
 * Author: Udo Einspanier, con terra GmbH
 */
public class Util {
    private final static TransformerFactory transformerFactory = TransformerFactory.newInstance();

    /**
     * Transforms a DOM document to a byte array.
     * @param doc DOM document
     * @return byte array
     * @throws javax.xml.transform.TransformerException
     */
    public static byte[] asByteArray(Document doc) throws TransformerException {
        Transformer transformer = null;
        transformer = transformerFactory.newTransformer();
        ByteArrayOutputStream bout = new ByteArrayOutputStream();
        StreamResult result = new StreamResult(bout);
        DOMSource source = new DOMSource(doc);
        transformer.transform(source, result);
        return bout.toByteArray();
    }
}

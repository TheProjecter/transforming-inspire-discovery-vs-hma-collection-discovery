package de.conterra.smaad.inspiretm;

import org.apache.log4j.Logger;

import javax.xml.transform.*;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;
import java.io.*;

/**
 * Transforms XML-based requests and responses. In special cases (GetCapabiities), the response can be generated directly
 * without a roundtrip to the wrapped CSW. Otherwise, the request is transformed to a matching request to the wrapped
 * CSW, and the resulting response is transformed to match the client's origial request.
 * Author: Udo Einspanier, con terra GmbH
 */
public class TransformationEngine implements URIResolver, ErrorListener {

    private final Logger LOGGER = Logger.getLogger(TransformationEngine.class);

    // this message from the stylesheet signals if a request can be locally processed, without
    // sending it to the wrapped CSW (e.g. GetCapabilities requests)
    private final static String LOCAL_PROCESSING = "local.processing";

    // need the original request for correct response transformation
    private byte[] originalRequest;

    // status that signals if this request was processed locally
    private String processing;
    
    private Transformer[] requestTransformers;
    private Transformer[] responseTransformers;

    // keep track of exceptions during the transformation
    private TransformerException transformerException;

    /**
     * Constructor
     * @param requestTransformers transformers for request transformation, in order of application
     * @param responseTransformers transformers for response transformation, in order of application
     */
    public TransformationEngine(Transformer[] requestTransformers, Transformer[] responseTransformers) {
        for (int i = 0; i < requestTransformers.length; i++) {
            requestTransformers[i].setURIResolver(this);
            requestTransformers[i].setErrorListener(this);
        }
        for (int i = 0; i < responseTransformers.length; i++) {
            responseTransformers[i].setURIResolver(this);
            responseTransformers[i].setErrorListener(this);
        }
        this.requestTransformers = requestTransformers;
        this.responseTransformers = responseTransformers;
    }

    /**
     * Transforms an XML request.
     * @param request the input stream for reading the request
     * @param out the output stream for writing the transformed request, or response if processing is local
     * @return true if local processing (the output stream contains a response), false otherwise
     * @throws ExceptionReport
     */
    public boolean transformRequest(InputStream request, OutputStream out) throws ExceptionReport {
        ByteArrayOutputStream bout = new ByteArrayOutputStream();
        byte[] buffer = new byte[1024];
        int len;
        try {
            while ((len = request.read(buffer)) > 0) {
                bout.write(buffer, 0, len);
            }
        } catch (IOException e) {
            throw new ExceptionReport("Error reading request", e);
        }
        originalRequest = bout.toByteArray();
        if (LOGGER.isDebugEnabled()) {
            LOGGER.debug("About to transform original request:");
            try {
                LOGGER.debug(new String(originalRequest, "utf-8"));
            } catch (UnsupportedEncodingException e) {
                LOGGER.error(e);
            }
        }

        InputStream tmpIn;
        OutputStream tmpOut = null;
        for (int i = 0; i < requestTransformers.length; i++) {
            if (i == 0) {
                tmpIn = new ByteArrayInputStream(originalRequest);
            }
            else {
                byte[] bytes = ((ByteArrayOutputStream)tmpOut).toByteArray();
                tmpIn = new ByteArrayInputStream(bytes);
                if (LOGGER.isDebugEnabled()) {
                    LOGGER.debug("Intermediate transformation result #" + i + ":");
                    try {
                        LOGGER.debug(new String(bytes, "utf-8"));
                    } catch (UnsupportedEncodingException e) {
                        LOGGER.error(e);
                    }
                }
            }
            if (i < requestTransformers.length - 1) {
                tmpOut = new ByteArrayOutputStream();
            }
            else {
                tmpOut = out;
            }

            try {
                requestTransformers[i].transform(new StreamSource(tmpIn), new StreamResult(tmpOut));
            } catch (TransformerException e) {
                LOGGER.error(e);
                transformerException = e;
            }
            if (transformerException != null) {
                String msg = processing != null ? processing : transformerException.getMessage();
                throw new ExceptionReport(msg);
            }
        }
        // signal if the request was already processed locally by the stylesheet
        return LOCAL_PROCESSING.equals(processing);
    }

    /**
     * Transforms an XML response.
     * @param response the input stream for reading the response
     * @param out the output stream for writing the transformed response
     * @throws ExceptionReport
     */
    public void transformResponse(InputStream response, OutputStream out) throws ExceptionReport {
        InputStream tmpIn;
        OutputStream tmpOut = null;
        for (int i = 0; i < responseTransformers.length; i++) {
            if (i == 0) {
                tmpIn = response;
            }
            else {
                tmpIn = new ByteArrayInputStream(((ByteArrayOutputStream)tmpOut).toByteArray());
            }
            if (i < responseTransformers.length - 1) {
                tmpOut = new ByteArrayOutputStream();
            }
            else {
                tmpOut = out;
            }

            try {
                responseTransformers[i].transform(new StreamSource(tmpIn), new StreamResult(tmpOut));
            } catch (TransformerException e) {
                LOGGER.error(e);
                transformerException = e;
            }
            if (transformerException != null) {
                String msg = processing != null ? processing : transformerException.getMessage();
                throw new ExceptionReport(msg);
            }
        }
    }

    /**
     * Transforms an exception report.
     * @param er the exception to be transformed
     * @param out the ourput stream to write the Exception to
     */
    public void transformException(ExceptionReport er, OutputStream out) {
        InputStream tmpIn;
        OutputStream tmpOut = null;
        for (int i = 0; i < responseTransformers.length; i++) {
            if (i == 0) {
                tmpIn = new ByteArrayInputStream(er.asByteArray());
            }
            else {
                tmpIn = new ByteArrayInputStream(((ByteArrayOutputStream)tmpOut).toByteArray());
            }
            if (i < responseTransformers.length - 1) {
                tmpOut = new ByteArrayOutputStream();
            }
            else {
                tmpOut = out;
            }

            try {
                responseTransformers[i].transform(new StreamSource(tmpIn), new StreamResult(tmpOut));
            } catch (TransformerException e) {
                // if we get an error when serializing the exception, it's over
                LOGGER.error(e);
                throw new RuntimeException("Error transforming response", e);
            }
        }
    }

    /**
     * Returns the original request
     * @return original request, as bytes
     */
    public byte[] getOriginalRequest() {
        return originalRequest;
    }

    /**
     * URI resolver implementation. We provide the response transformers with the required original request recieved
     * by this facade.
     * @param href requested document URI
     * @param base base of document
     * @return source
     * @throws TransformerException
     */
    public Source resolve(String href, String base) throws TransformerException {
        // requestDoc.xml is a virtual name that references the original request that was stored in a local variable
        if ("requestDoc.xml".equals(href)) {
            return new StreamSource(new ByteArrayInputStream(originalRequest));
        }
        return new StreamSource(getClass().getResourceAsStream(href));
    }

    /**
     * ErrorListener implementation. In warning we check if the request stylesheets were able to locally process the
     * request, so we don't have to forward it to the wrapped CSW.
     * @param exception exception containing the message
     * @throws TransformerException
     */
    public void warning(TransformerException exception) throws TransformerException {
        // store the message if it signals local processing
        processing = exception.getMessage();
    }

    /**
     * ErrorListener implementation. Check any errors during transformation.
     * @param exception exception
     * @throws TransformerException
     */
    public void error(TransformerException exception) throws TransformerException {
        transformerException = exception;
    }

    /**
     * ErrorListener implementation. Check any errors during transformation.
     * @param exception exception
     * @throws TransformerException
     */
    public void fatalError(TransformerException exception) throws TransformerException {
        transformerException = exception;
    }
}

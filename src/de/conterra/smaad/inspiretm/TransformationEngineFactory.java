package de.conterra.smaad.inspiretm;

import javax.xml.transform.*;
import javax.xml.transform.stream.StreamSource;

/**
 * Factory class for request- and response transformers.
 * Author: Udo Einspanier, con terra GmbH
 */
public class TransformationEngineFactory {

    private Templates[] requestTemplates;
    private Templates[] responseTemplates;

    /**
     * Constructor. Loads the stylesheets provided as parameters from the classpath.
     * @param requestTransform resource paths of the request transformers, in order of processing
     * @param responseTransform resource paths of the response transformers, in order of processing
     * @throws TransformerConfigurationException
     */
    public TransformationEngineFactory(String[] requestTransform, String[] responseTransform)
            throws TransformerException {
        requestTemplates = new Templates[requestTransform.length];
        responseTemplates = new Templates[responseTransform.length];
        TransformerFactory transformerFactory = TransformerFactory.newInstance();

        // install an error handler, it is possible that newTemplates returns null if an error is encountered
        // without throwing an exception
        transformerFactory.setErrorListener(new ErrorListener() {
            public void warning(TransformerException exception) throws TransformerException {
                throw exception;
            }
            public void error(TransformerException exception) throws TransformerException {
                throw exception;
            }
            public void fatalError(TransformerException exception) throws TransformerException {
                throw exception;
            }
        });
        for (int i = 0; i < requestTransform.length; i++) {
            requestTemplates[i] = transformerFactory.newTemplates(new
                    StreamSource(getClass().getResourceAsStream(requestTransform[i])));
        }
        for (int i = 0; i < responseTransform.length; i++) {
            responseTemplates[i] = transformerFactory.newTemplates(new
                    StreamSource(getClass().getResourceAsStream(responseTransform[i])));
        }
    }

    /**
     * Creates a new engine for transformation of a single request/response pair.
     * @return the engine
     * @throws ExceptionReport
     */
    public TransformationEngine newEngine() throws ExceptionReport{
        Transformer[] requestTransformers = new Transformer[requestTemplates.length];
        for (int i = 0; i < requestTransformers.length; i++) {
            try {
                requestTransformers[i] = requestTemplates[i].newTransformer();
            } catch (TransformerConfigurationException e) {
                throw new ExceptionReport("TransformerConfigurationException for request stylesheet", e);
            }
        }
        Transformer[] responseTransformers = new Transformer[responseTemplates.length];
        for (int i = 0; i < responseTransformers.length; i++) {
            try {
                responseTransformers[i] = responseTemplates[i].newTransformer();
            } catch (TransformerConfigurationException e) {
                throw new ExceptionReport("TransformerConfigurationException for response stylesheet", e);
            }
        }
        return new TransformationEngine(requestTransformers, responseTransformers);
    }
}

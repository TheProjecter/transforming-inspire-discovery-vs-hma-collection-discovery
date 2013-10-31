package de.conterra.smaad.inspiretm;

import org.apache.commons.httpclient.DefaultHttpMethodRetryHandler;
import org.apache.commons.httpclient.HttpClient;
import org.apache.commons.httpclient.MultiThreadedHttpConnectionManager;
import org.apache.commons.httpclient.methods.ByteArrayRequestEntity;
import org.apache.commons.httpclient.methods.PostMethod;
import org.apache.commons.httpclient.methods.RequestEntity;
import org.apache.commons.httpclient.params.HttpMethodParams;
import org.apache.log4j.Logger;

import javax.servlet.ServletException;
import javax.servlet.ServletInputStream;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.xml.transform.TransformerException;
import java.io.*;
import java.util.StringTokenizer;

/**
 * Servlet of the CSW facade. Can be either a CIM EP or INSPIRE DS facade, depending on the request- and response
 * transformation stylesheets configured for this servlet in web.xml.
 * Author: Udo Einspanier, con terra GmbH
 */
public class TransformationServlet extends HttpServlet {

    private final Logger LOGGER = Logger.getLogger(TransformationServlet.class);

    private String targetServiceUrl;

    private HttpClient client = new HttpClient(new MultiThreadedHttpConnectionManager());

    private TransformationEngineFactory transformationEngineFactory;

    private ParamsToXml paramsToXml = new ParamsToXml();

    @Override
    public void init() throws ServletException {
        targetServiceUrl = getInitParameter("target.service.url");
        LOGGER.info("Servlet " + getServletName() + " initialising, using target service " + targetServiceUrl);

        String proxyHost = getInitParameter("proxy.host");
        String proxyPort = getInitParameter("proxy.port");
        if (proxyHost != null && proxyHost.trim().length() > 0 || proxyPort != null && proxyPort.trim().length() > 0) {
            LOGGER.info("Servlet " + getServletName() + " uses proxy settings " + proxyHost + ":" + proxyPort);
            client.getHostConfiguration().setProxy(proxyHost, Integer.parseInt(proxyPort));
        }
        String paramRequestTransform = getInitParameter("request.transform");
        String paramResponseTransform = getInitParameter("response.transform");
        try {
            transformationEngineFactory = new TransformationEngineFactory(paramToArray(paramRequestTransform),
                    paramToArray(paramResponseTransform));
        } catch (TransformerException e) {
            LOGGER.fatal("Error initializing transformers", e);
            throw new ServletException("Error initializing transformers", e);
        }

    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        byte[] bytes;
        try {
            bytes = paramsToXml.asByteArray(req.getParameterMap());
        } catch (ExceptionReport exceptionReport) {
            throw new ServletException("Unexpected error");
        }
        handleRequest(new ByteArrayInputStream(bytes), resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // transform the request
        ServletInputStream in = req.getInputStream();
        handleRequest(in, resp);
    }

    /**
     * Processes an XML request. The request was either received as XML (via POST/SOAP) or URL-encoded parameters
     * were transformed to an XML representation in an earlier processing step. Request handling in this method includes
     * transformation of the request and, if required, forwarding the transformed request to the wrapped service and
     * transforming the response.
     * @param in input stream containing the request
     * @param resp http response
     * @throws ServletException
     * @throws IOException
     */
    private void handleRequest(InputStream in, HttpServletResponse resp) throws ServletException, IOException {
        ByteArrayOutputStream bout = new ByteArrayOutputStream();
        resp.setCharacterEncoding("utf-8");
        resp.setContentType("text/xml;charset=utf-8");
        TransformationEngine engine = null;
        try {
            engine = transformationEngineFactory.newEngine();
            if (engine.transformRequest(in, bout)) {
                // the engine was already able to process the request, we got the response in the output stream
                byte[] bytes = bout.toByteArray();
                if (LOGGER.isDebugEnabled()) {
                    LOGGER.debug("Result generated locally, no request to target service " + targetServiceUrl);
                }
                resp.getOutputStream().write(bytes);
                return;
            }

            // we have to forward to the wrapped CSW, send the transformed request
            byte[] bytes = bout.toByteArray();
            if (LOGGER.isDebugEnabled()) {
                try {
                    LOGGER.debug("About to send request to target service " + targetServiceUrl);
                    LOGGER.debug(new String(bytes, "utf-8"));
                } catch (UnsupportedEncodingException e) {
                    LOGGER.error(e);
                }
            }
            RequestEntity entity = new ByteArrayRequestEntity(bytes);

            // create HTTP request
            PostMethod method = new PostMethod(targetServiceUrl);
            method.addRequestHeader("Content-type", "text/xml;charset=UTF-8");
            method.setRequestEntity(entity);
            method.getParams().setParameter(HttpMethodParams.RETRY_HANDLER,
                    new DefaultHttpMethodRetryHandler(3, false));

            // we always generate a GetRecords request, the action will only be used by SOAP 1.1 servers
            method.setRequestHeader("SOAPAction", "\"http://www.opengis.net/cat/csw/2.0.2/requests#GetRecords\"");

            // send request
            byte[] targetResponse = null;
            try {
                int statusCode = client.executeMethod(method);
                checkResponseCode(statusCode);

                // transform response
                targetResponse = method.getResponseBody();
            }
            finally {
                method.releaseConnection();
            }
            if (LOGGER.isDebugEnabled()) {
                try {
                    LOGGER.debug("Received response from target service:");
                    LOGGER.debug(new String(targetResponse, "utf-8"));
                } catch (UnsupportedEncodingException e) {
                    LOGGER.error(e);
                }
            }

            bout.reset();
            transformResponse(engine, new ByteArrayInputStream(targetResponse), bout);
            bytes = bout.toByteArray();
            if (LOGGER.isDebugEnabled()) {
                try {
                    LOGGER.debug("Sending transformed response to client:");
                    LOGGER.debug(new String(bytes, "utf-8"));
                } catch (UnsupportedEncodingException e) {
                    LOGGER.error(e);
                }
            }
            resp.getOutputStream().write(bytes);
        }
        catch (ExceptionReport e) {
            LOGGER.error("Error in facade", e);
            resp.setStatus(400);
            if (engine != null) {
                engine.transformException(e, resp.getOutputStream());
            }
            else {
                resp.getOutputStream().write(e.asByteArray());
            }
        }
        finally {
            resp.getOutputStream().close();
        }
    }

    protected void transformResponse(TransformationEngine engine, ByteArrayInputStream response,
                                     ByteArrayOutputStream transformedResponse) throws ExceptionReport {
        engine.transformResponse(response, transformedResponse);
    }

    protected String getTargetServiceUrl() {
        return targetServiceUrl;
    }

    protected HttpClient getClient() {
        return client;
    }

    /**
     * Check status of of a request to wrapped CSW.
     * @param statusCode the HTTP status
     * @throws ExceptionReport if status is not ok
     */
    protected void checkResponseCode(int statusCode) throws ExceptionReport {
        if (LOGGER.isDebugEnabled()) {
            LOGGER.debug("Service replied with status code " + statusCode);
        }
        if (statusCode >= 300) {
            throw new ExceptionReport("Unexpected HTTP response code from service " + targetServiceUrl +
                    ": " + statusCode);
        }
    }

    /**
     * Tokenizes a String with "|" seperation character.
     * @param param string to tokenize
     * @return array of tokens
     */
    private String[] paramToArray(String param) {
        if (param == null || param.length() == 0) {
            return new String[0];
        }
        StringTokenizer st = new StringTokenizer(param, "|");
        String[] result = new String[st.countTokens()];
        int i = 0;
        while (st.hasMoreTokens()) {
            result[i++] = st.nextToken();
        }
        return result;
    }

}

To install:

1. modify build.properties
   target.inspire.url: URL of an INSPIRE DS that has to be wrapped by a CIM EP facade
   target.cim.url: URL of a CIM EP service that has to be wrapped by an INSPIRE facade
   proxy.host: proxy to be used (if no proxy leave empty)
   proxy.port: port of proxy to be used (if no proxy leave empty)

2. modify the capabilities document(s) inspireCapabilities and/or cimepCapabilities as desired

3. modify log4j.xml as desired (optional)

4. build via ant with build.xml

5. deploy in tomcat
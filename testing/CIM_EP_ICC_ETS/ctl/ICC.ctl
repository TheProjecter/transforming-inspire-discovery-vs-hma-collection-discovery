<?xml version="1.0" encoding="UTF-8"?>
<!--
 * Project:		ESA SMAAD
 * Sub-Project:		CSW 2.0.2 AP ebRIM EP CIM ICC Conformance Level Compliance Test Suite
 * Description:		ICC CTL
 * Organisation:  	con terra GmbH
 * Author:		Dr. Uwe Voges (u.voges@conterra.de)
 * Version:		2.0
-->
<ctl:package xmlns:ctl="http://www.occamlab.com/ctl" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
xmlns:xi="http://www.w3.org/2001/XInclude" xmlns:saxon="http://saxon.sf.net/" xmlns:ctlp="http://www.occamlab.com/te/parsers" xmlns:rim="urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0" xmlns:dct="http://purl.org/dc/terms/"
 xmlns:parsers="http://www.occamlab.com/te/parsers" xmlns:ows="http://www.opengis.net/ows/2.0" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:gmd="http://www.isotc211.org/2005/gmd"
   xmlns:sec="http://www.intecs.it/sec" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:wrs="http://www.opengis.net/cat/wrs/1.0"  xmlns:ogc="http://www.opengis.net/ogc" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:util="http://www.occamlab.com/te/util">

   <ctl:test name="csw:ICC">
    <ctl:param name="csw.capabilities.url"/>
    <ctl:param name="csw.getrecords.url"/>
    <ctl:param name="csw.getrepositoryitem.url"/>
    
    <ctl:assertion>Run tests for level ICC compliance.</ctl:assertion>
    <ctl:code>
          <ctl:message>Here is: csw:ICC !!</ctl:message>
          <ctl:message><xsl:value-of select="$csw.capabilities.url"/></ctl:message>

      <xsl:variable name="csw.GetCapabilities.get.url">
<!--        <xsl:value-of select="$csw.GetCapabilities.document//ows:OperationsMetadata/ows:Operation[@name='GetCapabilities']/ows:DCP/ows:HTTP/ows:Get/@xlink:href"/>-->
        <xsl:value-of select="$csw.capabilities.url"/>
      </xsl:variable>

      <xsl:variable name="csw.GetRecords.soap.url">
<!--     
        <xsl:choose>
          <xsl:when test="boolean($csw.GetCapabilities.document//ows:OperationsMetadata/ows:Operation[@name='GetRecords']/ows:DCP/ows:HTTP/ows:Post[ows:Constraint/ows:Value='SOAP']/@xlink:href)">
            <xsl:value-of select="$csw.GetCapabilities.document//ows:OperationsMetadata/ows:Operation[@name='GetRecords']/ows:DCP/ows:HTTP/ows:Post[ows:Constraint/ows:Value='SOAP']/@xlink:href"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$csw.GetCapabilities.document//ows:OperationsMetadata/ows:Operation[@name='GetRecords']/ows:DCP/ows:HTTP/ows:Post/@xlink:href"/>
          </xsl:otherwise>
        </xsl:choose>
-->
         <xsl:value-of select="$csw.getrecords.url"/>
      </xsl:variable>

      <xsl:variable name="csw.GetRepositoryItem.get.url">
<!--     
        <xsl:choose>
          <xsl:when test="boolean($csw.GetCapabilities.document//ows:OperationsMetadata/ows:Operation[@name='GetRecords']/ows:DCP/ows:HTTP/ows:Post[ows:Constraint/ows:Value='SOAP']/@xlink:href)">
            <xsl:value-of select="$csw.GetCapabilities.document//ows:OperationsMetadata/ows:Operation[@name='GetRecords']/ows:DCP/ows:HTTP/ows:Post[ows:Constraint/ows:Value='SOAP']/@xlink:href"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$csw.GetCapabilities.document//ows:OperationsMetadata/ows:Operation[@name='GetRecords']/ows:DCP/ows:HTTP/ows:Post/@xlink:href"/>
          </xsl:otherwise>
        </xsl:choose>
-->
         <xsl:value-of select="$csw.getrepositoryitem.url"/>
      </xsl:variable>
-->

      <ctl:call-test name="csw:ICC.GetCapabilities">
        <ctl:with-param name="csw.GetCapabilities.get.url" select="$csw.GetCapabilities.get.url"/>
      </ctl:call-test>

      <ctl:call-test name="csw:ICC.GetRecords-BBoxFilter">
        <ctl:with-param name="csw.GetRecords.soap.url" select="$csw.GetRecords.soap.url"/>
      </ctl:call-test>

      <ctl:call-test name="csw:ICC.GetRecords-Association">
        <ctl:with-param name="csw.GetRecords.soap.url" select="$csw.GetRecords.soap.url"/>
      </ctl:call-test>

      <ctl:call-test name="csw:ICC.GetRecords-Classification">
        <ctl:with-param name="csw.GetRecords.soap.url" select="$csw.GetRecords.soap.url"/>
      </ctl:call-test>

    <ctl:call-test name="csw:ICC.GetRecords-Specification">
        <ctl:with-param name="csw.GetRecords.soap.url" select="$csw.GetRecords.soap.url"/>
      </ctl:call-test>

    <ctl:call-test name="csw:ICC.GetRecords-INSPIREQueryablesComplexFilter">
        <ctl:with-param name="csw.GetRecords.soap.url" select="$csw.GetRecords.soap.url"/>
      </ctl:call-test>

<!--
   <ctl:call-test name="csw:ICC.GetRecords-INSPIREServicesFilter">
        <ctl:with-param name="csw.GetRecords.soap.url" select="$csw.GetRecords.soap.url"/>
      </ctl:call-test>

     <ctl:call-test name="csw:ICC.GetRecords-SyntaxError">
        <ctl:with-param name="csw.GetRecords.soap.url" select="$csw.GetRecords.soap.url"/>
      </ctl:call-test>

      <ctl:call-test name="csw:CIM.GetRecords-SemanticAnnotation">
        <ctl:with-param name="csw.GetRecords.soap.url" select="$csw.GetRecords.soap.url"/>
      </ctl:call-test>
-->

  <ctl:call-test name="csw:ICC.GetRecordById">
        <ctl:with-param name="csw.GetRecords.soap.url" select="$csw.GetRecords.soap.url"/>
      </ctl:call-test>

  <ctl:call-test name="csw:ICC.GetRepositoryItem">
        <ctl:with-param name="csw.GetRecords.soap.url" select="$csw.GetRecords.soap.url"/>
        <ctl:with-param name="csw.getrepositoryitem.url" select="$csw.getrepositoryitem.url"/>
      </ctl:call-test>

    </ctl:code>
  </ctl:test>

 
<!-- 
##################################################################
	 csw:ICC.GetCapabilities
##################################################################
-->
 <ctl:test name="csw:ICC.GetCapabilities">
    <ctl:param name="csw.GetCapabilities.get.url"/>
    <ctl:assertion>
      The response to a GetCapabilities request (HTTP/GET request where KVP´s  must be defined as follows: service = &quot;CSW&quot;, request = &quot;GetCapabilities&quot;) must satisfy 
      the applicable assertion:
		1.	the response is a well formed XML Document with a root node named &quot;Capabilities&quot; which is defined within the &quot;http://www.opengis.net/cat/wrs/1.0&quot; namespace. 
		2.	it contains the XML representation of a capabilities document, which can be validated against the XML schema http://schemas.opengis.net/csw/2.0.2/profiles/ebrim/1.0/csw-ebrim.xsd
		3.	must include a Filter_Capabilities section to describe which operands and operators are supported
    </ctl:assertion>
    <ctl:comment>Pass if the assertions hold.</ctl:comment>  
   
    <ctl:code>
          <ctl:message>Here is: csw:ICC.GetCapabilities</ctl:message>
          <ctl:message><xsl:value-of select="$csw.GetCapabilities.get.url"/></ctl:message>
    
    
        <xsl:variable name="response">
        <ctl:request>
          <ctl:url>
            <xsl:value-of select="$csw.GetCapabilities.get.url"/>
          </ctl:url>
          <ctl:method>GET</ctl:method>
          <ctl:param name="service">CSW-ebRIM</ctl:param>
          <ctl:param name="request">GetCapabilities</ctl:param>
          <ctl:param name="acceptversion">2.0.2</ctl:param>
          
         <ctl:message>!!! When you get the message: - Cannot resolve the name 'xml:lang' - this curiousely depend on slow internet connections - try again....</ctl:message>
          
		  <parsers:XMLValidatingParser>
			<parsers:schemas>
				<parsers:schema type="url">http://schemas.opengis.net/csw/2.0.2/profiles/ebrim/1.0/csw-ebrim.xsd</parsers:schema>
			</parsers:schemas>
		  </parsers:XMLValidatingParser>        

	  </ctl:request>
      </xsl:variable>

<!--      
      <ctl:call-test name="ctl:XMLValidatingParser">
         <ctl:with-param name="doc"><xsl:copy-of select="$response/wrs:Capabilities"/></ctl:with-param>
         <ctl:with-param name="instruction">
           <parsers:schemas>
             <parsers:schema type="url">http://schemas.opengis.net/csw/2.0.2/profiles/ebrim/1.0/csw-ebrim.xsd</parsers:schema>
           </parsers:schemas>
         </ctl:with-param>
       </ctl:call-test>
--> 
      <ctl:message>Capa Doc received and validated !!!!!</ctl:message>
      
        <xsl:if test="not($response/wrs:Capabilities/ogc:Filter_Capabilities)">
        <ctl:message>FAILURE: the third assertion failed</ctl:message>
        <ctl:fail/>
      </xsl:if>
      
        <xsl:if test="not($response/wrs:Capabilities/ows:OperationsMetadata/ows:Constraint/ows:Value[../@name='ConformanceClasses']='INSPIRE')">
        <ctl:message>WARNING!! No Operation Constraint ConformanceClasses with value INSPIRE defined</ctl:message>
       <!--  <ctl:fail/> -->
      </xsl:if>
              
    </ctl:code>
  </ctl:test>

 

<!-- 
##################################################################
	 csw:ICC.GetRecords-BBoxFilter
##################################################################
-->
<ctl:test name="csw:ICC.GetRecords-BBoxFilter">
    <ctl:param name="csw.GetRecords.soap.url"/>
    <ctl:assertion>
	The GetRecords request (sent via HTTP/SOAP/POST/XML) response must satisfy the applicable assertions:
	1.	the filter request is understood by the server and no exception concerning the request is thrown 
	2. the response includes at minimum 1 ‘full’ metadata entry returned of type DatasetCollection
	3. the response includes an ExternalIdentifier for the metadata entry found
	4.	the XML representation is valid structured concerning the CSW 2.0.2 and the CSW-ebRIM Registry Service and the corresponding xml schemas. 
     </ctl:assertion>
    <ctl:comment>Pass if the assertions hold.</ctl:comment>
    <ctl:code>
         <ctl:message>Here is: csw:ICC.GetRecords-BBoxFilter !!</ctl:message>
         <ctl:message><xsl:value-of select="$csw.GetRecords.soap.url"/></ctl:message>

        <xsl:variable name="responsesoap">        
        <ctl:soap-request version="1.2" charset="UTF-8">
          <ctl:url>
            <xsl:value-of select="$csw.GetRecords.soap.url"/>
          </ctl:url>
		  <ctl:action>http://www.opengis.net/cat/csw/2.0.2/requests#GetRecords</ctl:action>  
		 <ctl:body>
		<csw:GetRecords maxRecords="5" outputFormat="application/xml" outputSchema="urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0" resultType="results" service="CSW" startPosition="1" version="2.0.2" xmlns:csw="http://www.opengis.net/cat/csw/2.0.2" xmlns:ogc="http://www.opengis.net/ogc" xmlns:wrs="http://www.opengis.net/cat/wrs/1.0" xmlns:rim="urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0" xmlns:gml="http://www.opengis.net/gml">
			<csw:Query typeNames="wrs:ExtrinsicObject_e1">
				<csw:ElementSetName typeNames="$e1">full</csw:ElementSetName>
				<csw:Constraint version="1.1.0">
					<ogc:Filter xmlns:ogc="http://www.opengis.net/ogc">
							<ogc:BBOX>
								<ogc:PropertyName>$e1/rim:Slot[@name='urn:ogc:def:slot:OGC-CSW-ebRIM-CIM::Envelope']/wrs:ValueList/wrs:AnyValue</ogc:PropertyName>
								<gml:Envelope srsName="urn:ogc:def:crs:EPSG:4326">
									<gml:lowerCorner>-80.0 -170.0</gml:lowerCorner>
									<gml:upperCorner>80.0 170.0</gml:upperCorner>
								</gml:Envelope>
							</ogc:BBOX>
					</ogc:Filter>
				</csw:Constraint>
			</csw:Query>
		</csw:GetRecords>
		</ctl:body>
       </ctl:soap-request>
      </xsl:variable>
          
<!--
	<xsl:for-each select="$responsesoap//wrs:ExtrinsicObject">
			<ctl:call-test name="ctl:XMLValidatingParser">
				<ctl:with-param name="doc"><xsl:copy-of select="."/></ctl:with-param>
				<ctl:with-param name="instruction">
					<parsers:schemas>
						<parsers:schema type="url">http://schemas.opengis.net/csw/2.0.2/profiles/ebrim/1.0/csw-ebrim.xsd</parsers:schema>
					</parsers:schemas>
				</ctl:with-param>
			</ctl:call-test>
	</xsl:for-each>
-->
	<xsl:for-each select="$responsesoap//rim:ExtrinsicObject">
			<ctl:call-test name="ctl:XMLValidatingParser">
				<ctl:with-param name="doc"><xsl:copy-of select="."/></ctl:with-param>
				<ctl:with-param name="instruction">
					<parsers:schemas>
						<parsers:schema type="url">http://schemas.opengis.net/csw/2.0.2/profiles/ebrim/1.0/csw-ebrim.xsd</parsers:schema>
					</parsers:schemas>
				</ctl:with-param>
			</ctl:call-test>
	</xsl:for-each>

<!--
  		<ctl:call-test name="ctl:XMLValidatingParser">
		<ctl:with-param name="doc">
			<xsl:copy-of select="$responsesoap//csw:GetRecordsResponse"/>
		</ctl:with-param>
		<ctl:with-param name="instruction">
			<parsers:schemas>
				<parsers:schema type="url">http://schemas.opengis.net/csw/2.0.2/CSW-discovery.xsd</parsers:schema>
			</parsers:schemas>
		</ctl:with-param>
	</ctl:call-test>
-->

     <ctl:message><xsl:value-of select="count($responsesoap//wrs:ExtrinsicObject[@objectType='urn:ogc:def:objectType:OGC-CSW-ebRIM-CIM::DatasetCollection'])"/> wrs:ExtrinsicObject of type DatasetCollection found.</ctl:message>

     <xsl:if test="not(count($responsesoap//wrs:ExtrinsicObject[@objectType='urn:ogc:def:objectType:OGC-CSW-ebRIM-CIM::DatasetCollection'])>0)">
        <ctl:message>FAILURE: assertion 2 failed</ctl:message>
        <ctl:fail/>
      </xsl:if>

     <xsl:if test="not(count($responsesoap//rim:ExternalIdentifier)>0)">
        <ctl:message>FAILURE: assertion 3 failed</ctl:message>
        <ctl:fail/>
      </xsl:if>

    </ctl:code>
  </ctl:test>



<!-- 
##################################################################
	 csw:ICC.GetRecords-Association
##################################################################
-->
<ctl:test name="csw:ICC.GetRecords-Association">
    <ctl:param name="csw.GetRecords.soap.url"/>
    <ctl:assertion>
	The GetRecords request (sent via HTTP/SOAP/POST/XML) response must satisfy the applicable assertions:
	1.	the filter request is understood by the server and no exception concerning the request is thrown 
	2. the response includes at minimum 1 ‘full’ metadata entry returned of type DatasetCollection
	3. the response includes an ExternalIdentifier for the metadata entry found
	4. each ExtrinsicObject within the GetRecordsResponse which is in the Namespace “urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0” must be conformant http://schemas.opengis.net/csw/2.0.2/profiles/ebrim/1.0/csw-ebrim.xsd     
	</ctl:assertion>
    <ctl:comment>Pass if the assertions hold.</ctl:comment>
    <ctl:code>
         <ctl:message>Here is: csw:ICC.GetRecords-Association</ctl:message>
         <ctl:message><xsl:value-of select="$csw.GetRecords.soap.url"/></ctl:message>

        <xsl:variable name="responsesoap">
          <ctl:soap-request version="1.2" charset="UTF-8">
          <ctl:url>
            <xsl:value-of select="$csw.GetRecords.soap.url"/>
          </ctl:url>
		  <ctl:action>http://www.opengis.net/cat/csw/2.0.2/requests#GetRecords</ctl:action>  
		 <ctl:body>
						
			<csw:GetRecords maxRecords="5" outputFormat="application/xml" outputSchema="urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0" resultType="results" service="CSW" startPosition="1" version="2.0.2" xmlns:csw="http://www.opengis.net/cat/csw/2.0.2" xmlns:ogc="http://www.opengis.net/ogc" xmlns:wrs="http://www.opengis.net/cat/wrs/1.0" xmlns:rim="urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0" xmlns:gml="http://www.opengis.net/gml">
				<csw:Query typeNames="wrs:ExtrinsicObject_e1_e2 rim:Association_a1">
					<csw:ElementSetName typeNames="$e1">full</csw:ElementSetName>
					<csw:Constraint version="1.1.0">
						<ogc:Filter xmlns:ogc="http://www.opengis.net/ogc">
							<ogc:And>
								<ogc:PropertyIsEqualTo>
									<ogc:PropertyName>$a1/@associationType</ogc:PropertyName>
									<ogc:Literal>urn:ogc:def:associationType:OGC-CSW-ebRIM-CIM::ResourceMetadataInformation</ogc:Literal>
								</ogc:PropertyIsEqualTo>
								<ogc:PropertyIsEqualTo>
									<ogc:PropertyName>$a1/@sourceObject</ogc:PropertyName>
									<ogc:PropertyName>$e1/@id</ogc:PropertyName>
								</ogc:PropertyIsEqualTo>
								<ogc:PropertyIsEqualTo>
									<ogc:PropertyName>$e2/@id</ogc:PropertyName>
									<ogc:PropertyName>$a1/@targetObject</ogc:PropertyName>
								</ogc:PropertyIsEqualTo>
								<ogc:PropertyIsEqualTo>
									<ogc:PropertyName>$e1/@objectType</ogc:PropertyName>
									<ogc:Literal>urn:ogc:def:objectType:OGC-CSW-ebRIM-CIM::DatasetCollection</ogc:Literal>
								</ogc:PropertyIsEqualTo>
								<ogc:PropertyIsEqualTo>
									<ogc:PropertyName>$e2/@objectType</ogc:PropertyName>
									<ogc:Literal>urn:ogc:def:objectType:OGC-CSW-ebRIM-CIM::MetadataInformation</ogc:Literal>
								</ogc:PropertyIsEqualTo>
							</ogc:And>
						</ogc:Filter>
					</csw:Constraint>
				</csw:Query>
			</csw:GetRecords>

		</ctl:body>
       </ctl:soap-request>
      </xsl:variable>
 
      
  <ctl:message><xsl:value-of select="count($responsesoap//wrs:ExtrinsicObject[@objectType='urn:ogc:def:objectType:OGC-CSW-ebRIM-CIM::DatasetCollection'])"/> wrs:ExtrinsicObject of type DatasetCollection found.</ctl:message>

     <xsl:if test="not(count($responsesoap//wrs:ExtrinsicObject[@objectType='urn:ogc:def:objectType:OGC-CSW-ebRIM-CIM::DatasetCollection'])>0)">
        <ctl:message>FAILURE: assertion 2 failed</ctl:message>
        <ctl:fail/>
      </xsl:if>

     <xsl:if test="not(count($responsesoap//rim:ExternalIdentifier)>0)">
        <ctl:message>FAILURE: assertion 3 failed</ctl:message>
        <ctl:fail/>
      </xsl:if>

   <xsl:if test="not(count($responsesoap//csw:GetRecordsResponse)>0)">
        <ctl:message>FAILURE: assertion 4 failed</ctl:message>
        <ctl:fail/>
      </xsl:if>

	<xsl:for-each select="$responsesoap//rim:ExtrinsicObject">
			<ctl:call-test name="ctl:XMLValidatingParser">
				<ctl:with-param name="doc"><xsl:copy-of select="."/></ctl:with-param>
				<ctl:with-param name="instruction">
					<parsers:schemas>
						<parsers:schema type="url">http://schemas.opengis.net/csw/2.0.2/profiles/ebrim/1.0/csw-ebrim.xsd</parsers:schema>
					</parsers:schemas>
				</ctl:with-param>
			</ctl:call-test>
	</xsl:for-each>

    </ctl:code>
  </ctl:test>


<!-- 
##################################################################
	csw:ICC.GetRecords-Classification
##################################################################
-->
<ctl:test name="csw:ICC.GetRecords-Classification">
    <ctl:param name="csw.GetRecords.soap.url"/>
    <ctl:assertion>
	The GetRecords request (sent via HTTP/SOAP/POST/XML) response must satisfy the applicable assertions:
	1.	the filter request is understood by the server and no exception concerning the request is thrown 
     </ctl:assertion>
    <ctl:comment>Pass if the assertions hold.</ctl:comment>
    <ctl:code>
         <ctl:message>Here is: csw:ICC.GetRecords-Classification</ctl:message>
         <ctl:message><xsl:value-of select="$csw.GetRecords.soap.url"/></ctl:message>

        <xsl:variable name="responsesoap">
           <ctl:soap-request version="1.2" charset="UTF-8">
          <ctl:url>
            <xsl:value-of select="$csw.GetRecords.soap.url"/>
          </ctl:url>
		  <ctl:action>http://www.opengis.net/cat/csw/2.0.2/requests#GetRecords</ctl:action>  
		 <ctl:body>

<csw:GetRecords maxRecords="5" outputFormat="application/xml" outputSchema="urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0" resultType="results" service="CSW" startPosition="1" version="2.0.2" xmlns:csw="http://www.opengis.net/cat/csw/2.0.2" xmlns:ogc="http://www.opengis.net/ogc" xmlns:wrs="http://www.opengis.net/cat/wrs/1.0" xmlns:rim="urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0" xmlns:gml="http://www.opengis.net/gml">
	<csw:Query xmlns:csw="http://www.opengis.net/cat/csw/2.0.2" xmlns:rim="urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0" typeNames="rim:ExtrinsicObject_e1 rim:Classification_c2 rim:ClassificationNode_cn2">
		<csw:ElementSetName typeNames="wrs:ExtrinsicObject">summary</csw:ElementSetName>
		<csw:Constraint version="1.1.0">
			<ogc:Filter xmlns:ogc="http://www.opengis.net/ogc">
				<ogc:And>
					<ogc:PropertyIsEqualTo>
						<ogc:PropertyName>$e1/@objectType</ogc:PropertyName>
						<ogc:Literal>urn:ogc:def:objectType:OGC-CSW-ebRIM-CIM::DatasetCollection</ogc:Literal>
					</ogc:PropertyIsEqualTo>
					<ogc:PropertyIsEqualTo>
						<ogc:PropertyName>$e1/@id</ogc:PropertyName>
						<ogc:PropertyName>$c2/@classifiedObject</ogc:PropertyName>
					</ogc:PropertyIsEqualTo>
					<ogc:PropertyIsEqualTo>
						<ogc:PropertyName>$c2/@classificationScheme</ogc:PropertyName>
						<ogc:Literal>urn:ogc:def:classificationScheme:OGC-CSW-ebRIM-CIM::TopicCategoryCode</ogc:Literal>
					</ogc:PropertyIsEqualTo>
					<ogc:PropertyIsEqualTo>
						<ogc:PropertyName>$c2/@classificationNode</ogc:PropertyName>
						<ogc:PropertyName>$cn2/@id</ogc:PropertyName>
					</ogc:PropertyIsEqualTo>
					<ogc:PropertyIsEqualTo>
						<ogc:PropertyName>$cn2/@code</ogc:PropertyName>
						<ogc:Literal>climatologyMeteorologyAtmosphere</ogc:Literal>
					</ogc:PropertyIsEqualTo>
				</ogc:And>
			</ogc:Filter>
		</csw:Constraint>
	</csw:Query>
</csw:GetRecords>


		</ctl:body>
       </ctl:soap-request>
      </xsl:variable>
      
 <ctl:message><xsl:value-of select="count($responsesoap//wrs:ExtrinsicObject[@objectType='urn:ogc:def:objectType:OGC-CSW-ebRIM-CIM::DatasetCollection'])"/> wrs:ExtrinsicObject of type DatasetCollection found.</ctl:message>

 
    </ctl:code>
  </ctl:test>


<!-- 
##################################################################
	csw:ICC.GetRecords-Specification
##################################################################
-->
<ctl:test name="csw:ICC.GetRecords-Specification">
    <ctl:param name="csw.GetRecords.soap.url"/>
    <ctl:assertion>
	The GetRecords request (sent via HTTP/SOAP/POST/XML) response must satisfy the applicable assertions:
	1.	the filter request is understood by the server and no exception concerning the request is thrown 
	2. each ExtrinsicObject within the GetRecordsResponse which is in the Namespace “urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0” must be conformant http://schemas.opengis.net/csw/2.0.2/profiles/ebrim/1.0/csw-ebrim.xsd     
     </ctl:assertion>
    <ctl:comment>Pass if the assertions hold.</ctl:comment>
    <ctl:code>
         <ctl:message>Here is: csw:ICC.GetRecords-Specification</ctl:message>
         <ctl:message><xsl:value-of select="$csw.GetRecords.soap.url"/></ctl:message>

        <xsl:variable name="responsesoap">
          <ctl:soap-request version="1.2" charset="UTF-8">
          <ctl:url>
            <xsl:value-of select="$csw.GetRecords.soap.url"/>
          </ctl:url>
		  <ctl:action>http://www.opengis.net/cat/csw/2.0.2/requests#GetRecords</ctl:action>  
		 <ctl:body>

		<csw:GetRecords maxRecords="5" outputFormat="application/xml" outputSchema="urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0" resultType="results" service="CSW" startPosition="1" version="2.0.2" xmlns:csw="http://www.opengis.net/cat/csw/2.0.2" xmlns:ogc="http://www.opengis.net/ogc" xmlns:wrs="http://www.opengis.net/cat/wrs/1.0" xmlns:rim="urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0" xmlns:gml="http://www.opengis.net/gml">
			<csw:Query typeNames="wrs:ExtrinsicObject_e1 rim:ExtrinsicObject_e2_e3 rim:Association_a1_a2">
				<csw:ElementSetName typeNames="$e1">full</csw:ElementSetName>
				<csw:Constraint version="1.1.0">
					<ogc:Filter xmlns:ogc="http://www.opengis.net/ogc">
						<ogc:And>
							<ogc:PropertyIsEqualTo>
								<ogc:PropertyName>$a1/@associationType</ogc:PropertyName>
								<ogc:Literal>urn:ogc:def:associationType:OGC-CSW-ebRIM-CIM::ResourceMetadataInformation</ogc:Literal>
							</ogc:PropertyIsEqualTo>
							<ogc:PropertyIsEqualTo>
								<ogc:PropertyName>$a1/@sourceObject</ogc:PropertyName>
								<ogc:PropertyName>$e1/@id</ogc:PropertyName>
							</ogc:PropertyIsEqualTo>
							<ogc:PropertyIsEqualTo>
								<ogc:PropertyName>$e2/@id</ogc:PropertyName>
								<ogc:PropertyName>$a1/@targetObject</ogc:PropertyName>
							</ogc:PropertyIsEqualTo>
							<ogc:PropertyIsEqualTo>
								<ogc:PropertyName>$e1/@objectType</ogc:PropertyName>
								<ogc:Literal>urn:ogc:def:objectType:OGC-CSW-ebRIM-CIM::DataMetadata</ogc:Literal>
							</ogc:PropertyIsEqualTo>
							<ogc:PropertyIsEqualTo>
								<ogc:PropertyName>$e2/@objectType</ogc:PropertyName>
								<ogc:Literal>urn:ogc:def:objectType:OGC-CSW-ebRIM-CIM::MetadataInformation</ogc:Literal>
							</ogc:PropertyIsEqualTo>
							<ogc:PropertyIsEqualTo>
								<ogc:PropertyName>$a2/@associationType</ogc:PropertyName>
								<ogc:Literal>urn:ogc:def:associationType:OGC-CSW-ebRIM-CIM::Specification</ogc:Literal>
							</ogc:PropertyIsEqualTo>
							<ogc:PropertyIsEqualTo>
								<ogc:PropertyName>$a2/@sourceObject</ogc:PropertyName>
								<ogc:PropertyName>$e1/@id</ogc:PropertyName>
							</ogc:PropertyIsEqualTo>
							<ogc:PropertyIsEqualTo>
								<ogc:PropertyName>$e3/@id</ogc:PropertyName>
								<ogc:PropertyName>$a2/@targetObject</ogc:PropertyName>
							</ogc:PropertyIsEqualTo>
							<ogc:PropertyIsEqualTo>
								<ogc:PropertyName>$e3/@objectType</ogc:PropertyName>
								<ogc:Literal>urn:ogc:def:objectType:OGC-CSW-ebRIM-CIM::ReferenceSpecification</ogc:Literal>
							</ogc:PropertyIsEqualTo>
						</ogc:And>
					</ogc:Filter>
				</csw:Constraint>
			</csw:Query>
		</csw:GetRecords>
		</ctl:body>
       </ctl:soap-request>
      </xsl:variable>
      
	  <xsl:if test="not(count($responsesoap//csw:GetRecordsResponse)>0)">
			<ctl:message>FAILURE: assertion 2 failed</ctl:message>
			<ctl:fail/>
		  </xsl:if>
 
	 <ctl:message><xsl:value-of select="count($responsesoap//wrs:ExtrinsicObject[@objectType='urn:ogc:def:objectType:OGC-CSW-ebRIM-CIM::DatasetCollection'])"/> wrs:ExtrinsicObject of type DatasetCollection found.</ctl:message>

	<xsl:for-each select="$responsesoap//rim:ExtrinsicObject">
			<ctl:call-test name="ctl:XMLValidatingParser">
				<ctl:with-param name="doc"><xsl:copy-of select="."/></ctl:with-param>
				<ctl:with-param name="instruction">
					<parsers:schemas>
						<parsers:schema type="url">http://schemas.opengis.net/csw/2.0.2/profiles/ebrim/1.0/csw-ebrim.xsd</parsers:schema>
					</parsers:schemas>
				</ctl:with-param>
			</ctl:call-test>
	</xsl:for-each>
	
    </ctl:code>
  </ctl:test>
  
  
<!-- 
##################################################################
	 csw:ICC.GetRecords-INSPIREQueryablesComplexFilter
##################################################################
-->
<ctl:test name="csw:ICC.GetRecords-INSPIREQueryablesComplexFilter">
    <ctl:param name="csw.GetRecords.soap.url"/>
    <ctl:assertion>
	The GetRecords request (sent via HTTP/SOAP/POST/XML) response must satisfy the applicable assertions:
	1.	the filter request is understood by the server and no exception concerning the request is thrown 
	2.	the XML representation is valid structured concerning the CSW 2.0.2 and the CSW-ebRIM Registry Service and the corresponding xml schemas. 
     </ctl:assertion>
    <ctl:comment>Pass if the assertions hold.</ctl:comment>
    <ctl:code>
       <ctl:message>Here is: csw:ICC.GetRecords-INSPIREQueryablesComplexFilter</ctl:message>
         <ctl:message><xsl:value-of select="$csw.GetRecords.soap.url"/></ctl:message>

        <xsl:variable name="responsesoap">
          <ctl:soap-request version="1.2" charset="UTF-8">
          <ctl:url>
            <xsl:value-of select="$csw.GetRecords.soap.url"/>
          </ctl:url>
		  <ctl:action>http://www.opengis.net/cat/csw/2.0.2/requests#GetRecords</ctl:action>  
		 <ctl:body>
	
<csw:GetRecords maxRecords="5" outputFormat="application/xml" outputSchema="urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0" resultType="results" service="CSW" startPosition="1" version="2.0.2" xmlns:csw="http://www.opengis.net/cat/csw/2.0.2" xmlns:ogc="http://www.opengis.net/ogc" xmlns:wrs="http://www.opengis.net/cat/wrs/1.0" xmlns:rim="urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0" xmlns:gml="http://www.opengis.net/gml">
	<csw:Query typeNames="wrs:ExtrinsicObject_e1 wrs:ExtrinsicObject_e2_e4 rim:RegistryObject_r1 rim:Association_a1_a2_a4 rim:Classification_c1_c2 rim:ClassificationNode_cn2">
		<csw:ElementSetName typeNames="$e1">full</csw:ElementSetName>
		<csw:Constraint version="1.1.0">
			<ogc:Filter xmlns:ogc="http://www.opengis.net/ogc">
				<ogc:And>
					<ogc:PropertyIsEqualTo>
						<ogc:PropertyName>$a1/@associationType</ogc:PropertyName>
						<ogc:Literal>urn:ogc:def:associationType:OGC-CSW-ebRIM-CIM::ResourceMetadataInformation</ogc:Literal>
					</ogc:PropertyIsEqualTo>
					<ogc:PropertyIsEqualTo>
						<ogc:PropertyName>$a1/@sourceObject</ogc:PropertyName>
						<ogc:PropertyName>$e1/@id</ogc:PropertyName>
					</ogc:PropertyIsEqualTo>
					<ogc:PropertyIsEqualTo>
						<ogc:PropertyName>$e2/@id</ogc:PropertyName>
						<ogc:PropertyName>$a1/@targetObject</ogc:PropertyName>
					</ogc:PropertyIsEqualTo>
					<ogc:PropertyIsEqualTo>
						<ogc:PropertyName>$e1/@objectType</ogc:PropertyName>
						<ogc:Literal>urn:ogc:def:objectType:OGC-CSW-ebRIM-CIM::DataMetadata</ogc:Literal>
					</ogc:PropertyIsEqualTo>
					<ogc:PropertyIsEqualTo>
						<ogc:PropertyName>$e2/@objectType</ogc:PropertyName>
						<ogc:Literal>urn:ogc:def:objectType:OGC-CSW-ebRIM-CIM::MetadataInformation</ogc:Literal>
					</ogc:PropertyIsEqualTo>
					<ogc:PropertyIsEqualTo>
						<ogc:PropertyName>$a2/@associationType</ogc:PropertyName>
						<ogc:Literal>urn:ogc:def:associationType:OGC-CSW-ebRIM-CIM::MetadataPointOfContact</ogc:Literal>
					</ogc:PropertyIsEqualTo>
					<ogc:PropertyIsEqualTo>
						<ogc:PropertyName>$a2/@sourceObject</ogc:PropertyName>
						<ogc:PropertyName>$e2/@id</ogc:PropertyName>
					</ogc:PropertyIsEqualTo>
					<ogc:PropertyIsEqualTo>
						<ogc:PropertyName>$r1/@id</ogc:PropertyName>
						<ogc:PropertyName>$a2/@targetObject</ogc:PropertyName>
					</ogc:PropertyIsEqualTo>
					<ogc:PropertyIsEqualTo>
						<ogc:PropertyName>$r1/@objectType</ogc:PropertyName>
						<ogc:Literal>urn:ogc:def:objectType:OGC-CSW-ebRIM-CIM::Organization</ogc:Literal>
					</ogc:PropertyIsEqualTo>
					<ogc:PropertyIsLike escapeChar="\" singleChar="?" wildCard="*">
						<ogc:PropertyName>$r1/rim:Name</ogc:PropertyName>
						<ogc:Literal>*</ogc:Literal>
					</ogc:PropertyIsLike>
					<ogc:PropertyIsLike escapeChar="\" singleChar="?" wildCard="*">
						<ogc:PropertyName>$e1/rim:Slot[@name='urn:ogc:def:slot:OGC-CSW-ebRIM-CIM::Lineage']/rim:ValueList/rim:Value</ogc:PropertyName>
						<ogc:Literal>*</ogc:Literal>
					</ogc:PropertyIsLike>
					<ogc:PropertyIsEqualTo>
						<ogc:PropertyName>$a4/@sourceObject</ogc:PropertyName>
						<ogc:PropertyName>$e1/@id</ogc:PropertyName>
					</ogc:PropertyIsEqualTo>
					<ogc:PropertyIsEqualTo>
						<ogc:PropertyName>$a4/@associationType</ogc:PropertyName>
						<ogc:Literal>urn:ogc:def:associationType:OGC-CSW-ebRIM-CIM::ResourceConstraints</ogc:Literal>
					</ogc:PropertyIsEqualTo>
					<ogc:PropertyIsEqualTo>
						<ogc:PropertyName>$e4/@id</ogc:PropertyName>
						<ogc:PropertyName>$a4/@targetObject</ogc:PropertyName>
					</ogc:PropertyIsEqualTo>
					<ogc:PropertyIsEqualTo>
						<ogc:PropertyName>$e4/@objectType</ogc:PropertyName>
						<ogc:Literal>urn:ogc:def:objectType:OGC-CSW-ebRIM-CIM::SecurityConstraints</ogc:Literal>
					</ogc:PropertyIsEqualTo>
					<ogc:PropertyIsEqualTo>
						<ogc:PropertyName>$e4/@id</ogc:PropertyName>
						<ogc:PropertyName>$c1/@classifiedObject</ogc:PropertyName>
					</ogc:PropertyIsEqualTo>
					<ogc:PropertyIsEqualTo>
						<ogc:PropertyName>$c1/@classificationScheme</ogc:PropertyName>
						<ogc:Literal>urn:ogc:def:classificationScheme:OGC-CSW-ebRIM-CIM::ClassificationCode</ogc:Literal>
					</ogc:PropertyIsEqualTo>
					<ogc:PropertyIsEqualTo>
						<ogc:PropertyName>$c1/@classificationNode</ogc:PropertyName>
						<ogc:PropertyName>$cn2/@id</ogc:PropertyName>
					</ogc:PropertyIsEqualTo>
					<ogc:PropertyIsEqualTo>
						<ogc:PropertyName>$cn2/@code</ogc:PropertyName>
						<ogc:Literal>unclassified</ogc:Literal>
					</ogc:PropertyIsEqualTo>

				</ogc:And>
			</ogc:Filter>
		</csw:Constraint>
	</csw:Query>
</csw:GetRecords>	

		</ctl:body>
       </ctl:soap-request>
      </xsl:variable>

	  <xsl:if test="not(count($responsesoap//csw:GetRecordsResponse)>0)">
			<ctl:message>FAILURE: assertion 2 failed</ctl:message>
			<ctl:fail/>
		  </xsl:if>

	 <ctl:message><xsl:value-of select="count($responsesoap//wrs:ExtrinsicObject[@objectType='urn:ogc:def:objectType:OGC-CSW-ebRIM-CIM::DatasetCollection'])"/> wrs:ExtrinsicObject of type DatasetCollection found.</ctl:message>

 
    </ctl:code>
  </ctl:test>
  
  
  


<!-- 
##################################################################
	csw:ICC.GetRecords-INSPIREServicesFilter
##################################################################
-->
<ctl:test name="csw:ICC.GetRecords-INSPIREServicesFilter">
    <ctl:param name="csw.GetRecords.soap.url"/>
    <ctl:assertion>
	The GetRecords request (sent via HTTP/SOAP/POST/XML) response must satisfy the applicable assertions:
	1.	the filter request is understood by the server and no exception concerning the request is thrown 
	2.	the XML representation is valid structured concerning the CSW 2.0.2 and the CSW-ebRIM Registry Service and the corresponding xml schemas. 
     </ctl:assertion>
    <ctl:comment>Pass if the assertions hold.</ctl:comment>
    <ctl:code>
       <ctl:message>Here is: csw:ICC.GetRecords-INSPIREServicesFilter</ctl:message>
        <ctl:message><xsl:value-of select="$csw.GetRecords.soap.url"/></ctl:message>

        <xsl:variable name="responsesoap">
          <ctl:soap-request version="1.2" charset="UTF-8">
          <ctl:url>
            <xsl:value-of select="$csw.GetRecords.soap.url"/>
          </ctl:url>
		  <ctl:action>http://www.opengis.net/cat/csw/2.0.2/requests#GetRecords</ctl:action>  
		 <ctl:body>

<csw:GetRecords maxRecords="10" outputFormat="application/xml" outputSchema="urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0" resultType="results" service="CSW" startPosition="1" version="2.0.2" xmlns:csw="http://www.opengis.net/cat/csw/2.0.2" xmlns:ogc="http://www.opengis.net/ogc" xmlns:wrs="http://www.opengis.net/cat/wrs/1.0" xmlns:rim="urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0">
	<csw:Query typeNames="wrs:ExtrinsicObject_e1 rim:Classification rim:ClassificationNode">
		<csw:ElementSetName typeNames="rim:ExtrinsicObject">brief</csw:ElementSetName>
		<csw:Constraint version="1.1.0">
			<ogc:Filter>
				<ogc:And>
					<ogc:PropertyIsEqualTo>
						<ogc:PropertyName>$e1/@objectType</ogc:PropertyName>
						<ogc:Literal>urn:ogc:def:objectType:OGC-CSW-ebRIM-CIM::ServiceMetadata</ogc:Literal>
					</ogc:PropertyIsEqualTo>
					<ogc:PropertyIsEqualTo>
						<ogc:PropertyName>$e1/@id</ogc:PropertyName>
						<ogc:PropertyName>rim:Classification/@classifiedObject</ogc:PropertyName>
					</ogc:PropertyIsEqualTo>
					<ogc:PropertyIsEqualTo>
						<ogc:PropertyName>rim:Classification/@classificationScheme</ogc:PropertyName>
						<ogc:Literal>urn:ogc:def:ebRIM-ClassificationScheme:ISO-19119:2005:Services</ogc:Literal>
					</ogc:PropertyIsEqualTo>
					<ogc:PropertyIsEqualTo>
						<ogc:PropertyName>rim:Classification/@classificationNode</ogc:PropertyName>
						<ogc:PropertyName>rim:ClassificationNode/@id</ogc:PropertyName>
					</ogc:PropertyIsEqualTo>
					<ogc:PropertyIsEqualTo>
						<ogc:PropertyName>rim:ClassificationNode/@code</ogc:PropertyName>
						<ogc:Literal>WMS</ogc:Literal>
					</ogc:PropertyIsEqualTo>


				</ogc:And>
			</ogc:Filter>
		</csw:Constraint>
	</csw:Query>
</csw:GetRecords>

		</ctl:body>
       </ctl:soap-request>
      </xsl:variable>
      
	  <xsl:if test="not(count($responsesoap//csw:GetRecordsResponse)>0)">
			<ctl:message>FAILURE: assertion 2 failed</ctl:message>
			<ctl:fail/>
		  </xsl:if>

 <ctl:message><xsl:value-of select="count($responsesoap//wrs:ExtrinsicObject[@objectType='urn:ogc:def:objectType:OGC-CSW-ebRIM-CIM::DatasetCollection'])"/> wrs:ExtrinsicObject of type DatasetCollection found.</ctl:message>


    </ctl:code>
  </ctl:test>  

  
<!-- 
##################################################################
	 csw:ICC.GetRecords-SyntaxError
##################################################################
-->
<ctl:test name="csw:ICC.GetRecords-SyntaxError">
    <ctl:param name="csw.GetRecords.soap.url"/>
    <ctl:assertion>
	The GetRecords request (sent via HTTP/SOAP/POST/XML) response must satisfy the applicable assertions:
	1.	valid exception...
     </ctl:assertion>
    <ctl:comment>Pass if the assertions hold.</ctl:comment>
    <ctl:code>
         <ctl:message>Here is: csw:ICC.GetRecords-SyntaxError !!</ctl:message>
         <ctl:message><xsl:value-of select="$csw.GetRecords.soap.url"/></ctl:message>

        <xsl:variable name="responsesoap">        
        <ctl:soap-request version="1.2" charset="UTF-8">
          <ctl:url>
            <xsl:value-of select="$csw.GetRecords.soap.url"/>
          </ctl:url>
		  <ctl:action>http://www.opengis.net/cat/csw/2.0.2/requests#GetRecords</ctl:action>  
		 <ctl:body>
			 <csw:GetRecords maxRecords="5" outputFormat="application/xml" outputSchema="urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0" resultType="results" service="CSW" startPosition="1" version="2.0.2" xmlns:csw="http://www.opengis.net/cat/csw/2.0.2" xmlns:ogc="http://www.opengis.net/ogc" xmlns:wrs="http://www.opengis.net/cat/wrs/1.0" xmlns:rim="urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0" xmlns:gml="http://www.opengis.net/gml">
				<csw:Query typeNames="wrs:ExtrinsicObject_e1">
					<csw:ElementSetName typeNames="$e1">full</csw:ElementSetName>
					<csw:Constraint version="1.1.0">
						<ogc:Filter xmlns:ogc="http://www.opengis.net/ogc">
								<ogc:BBOX>
									<ogc:PropertyName>$e1/rim:SlotSyntaxError[@name='urn:ogc:def:slot:OGC-CSW-ebRIM-CIM::Envelope']/wrs:ValueList/wrs:AnyValue</ogc:PropertyName>
									<gml:Envelope srsName="urn:ogc:def:crs:EPSG:4326">
										<gml:lowerCorner>-90.0 -180.0</gml:lowerCorner>
										<gml:upperCorner>90.0 180.0</gml:upperCorner>
									</gml:Envelope>
								</ogc:BBOX>
						</ogc:Filter>
					</csw:Constraint>
				</csw:Query>
			</csw:GetRecords>
		</ctl:body>
       </ctl:soap-request>
      </xsl:variable>

        <ctl:message><xsl:value-of select="$responsesoap"/></ctl:message>
         
     <xsl:if test="not(count($responsesoap//soap:Fault)>0)">
        <ctl:message>FAILURE: assertion failed</ctl:message>
        <ctl:fail/>
      </xsl:if>

     <xsl:if test="not(count($responsesoap//ows:ExceptionReport)>0)">
        <ctl:message>FAILURE: assertion failed</ctl:message>
        <ctl:fail/>
      </xsl:if>
 
    </ctl:code>
  </ctl:test>


 
<!-- 
##################################################################
	 csw:ICC.ICC.GetRecordById
##################################################################
-->
<ctl:test name="csw:ICC.GetRecordById">
    <ctl:param name="csw.GetRecords.soap.url"/>
    <ctl:assertion>
	The GetRecordById request (sent via HTTP/SOAP/POST/XML) response must satisfy the applicable assertions:
	1.	the request is understood by the server and no exception concerning the request is thrown 
	2. the XML representation of the response frame is valid structured 
	3. each ExtrinsicObject within the GetRecordsResponse which is in the Namespace “urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0” must be conformant http://schemas.opengis.net/csw/2.0.2/profiles/ebrim/1.0/csw-ebrim.xsd
     </ctl:assertion>
    <ctl:comment>Pass if the assertions hold.</ctl:comment>
    <ctl:code>
         <ctl:message>Here is: csw:ICC.ICC.GetRecordById</ctl:message>
         <ctl:message><xsl:value-of select="csw.GetRecords.soap.url"/></ctl:message>

        <xsl:variable name="responsesoap">        
        <ctl:soap-request version="1.2" charset="UTF-8">
          <ctl:url>
            <xsl:value-of select="$csw.GetRecords.soap.url"/>
          </ctl:url>
		  <ctl:action>http://www.opengis.net/cat/csw/2.0.2/requests#GetRecords</ctl:action>  
		 <ctl:body>
			 <csw:GetRecords maxRecords="5" outputFormat="application/xml" outputSchema="urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0" resultType="results" service="CSW" startPosition="1" version="2.0.2" xmlns:csw="http://www.opengis.net/cat/csw/2.0.2" xmlns:ogc="http://www.opengis.net/ogc" xmlns:wrs="http://www.opengis.net/cat/wrs/1.0" xmlns:rim="urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0" xmlns:gml="http://www.opengis.net/gml">
				<csw:Query typeNames="wrs:ExtrinsicObject_e1">
					<csw:ElementSetName typeNames="$e1">full</csw:ElementSetName>
					<csw:Constraint version="1.1.0">
						<ogc:Filter xmlns:ogc="http://www.opengis.net/ogc">
								<ogc:BBOX>
									<ogc:PropertyName>$e1/rim:Slot[@name='urn:ogc:def:slot:OGC-CSW-ebRIM-CIM::Envelope']/wrs:ValueList/wrs:AnyValue</ogc:PropertyName>
									<gml:Envelope srsName="urn:ogc:def:crs:EPSG:4326">
										<gml:lowerCorner>-90.0 -180.0</gml:lowerCorner>
										<gml:upperCorner>90.0 180.0</gml:upperCorner>
									</gml:Envelope>
								</ogc:BBOX>
						</ogc:Filter>
					</csw:Constraint>
				</csw:Query>
			</csw:GetRecords>
		</ctl:body>
       </ctl:soap-request>
      </xsl:variable>
          
     <ctl:message><xsl:value-of select="count($responsesoap//wrs:ExtrinsicObject[@objectType='urn:ogc:def:objectType:OGC-CSW-ebRIM-CIM::DatasetCollection'])"/> wrs:ExtrinsicObject of type DatasetCollection found.</ctl:message>

     <xsl:if test="not(count($responsesoap//wrs:ExtrinsicObject[@objectType='urn:ogc:def:objectType:OGC-CSW-ebRIM-CIM::DatasetCollection'])>0)">
        <ctl:message>FAILURE: no record for subsequent GetRecordById avaialble: precondition for testing GetRecordById not fullfilled!!</ctl:message>
        <ctl:fail/>
      </xsl:if>

      <ctl:message>At minimum one DatasetCollection Extrinsic Object found with id:</ctl:message>
	  <ctl:message><xsl:value-of select="$responsesoap//wrs:ExtrinsicObject[1]/@id[../@objectType='urn:ogc:def:objectType:OGC-CSW-ebRIM-CIM::DatasetCollection']"></xsl:value-of></ctl:message>

       <xsl:variable name="responsesoap2">        
        <ctl:soap-request version="1.2" charset="UTF-8">
          <ctl:url>
            <xsl:value-of select="$csw.GetRecords.soap.url"/>
          </ctl:url>
		  <ctl:action>http://www.opengis.net/cat/csw/2.0.2/requests#GetRecordById</ctl:action>  
		 <ctl:body>
			<csw:GetRecordById service="CSW" version="2.0.2" outputFormat="text/xml" outputSchema="urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0" 
			xmlns:csw="http://www.opengis.net/cat/csw/2.0.2" xmlns:ogc="http://www.opengis.net/ogc" 
			xmlns:wrs="http://www.opengis.net/cat/wrs/1.0" xmlns:rim="urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0" xmlns:gml="http://www.opengis.net/gml">
					<!--1 or more repetitions:-->
					 <csw:Id><xsl:value-of select="$responsesoap//wrs:ExtrinsicObject[1]/@id[../@objectType='urn:ogc:def:objectType:OGC-CSW-ebRIM-CIM::DatasetCollection']"></xsl:value-of></csw:Id>
					 <!--Optional:-->
					 <csw:ElementSetName>full</csw:ElementSetName>
				  </csw:GetRecordById>
		</ctl:body>
       </ctl:soap-request>
      </xsl:variable>

 <xsl:if test="not(count($responsesoap2//csw:GetRecordByIdResponse)>0)">
        <ctl:message>FAILURE: assertion 2 failed</ctl:message>
        <ctl:fail/>
      </xsl:if>

     <xsl:if test="not(count($responsesoap2//wrs:ExtrinsicObject[@objectType='urn:ogc:def:objectType:OGC-CSW-ebRIM-CIM::DatasetCollection'])>0)">
        <ctl:message>FAILURE: assertion 3 failed</ctl:message>
        <ctl:fail/>
      </xsl:if>

    <xsl:if test="not(count($responsesoap//rim:ExternalIdentifier)>0)">
        <ctl:message>FAILURE: assertion 4 failed</ctl:message>
        <ctl:fail/>
      </xsl:if>

	<xsl:for-each select="$responsesoap2//rim:ExtrinsicObject">
			<ctl:call-test name="ctl:XMLValidatingParser">
				<ctl:with-param name="doc"><xsl:copy-of select="."/></ctl:with-param>
				<ctl:with-param name="instruction">
					<parsers:schemas>
						<parsers:schema type="url">http://schemas.opengis.net/csw/2.0.2/profiles/ebrim/1.0/csw-ebrim.xsd</parsers:schema>
					</parsers:schemas>
				</ctl:with-param>
			</ctl:call-test>
	</xsl:for-each>


    </ctl:code>
  </ctl:test>
 


<!-- 
##################################################################
	  csw:ICC.GetRepositoryItem
##################################################################
-->
<ctl:test name="csw:ICC.GetRepositoryItem">
    <ctl:param name="csw.GetRecords.soap.url"/>
	<ctl:param name="csw.getrepositoryitem.url"/>
    <ctl:assertion>
	The GetRepositoryItem request (sent via HTTP/GET/KVP) response must satisfy the applicable assertions:
	1.	the request is understood by the server and no exception concerning the request is thrown 
	2. the XML representation of the response is valid to the ISO191(15|19|39) XML schema. The response can be validated with the ISO19139 [ISO19139] xml schema  http://schemas.opengis.net/csw/2.0.2/profiles/apiso/1.0.0/apiso.xsd)     </ctl:assertion>
    <ctl:comment>Pass if the assertions hold.</ctl:comment>
    <ctl:code>
         <ctl:message>Here is: csw:ICC.GetRepositoryItem</ctl:message>
         <ctl:message><xsl:value-of select="$csw.GetRecords.soap.url"/></ctl:message>
         <ctl:message><xsl:value-of select="$csw.getrepositoryitem.url"/></ctl:message>

        <xsl:variable name="responsesoap">        
        <ctl:soap-request version="1.2" charset="UTF-8">
          <ctl:url>
            <xsl:value-of select="$csw.GetRecords.soap.url"/>
          </ctl:url>
		  <ctl:action>http://www.opengis.net/cat/csw/2.0.2/requests#GetRecords</ctl:action>  
		 <ctl:body>
			 <csw:GetRecords maxRecords="5" outputFormat="application/xml" outputSchema="urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0" resultType="results" service="CSW" startPosition="1" version="2.0.2" xmlns:csw="http://www.opengis.net/cat/csw/2.0.2" xmlns:ogc="http://www.opengis.net/ogc" xmlns:wrs="http://www.opengis.net/cat/wrs/1.0" xmlns:rim="urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0" xmlns:gml="http://www.opengis.net/gml">
				<csw:Query typeNames="wrs:ExtrinsicObject_e1">
					<csw:ElementSetName typeNames="$e1">full</csw:ElementSetName>
					<csw:Constraint version="1.1.0">
						<ogc:Filter xmlns:ogc="http://www.opengis.net/ogc">
								<ogc:BBOX>
									<ogc:PropertyName>$e1/rim:Slot[@name='urn:ogc:def:slot:OGC-CSW-ebRIM-CIM::Envelope']/wrs:ValueList/wrs:AnyValue</ogc:PropertyName>
									<gml:Envelope srsName="urn:ogc:def:crs:EPSG:4326">
										<gml:lowerCorner>-90.0 -180.0</gml:lowerCorner>
										<gml:upperCorner>90.0 180.0</gml:upperCorner>
									</gml:Envelope>
								</ogc:BBOX>
						</ogc:Filter>
					</csw:Constraint>
				</csw:Query>
			</csw:GetRecords>
		</ctl:body>
       </ctl:soap-request>
      </xsl:variable>
          
     <ctl:message><xsl:value-of select="count($responsesoap//wrs:ExtrinsicObject[@objectType='urn:ogc:def:objectType:OGC-CSW-ebRIM-CIM::DatasetCollection'])"/> wrs:ExtrinsicObject of type DatasetCollection found.</ctl:message>

     <xsl:if test="not(count($responsesoap//wrs:ExtrinsicObject[@objectType='urn:ogc:def:objectType:OGC-CSW-ebRIM-CIM::DatasetCollection'])>0)">
        <ctl:message>FAILURE: no record for subsequent GetRepositoryItem avaialble: precondition for testing GetRepositoryItem not fullfilled!!</ctl:message>
        <ctl:fail/>
      </xsl:if>

      <ctl:message>At minimum one DatasetCollection Extrinsic Object found with id:</ctl:message>
	  <ctl:message><xsl:value-of select="$responsesoap//wrs:ExtrinsicObject[1]/@id[../@objectType='urn:ogc:def:objectType:OGC-CSW-ebRIM-CIM::DatasetCollection']"></xsl:value-of></ctl:message>

      <xsl:variable name="response2">
        <ctl:request>
          <ctl:url>
            <xsl:value-of select="$csw.getrepositoryitem.url"/>
          </ctl:url>
          <ctl:method>GET</ctl:method>
          <ctl:param name="service">CSW-ebRIM</ctl:param>
          <ctl:param name="request">GetRepositoryItem</ctl:param>
          <ctl:param name="Id"><xsl:value-of select="$responsesoap//wrs:ExtrinsicObject[1]/@id[../@objectType='urn:ogc:def:objectType:OGC-CSW-ebRIM-CIM::DatasetCollection']"></xsl:value-of></ctl:param> 
	  </ctl:request>
      </xsl:variable>

      <xsl:if test="count($response2//gmd:MD_Metadata>0)">
        <ctl:message>gmd:MD_Metadata found</ctl:message>
      </xsl:if>

      <xsl:if test="not(count($response2//gmd:MD_Metadata)>0)">
        <ctl:message>FAILURE: assertion 2 failed</ctl:message>
        <ctl:fail/>
      </xsl:if>

      <xsl:for-each select="$response2//gmd:MD_Metadata">
        <ctl:call-test name="ctl:XMLValidatingParser">
          <ctl:with-param name="doc"><xsl:copy-of select="."/></ctl:with-param>
          <ctl:with-param name="instruction">
            <parsers:schemas>
              <parsers:schema type="url">http://schemas.opengis.net/iso/19139/20060504/gmd/gmd.xsd</parsers:schema>
            </parsers:schemas>
          </ctl:with-param>
        </ctl:call-test>
      </xsl:for-each>
  
    </ctl:code>
  </ctl:test>
 

<!-- 
##################################################################
	csw:CIM.GetRecords-SemanticAnnotation
##################################################################
-->
<ctl:test name="csw:CIM.GetRecords-SemanticAnnotation">
    <ctl:param name="csw.GetRecords.soap.url"/>
    <ctl:assertion>
	The GetRecords request (sent via HTTP/SOAP/POST/XML) response must satisfy the applicable assertions:
	1.	the filter request is understood by the server and no exception concerning the request is thrown 
     </ctl:assertion>
    <ctl:comment>Pass if the assertions hold.</ctl:comment>
    <ctl:code>
         <ctl:message>Here is: csw:CIM.GetRecords-SemanticAnnotation</ctl:message>
         <ctl:message><xsl:value-of select="$csw.GetRecords.soap.url"/></ctl:message>

        <xsl:variable name="responsesoap">
           <ctl:soap-request version="1.2" charset="UTF-8">
          <ctl:url>
            <xsl:value-of select="$csw.GetRecords.soap.url"/>
          </ctl:url>
		  <ctl:action>http://www.opengis.net/cat/csw/2.0.2/requests#GetRecords</ctl:action>  
		 <ctl:body>
				
			<csw:GetRecords maxRecords="5" outputFormat="application/xml" outputSchema="urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0" 
				resultType="results" service="CSW" startPosition="1" version="2.0.2" xmlns:csw="http://www.opengis.net/cat/csw/2.0.2" xmlns:ogc="http://www.opengis.net/ogc" xmlns:wrs="http://www.opengis.net/cat/wrs/1.0" xmlns:rim="urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0" xmlns:gml="http://www.opengis.net/gml">
				<csw:Query typeNames="wrs:ExtrinsicObject_e1 rim:Classification_c1 rim:ClassificationNode_n1">
					<csw:ElementSetName typeNames="$e1">full</csw:ElementSetName>
					<csw:Constraint version="1.1.0">
						<ogc:Filter xmlns:ogc="http://www.opengis.net/ogc">
							<ogc:And>
								<ogc:PropertyIsEqualTo>
									<ogc:PropertyName>$e1/@id</ogc:PropertyName>
									<ogc:PropertyName>$c1/@classifiedObject</ogc:PropertyName>
								</ogc:PropertyIsEqualTo>
								<ogc:PropertyIsEqualTo>
									<ogc:PropertyName>$c1/@classificationNode</ogc:PropertyName>
									<ogc:Literal>$n1/@id</ogc:Literal>
								</ogc:PropertyIsEqualTo>
								<ogc:PropertyIsEqualTo>
									<ogc:PropertyName>$n1/rim:Slot[@name='urn:ogc:def:slot:OGC-CSW-ebRIM-CIM::Url']/rim:ValueList/rim:Value</ogc:PropertyName>
									<ogc:Literal>http://anyURL</ogc:Literal>
								</ogc:PropertyIsEqualTo>
							</ogc:And>
			
						</ogc:Filter>
					</csw:Constraint>
				</csw:Query>
			</csw:GetRecords>

		</ctl:body>
       </ctl:soap-request>
      </xsl:variable>
      
     <ctl:message><xsl:value-of select="count($responsesoap//wrs:ExtrinsicObject)" /> wrs:ExtrinsicObject elements found.</ctl:message>

    </ctl:code>
  </ctl:test>


  <xsl:template match="csw2:GetRecordsResponse">
    <xsl:copy>
      <xsl:copy-of select="csw2:RequestId | csw2:SearchStatus" />
      <xsl:for-each select="csw2:SearchResults">
        <xsl:copy>
          <xsl:copy-of select="@*" />
        </xsl:copy>
      </xsl:for-each>
    </xsl:copy>
  </xsl:template>

<!--
      <ctl:call-test name="ctl:XMLValidatingParser">
        <ctl:with-param name="doc"><xsl:copy-of select="$response"/></ctl:with-param>
        <ctl:with-param name="instruction">
          <parsers:schemas>
            <parsers:schema type="url">http://schemas.opengis.net/csw/2.0.2/profiles/ebrim/1.0/csw-ebrim.xsd
            </parsers:schema>
          </parsers:schemas>
        </ctl:with-param>
      </ctl:call-test>
      <xsl:if test="not($response/wrs:Capabilities)">
        <ctl:message>FAILURE: the second assertion failed: root node named &quot;Capabilities&quot; not defined within the &quot;http://www.opengis.net/cat/wrs/1.0&quot; namespace</ctl:message>
        <ctl:fail/>
      </xsl:if>
-->

</ctl:package>

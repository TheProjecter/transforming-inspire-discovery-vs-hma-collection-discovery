<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
Transforms a CIM EP request to an ISO AP request.

 Author: Udo Einspanier, con terra GmbH
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:gmd="http://www.isotc211.org/2005/gmd" xmlns:gco="http://www.isotc211.org/2005/gco" xmlns:gml="http://www.opengis.net/gml" xmlns:csw="http://www.opengis.net/cat/csw/2.0.2" xmlns:ogc="http://www.opengis.net/ogc" xmlns:ows="http://www.opengis.net/ows" xmlns:rim="urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0" xmlns:wrs="http://www.opengis.net/cat/wrs/1.0" xmlns:apiso="http://www.opengis.net/cat/csw/apiso/1.0" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:soap12="http://www.w3.org/2003/05/soap-envelope" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:gmx="http://www.isotc211.org/2005/gmx" xmlns:xlink="http://www.w3.org/1999/xlink">

	<xsl:output method="xml" encoding="utf-8"/>

	<!-- we need the request document to determine the correct response - we get a GetReocrdsResponse for GetRecords, GetRecordById and GetRepositoryItem requests -->
	<xsl:variable name="requestDoc" select="document('requestDoc.xml')"/>

	<!-- language of metadata record character string fields -->
	<xsl:variable name="lang" select="//gmd:MD_Metadata[1]/gmd:language/gmd:LanguageCode/@codeListValue"/>
	
	<!-- remove schema location to avoid validation errors -->
	<xsl:template match="@xsi:schemaLocation"/>

	<!-- if it was a SOAP request, transform to the client's SOAP version -->
	<xsl:template match="soap12:*">
		<xsl:choose>
			<xsl:when test="$requestDoc/soap12:Envelope">
				<xsl:copy>
					<xsl:apply-templates select="@*|node()"/>
				</xsl:copy>
			</xsl:when>
			<xsl:when test="$requestDoc/soap:Envelope">
				<xsl:element name="{concat('soap:', local-name())}">
					<xsl:apply-templates select="@*|node()"/>
				</xsl:element>
			</xsl:when>
			<xsl:otherwise>
				<!-- no SOAP request, skip the SOAP elements -->
				<xsl:apply-templates select="//soap12:Body/*"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- map SOAP fault structure, if required -->
	<xsl:template match="soap12:Fault">
		<xsl:choose>
			<xsl:when test="$requestDoc/soap:Envelope">
				<soap:Fault>
					<faultcode><xsl:value-of select="soap12:Code/soap12:Value"/></faultcode>
					<faultstring><xsl:value-of select="soap12:Reason"/></faultstring>
					<detail><xsl:value-of select="soap12:Detail"/></detail>
				</soap:Fault>
			</xsl:when>
			<xsl:when test="$requestDoc/soap12:Envelope">
				<xsl:copy-of select="."/>
			</xsl:when>
			<xsl:otherwise>
				<!-- no SOAP request, skip the SOAP elements -->
				<xsl:apply-templates select="soap12:Detail/*"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- exception as root, check if request was SOAP and we need a SOAP fault -->
	<xsl:template match="/ows:ExceptionReport">
		<xsl:choose>
			<xsl:when test="$requestDoc/soap:Envelope">
				<soap:Fault>
					<faultcode>soap:Server</faultcode>
					<faultstring>A server exception was encountered.</faultstring>
					<detail>
						<xsl:copy-of select="."/>
					</detail>
				</soap:Fault>
			</xsl:when>
			<xsl:when test="$requestDoc/soap12:Envelope">
				<soap12:Fault>
					<soap12:Code>
						<soap12:Value>soap:Server</soap12:Value>
					</soap12:Code>
					<soap12:Reason>A server exception was encountered.</soap12:Reason>
					<soap12:Detail>
						<xsl:copy-of select="."/>
					</soap12:Detail>
				</soap12:Fault>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy-of select="."/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- match the GetRecordsResponse to the correct response type -->
	<xsl:template match="csw:GetRecordsResponse">
		<xsl:choose>
			<xsl:when test="$requestDoc//csw:GetRecords">
				<xsl:copy>
					<xsl:apply-templates select="@*|node()"/>
				</xsl:copy>
			</xsl:when>
			<xsl:when test="$requestDoc//csw:GetRecordById">
				<csw:GetRecordByIdResponse>
					<xsl:apply-templates select="csw:SearchResults/*"/>
				</csw:GetRecordByIdResponse>
			</xsl:when>
			<xsl:otherwise>
				<!-- GetRepositoryItem -->
				<xsl:apply-templates select="csw:SearchResults/*" mode="getRepositoryItem"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- GetRepositoryItem response, just copy the full MD_Metadata instance -->
	<xsl:template match="gmd:MD_Metadata" mode="getRepositoryItem">
		<xsl:copy-of select="."/>
	</xsl:template>

	<!-- set requested element set -->
	<xsl:template match="@elementSet">
		<xsl:variable name="elementSet" select="$requestDoc//csw:ElementSetName"/>
		<xsl:if test="$elementSet">
			<xsl:attribute name="elementSet"><xsl:value-of select="$elementSet"/></xsl:attribute>
		</xsl:if>
	</xsl:template>

	<!-- set requested record schema -->
	<xsl:template match="@recordSchema">
		<xsl:variable name="recordSchema" select="$requestDoc//@outputSchema"/>
		<xsl:if test="$recordSchema">
			<xsl:attribute name="recordSchema"><xsl:value-of select="$recordSchema"/></xsl:attribute>
		</xsl:if>
	</xsl:template>
	
	<!-- transform the metadata records -->
	<xsl:template match="gmd:MD_Metadata">
		<xsl:variable name="fileId" select="gmd:fileIdentifier/gco:CharacterString"/>
		<xsl:variable name="elementSet" select="$requestDoc//csw:ElementSetName"/>
		<wrs:ExtrinsicObject id="{concat('RM:', $fileId)}" lid="{concat('RM:', $fileId)}" status="urn:oasis:names:tc:ebxml-regrep:StatusType:Submitted">
			<xsl:variable name="scopeCode" select="gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue"/>
			<xsl:attribute name="objectType">
				<xsl:choose>
					<xsl:when test="$scopeCode = 'service'">
						<xsl:value-of select="'urn:ogc:def:objectType:OGC-CSW-ebRIM-CIM::ServiceMetadata'"/>
					</xsl:when>
					<xsl:when test="$scopeCode = 'series'">
						<xsl:value-of select="'urn:ogc:def:objectType:OGC-CSW-ebRIM-CIM::DatasetCollection'"/>
					</xsl:when>
					<xsl:when test="$scopeCode = 'application'">
						<xsl:value-of select="'urn:ogc:def:objectType:OGC-CSW-ebRIM-CIM::Application'"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="'urn:ogc:def:objectType:OGC-CSW-ebRIM-CIM::DataMetadata'"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<xsl:if test="$elementSet != 'brief'">
				<!-- ResourceMetadata slots -->
				<xsl:call-template name="internationalSlot">
					<xsl:with-param name="name" select="'http://purl.org/dc/terms/type'"/>
					<xsl:with-param name="values" select="gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue"/>
				</xsl:call-template>
				<xsl:call-template name="dateSlot">
					<xsl:with-param name="name" select="'http://purl.org/dc/terms/created'"/>
					<xsl:with-param name="values" select="gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation/gmd:date/gmd:CI_Date[gmd:dateType/gmd:CI_DateTypeCode/@codeListValue = 'creation']/gmd:date/gco:Date"/>
				</xsl:call-template>
				<xsl:call-template name="dateSlot">
					<xsl:with-param name="name" select="'http://purl.org/dc/terms/issued'"/>
					<xsl:with-param name="values" select="gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation/gmd:date/gmd:CI_Date[gmd:dateType/gmd:CI_DateTypeCode/@codeListValue = 'publication']/gmd:date/gco:Date"/>
				</xsl:call-template>
				<xsl:call-template name="dateSlot">
					<xsl:with-param name="name" select="'http://purl.org/dc/terms/modified'"/>
					<xsl:with-param name="values" select="gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation/gmd:date/gmd:CI_Date[gmd:dateType/gmd:CI_DateTypeCode/@codeListValue = 'revision']/gmd:date/gco:Date"/>
				</xsl:call-template>
				<xsl:call-template name="internationalSlot">
					<xsl:with-param name="name" select="'urn:ogc:def:slot:OGC-CSW-ebRIM-CIM::Lineage'"/>
					<xsl:with-param name="values" select="gmd:dataQualityInfo/*/gmd:lineage/gmd:LI_Lineage/gmd:statement/gco:CharacterString"/>
				</xsl:call-template>
				<xsl:call-template name="internationalSlot">
					<xsl:with-param name="name" select="'http://purl.org/dc/terms/source'"/>
					<xsl:with-param name="values" select="gmd:distributionInfo/*/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource/gmd:linkage/gmd:URL"/>
				</xsl:call-template>
				<xsl:call-template name="internationalSlot">
					<xsl:with-param name="name" select="'http://purl.org/dc/terms/format'"/>
					<xsl:with-param name="values" select="gmd:identificationInfo/*/gmd:resourceFormat/gmd:MD_Format/gmd:name/gco:CharacterString"/>
				</xsl:call-template>
				<!-- DataMetadata slots -->
				<xsl:call-template name="slot">
					<xsl:with-param name="name" select="'http://purl.org/dc/elements/1.1/language'"/>
					<xsl:with-param name="values" select="gmd:identificationInfo/*/gmd:language/gmd:LanguageCode/@codeListValue"/>
				</xsl:call-template>
				<xsl:call-template name="envelope"/>
				<xsl:call-template name="tempExtent"/>
				<xsl:call-template name="resolution"/>
				<xsl:call-template name="integerSlot">
					<xsl:with-param name="name" select="'urn:ogc:def:slot:OGC-CSW-ebRIM-CIM::ScaleDenominator'"/>
					<xsl:with-param name="values" select="gmd:identificationInfo/*/gmd:spatialResolution/gmd:MD_Resolution/gmd:equivalentScale/gmd:MD_RepresentativeFraction/gmd:denominator/gco:Integer"/>
				</xsl:call-template>

				<!-- rim:Name and rim:Description -->
				<xsl:apply-templates select="gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation/gmd:title/gco:CharacterString"/>
				<xsl:apply-templates select="gmd:identificationInfo/*/gmd:abstract/gco:CharacterString"/>
			</xsl:if>
			<xsl:if test="$elementSet = 'full'">
				<!-- DataMetadata classifications -->
				<xsl:call-template name="classification">
					<xsl:with-param name="classifiedObject" select="concat('RM:', $fileId)"/>
					<xsl:with-param name="classificationScheme" select="'TopicCategory'"/>
					<xsl:with-param name="values" select="gmd:identificationInfo/*/gmd:topicCategory/gmd:MD_TopicCategoryCode"/>
				</xsl:call-template>
				<xsl:call-template name="classification">
					<xsl:with-param name="classifiedObject" select="concat('RM:', $fileId)"/>
					<xsl:with-param name="classificationScheme" select="'SpatialRepresentationType'"/>
					<xsl:with-param name="values" select="gmd:identificationInfo/*/gmd:spatialRepresentationType/gmd:MD_SpatialRepresentationTypeCode/@codeListValue"/>
				</xsl:call-template>
				<xsl:call-template name="classification">
					<xsl:with-param name="classifiedObject" select="concat('RM:', $fileId)"/>
					<xsl:with-param name="classificationScheme" select="'KeywordType'"/>
					<xsl:with-param name="values" select="gmd:identificationInfo/*/gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:type/gmd:MD_KeywordTypeCode/@codeListValue"/>
				</xsl:call-template>
				<xsl:call-template name="classification">
					<xsl:with-param name="classifiedObject" select="concat('RM:', $fileId)"/>
					<xsl:with-param name="classificationScheme" select="'KeywordScheme'"/>
					<xsl:with-param name="values" select="gmd:identificationInfo/*/gmd:descriptiveKeywords/gmd:MD_Keywords[not(gmd:thesaurusName)]/gmd:keyword/gco:CharacterString"/>
				</xsl:call-template>
				<xsl:call-template name="thesaurusClassifications">
					<xsl:with-param name="classifiedObject" select="concat('RM:', $fileId)"/>
					<xsl:with-param name="values" select="gmd:identificationInfo/*/gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:thesaurusName"/>
				</xsl:call-template>
				<!-- TODO: ServiceMetadata: classification Services, containing service type and service type version -->
			</xsl:if>

			<!-- resource identifier -->
			<xsl:variable name="resIdentifier" select="gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation/gmd:identifier/*/gmd:code/gco:CharacterString"/>
			<xsl:if test="$elementSet != 'brief and $resIdentifier'">
				<rim:ExternalIdentifier objectType="urn:oasis:names:tc:ebxml-regrep:ObjectType:RegistryObject:ExternalIdentifier" identificationScheme="urn:x-ogc:specification:csw-ebrim:EO:UnknownIdentifiers" value="{$resIdentifier}" id="{concat('EI:', $fileId)}" registryObject="{concat('RM:', $fileId)}"/>
			</xsl:if>
		</wrs:ExtrinsicObject>
<!--
		<xsl:if test="$elementSet = 'full'">
			<xsl:call-template name="classificationNode">
				<xsl:with-param name="classifiedObject" select="concat('RM:', $fileId)"/>
				<xsl:with-param name="classificationScheme" select="'TopicCategory'"/>
				<xsl:with-param name="values" select="gmd:identificationInfo/*/gmd:topicCategory/gmd:MD_TopicCategoryCode"/>
			</xsl:call-template>
			<xsl:call-template name="classificationNode">
				<xsl:with-param name="classifiedObject" select="concat('RM:', $fileId)"/>
				<xsl:with-param name="classificationScheme" select="'SpatialRepresentationType'"/>
				<xsl:with-param name="values" select="gmd:identificationInfo/*/gmd:spatialRepresentationType/gmd:MD_SpatialRepresentationTypeCode/@codeListValue"/>
			</xsl:call-template>
			<xsl:call-template name="classificationNode">
				<xsl:with-param name="classifiedObject" select="concat('RM:', $fileId)"/>
				<xsl:with-param name="classificationScheme" select="'KeywordType'"/>
				<xsl:with-param name="values" select="gmd:identificationInfo/*/gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:type/gmd:MD_KeywordTypeCode/@codeListValue"/>
			</xsl:call-template>
			<xsl:call-template name="classificationNode">
				<xsl:with-param name="classifiedObject" select="concat('RM:', $fileId)"/>
				<xsl:with-param name="classificationScheme" select="'KeywordScheme'"/>
				<xsl:with-param name="values" select="gmd:identificationInfo/*/gmd:descriptiveKeywords/gmd:MD_Keywords[not(gmd:thesaurusName)]/gmd:keyword/gco:CharacterString"/>
			</xsl:call-template>
			<xsl:call-template name="thesaurus">
				<xsl:with-param name="classifiedObject" select="concat('RM:', $fileId)"/>
				<xsl:with-param name="values" select="gmd:identificationInfo/*/gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:thesaurusName"/>
			</xsl:call-template>
			<xsl:call-template name="responsibleParty">
				<xsl:with-param name="values" select="gmd:identificationInfo[1]/*/gmd:pointOfContact/*[gmd:organisationName/gco:CharacterString != '']"/>
			</xsl:call-template>
			<xsl:call-template name="metadataInformation"/>
			<xsl:call-template name="legalConstraints"/>
			<xsl:call-template name="securityConstraints"/>
			<xsl:call-template name="referenceSystem"/>
			<xsl:call-template name="graphicOverview"/>
			<xsl:call-template name="referenceSpecification"/>
			<xsl:call-template name="parentIdentifier"/>
		</xsl:if>
-->
	</xsl:template>
	<!-- title -->
	<xsl:template match="gmd:title/gco:CharacterString">
		<rim:Name>
			<rim:LocalizedString xml:lang="{$lang}" value="{text()}"/>
		</rim:Name>
	</xsl:template>

	<!-- abstact -->
	<xsl:template match="gmd:abstract/gco:CharacterString">
		<rim:Description>
			<rim:LocalizedString xml:lang="{$lang}" value="{text()}"/>
		</rim:Description>
	</xsl:template>
	
	<!-- resolution -->
	<xsl:template name="resolution">
		<xsl:variable name="values" select="gmd:identificationInfo/*/gmd:spatialResolution/gmd:MD_Resolution/gmd:distance/gco:Distance"/>
		<xsl:if test="$values">
			<rim:Slot name="urn:ogc:def:slot:OGC-CSW-ebRIM-CIM::Resolution" slotType="urn:ogc:def:dataType:gml:MeasureType">
				<wrs:ValueList>
					<xsl:for-each select="$values">
						<wrs:AnyValue>
							<gml:measure uom="{@uom}"><xsl:value-of select="text()"/></gml:measure>
						</wrs:AnyValue>
					</xsl:for-each>
				</wrs:ValueList>
			</rim:Slot>
		</xsl:if>
	</xsl:template>

	<!-- bounding box -->
	<xsl:template name="envelope">
		<xsl:variable name="values" select="gmd:identificationInfo/*/gmd:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox"/>
		<xsl:if test="$values">
			<rim:Slot name="urn:ogc:def:slot:OGC-CSW-ebRIM-CIM::Envelope" slotType="urn:ogc:def:dataType:ISO-19107:2003:GM_Envelope">
				<wrs:ValueList>
					<xsl:for-each select="$values">
						<wrs:AnyValue>
							<gml:Envelope srsName="epsg:4326">
								<gml:lowerCorner><xsl:value-of select="concat(gmd:southBoundLatitude, ' ', gmd:westBoundLongitude)"/></gml:lowerCorner>
								<gml:upperCorner><xsl:value-of select="concat(gmd:northBoundLatitude, ' ', gmd:eastBoundLongitude)"/></gml:upperCorner>
							</gml:Envelope>
						</wrs:AnyValue>
					</xsl:for-each>
				</wrs:ValueList>
			</rim:Slot>
		</xsl:if>
	</xsl:template>

	<!-- temporal extent -->
	<xsl:template name="tempExtent">
		<xsl:variable name="values" select="gmd:identificationInfo/*/gmd:extent/gmd:EX_Extent/gmd:temporalElement/gmd:EX_TemporalExtent/gmd:extent/gml:TimePeriod"/>
		<xsl:if test="$values">
			<rim:Slot name="http://purl.org/dc/terms/temporal" slotType="urn:ogc:def:dataType:ISO-19108:2002:TM_Period">
				<wrs:ValueList>
					<xsl:for-each select="$values">
						<wrs:AnyValue>
							<xsl:copy-of select="."/>
						</wrs:AnyValue>
					</xsl:for-each>
				</wrs:ValueList>
			</rim:Slot>
		</xsl:if>
	</xsl:template>

	<!-- responsible party -->
	<xsl:template name="responsibleParty">
		<xsl:param name="sourceObject" select="concat('RM:', gmd:fileIdentifier/gco:CharacterString)"/>
		<xsl:param name="values"/>
		<!-- onyl contacts with none-emty organisation name should be mapped  -->
		<xsl:for-each select="$values[gmd:role/gmd:CI_RoleCode/@codeListValue = 'publisher']">
			<xsl:call-template name="organization">
				<xsl:with-param name="sourceObject" select="$sourceObject"/>
				<xsl:with-param name="role" select="'Publisher'"/>
			</xsl:call-template>
		</xsl:for-each>
		<xsl:for-each select="$values[gmd:role/gmd:CI_RoleCode/@codeListValue = 'originator']">
			<xsl:call-template name="organization">
				<xsl:with-param name="sourceObject" select="$sourceObject"/>
				<xsl:with-param name="role" select="'Originator'"/>
			</xsl:call-template>
		</xsl:for-each>
		<xsl:for-each select="$values[gmd:role/gmd:CI_RoleCode/@codeListValue = 'author']">
			<xsl:call-template name="organization">
				<xsl:with-param name="sourceObject" select="$sourceObject"/>
				<xsl:with-param name="role" select="'Author'"/>
			</xsl:call-template>
		</xsl:for-each>
		<xsl:for-each select="$values[gmd:role/gmd:CI_RoleCode/@codeListValue = 'pointOfContact']">
			<xsl:call-template name="organization">
				<xsl:with-param name="sourceObject" select="$sourceObject"/>
				<xsl:with-param name="role" select="'PointOfContact'"/>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>

	<!-- generic template for organization type + association -->
	<xsl:template name="organization">
		<xsl:param name="sourceObject"/>
		<xsl:param name="role"/>
		<xsl:variable name="targetObject" select="concat('OR:', $sourceObject, ':', $role)"/>
		<rim:Association id="{concat($targetObject, ':Association')}" objectType="urn:oasis:names:tc:ebxml-regrep:ObjectType:RegistryObject:Association" associationType="{concat('urn:ogc:def:associationType:OGC-CSW-ebRIM-CIM::', $role)}" sourceObject="{$sourceObject}" targetObject="{$targetObject}"/>
		<rim:Organization id="{$targetObject}" objectType="urn:oasis:names:tc:ebxml-regrep:ObjectType:RegistryObject:Organization">
			<rim:Name>
				<rim:LocalizedString xml:lang="{$lang}" value="{gmd:organisationName/gco:CharacterString}"/>
			</rim:Name>
			<rim:EmailAddress address="{gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:electronicMailAddress/gco:CharacterString}"/>
		</rim:Organization>
	</xsl:template>

	<!-- metadatInformation -->
	<xsl:template name="metadataInformation">
		<xsl:variable name="fileId" select="gmd:fileIdentifier/gco:CharacterString"/>
		<xsl:variable name="sourceObject" select="concat('RM:', gmd:fileIdentifier/gco:CharacterString)"/>
		<xsl:variable name="targetObject" select="concat('MI:', gmd:fileIdentifier/gco:CharacterString)"/>
		<rim:ExtrinsicObject id="{$targetObject}" objectType="urn:ogc:def:objectType:OGC-CSW-ebRIM-CIM::MetadataInformation">
			<xsl:call-template name="slot">
				<xsl:with-param name="name" select="'http://purl.org/dc/elements/1.1/Identifier'"/>
				<xsl:with-param name="values" select="$fileId"/>
			</xsl:call-template>
			<xsl:call-template name="slot">
				<xsl:with-param name="name" select="'http://purl.org/dc/elements/1.1/language'"/>
				<xsl:with-param name="values" select="gmd:language/gmd:LanguageCode/@codeListValue"/>
			</xsl:call-template>
			<xsl:call-template name="dateSlot">
				<xsl:with-param name="name" select="'http://purl.org/dc/elements/1.1/date'"/>
				<xsl:with-param name="values" select="gmd:dateStamp/gco:Date"/>
			</xsl:call-template>
			<xsl:call-template name="slot">
				<xsl:with-param name="name" select="'http://purl.org/dc/terms/conformsTo'"/>
				<xsl:with-param name="values" select="gmd:metadataStandardName/gco:CharacterString"/>
			</xsl:call-template>
			<xsl:call-template name="classification">
				<xsl:with-param name="classifiedObject" select="$targetObject"/>
				<xsl:with-param name="classificationScheme" select="'CharacterSet'"/>
				<xsl:with-param name="values" select="gmd:characterSet/gmd:MD_CharacterSetCode/@codeListValue"/>
			</xsl:call-template>
		</rim:ExtrinsicObject>
		<xsl:call-template name="classificationNode">
			<xsl:with-param name="classifiedObject" select="$targetObject"/>
			<xsl:with-param name="classificationScheme" select="'CharacterSet'"/>
			<xsl:with-param name="values" select="gmd:characterSet/gmd:MD_CharacterSetCode/@codeListValue"/>
		</xsl:call-template>
		<rim:Association id="{concat($targetObject, ':Association')}" objectType="urn:oasis:names:tc:ebxml-regrep:ObjectType:RegistryObject:Association" associationType="urn:ogc:def:associationType:OGC-CSW-ebRIM-CIM::ResourceMetadataInformation" sourceObject="{$sourceObject}" targetObject="{$targetObject}"/>
		<xsl:call-template name="metadatContact"/>
	</xsl:template>

	<!-- metadata cotact -->
	<xsl:template name="metadatContact">
		<xsl:variable name="sourceObject" select="concat('MI:', gmd:fileIdentifier/gco:CharacterString)"/>
		<!-- onyl contacts with none-emty organisation name should be mapped  -->
		<xsl:for-each select="gmd:contact/*[gmd:organisationName/gco:CharacterString != '' and gmd:role/gmd:CI_RoleCode/@codeListValue = 'publisher']">
			<xsl:call-template name="organization">
				<xsl:with-param name="sourceObject" select="$sourceObject"/>
				<xsl:with-param name="role" select="'Publisher'"/>
			</xsl:call-template>
		</xsl:for-each>
		<xsl:for-each select="gmd:contact/*[gmd:organisationName/gco:CharacterString != '' and gmd:role/gmd:CI_RoleCode/@codeListValue = 'originator']">
			<xsl:call-template name="organization">
				<xsl:with-param name="sourceObject" select="$sourceObject"/>
				<xsl:with-param name="role" select="'Originator'"/>
			</xsl:call-template>
		</xsl:for-each>
		<xsl:for-each select="gmd:contact/*[gmd:organisationName/gco:CharacterString != '' and gmd:role/gmd:CI_RoleCode/@codeListValue = 'author']">
			<xsl:call-template name="organization">
				<xsl:with-param name="sourceObject" select="$sourceObject"/>
				<xsl:with-param name="role" select="'Author'"/>
			</xsl:call-template>
		</xsl:for-each>
		<xsl:for-each select="gmd:contact/*[gmd:organisationName/gco:CharacterString != '' and gmd:role/gmd:CI_RoleCode/@codeListValue = 'pointOfContact']">
			<xsl:call-template name="organization">
				<xsl:with-param name="sourceObject" select="$sourceObject"/>
				<xsl:with-param name="role" select="'PointOfContact'"/>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>
	
	<!-- generates a single legal constraint extrinsic object + association -->
	<xsl:template name="legalConstraints">
		<xsl:param name="values" select="gmd:identificationInfo/*/gmd:resourceConstraints/gmd:MD_LegalConstraints"/>
		<xsl:variable name="fileId" select="gmd:fileIdentifier/gco:CharacterString"/>
		<xsl:if test="$values">
			<xsl:variable name="targetObject" select="concat('LC:', $fileId, ':', count($values))"/>
			<rim:Association id="{concat($targetObject, ':Association')}" objectType="urn:oasis:names:tc:ebxml-regrep:ObjectType:RegistryObject:Association" associationType="urn:ogc:def:associationType:OGC-CSW-ebRIM-CIM::ResourceConstraints" sourceObject="{concat('RM:', $fileId)}" targetObject="{$targetObject}"/>
			<rim:ExtrinsicObject id="{$targetObject}" objectType="urn:ogc:def:objectType:OGC-CSW-ebRIM-CIM::LegalConstraints">
				<xsl:call-template name="internationalSlot">
					<xsl:with-param name="name" select="'http://purl.org/dc/elements/1.1/abstract'"/>
					<xsl:with-param name="values" select="$values[1]/gmd:useLimitation/gco:CharacterString"/>
				</xsl:call-template>
				<xsl:call-template name="internationalSlot">
					<xsl:with-param name="name" select="'http://purl.org/dc/elements/1.1/rights'"/>
					<xsl:with-param name="values" select="$values[1]/gmd:otherConstraints/gco:CharacterString"/>
				</xsl:call-template>
				<xsl:call-template name="classification">
					<xsl:with-param name="classifiedObject" select="$targetObject"/>
					<xsl:with-param name="classificationScheme" select="'RestrictionCode'"/>
					<xsl:with-param name="values" select="$values[1]/gmd:accessConstraints/gmd:MD_RestrictionCode/@codeListValue"/>
				</xsl:call-template>
			</rim:ExtrinsicObject>
			<xsl:call-template name="classificationNode">
				<xsl:with-param name="classifiedObject" select="$targetObject"/>
				<xsl:with-param name="classificationScheme" select="'RestrictionCode'"/>
				<xsl:with-param name="values" select="$values[1]/gmd:accessConstraints/gmd:MD_RestrictionCode/@codeListValue"/>
			</xsl:call-template>
			<!-- recursive call to generate remaining constraints objects -->
			<xsl:call-template name="legalConstraints">
				<xsl:with-param name="fileId" select="$fileId"/>
				<xsl:with-param name="values" select="$values[position() &gt; 1]"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<!-- security constraints -->
	<xsl:template name="securityConstraints">
		<xsl:param name="values" select="gmd:identificationInfo/*/gmd:resourceConstraints/gmd:MD_SecurityConstraints"/>
		<xsl:variable name="fileId" select="gmd:fileIdentifier/gco:CharacterString"/>
		<xsl:if test="$values">
			<xsl:variable name="targetObject" select="concat('SC:', $fileId, ':', count($values))"/>
			<rim:Association id="{concat($targetObject, ':Association')}" objectType="urn:oasis:names:tc:ebxml-regrep:ObjectType:RegistryObject:Association" associationType="urn:ogc:def:associationType:OGC-CSW-ebRIM-CIM::ResourceConstraints" sourceObject="{concat('RM:', $fileId)}" targetObject="{$targetObject}"/>
			<rim:ExtrinsicObject id="{$targetObject}" objectType="urn:ogc:def:objectType:OGC-CSW-ebRIM-CIM::SecurityConstraints">
				<xsl:call-template name="internationalSlot">
					<xsl:with-param name="name" select="'http://purl.org/dc/elements/1.1/abstract'"/>
					<xsl:with-param name="values" select="$values[1]/gmd:useLimitation/gco:CharacterString"/>
				</xsl:call-template>
				<xsl:call-template name="classification">
					<xsl:with-param name="classifiedObject" select="$targetObject"/>
					<xsl:with-param name="classificationScheme" select="'ClassificationCode'"/>
					<xsl:with-param name="values" select="$values[1]/gmd:classification/gmd:MD_ClassificationCode/@codeListValue"/>
				</xsl:call-template>
			</rim:ExtrinsicObject>
			<xsl:call-template name="classificationNode">
				<xsl:with-param name="classifiedObject" select="$targetObject"/>
				<xsl:with-param name="classificationScheme" select="'ClassificationCode'"/>
				<xsl:with-param name="values" select="$values[1]/gmd:classification/gmd:MD_ClassificationCode/@codeListValue"/>
			</xsl:call-template>
			<!-- recursive call to generate remaining constraints objects -->
			<xsl:call-template name="securityConstraints">
				<xsl:with-param name="fileId" select="$fileId"/>
				<xsl:with-param name="values" select="$values[position() &gt; 1]"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
	
	<!-- reference system info -->
	<xsl:template name="referenceSystem">
		<xsl:param name="values" select="gmd:referenceSystemInfo/*/gmd:referenceSystemIdentifier/*"/>
		<xsl:variable name="fileId" select="gmd:fileIdentifier/gco:CharacterString"/>
		<xsl:if test="$values">
			<xsl:variable name="targetObject" select="concat('CS:', $fileId, ':', count($values))"/>
			<rim:Association id="{concat($targetObject, ':Association')}" objectType="urn:oasis:names:tc:ebxml-regrep:ObjectType:RegistryObject:Association" associationType="urn:ogc:def:associationType:OGC-CSW-ebRIM-CIM::ResourceReferenceSystem" sourceObject="{concat('RM:', $fileId)}" targetObject="{$targetObject}"/>
			<rim:ExtrinsicObject id="{$targetObject}" objectType="urn:ogc:def:objectType:OGC-CSW-ebRIM-CIM::IdentifiedItem">
				<rim:Name>
					<rim:LocalizedString xml:lang="{$lang}" value="{$values/gmd:code/gco:CharacterString}"/>
				</rim:Name>
			</rim:ExtrinsicObject>
			<!-- check if we need a codespace object -->
			<xsl:if test="$values/gmd:codeSpace/gco:CharacterString">
				<xsl:variable name="codespaceId" select="concat('CS:', $targetObject)"/>
				<rim:Association id="{concat($codespaceId, ':Association')}" objectType="urn:oasis:names:tc:ebxml-regrep:ObjectType:RegistryObject:Association" associationType="urn:ogc:def:associationType:OGC-CSW-ebRIM-CIM::CodeSpace" sourceObject="{$targetObject}" targetObject="{$codespaceId}"/>
				<rim:ExtrinsicObject id="{$codespaceId}" objectType="urn:ogc:def:objectType:OGC-CSW-ebRIM-CIM::IdentifiedItem">
					<rim:Name>
						<rim:LocalizedString xml:lang="{$lang}" value="{$values/gmd:codeSpace/gco:CharacterString}"/>
					</rim:Name>
				</rim:ExtrinsicObject>
				<xsl:call-template name="citedItem">
					<xsl:with-param name="sourceObject" select="$targetObject"/>
					<xsl:with-param name="assocType" select="'Auhority'"/>
					<xsl:with-param name="values" select="$values/gmd:authority/*"/>
				</xsl:call-template>
			</xsl:if>
			<!-- recursive call to generate remaining constraints objects -->
			<xsl:call-template name="referenceSystem">
				<xsl:with-param name="fileId" select="$fileId"/>
				<xsl:with-param name="values" select="$values[position() &gt; 1]"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<!-- create a cited item + association -->
	<xsl:template name="citedItem">
		<xsl:param name="sourceObject"/>
		<xsl:param name="assocType"/>
		<xsl:param name="values"/>
		<xsl:if test="$values">
			<xsl:variable name="targetObject" select="concat('CI:', $sourceObject)"/>
			<xsl:if test="$assocType">
				<rim:Association id="{concat($targetObject, ':Association')}" objectType="urn:oasis:names:tc:ebxml-regrep:ObjectType:RegistryObject:Association" associationType="{concat('urn:ogc:def:associationType:OGC-CSW-ebRIM-CIM::', $assocType)}" sourceObject="{$sourceObject}" targetObject="{$targetObject}"/>
			</xsl:if>
			<rim:ExtrinsicObject id="{$targetObject}" objectType="urn:ogc:def:objectType:OGC-CSW-ebRIM-CIM::CitedItem">
				<rim:Name>
					<rim:LocalizedString xml:lang="{$lang}" value="{$values/gmd:title/gco:CharacterString | $values/gmd:title/gmx:Anchor}"/>
				</rim:Name>
				<xsl:call-template name="internationalSlot">
					<xsl:with-param name="name" select="'http://purl.org/dc/terms/title'"/>
					<xsl:with-param name="values" select="$values/gmd:alternateTitle/gco:CharacterString"/>
				</xsl:call-template>
				<xsl:call-template name="dateSlot">
					<xsl:with-param name="name" select="'http://purl.org/dc/terms/created'"/>
					<xsl:with-param name="values" select="$values/gmd:date/gmd:CI_Date[gmd:dateType/gmd:CI_DateTypeCode/@codeListValue = 'creation']/gmd:date/gco:Date"/>
				</xsl:call-template>
				<xsl:call-template name="dateSlot">
					<xsl:with-param name="name" select="'http://purl.org/dc/terms/issued'"/>
					<xsl:with-param name="values" select="$values/gmd:date/gmd:CI_Date[gmd:dateType/gmd:CI_DateTypeCode/@codeListValue = 'publication']/gmd:date/gco:Date"/>
				</xsl:call-template>
				<xsl:call-template name="dateSlot">
					<xsl:with-param name="name" select="'http://purl.org/dc/terms/modified'"/>
					<xsl:with-param name="values" select="$values/gmd:date/gmd:CI_Date[gmd:dateType/gmd:CI_DateTypeCode/@codeListValue = 'revision']/gmd:date/gco:Date"/>
				</xsl:call-template>
				<!-- SMAAD URL extension for cited item -->
				<!-- TODO: slot name -->
				<xsl:call-template name="slot">
					<xsl:with-param name="name" select="'urn:ogc:def:slot:OGC-CSW-ebRIM-CIM::url'"/>
					<xsl:with-param name="values" select="$values/gmd:title/gmx:Anchor/@xlink:href"/>
				</xsl:call-template>
			</rim:ExtrinsicObject>
			<xsl:call-template name="responsibleParty">
				<xsl:with-param name="sourceObject" select="$targetObject"/>
				<xsl:with-param name="values" select="$values/gmd:citedResponsibleParty/*"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<!-- graphic overview -->
	<xsl:template name="graphicOverview">
		<xsl:param name="values" select="gmd:identificationInfo/*/gmd:graphicOverview/*"/>
		<xsl:variable name="fileId" select="gmd:fileIdentifier/gco:CharacterString"/>
		<xsl:if test="$values">
			<xsl:variable name="targetObject" select="concat('GO:', $fileId, ':', count($values))"/>
			<rim:Association id="{concat($targetObject, ':Association')}" objectType="urn:oasis:names:tc:ebxml-regrep:ObjectType:RegistryObject:Association" associationType="urn:ogc:def:associationType:OGC-CSW-ebRIM-CIM::GraphicOverview" sourceObject="{concat('RM:', $fileId)}" targetObject="{$targetObject}"/>
			<rim:ExtrinsicObject id="{$targetObject}" objectType="urn:ogc:def:objectType:OGC-CSW-ebRIM-CIM::Image">
				<rim:Name>
					<rim:LocalizedString xml:lang="{$lang}" value="{$values[1]/gmd:fileName/gco:CharacterString}"/>
				</rim:Name>
			</rim:ExtrinsicObject>
			<xsl:call-template name="graphicOverview">
				<xsl:with-param name="values" select="$values[position() &gt; 1]"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
	
	<!-- reference specification -->
	<xsl:template name="referenceSpecification">
		<xsl:param name="values" select="gmd:dataQualityInfo/*/gmd:report/*/gmd:result/gmd:DQ_ConformanceResult"/>
		<xsl:variable name="fileId" select="gmd:fileIdentifier/gco:CharacterString"/>
		<xsl:if test="$values">
			<xsl:variable name="targetObject" select="concat('RS:', $fileId, ':', count($values))"/>
			<rim:Association id="{concat($targetObject, ':Association')}" objectType="urn:oasis:names:tc:ebxml-regrep:ObjectType:RegistryObject:Association" associationType="urn:ogc:def:associationType:OGC-CSW-ebRIM-CIM::Specification" sourceObject="{concat('RM:', $fileId)}" targetObject="{$targetObject}"/>
			<rim:ExtrinsicObject id="{$targetObject}" objectType="urn:ogc:def:objectType:OGC-CSW-ebRIM-CIM::ReferenceSpecification">
				<rim:Name>
					<rim:LocalizedString xml:lang="{$lang}" value="{$values/gmd:specification/gmd:CI_Citation/gmd:title/gco:CharacterString}"/>
				</rim:Name>
				<!-- TODO: datatype internat. string or boolean? -->
				<rim:Slot name="'urn:ogc:def:slot:OGC-CSW-ebRIM-CIM::Conformance'" slotType="urn:oasis:names:tc:ebxml-regrep:DataType:Boolean">
					<rim:ValueList>
						<rim:Value><xsl:value-of select="$values/gmd:pass/gco:Boolean"/></rim:Value>
					</rim:ValueList>
				</rim:Slot>
				<xsl:call-template name="internationalSlot">
					<!-- TODO: is slot name correct? -->
					<xsl:with-param name="name" select="'http://purl.org/dc/terms/title'"/>
					<xsl:with-param name="values" select="$values/gmd:specification/gmd:CI_Citation/gmd:alternateTitle/gco:CharacterString"/>
				</xsl:call-template>
				<xsl:call-template name="dateSlot">
					<xsl:with-param name="name" select="'http://purl.org/dc/terms/created'"/>
					<xsl:with-param name="values" select="$values/gmd:specification/gmd:CI_Citation/gmd:date/gmd:CI_Date[gmd:dateType/gmd:CI_DateTypeCode/@codeListValue = 'creation']/gmd:date/gco:Date"/>
				</xsl:call-template>
				<xsl:call-template name="dateSlot">
					<xsl:with-param name="name" select="'http://purl.org/dc/terms/issued'"/>
					<xsl:with-param name="values" select="$values/gmd:specification/gmd:CI_Citation/gmd:date/gmd:CI_Date[gmd:dateType/gmd:CI_DateTypeCode/@codeListValue = 'publication']/gmd:date/gco:Date"/>
				</xsl:call-template>
				<xsl:call-template name="dateSlot">
					<xsl:with-param name="name" select="'http://purl.org/dc/terms/modified'"/>
					<xsl:with-param name="values" select="$values/gmd:specification/gmd:CI_Citation/gmd:date/gmd:CI_Date[gmd:dateType/gmd:CI_DateTypeCode/@codeListValue = 'revision']/gmd:date/gco:Date"/>
				</xsl:call-template>
			</rim:ExtrinsicObject>
			<xsl:call-template name="responsibleParty">
				<xsl:with-param name="sourceObject" select="$targetObject"/>
				<xsl:with-param name="values" select="$values/gmd:specification/gmd:CI_Citation/gmd:citedResponsibleParty/*"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
	
	<!-- parent identifier -->
	<xsl:template name="parentIdentifier">
		<xsl:param name="values" select="gmd:parentIdentifier/gco:CharacterString"/>
		<xsl:variable name="fileId" select="gmd:fileIdentifier/gco:CharacterString"/>
		<xsl:if test="$values">
			<xsl:choose>
				<xsl:when test="//gmd:fileIdentifier/gco:CharacterString[text() = $values[1]]">
					<!-- there is a parent metedata set present in the results -->
					<xsl:variable name="targetObject" select="concat('MI:', $fileId)"/>
					<rim:Association id="{concat($targetObject, ':Association')}" objectType="urn:oasis:names:tc:ebxml-regrep:ObjectType:RegistryObject:Association" associationType="urn:ogc:def:associationType:OGC-CSW-ebRIM-CIM::ParentMetadataInformation" sourceObject="{concat('RM:', $fileId)}" targetObject="{$targetObject}"/>
				</xsl:when>
				<xsl:otherwise>
					<!-- no parent metadataset present, create a matching metadata information object-->
					<xsl:variable name="targetObject" select="concat('PI:', $fileId)"/>
					<rim:Association id="{concat($targetObject, ':Association')}" objectType="urn:oasis:names:tc:ebxml-regrep:ObjectType:RegistryObject:Association" associationType="urn:ogc:def:associationType:OGC-CSW-ebRIM-CIM::ParentMetadataInformation" sourceObject="{concat('RM:', $fileId)}" targetObject="{$targetObject}"/>
					<rim:ExtrinsicObject id="{$targetObject}" objectType="urn:ogc:def:objectType:OGC-CSW-ebRIM-CIM::MetadataInformation">
						<xsl:call-template name="slot">
							<xsl:with-param name="name" select="'http://purl.org/dc/elements/1.1/identifier'"/>
							<xsl:with-param name="values" select="$values[1]"/>
						</xsl:call-template>
					</rim:ExtrinsicObject>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>

	<!-- calls a template to generate classifications for the keywords in a thesaurus -->
	<xsl:template name="thesaurusClassifications">
		<!-- ID of the classified object -->
		<xsl:param name="classifiedObject"/>
		<!-- nodeset with values to generate classifications for -->
		<xsl:param name="values"/>
		<xsl:if test="$values">
			<xsl:variable name="thesaurus" select="concat($classifiedObject, 'Thesaurus', ':', count($values))"/>
			<xsl:call-template name="thesaurusClassification">
				<xsl:with-param name="classifiedObject" select="$classifiedObject"/>
				<xsl:with-param name="values" select="$values[1]/../gmd:keyword/*"/>
				<xsl:with-param name="thesaurus" select="$thesaurus"/>
			</xsl:call-template>
			<!-- recursive call to this template for remaining nodes requiering classification -->
			<xsl:call-template name="thesaurusClassifications">
				<xsl:with-param name="classifiedObject" select="$classifiedObject"/>
				<xsl:with-param name="values" select="$values[position() &gt; 1]"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
	
	<!-- generates classifications for the keywords in a thesaurus -->
	<xsl:template name="thesaurusClassification">
		<!-- ID of the classified object -->
		<xsl:param name="classifiedObject"/>
		<!-- nodeset with values to generate classifications for -->
		<xsl:param name="values"/>
		<!-- ID of thesaurus -->
		<xsl:param name="thesaurus"/>
		<xsl:if test="$values">
			<rim:Classification id="{concat($thesaurus, 'Classification', ':', count($values))}"
				objectType="urn:oasis:names:tc:ebxml-regrep:ObjectType:RegistryObject:Classification"
				classifiedObject="{$classifiedObject}"
				classificationNode="{concat($thesaurus, ':', 'ClassificationNode', ':', count($values))}"
				classificationScheme="urn:ogc:def:classificationScheme:OGC-CSW-ebRIM-CIM::KeywordScheme"/>
			<!-- recursive call to this template for remaining nodes requiering classification -->
			<xsl:call-template name="thesaurusClassification">
				<xsl:with-param name="classifiedObject" select="$classifiedObject"/>
				<xsl:with-param name="thesaurus" select="$thesaurus"/>
				<xsl:with-param name="values" select="$values[position() &gt; 1]"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<!-- generates a cited item for each keyword thesaurus -->
	<xsl:template name="thesaurus">
		<!-- ID of the classified object -->
		<xsl:param name="classifiedObject"/>
		<!-- nodeset with values to generate classifications for -->
		<xsl:param name="values"/>
		<xsl:if test="$values">
			<!-- create cited item for thesaurus -->
			<xsl:variable name="citedItem" select="concat($classifiedObject, 'Thesaurus', ':', count($values))"/>
			<!-- call citedItem without association, we want all keywords in this thesaurus to refrence one cited item -->
			<xsl:call-template name="citedItem">
				<xsl:with-param name="sourceObject" select="$citedItem"/>
				<xsl:with-param name="values" select="$values[1]/*"/>
			</xsl:call-template>
			<!-- now create nodes for each keyword -->
			<xsl:call-template name="thesaurusClassificationNode">
				<xsl:with-param name="classifiedObject" select="$classifiedObject"/>
				<xsl:with-param name="values" select="$values[1]/../gmd:keyword/*"/>
				<xsl:with-param name="thesaurus" select="$citedItem"/>
			</xsl:call-template>
			<!-- recursive call to this template for remaining nodes requiering classification -->
			<xsl:call-template name="thesaurus">
				<xsl:with-param name="classifiedObject" select="$classifiedObject"/>
				<xsl:with-param name="values" select="$values[position() &gt; 1]"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
	
	<!-- generates a classification node for a keyword in a thesaurus -->
	<xsl:template name="thesaurusClassificationNode">
		<!-- ID of the classified object -->
		<xsl:param name="classifiedObject"/>
		<!-- nodeset with values to generate classifications for -->
		<xsl:param name="values"/>
		<!-- ID of thesaurus -->
		<xsl:param name="thesaurus"/>		
		<xsl:if test="$values">
			<xsl:variable name="classificationNode" select="concat($thesaurus, ':', 'ClassificationNode', ':', count($values))"/>
			<rim:Association id="{concat($thesaurus, ':', count($values), ':Association')}" objectType="urn:oasis:names:tc:ebxml-regrep:ObjectType:RegistryObject:Association" associationType="urn:ogc:def:associationType:OGC-CSW-ebRIM-CIM::Thesaurus" sourceObject="{$classificationNode}" targetObject="{concat('CI:', $thesaurus)}"/>
			<rim:ClassificationNode id="{$classificationNode}" objectType="urn:oasis:names:tc:ebxml-regrep:ObjectType:RegistryObject:ClassificationNode" code="{$values[1]}" parent="urn:ogc:def:classificationScheme:OGC-CSW-ebRIM-CIM::KeywordScheme">
				<rim:Name>
					<rim:LocalizedString xml:lang="{$lang}" value="{$values[1]}"/>
				</rim:Name>
				<!-- TODO: slot name -->
				<xsl:call-template name="slot">
					<xsl:with-param name="name" select="'urn:ogc:def:slot:OGC-CSW-ebRIM-CIM::url'"/>
					<xsl:with-param name="values" select="$values[1]/@xlink:href"/>
				</xsl:call-template>
			</rim:ClassificationNode>
			<!-- recursive call to this template for remaining nodes requiering classification -->
			<xsl:call-template name="thesaurusClassificationNode">
				<xsl:with-param name="classifiedObject" select="$classifiedObject"/>
				<xsl:with-param name="thesaurus" select="$thesaurus"/>
				<xsl:with-param name="values" select="$values[position() &gt; 1]"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<!-- generic template for classifications -->
	<xsl:template name="classification">
		<!-- ID of the classified object -->
		<xsl:param name="classifiedObject"/>
		<!-- name of the classification scheme -->
		<xsl:param name="classificationScheme"/>
		<!-- nodeset with values to generate classifications for -->
		<xsl:param name="values"/>
		<xsl:if test="$values">
			<rim:Classification id="{concat($classifiedObject, $classificationScheme, 'Classification', ':', count($values))}"
				objectType="urn:oasis:names:tc:ebxml-regrep:ObjectType:RegistryObject:Classification"
				classifiedObject="{$classifiedObject}"
				classificationNode="{concat($classifiedObject, $classificationScheme, 'ClassificationNode', ':', count($values))}"
				classificationScheme="{concat('urn:ogc:def:classificationScheme:OGC-CSW-ebRIM-CIM::', $classificationScheme)}"/>
			<!-- recursive call to this template for remaining nodes requiering classification -->
			<xsl:call-template name="classification">
				<xsl:with-param name="classifiedObject" select="$classifiedObject"/>
				<xsl:with-param name="classificationScheme" select="$classificationScheme"/>
				<xsl:with-param name="values" select="$values[position() &gt; 1]"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
	
	<!-- generic template for classification nodes -->
	<xsl:template name="classificationNode">
		<!-- ID of the classified object -->
		<xsl:param name="classifiedObject"/>
		<!-- name of the classification scheme -->
		<xsl:param name="classificationScheme"/>
		<!-- nodeset with values to generate classifications for -->
		<xsl:param name="values"/>
		<xsl:if test="$values">
			<rim:ClassificationNode id="{concat($classifiedObject, $classificationScheme, 'ClassificationNode', ':', count($values))}" objectType="urn:oasis:names:tc:ebxml-regrep:ObjectType:RegistryObject:ClassificationNode" code="{$values[1]}" parent="{concat('urn:ogc:def:classificationScheme:OGC-CSW-ebRIM-CIM::', $classificationScheme)}">
				<rim:Name>
					<rim:LocalizedString xml:lang="{$lang}" value="{$values[1]}"/>
				</rim:Name>
			</rim:ClassificationNode>
			<!-- recursive call to this template for remaining nodes requiering classification -->
			<xsl:call-template name="classificationNode">
				<xsl:with-param name="classifiedObject" select="$classifiedObject"/>
				<xsl:with-param name="classificationScheme" select="$classificationScheme"/>
				<xsl:with-param name="values" select="$values[position() &gt; 1]"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<!-- generic template for slot of integer type -->
	<xsl:template name="integerSlot">
		<xsl:param name="name"/>
		<xsl:param name="values"/>
		<xsl:if test="$values">
			<rim:Slot name="{$name}" slotType="urn:oasis:names:tc:ebxml-regrep:DataType:Integer">
				<rim:ValueList>
					<xsl:for-each select="$values">
						<rim:Value><xsl:value-of select="$values"/></rim:Value>
					</xsl:for-each>
				</rim:ValueList>
			</rim:Slot>
		</xsl:if>
	</xsl:template>

	<!-- generic template for slot of date type -->
	<xsl:template name="dateSlot">
		<xsl:param name="name"/>
		<xsl:param name="values"/>
		<xsl:if test="$values">
			<rim:Slot name="{$name}" slotType="urn:oasis:names:tc:ebxml-regrep:DataType:DateTime">
				<rim:ValueList>
					<xsl:for-each select="$values">
						<rim:Value><xsl:value-of select="$values"/></rim:Value>
					</xsl:for-each>
				</rim:ValueList>
			</rim:Slot>
		</xsl:if>
	</xsl:template>

	<!-- generic template for slot of international string type -->
	<xsl:template name="internationalSlot">
		<xsl:param name="name"/>
		<xsl:param name="values"/>
		<xsl:if test="$values">
			<rim:Slot name="{$name}" slotType="urn:oasis:names:tc:ebxmlregrep:DataType:InternationalString">
				<wrs:ValueList>
					<xsl:for-each select="$values">
						<wrs:AnyValue>
							<rim:InternationalString>
								<rim:LocalizedString xml:lang="{$lang}" value="{$values}"/>
							</rim:InternationalString>
						</wrs:AnyValue>
					</xsl:for-each>
				</wrs:ValueList>
			</rim:Slot>
		</xsl:if>
	</xsl:template>

	<!-- generic template for slot of string type -->
	<xsl:template name="slot">
		<xsl:param name="name"/>
		<xsl:param name="values"/>
		<xsl:if test="$values">
			<rim:Slot name="{$name}" slotType="rn:oasis:names:tc:ebxmlregrep:DataType:InternationalString">
				<rim:ValueList>
					<xsl:for-each select="$values">
						<rim:Value><xsl:value-of select="$values"/></rim:Value>
					</xsl:for-each>
				</rim:ValueList>
			</rim:Slot>
		</xsl:if>
	</xsl:template>

	<!-- identity transform for all remaining objects -->
	<xsl:template match="node()|@*">
		<xsl:copy>
			<xsl:apply-templates select="node()|@*"/>
		</xsl:copy>
	</xsl:template>

</xsl:stylesheet>

<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
Transforms a CIM EP request to an ISO AP request.

 Author: Udo Einspanier, con terra GmbH
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:gmd="http://www.isotc211.org/2005/gmd" xmlns:gco="http://www.isotc211.org/2005/gco" xmlns:srv="http://www.isotc211.org/2005/srv" xmlns:gml="http://www.opengis.net/gml" xmlns:csw="http://www.opengis.net/cat/csw/2.0.2" xmlns:ogc="http://www.opengis.net/ogc" xmlns:ows="http://www.opengis.net/ows" xmlns:rim="urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0" xmlns:wrs="http://www.opengis.net/cat/wrs/1.0" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:soap12="http://www.w3.org/2003/05/soap-envelope" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:gmx="http://www.isotc211.org/2005/gmx" xmlns:xlink="http://www.w3.org/1999/xlink">

	<xsl:output method="xml" encoding="utf-8"/>

	<!-- we need the request document to determine the correct response - we get a GetReocrdsResponse for GetRecords, GetRecordById and GetRepositoryItem requests -->
	<xsl:variable name="requestDoc" select="document('requestDoc.xml')"/>

	<!-- remove schema location to avoid validation errors -->
	<xsl:template match="@xsi:schemaLocation"/>

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
	<xsl:template match="*[@objectType = 'urn:ogc:def:objectType:OGC-CSW-ebRIM-CIM::DataMetadata' or @objectType = 'urn:ogc:def:objectType:OGC-CSW-ebRIM-CIM::ServiceMetadata']">
		<xsl:variable name="elementSet" select="$requestDoc//csw:ElementSetName/text()"/>
		<xsl:variable name="rmId" select="@id"/>
		<gmd:MD_Metadata>
			<gmd:fileIdentifier>
				<gco:CharacterString><xsl:call-template name="identifierValue"/></gco:CharacterString>
			</gmd:fileIdentifier>
			<xsl:if test="$elementSet != 'brief'">
				<gmd:language>
					<gco:CharacterString><xsl:call-template name="mdLanguageValue"/></gco:CharacterString>
				</gmd:language>
				<gmd:characterSet>
					<gmd:MD_CharacterSetCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/ML_gmxCodelists.xml#MD_CharacterSetCode" codeListValue="utf8"/>
				</gmd:characterSet>
			</xsl:if>
			<gmd:hierarchyLevel>
				<gmd:MD_ScopeCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/ML_gmxCodelists.xml#MD_ScopeCode">
					<xsl:call-template name="hierarchyLevelValue"/>
				</gmd:MD_ScopeCode>
			</gmd:hierarchyLevel>
			<xsl:call-template name="mdContact"/>
			<gmd:contact/>
			<gmd:dateStamp>
				<gco:Date><xsl:call-template name="dateStampValue"/></gco:Date>
			</gmd:dateStamp>
			<xsl:if test="$elementSet != 'brief'">
				<gmd:metadataStandardName>
					<gco:CharacterString>ISO19115</gco:CharacterString>
				</gmd:metadataStandardName>
				<gmd:metadataStandardVersion>
					<gco:CharacterString>2003/Cor.1:2006</gco:CharacterString>
				</gmd:metadataStandardVersion>
			</xsl:if>
			<xsl:apply-templates select="../rim:Association[@sourceObject=$rmId and @associationType='urn:ogc:def:associationType:OGC-CSW-ebRIM-CIM::ResourceReferenceSystem']" mode="assoc"/>
			<gmd:identificationInfo>
				<xsl:choose>
					<xsl:when test="@objectType = 'urn:ogc:def:objectType:OGC-CSW-ebRIM-CIM::ServiceMetadata'">
						<srv:SV_ServiceIdentification>
							<gmd:citation>
								<xsl:call-template name="citation">
									<xsl:with-param name="elementSet" select="$elementSet"/>
								</xsl:call-template>
							</gmd:citation>
							<gmd:abstract>
								<gco:CharacterString><xsl:value-of select="rim:Name/rim:LocalizedString/@value"/></gco:CharacterString>
							</gmd:abstract>
							<xsl:if test="$elementSet != 'brief'">
								<xsl:call-template name="pointOfContact"/>
							</xsl:if>
							<gmd:graphicOverview>
								<gmd:MD_BrowseGraphic>
									<gmd:fileName>
										<gco:CharacterString><xsl:call-template name="browseGraphic"/></gco:CharacterString>
									</gmd:fileName>
								</gmd:MD_BrowseGraphic>
							</gmd:graphicOverview>
							<xsl:if test="$elementSet = 'full'">
								<xsl:apply-templates select="rim:Classification[@classifiedObject = $rmId and @classificationScheme='urn:ogc:def:classificationScheme:OGC-CSW-ebRIM-CIM::KeywordScheme']" mode="cls"/>
							</xsl:if>
							<xsl:if test="$elementSet != 'brief'">
								<xsl:apply-templates select="../rim:Association[@associationType = 'urn:ogc:def:associationType:OGC-CSW-ebRIM-CIM::ResourceConstraints' and @sourceObject = $rmId]" mode="assoc"/>
							</xsl:if>
							<!-- TODO: service type, service type version -->
						</srv:SV_ServiceIdentification>
					</xsl:when>
					<xsl:otherwise>
						<gmd:MD_DataIdentification>
							<gmd:citation>
								<xsl:call-template name="citation">
									<xsl:with-param name="elementSet" select="$elementSet"/>
								</xsl:call-template>
							</gmd:citation>
							<gmd:abstract>
								<gco:CharacterString><xsl:value-of select="rim:Name/rim:LocalizedString/@value"/></gco:CharacterString>
							</gmd:abstract>
							<xsl:if test="$elementSet != 'brief'">
								<xsl:call-template name="pointOfContact"/>
							</xsl:if>
							<gmd:graphicOverview>
								<gmd:MD_BrowseGraphic>
									<gmd:fileName>
										<gco:CharacterString><xsl:call-template name="browseGraphic"/></gco:CharacterString>
									</gmd:fileName>
								</gmd:MD_BrowseGraphic>
							</gmd:graphicOverview>
							<xsl:if test="$elementSet = 'full'">
								<xsl:apply-templates select="rim:Classification[@classifiedObject = $rmId and @classificationScheme='urn:ogc:def:classificationScheme:OGC-CSW-ebRIM-CIM::KeywordScheme']" mode="cls"/>
							</xsl:if>
							<xsl:if test="$elementSet != 'brief'">
								<xsl:apply-templates select="../rim:Association[@associationType = 'urn:ogc:def:associationType:OGC-CSW-ebRIM-CIM::ResourceConstraints' and @sourceObject = $rmId]" mode="assoc"/>
							</xsl:if>
		<!--
							<gmd:spatialRepresentationType>
								<gmd:MD_SpatialRepresentationTypeCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/ML_gmxCodelists.xml#MD_SpatialRepresentationTypeCode" codeListValue="vector"/>
							</gmd:spatialRepresentationType>
		-->
							<xsl:if test="$elementSet != 'brief'">
								<xsl:apply-templates select="rim:Slot[@name = 'urn:ogc:def:slot:OGC-CSW-ebRIM-CIM::Resolution']/wrs:ValueList/wrs:AnyValue/gml:measure"/>
								<xsl:apply-templates select="rim:Slot[@name= 'urn:ogc:def:slot:OGC-CSW-ebRIM-CIM::ScaleDenominator']/rim:ValueList/rim:Value"/>
							</xsl:if>
							<gmd:language>
								<gco:CharacterString><xsl:value-of select="rim:Slot[@name= 'http://purl.org/dc/elements/1.1/language']/rim:ValueList/rim:Value"/></gco:CharacterString>
							</gmd:language>
							<xsl:apply-templates select="rim:Classification[@classifiedObject = $rmId and @classificationScheme='urn:ogc:def:classificationScheme:OGC-CSW-ebRIM-CIM::TopicCategory']"/>
							<xsl:apply-templates select="rim:Slot[@name= 'urn:ogc:def:slot:OGC-CSW-ebRIM-CIM::Envelope']/wrs:ValueList/wrs:AnyValue/gml:Envelope"/>
							<xsl:apply-templates select="rim:Slot[@name= 'http://purl.org/dc/terms/temporal']/wrs:ValueList/wrs:AnyValue/gml:TimePeriod"/>
						</gmd:MD_DataIdentification>
					</xsl:otherwise>
				</xsl:choose>
			</gmd:identificationInfo>
			<xsl:if test="$elementSet = 'full'">
				<xsl:apply-templates select="rim:Slot[@name= 'urn:ogc:def:slot:OGC-CSW-ebRIM-CIM::Lineage']/wrs:ValueList/wrs:AnyValue/rim:InternationalString/rim:LocalizedString/@value"/>
				<xsl:apply-templates select="../rim:Association[@associationType = 'urn:ogc:def:associationType:OGC-CSW-ebRIM-CIM::Specification' and @sourceObject = $rmId]" mode="assoc"/>
			</xsl:if>
		</gmd:MD_Metadata>
	</xsl:template>
	
	<!-- lineage -->
	<xsl:template match="rim:Slot[@name= 'urn:ogc:def:slot:OGC-CSW-ebRIM-CIM::Lineage']/wrs:ValueList/wrs:AnyValue/rim:InternationalString/rim:LocalizedString/@value">
		<gmd:dataQualityInfo>
			<gmd:DQ_DataQuality>
				<!-- scope is not clear -->
				<gmd:scope/>
				<gmd:lineage>
					<gmd:LI_Lineage>
						<gmd:statement>
							<gco:CharacterString><xsl:value-of select="."/></gco:CharacterString>
						</gmd:statement>
					</gmd:LI_Lineage>
				</gmd:lineage>
			</gmd:DQ_DataQuality>
		</gmd:dataQualityInfo>
	</xsl:template>
	
	<!-- reference system -->
	<xsl:template match="rim:Association[@associationType='urn:ogc:def:associationType:OGC-CSW-ebRIM-CIM::ResourceReferenceSystem']" mode="assoc">
		<xsl:variable name="targetObject" select="@targetObject"/>
		<xsl:apply-templates select="../rim:ExtrinsicObject[@id = $targetObject]" mode="referenceSystem"/>
	</xsl:template>
	
	<!-- reference system -->
	<xsl:template match="rim:ExtrinsicObject" mode="referenceSystem">
		<gmd:referenceSystemInfo>
			<gmd:MD_ReferenceSystem>
				<gmd:referenceSystemIdentifier>
					<gmd:RS_Identifier>
						<gmd:code>
							<gco:CharacterString><xsl:value-of select="rim:Name/rim:LocalizedString/@value"/></gco:CharacterString>
						</gmd:code>
						<xsl:variable name="sourceObject" select="@id"/>
						<xsl:apply-templates select="../rim:Association[@sourceObject=$sourceObject and @associationType='urn:ogc:def:associationType:OGC-CSW-ebRIM-CIM::CodeSpace']" mode="assoc"/>
					</gmd:RS_Identifier>
				</gmd:referenceSystemIdentifier>
			</gmd:MD_ReferenceSystem>
		</gmd:referenceSystemInfo>
	</xsl:template>

	<!-- reference system code space -->
	<xsl:template match="rim:Association[@associationType = 'urn:ogc:def:associationType:OGC-CSW-ebRIM-CIM::CodeSpace']" mode="assoc">
		<xsl:variable name="targetObject" select="@targetObject"/>
		<xsl:apply-templates select="../rim:ExtrinsicObject[@id = $targetObject]" mode="codeSpace"/>
	</xsl:template>

	<!-- reference system code space -->
	<xsl:template match="rim:ExtrinsicObject" mode="codeSpace">
		<gmd:codeSpace>
			<gco:CharacterString><xsl:value-of select="rim:Name/rim:LocalizedString/@value"/></gco:CharacterString>
		</gmd:codeSpace>
	</xsl:template>

	<!-- reference specification -->
	<xsl:template match="rim:Association[@associationType = 'urn:ogc:def:associationType:OGC-CSW-ebRIM-CIM::Specification']" mode="assoc">
		<xsl:variable name="targetObject" select="@targetObject"/>
		<xsl:apply-templates select="../rim:ExtrinsicObject[@id = $targetObject]" mode="assoc"/>
	</xsl:template>
	
	<!-- reference specification -->
	<xsl:template match="rim:ExtrinsicObject[@objectType = 'urn:ogc:def:objectType:OGC-CSW-ebRIM-CIM::ReferenceSpecification']" mode="assoc">
		<gmd:dataQualityInfo>
			<gmd:DQ_DataQuality>
				<gmd:scope/>
				<gmd:report>
					<gmd:DQ_ConceptualConsistency>
						<gmd:result>
							<gmd:DQ_ConformanceResult>
								<gmd:specification>
									<xsl:call-template name="citation"/>
								</gmd:specification>
								<gmd:explanation>
									<gco:CharacterString/>
								</gmd:explanation>
								<gmd:pass>
									<gco:Boolean><xsl:value-of select="rim:Slot[@name='urn:ogc:def:slot:OGC-CSW-ebRIM-CIM::Conformance']/rim:ValueList/rim:Value"/></gco:Boolean>
								</gmd:pass>
							</gmd:DQ_ConformanceResult>
						</gmd:result>
					</gmd:DQ_ConceptualConsistency>
				</gmd:report>
			</gmd:DQ_DataQuality>
		</gmd:dataQualityInfo>
	</xsl:template>

	<!-- creates a citation -->
	<xsl:template name="citation">
		<xsl:param name="elementSet">full</xsl:param>
		<gmd:CI_Citation>
			<gmd:title>
				<xsl:choose>
					<xsl:when test="rim:Slot[@name='urn:ogc:def:slot:OGC-CSW-ebRIM-CIM::url']">
						<gmx:Anchor xlink:href="{rim:Slot[@name='urn:ogc:def:slot:OGC-CSW-ebRIM-CIM::url']/rim:ValueList/rim:Value}"><xsl:value-of select="rim:Name/rim:LocalizedString/@value"/></gmx:Anchor>
					</xsl:when>
					<xsl:otherwise>
						<gco:CharacterString><xsl:value-of select="rim:Name/rim:LocalizedString/@value"/></gco:CharacterString>
					</xsl:otherwise>
				</xsl:choose>
			</gmd:title>
			<gmd:alternateTitle>
				<gco:CharacterString><xsl:value-of select="rim:Slot[@name = 'http://purl.org/dc/terms/title']"/></gco:CharacterString>
			</gmd:alternateTitle>
			<xsl:apply-templates select="rim:Slot[@name = 'http://purl.org/dc/terms/created']"/>
			<xsl:if test="$elementSet != 'brief'">
				<xsl:apply-templates select="rim:Slot[@name = 'http://purl.org/dc/terms/modified']"/>
			</xsl:if>
			<xsl:if test="$elementSet = 'full'">
				<xsl:apply-templates select="rim:Slot[@name = 'http://purl.org/dc/terms/issued']"/>
			</xsl:if>
			<xsl:if test="$elementSet != 'brief'">
				<gmd:identifier>
					<gmd:MD_Identifier>
						<gmd:code>
							<gco:CharacterString><xsl:value-of select="rim:ExternalIdentifier/@value"/></gco:CharacterString>
						</gmd:code>
					</gmd:MD_Identifier>
				</gmd:identifier>
			</xsl:if>
		</gmd:CI_Citation>
	</xsl:template>

	<!-- identifier -->
	<xsl:template name="identifierValue">
		<xsl:variable name="rmId" select="@id"/>
		<xsl:variable name="targetObject" select="../rim:Association[@associationType = 'urn:ogc:def:associationType:OGC-CSW-ebRIM-CIM::ResourceMetadataInformation' and @sourceObject = $rmId]/@targetObject"/>
		<xsl:value-of select="../rim:ExtrinsicObject[@id = $targetObject]/rim:Slot[@name = 'http://purl.org/dc/elements/1.1/Identifier']/rim:ValueList/rim:Value"/>
	</xsl:template>

	<!-- metadata language -->
	<xsl:template name="mdLanguageValue">
		<xsl:variable name="rmId" select="@id"/>
		<xsl:variable name="targetObject" select="../rim:Association[@associationType = 'urn:ogc:def:associationType:OGC-CSW-ebRIM-CIM::ResourceMetadataInformation' and @sourceObject = $rmId]/@targetObject"/>
		<xsl:value-of select="../rim:ExtrinsicObject[@id = $targetObject]/rim:Slot[@name = 'http://purl.org/dc/elements/1.1/language']/rim:ValueList/rim:Value"/>
	</xsl:template>
	
	<!-- hierarchy level -->
	<xsl:template name="hierarchyLevelValue">
		<xsl:attribute name="codeListValue">
			<xsl:choose>
				<xsl:when test="@objectType = 'urn:ogc:def:objectType:OGC-CSW-ebRIM-CIM::ServiceMetadata'">
					<xsl:value-of select="'service'"/>
				</xsl:when>
				<xsl:when test="@objectType = 'urn:ogc:def:objectType:OGC-CSW-ebRIM-CIM::DatasetCollection'">
					<xsl:value-of select="'series'"/>
				</xsl:when>
				<xsl:when test="@objectType = 'urn:ogc:def:objectType:OGC-CSW-ebRIM-CIM::Application'">
					<xsl:value-of select="'application'"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="'dataset'"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
	</xsl:template>
	
	<!-- creation date -->
	<xsl:template match="rim:Slot[@name = 'http://purl.org/dc/terms/created']">
		<xsl:call-template name="ciDate">
			<xsl:with-param name="date" select="rim:ValueList/rim:Value"/>
			<xsl:with-param name="type" select="'creation'"/>
		</xsl:call-template>
	</xsl:template>
	
	<!-- publication date -->
	<xsl:template match="rim:Slot[@name = 'http://purl.org/dc/terms/issued']">
		<xsl:call-template name="ciDate">
			<xsl:with-param name="date" select="rim:ValueList/rim:Value"/>
			<xsl:with-param name="type" select="'publication'"/>
		</xsl:call-template>
	</xsl:template>
	
	<!-- revision date -->
	<xsl:template match="rim:Slot[@name = 'http://purl.org/dc/terms/modified']">
		<xsl:call-template name="ciDate">
			<xsl:with-param name="date" select="rim:ValueList/rim:Value"/>
			<xsl:with-param name="type" select="'revision'"/>
		</xsl:call-template>
	</xsl:template>
	
	<!-- generic date template -->
	<xsl:template name="ciDate">
		<xsl:param name="date"/>
		<xsl:param name="type"/>
		<xsl:if test="$date">
			<gmd:date>
				<gmd:CI_Date>
					<gmd:date>
						<gco:Date><xsl:value-of select="$date"/></gco:Date>
					</gmd:date>
					<gmd:dateType>
						<gmd:CI_DateTypeCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/ML_gmxCodelists.xml#CI_DateTypeCode" codeListValue="{$type}"/>
					</gmd:dateType>
				</gmd:CI_Date>
			</gmd:date>
		</xsl:if>
	</xsl:template>
	
	<!-- metadata contact -->
	<xsl:template name="mdContact">
		<xsl:variable name="rmId" select="@id"/>
		<xsl:variable name="miId" select="../rim:Association[@associationType = 'urn:ogc:def:associationType:OGC-CSW-ebRIM-CIM::ResourceMetadataInformation' and @sourceObject = $rmId]/@targetObject"/>
		<xsl:apply-templates select="../rim:Association[@sourceObject = $miId]" mode="contact"/>
	</xsl:template>
	
	<!-- point of contact -->
	<xsl:template name="pointOfContact">
		<xsl:variable name="rmId" select="@id"/>
		<xsl:apply-templates select="../rim:Association[@sourceObject = $rmId]" mode="pointOfContact"/>
	</xsl:template>
	
	<!-- generic responsible party template -->
	<xsl:template match="rim:Association[@associationType = 'urn:ogc:def:associationType:OGC-CSW-ebRIM-CIM::Publisher' or @associationType = 'urn:ogc:def:associationType:OGC-CSW-ebRIM-CIM::Originator' or @associationType = 'urn:ogc:def:associationType:OGC-CSW-ebRIM-CIM::Author'  or @associationType = 'urn:ogc:def:associationType:OGC-CSW-ebRIM-CIM::PointOfContact']" mode="contact">
		<gmd:contact>
			<xsl:apply-templates select="." mode="responsibleParty"/>
		</gmd:contact>
	</xsl:template>
	
	<!-- generic responsible party template -->
	<xsl:template match="rim:Association[@associationType = 'urn:ogc:def:associationType:OGC-CSW-ebRIM-CIM::Publisher' or @associationType = 'urn:ogc:def:associationType:OGC-CSW-ebRIM-CIM::Originator' or @associationType = 'urn:ogc:def:associationType:OGC-CSW-ebRIM-CIM::Author'  or @associationType = 'urn:ogc:def:associationType:OGC-CSW-ebRIM-CIM::PointOfContact']" mode="pointOfContact">
		<gmd:pointOfContact>
			<xsl:apply-templates select="." mode="responsibleParty"/>
		</gmd:pointOfContact>
	</xsl:template>

	<!-- cerates a valid date stamp -->
	<xsl:template name="dateStampValue">
		<xsl:variable name="rmId" select="@id"/>
		<xsl:variable name="targetObject" select="../rim:Association[@associationType = 'urn:ogc:def:associationType:OGC-CSW-ebRIM-CIM::ResourceMetadataInformation' and @sourceObject = $rmId]/@targetObject"/>
		<xsl:variable name="date" select="../rim:ExtrinsicObject[@id = $targetObject]/rim:Slot[@name = 'http://purl.org/dc/elements/1.1/date']/rim:ValueList/rim:Value"/>
		<xsl:choose>
			<xsl:when test="$date">
				<xsl:value-of select="$date"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>2011-01-01</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- generic responsible party template -->
	<xsl:template match="rim:Association[@associationType = 'urn:ogc:def:associationType:OGC-CSW-ebRIM-CIM::Publisher' or @associationType = 'urn:ogc:def:associationType:OGC-CSW-ebRIM-CIM::Originator' or @associationType = 'urn:ogc:def:associationType:OGC-CSW-ebRIM-CIM::Author'  or @associationType = 'urn:ogc:def:associationType:OGC-CSW-ebRIM-CIM::PointOfContact']" mode="responsibleParty">
		<xsl:variable name="targetObject" select="@targetObject"/>
		<xsl:variable name="organization" select="../rim:Organization[@id = $targetObject]"/>
		<gmd:CI_ResponsibleParty>
			<gmd:organisationName>
				<gco:CharacterString><xsl:value-of select="$organization/rim:Name/rim:LocalizedString/@value"/></gco:CharacterString>
			</gmd:organisationName>
			<gmd:contactInfo>
				<gmd:CI_Contact>
					<gmd:address>
						<gmd:CI_Address>
							<gmd:electronicMailAddress>
								<gco:CharacterString><xsl:value-of select="$organization/rim:EmailAddress/@address"/></gco:CharacterString>
							</gmd:electronicMailAddress>
						</gmd:CI_Address>
					</gmd:address>
				</gmd:CI_Contact>
			</gmd:contactInfo>
			<gmd:role>
				<gmd:CI_RoleCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/ML_gmxCodelists.xml#CI_RoleCode">
					<xsl:attribute name="codeListValue">
						<xsl:choose>
							<xsl:when test="contains(@associationType, 'Publisher')"><xsl:value-of select="'publisher'"/></xsl:when>
							<xsl:when test="contains(@associationType, 'Originator')"><xsl:value-of select="'originator'"/></xsl:when>
							<xsl:when test="contains(@associationType, 'Author')"><xsl:value-of select="'author'"/></xsl:when>
							<xsl:otherwise><xsl:value-of select="'pointOfContact'"/></xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>
				</gmd:CI_RoleCode>
			</gmd:role>
		</gmd:CI_ResponsibleParty>		
	</xsl:template>

	<!-- graphic overview -->
	<xsl:template name="browseGraphic">
		<xsl:variable name="rmId" select="@id"/>
		<xsl:variable name="targetObject" select="../rim:Association[@associationType = 'urn:ogc:def:associationType:OGC-CSW-ebRIM-CIM::GraphicOverview' and @sourceObject = $rmId]/@targetObject"/>
		<xsl:value-of select="../rim:ExtrinsicObject[@id = $targetObject]/rim:Name/rim:LocalizedString/@value"/>
	</xsl:template>

	<!-- keywords -->
	<xsl:template match="rim:Classification[@classificationScheme='urn:ogc:def:classificationScheme:OGC-CSW-ebRIM-CIM::KeywordScheme']" mode="cls">
		<xsl:variable name="nodeId" select="@classificationNode"/>
		<xsl:apply-templates select="../../rim:ClassificationNode[@id = $nodeId]" mode="keyword"/>
	</xsl:template>
	
	<!-- we can not re-assign the correct keyword type to the keywords -->
	<xsl:template match="rim:ClassificationNode" mode="keyword">
		<gmd:descriptiveKeywords>
			<gmd:MD_Keywords>
				<gmd:keyword>
					<gco:CharacterString><xsl:value-of select="@code"/></gco:CharacterString>
				</gmd:keyword>
				<xsl:variable name="nodeId" select="@id"/>
				<xsl:apply-templates select="../rim:Association[@sourceObject = $nodeId]" mode="assoc"/>
			</gmd:MD_Keywords>
		</gmd:descriptiveKeywords>
	</xsl:template>
	
	<!-- keyword with thesaurus -->
	<!-- NOTE: this produces MD_Metadata that is not valid wrt the official apiso.xsd schema! -->
	<!-- TODO: slot name/path -->
	<xsl:template match="rim:ClassificationNode[rim:Slot/@name='urn:ogc:def:slot:OGC-CSW-ebRIM-CIM::url']" mode="keyword">
		<gmd:descriptiveKeywords>
			<gmd:MD_Keywords>
				<gmd:keyword>
					<gmx:Anchor xlink:href="{rim:Slot[@name='urn:ogc:def:slot:OGC-CSW-ebRIM-CIM::url']/rim:ValueList/rim:Value}"><xsl:value-of select="@code"/></gmx:Anchor>
				</gmd:keyword>
				<xsl:variable name="nodeId" select="@id"/>
				<xsl:apply-templates select="../rim:Association[@sourceObject = $nodeId]"/>
			</gmd:MD_Keywords>
		</gmd:descriptiveKeywords>
	</xsl:template>
	
	<!-- get the thesaurus for this keyword node -->
	<xsl:template match="rim:Association[@associationType='urn:ogc:def:associationType:OGC-CSW-ebRIM-CIM::Thesaurus']" mode="assoc">
		<xsl:variable name="targetObject" select="@targetObject"/>
		<xsl:apply-templates select="../rim:ExtrinsicObject[@id = $targetObject]" mode="thesaurus"/>
	</xsl:template>
	
	<!-- create the thesaurus citation -->
	<!-- TODO: url slot name -->
	<xsl:template match="rim:ExtrinsicObject" mode="thesaurus">
		<gmd:thesaurusName>
			<xsl:call-template name="citation"/>
		</gmd:thesaurusName>
	</xsl:template>

	<!-- resource constraints -->
	<xsl:template match="rim:Association[@associationType = 'urn:ogc:def:associationType:OGC-CSW-ebRIM-CIM::ResourceConstraints']"  mode="assoc">
		<xsl:variable name="targetObject" select="@targetObject"/>
		<xsl:apply-templates select="../rim:ExtrinsicObject[@id = $targetObject]"  mode="assoc"/>
	</xsl:template>
	
	<!-- legal constraints -->
	<xsl:template match="rim:ExtrinsicObject[@objectType = 'urn:ogc:def:objectType:OGC-CSW-ebRIM-CIM::LegalConstraints']"  mode="assoc">
		<gmd:resourceConstraints>
			<gmd:MD_LegalConstraints>
				<gmd:useLimitation>
					<gco:CharacterString><xsl:value-of select="rim:Slot[@name = 'http://purl.org/dc/elements/1.1/abstract']/wrs:ValueList/wrs:AnyValue[1]/rim:InternationalString/rim:LocalizedString[1]/@value"/></gco:CharacterString>
				</gmd:useLimitation>
				<xsl:variable name="id" select="@id"/>
				<xsl:apply-templates select="rim:Classification[@classifiedObject = $id and @classificationScheme='urn:ogc:def:classificationScheme:OGC-CSW-ebRIM-CIM::RestrictionCode']"  mode="assoc"/>
				<gmd:otherConstraints>
					<gco:CharacterString><xsl:value-of select="rim:Slot[@name = 'http://purl.org/dc/elements/1.1/rigts']/wrs:ValueList/wrs:AnyValue[1]/rim:InternationalString/rim:LocalizedString[1]/@value"/></gco:CharacterString>
				</gmd:otherConstraints>
			</gmd:MD_LegalConstraints>
		</gmd:resourceConstraints>
	</xsl:template>

	<!-- security constraints -->
	<xsl:template match="rim:ExtrinsicObject[@objectType = 'urn:ogc:def:objectType:OGC-CSW-ebRIM-CIM::SecurityConstraints']"   mode="assoc">
		<gmd:resourceConstraints>
			<gmd:MD_SecurityConstraints>
				<gmd:useLimitation>
					<gco:CharacterString><xsl:value-of select="rim:Slot[@name = 'http://purl.org/dc/elements/1.1/abstract']/wrs:ValueList/wrs:AnyValue[1]/rim:InternationalString/rim:LocalizedString[1]/@value"/></gco:CharacterString>
				</gmd:useLimitation>
				<xsl:variable name="id" select="@id"/>
				<xsl:apply-templates select="rim:Classification[@classifiedObject = $id and @classificationScheme='urn:ogc:def:classificationScheme:OGC-CSW-ebRIM-CIM::ClassificationCode']"  mode="cls"/>
			</gmd:MD_SecurityConstraints>
		</gmd:resourceConstraints>
	</xsl:template>

	<!-- classification -->
	<xsl:template match="rim:Classification[@classificationScheme='urn:ogc:def:classificationScheme:OGC-CSW-ebRIM-CIM::ClassificationCode']"  mode="cls">
		<xsl:variable name="nodeId" select="@classificationNode"/>
		<xsl:apply-templates select="../../rim:ClassificationNode[@id = $nodeId]" mode="classification"/>
	</xsl:template>
	
	<!-- classification -->
	<xsl:template match="rim:Classification" mode="classification">
		<gmd:classification>
			<gmd:MD_RestrictionCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/ML_gmxCodelists.xml#MD_ClassificationCode" codeListValue="{rim:Name/rim:LocalizedString/@value}"/>
		</gmd:classification>
	</xsl:template>
	
	<!-- restriction -->
	<xsl:template match="rim:Classification[@classificationScheme='urn:ogc:def:classificationScheme:OGC-CSW-ebRIM-CIM::RestrictionCode']" mode="cls">
		<xsl:variable name="nodeId" select="@classificationNode"/>
		<xsl:apply-templates select="../../rim:ClassificationNode[@id = $nodeId]" mode="restriction"/>
	</xsl:template>
	
	<!-- restriction -->
	<xsl:template match="rim:Classification" mode="restriction">
		<gmd:accessConstraints>
			<gmd:MD_RestrictionCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/ML_gmxCodelists.xml#MD_RestrictionCode" codeListValue="{rim:Name/rim:LocalizedString/@value}"/>
		</gmd:accessConstraints>
	</xsl:template>

	<!-- distance -->
	<xsl:template match="gml:measure">
		<gmd:spatialResolution>
			<gmd:MD_Resolution>
				<gmd:distance>
					<gco:Distance uom="{uom}"><xsl:value-of select="text()"/></gco:Distance>
				</gmd:distance>
			</gmd:MD_Resolution>
		</gmd:spatialResolution>
	</xsl:template>

	<!-- scale denominator -->
	<xsl:template match="rim:Slot[@name= 'urn:ogc:def:slot:OGC-CSW-ebRIM-CIM::ScaleDenominator']/rim:ValueList/rim:Value">
		<gmd:spatialResolution>
			<gmd:MD_Resolution>
				<gmd:equivalentScale>
					<gmd:MD_RepresentativeFraction>
						<gmd:denominator>
							<gco:Integer><xsl:value-of select="text()"/></gco:Integer>
						</gmd:denominator>
					</gmd:MD_RepresentativeFraction>
				</gmd:equivalentScale>
			</gmd:MD_Resolution>
		</gmd:spatialResolution>
	</xsl:template>
	
	<!-- topic category -->
	<xsl:template match="rim:Classification[@classificationScheme='urn:ogc:def:classificationScheme:OGC-CSW-ebRIM-CIM::TopicCategory']">
		<xsl:variable name="nodeId" select="@classificationNode"/>
		<xsl:apply-templates select="../../rim:ClassificationNode[@id = $nodeId]" mode="topic"/>
	</xsl:template>
	
	<!-- topic category -->
	<xsl:template match="rim:ClassificationNode" mode="topic">
		<gmd:topicCategory>
			<gmd:MD_TopicCategoryCode><xsl:value-of select="rim:Name/rim:LocalizedString/@value"/></gmd:MD_TopicCategoryCode>
		</gmd:topicCategory>
	</xsl:template>

	<!-- bounding box -->
	<xsl:template match="gml:Envelope">
		<gmd:extent>
			<gmd:EX_Extent>
				<gmd:geographicElement>
					<gmd:EX_GeographicBoundingBox>
						<gmd:westBoundLongitude>
							<gco:Decimal><xsl:value-of select="substring-after(gml:lowerCorner, ' ')"/></gco:Decimal>
						</gmd:westBoundLongitude>
						<gmd:eastBoundLongitude>
							<gco:Decimal><xsl:value-of select="substring-after(gml:upperCorner, ' ')"/></gco:Decimal>
						</gmd:eastBoundLongitude>
						<gmd:southBoundLatitude>
							<gco:Decimal><xsl:value-of select="substring-before(gml:lowerCorner, ' ')"/></gco:Decimal>
						</gmd:southBoundLatitude>
						<gmd:northBoundLatitude>
							<gco:Decimal><xsl:value-of select="substring-before(gml:upperCorner, ' ')"/></gco:Decimal>
						</gmd:northBoundLatitude>
					</gmd:EX_GeographicBoundingBox>
				</gmd:geographicElement>
			</gmd:EX_Extent>
		</gmd:extent>
	</xsl:template>
	
	<!-- temporal extent -->
	<xsl:template match="gml:TimePeriod">
		<gmd:extent>
			<gmd:EX_Extent>
				<gmd:temporalElement>
					<gmd:EX_TemporalExtent>
						<gmd:extent>
							<xsl:copy-of select="."/>
						</gmd:extent>
					</gmd:EX_TemporalExtent>
				</gmd:temporalElement>
			</gmd:EX_Extent>
		</gmd:extent>
	</xsl:template>

	<!-- registry package -->
	<xsl:template match="rim:RegistryPackage">
		<xsl:apply-templates select="*"/>
	</xsl:template>

	<!-- filter unknown objects -->
	<xsl:template match="rim:*"/>
<!--	
	<xsl:template match="rim:Association"/>

	<xsl:template match="rim:Classification"/>

	<xsl:template match="rim:ClassificationNode"/>

	<xsl:template match="rim:Organization"/>
-->
	<!-- identity transform for all remaining objects -->
	<xsl:template match="node()|@*">
		<xsl:copy>
			<xsl:apply-templates select="node()|@*"/>
		</xsl:copy>
	</xsl:template>

</xsl:stylesheet>

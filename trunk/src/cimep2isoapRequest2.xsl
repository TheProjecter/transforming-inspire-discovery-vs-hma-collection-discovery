<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
Transforms a CIM EP request to an ISO AP request.

 Author: Udo Einspanier, con terra GmbH
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:gmd="http://www.isotc211.org/2005/gmd" xmlns:gml="http://www.opengis.net/gml" xmlns:csw="http://www.opengis.net/cat/csw/2.0.2" xmlns:ogc="http://www.opengis.net/ogc" xmlns:rim="urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0" xmlns:wrs="http://www.opengis.net/cat/wrs/1.0" xmlns:apiso="http://www.opengis.net/cat/csw/apiso/1.0" xmlns:tmp="urn:aadd40b1-c384-41a1-bb5f-b9730a90daae" xmlns:soap12="http://www.w3.org/2003/05/soap-envelope">
	<xsl:output method="xml" encoding="utf-8"/>

	<!-- The name of the thesaurus concept URI queryable. If left empty, it is ignored if a requests contains a respective constraint. -->
	<xsl:variable name="concept_uri">concept_uri</xsl:variable>

	<!-- +++++++++++++ -->
	<!-- GetRecords -->
	<!-- +++++++++++++ -->

	<!-- first check if this is an ebRIM request or a CSW base request (in which case we have nothing to do) -->
	<xsl:template match="csw:GetRecords[@outputSchema = 'http://www.opengis.net/cat/csw/2.0.2'] | csw:GetRecordById[@outputSchema = 'http://www.opengis.net/cat/csw/2.0.2']">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" mode="cswRecord"/>
		</xsl:copy>
	</xsl:template>
	
	<!-- in case of CSW base request, nothing to do -->
	<xsl:template match="@*|node()" mode="cswRecord">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" mode="cswRecord"/>
		</xsl:copy>
	</xsl:template>

	<!-- strip off elements in tmp namepsace for CSW base requests -->
	<xsl:template match="tmp:*" mode="cswRecord"/>
	
	<!-- output schema always ISO -->
	<xsl:template match="@outputSchema">
		<xsl:attribute name="outputSchema"><xsl:value-of select="'http://www.isotc211.org/2005/gmd'"/></xsl:attribute>
	</xsl:template>

	<!-- MD_Metadata is in ISO the only type that can be requested -->
	<xsl:template match="@typeNames">
		<xsl:attribute name="typeNames">
			<xsl:value-of select="'gmd:MD_Metadata'"/>
		</xsl:attribute>
	</xsl:template>

	<!-- always request full -->
	<xsl:template match="csw:ElementSetName[text() != 'full']">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<xsl:text>full</xsl:text>
		</xsl:copy>
	</xsl:template>
	
	<!-- do not copy the And node if it contains just a single value comparison and otherwise only comparisons necessary for joins -->
	<xsl:template match="ogc:And[count(*) - count(*/tmp:type[text() != 'comparison']) &lt; 2]">
		<xsl:apply-templates select="node()"/>
	</xsl:template>
	
	<!-- do not copy any comparisons necessary for joins -->
	<xsl:template match="ogc:PropertyIsEqualTo[tmp:type/text() != 'comparison']"/>

	<!-- remove all temporary elements used for parsing the filter -->
	<xsl:template match="tmp:*"/>

	<!-- we use the temporary annotations for mapping PropertyName -->
	<xsl:template match="ogc:PropertyName"/>
	
	<!-- service type -->
	<xsl:template match="*[tmp:PropertyName/tmp:step[2]/tmp:localName = '@objectType' and ogc:Literal = 'urn:ogc:def:ebRIM-ObjectType:OGC-I15::ServiceMetadata']">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<ogc:PropertyName>apiso:type</ogc:PropertyName>
			<ogc:Literal>service</ogc:Literal>
		</xsl:copy>
	</xsl:template>

	<!-- dataset type -->
	<xsl:template match="*[tmp:PropertyName/tmp:step[2]/tmp:localName = '@objectType' and ogc:Literal = 'urn:ogc:def:ebRIM-ObjectType:OGC-I15::ElementaryDataset']">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<ogc:PropertyName>apiso:type</ogc:PropertyName>
			<ogc:Literal>dataset</ogc:Literal>
		</xsl:copy>
	</xsl:template>

	<!-- series type -->
	<xsl:template match="*[tmp:PropertyName/tmp:step[2]/tmp:localName = '@objectType' and ogc:Literal = 'urn:ogc:def:ebRIM-ObjectType:OGC-I15::DatasetCollection']">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<ogc:PropertyName>apiso:type</ogc:PropertyName>
			<ogc:Literal>datasetcollection</ogc:Literal>
		</xsl:copy>
	</xsl:template>

	<!-- application type -->
	<xsl:template match="*[tmp:PropertyName/tmp:step[2]/tmp:localName = '@objectType' and ogc:Literal = 'urn:ogc:def:ebRIM-ObjectType:OGC-I15::Application']">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<ogc:PropertyName>apiso:type</ogc:PropertyName>
			<ogc:Literal>application</ogc:Literal>
		</xsl:copy>
	</xsl:template>

	<!-- rim:Name -->
	<xsl:template match="*[tmp:PropertyName[tmp:step[2]/tmp:nsUri/text() = 'urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0' and tmp:step[2]/tmp:localName/text() = 'Name']]">
		<!-- find out if the object type is represented by a variable -->
		<xsl:variable name="otVariable" select="tmp:PropertyName/tmp:step[1]/tmp:variable/text()"/>
		<xsl:choose>
			<xsl:when test="tmp:PropertyName/tmp:step[1]/tmp:localName = 'Organization' or //tmp:typeName[tmp:variable/text() = $otVariable and tmp:localName='Organization']">
				<xsl:copy>
					<xsl:apply-templates select="@*"/>
					<ogc:PropertyName>apiso:OrganisationName</ogc:PropertyName>
					<xsl:apply-templates select="ogc:Literal"/>
				</xsl:copy>
			</xsl:when>
			<!-- association to object that holds this name, must be something other than title -->
			<xsl:when test="//*[tmp:PropertyName/tmp:step[1]/*/text() = $otVariable and tmp:PropertyName/tmp:step[2]/tmp:localName = '@targetObject']">
				<!-- associated object, since we already handled organisation it can only be specification name -->
				<xsl:copy>
					<xsl:apply-templates select="@*"/>
					<ogc:PropertyName>apiso:SpecificationTitle</ogc:PropertyName>
					<xsl:apply-templates select="ogc:Literal"/>
				</xsl:copy>
			</xsl:when>
			<!-- name of ResourceMetadata, map to title if it does not reference keyword name-->
			<xsl:when test="not(contains($otVariable, 'ClassificationNode') or starts-with(//tmp:Query/tmp:typeName/tmp:localName[contains(text(), $otVariable)], 'ClassificationNode'))">
				<xsl:copy>
					<xsl:apply-templates select="@*"/>
					<ogc:PropertyName>apiso:title</ogc:PropertyName>
					<xsl:apply-templates select="ogc:Literal"/>
				</xsl:copy>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<!-- find the object type with the given name -->
<!--
	<xsl:template name="mapRimName">
		<xsl:param name="otVariable"/>
		<xsl:variable name="objectType" select="../ogc:PropertyIsEqualTo[tmp:PropertyName/tmp:step[1]/tmp:variable = $otVariable and tmp:PropertyName/tmp:step[2]/tmp:localName = '@objectType']/ogc:Literal"/>
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<ogc:PropertyName>
				<xsl:choose>
					<xsl:when test="$objectType = 'urn:ogc:def:ebRIM-ObjectType:OGC-I15::Organization'">
						<xsl:text>apiso:OrganisationName</xsl:text>
					</xsl:when>
					<xsl:when test="$objectType = 'urn:ogc:def:ebRIM-ObjectType:OGC-I15::ReferenceSpecification'">
						<xsl:text>apiso:SpecificationTitle</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:variable name="assocVariable" select="//*[tmp:PropertyName/tmp:step[1]/tmp:variable = $otVariable and tmp:PropertyName/tmp:step[2]/tmp:localName = '@targetObject']/tmp:PropertyName/tmp:step[1]/*[text() != $otVariable]"/>
						<xsl:variable name="assocType" select="//ogc:PropertyIsEqualTo[tmp:PropertyName/tmp:step[1]/tmp:variable = $assocVariable and tmp:PropertyName/tmp:step[2]/tmp:localName = '@associationType']/ogc:Literal"/>
						<xsl:choose>
							<xsl:when test="$assocType = 'urn:ogc:def:ebRIM-ObjectType:OGC-I15::Specification'">
								<xsl:text>apiso:SpecificationTitle</xsl:text>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>apiso:OrganisationName</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
			</ogc:PropertyName>
			<xsl:copy-of select="ogc:Literal"/>
		</xsl:copy>
	</xsl:template>
-->
	<!-- abstract -->
	<xsl:template match="tmp:PropertyName[tmp:step[2]/tmp:nsUri/text() = 'urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0' and tmp:step[2]/tmp:localName/text() = 'Description']">
		<xsl:variable name="otVariable" select="tmp:PropertyName/tmp:step[1]/tmp:variable/text()"/>
		<xsl:choose>
			<!-- association to object that holds this slot, must be rights -->
			<xsl:when test="//*[tmp:PropertyName/tmp:step[1]/tmp:variable = $otVariable and tmp:PropertyName/tmp:step[2]/tmp:localName = '@targetObject']">
				<ogc:PropertyName>apiso:ConditionApplyingToAccessAndUse</ogc:PropertyName>
			</xsl:when>
			<!-- no association, slot should be contained in the requested *Metadata object -->
			<xsl:otherwise>
				<ogc:PropertyName>apiso:abstract</ogc:PropertyName>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- resource identifier -->
	<xsl:template match="tmp:PropertyName[tmp:step[2]/tmp:nsUri/text() = 'urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0' and tmp:step[2]/tmp:localName/text() = 'ExternalIdentifier']">
		<ogc:PropertyName>apiso:ResourceIdentifier</ogc:PropertyName>
	</xsl:template>
	
	<!-- CLASSIFICATIONS -->
	<!-- generic template for classifications -->
	<xsl:template match="*[tmp:PropertyName[tmp:step[2]/tmp:localName/text() = '@classificationNode']]">
		<xsl:choose>
			<xsl:when test="starts-with(ogc:Literal, 'urn:ogc:def:ebRIM-ClassificationScheme:OGC-I15::')">
				<xsl:variable name="classificationWithScheme" select="substring-after(ogc:Literal, 'urn:ogc:def:ebRIM-ClassificationScheme:OGC-I15::')"/>
				<xsl:call-template name="classificationNode">
					<xsl:with-param name="scheme" select="substring-before($classificationWithScheme, ':')"/>
					<xsl:with-param name="literal" select="substring-after($classificationWithScheme, ':')"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="starts-with(ogc:Literal, 'urn:ogc:serviceType')">
				<xsl:call-template name="serviceTypeMapping"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:message terminate="yes"><xsl:value-of select="concat('Unknown classsification scheme: ', ogc:Literal)"/></xsl:message>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="classificationNode">
		<xsl:param name="scheme"/>
		<xsl:param name="literal"/>
		<xsl:choose>
			<xsl:when test="starts-with($scheme, 'KeywordScheme')">
				<xsl:variable name="keywordScheme" select="translate(substring-after($scheme, 'KeywordScheme'), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')"/>
				<xsl:choose>
					<xsl:when test="$keywordScheme = 'untyped'">
						<xsl:copy>
							<xsl:apply-templates select="@*"/>
							<ogc:PropertyName>apiso:subject</ogc:PropertyName>
							<ogc:Literal><xsl:value-of select="$literal"/></ogc:Literal>	
						</xsl:copy>
					</xsl:when>
					<xsl:otherwise>
						<ogc:And>
							<xsl:copy>
								<xsl:apply-templates select="@*"/>
								<ogc:PropertyName>apiso:subject</ogc:PropertyName>
								<ogc:Literal><xsl:value-of select="$literal"/></ogc:Literal>	
							</xsl:copy>
							<ogc:PropertyIsEqualTo>
								<ogc:PropertyName>apiso:KeywordType</ogc:PropertyName>
								<ogc:Literal><xsl:value-of select="$keywordScheme"/></ogc:Literal>
							</ogc:PropertyIsEqualTo>
						</ogc:And>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
<!--
			<xsl:when test="$scheme='KeywordScheme'">
				<xsl:copy>
					<xsl:apply-templates select="@*"/>
					<ogc:PropertyName>apiso:subject</ogc:PropertyName>
					<ogc:Literal><xsl:value-of select="$literal"/></ogc:Literal>	
				</xsl:copy>
			</xsl:when>
-->
			<xsl:when test="$scheme='RestrictionCode'">
				<xsl:copy>
					<xsl:apply-templates select="@*"/>
					<ogc:PropertyName>apiso:AccessConstraints</ogc:PropertyName>
					<ogc:Literal><xsl:value-of select="$literal"/></ogc:Literal>	
				</xsl:copy>
			</xsl:when>
			<xsl:when test="$scheme='ClassificationCode'">
				<xsl:copy>
					<xsl:apply-templates select="@*"/>
					<ogc:PropertyName>apiso:Classification</ogc:PropertyName>
					<ogc:Literal><xsl:value-of select="$literal"/></ogc:Literal>	
				</xsl:copy>
			</xsl:when>
			<xsl:when test="$scheme='Services'">
				<xsl:call-template name="serviceTypeMapping"/>
			</xsl:when>
			<xsl:when test="$scheme='TopicCategory'">
				<xsl:copy>
					<xsl:apply-templates select="@*"/>
					<ogc:PropertyName>apiso:TopicCategory</ogc:PropertyName>
					<ogc:Literal><xsl:value-of select="$literal"/></ogc:Literal>	
				</xsl:copy>
			</xsl:when>
<!--
			<xsl:when test="$scheme='KeywordType'">
				<xsl:copy>
					<xsl:apply-templates select="@*"/>
					<ogc:PropertyName><xsl:value-of select="concat('apsio:', $scheme)"/></ogc:PropertyName>
					<ogc:Literal><xsl:value-of select="$literal"/></ogc:Literal>	
				</xsl:copy>
			</xsl:when>
-->
			<xsl:otherwise>
				<xsl:message terminate="yes"><xsl:value-of select="concat('Unknown classsification scheme: ', $scheme)"/></xsl:message>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="classificationWithScheme">
		<xsl:param name="schemeAndValue"/>
		<xsl:param name="literal"/>
		<xsl:variable name="scheme" select="substring-after($schemeAndValue, 'urn:ogc:def:ebRIM-ClassificationScheme:OGC-I15::')"/>
		<xsl:choose>
			<xsl:when test="starts-with($scheme, 'KeywordScheme')">
				<xsl:variable name="keywordScheme" select="translate(substring-after($scheme, 'KeywordScheme'), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')"/>
				<xsl:choose>
					<xsl:when test="$keywordScheme = 'untyped'">
						<xsl:copy>
							<xsl:apply-templates select="@*"/>
							<ogc:PropertyName>apiso:subject</ogc:PropertyName>
							<ogc:Literal><xsl:value-of select="$literal"/></ogc:Literal>	
						</xsl:copy>
					</xsl:when>
					<xsl:otherwise>
						<ogc:And>
							<xsl:copy>
								<xsl:apply-templates select="@*"/>
								<ogc:PropertyName>apiso:subject</ogc:PropertyName>
								<ogc:Literal><xsl:value-of select="$literal"/></ogc:Literal>	
							</xsl:copy>
							<ogc:PropertyIsEqualTo>
								<ogc:PropertyName>apiso:KeywordType</ogc:PropertyName>
								<ogc:Literal><xsl:value-of select="$keywordScheme"/></ogc:Literal>
							</ogc:PropertyIsEqualTo>
						</ogc:And>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
<!--
			<xsl:when test="$scheme='KeywordScheme'">
				<xsl:copy>
					<xsl:apply-templates select="@*"/>
					<ogc:PropertyName>apiso:subject</ogc:PropertyName>
					<ogc:Literal><xsl:value-of select="$literal"/></ogc:Literal>	
				</xsl:copy>
			</xsl:when>
-->
			<xsl:when test="$scheme='RestrictionCode'">
				<xsl:copy>
					<xsl:apply-templates select="@*"/>
					<ogc:PropertyName>apiso:AccessConstraints</ogc:PropertyName>
					<ogc:Literal><xsl:value-of select="$literal"/></ogc:Literal>	
				</xsl:copy>
			</xsl:when>
			<xsl:when test="$scheme='ClassificationCode'">
				<xsl:copy>
					<xsl:apply-templates select="@*"/>
					<ogc:PropertyName>apiso:Classification</ogc:PropertyName>
					<ogc:Literal><xsl:value-of select="$literal"/></ogc:Literal>	
				</xsl:copy>
			</xsl:when>
			<xsl:when test="$scheme='Services'">
				<xsl:call-template name="serviceTypeMapping"/>
			</xsl:when>
			<xsl:when test="$scheme='TopicCategoryCode'">
				<xsl:copy>
					<xsl:apply-templates select="@*"/>
					<ogc:PropertyName>apiso:TopicCategory</ogc:PropertyName>
					<ogc:Literal><xsl:value-of select="$literal"/></ogc:Literal>	
				</xsl:copy>
			</xsl:when>
<!--
			<xsl:when test="$scheme='KeywordType'">
				<xsl:copy>
					<xsl:apply-templates select="@*"/>
					<ogc:PropertyName><xsl:value-of select="concat('apsio:', $scheme)"/></ogc:PropertyName>
					<ogc:Literal><xsl:value-of select="$literal"/></ogc:Literal>	
				</xsl:copy>
			</xsl:when>
-->
		</xsl:choose>
	</xsl:template>

	<!-- classification schemes are not processed individually -->
	<xsl:template match="*[tmp:PropertyName[tmp:step[2]/tmp:localName = '@classificationScheme']]"/>

	<!-- classification values are not processed individually -->
	<xsl:template match="*[tmp:PropertyName[tmp:step[2]/tmp:localName = '@code']]"/>

	<!-- map classification identifier to property name and value -->
<!--
	<xsl:template match="*[tmp:PropertyName[tmp:step[2]/tmp:localName/text() = '@classificationNode']]">
		<xsl:apply-templates select="ogc:Literal" mode="classificationNode"/>
	</xsl:template>
-->
	<!-- unknown classification, stop processing -->
<!--
	<xsl:template match="ogc:Literal[not(starts-with(text(), 'urn:ogc:def:ebRIM-ClassificationScheme:OGC-I15:'))]" mode="classificationNode">
		<xsl:message terminate="yes"><xsl:value-of select="concat('Unknown classification scheme: ', text())"/></xsl:message>
	</xsl:template>
-->
	<!-- ServiceType (-Version) Mapping -->
	<!--
		Mapping serviceType/serviceType version is currently inconsistently defined in the specifications.
		For example INSPIRE uses serviceTypes like _view_ and _download_ (without version infor), while AP ISO uses combinations like WMS/1.1.1, WMS/1.3.0, WCS/1.0.0. 
		The CIM supports for classifying a metadata entry the following classification nodes:
			<rim:ClassificationNode 
				  objectType="urn:oasis:names:tc:ebxml-regrep:ObjectType:RegistryObject:ClassificationNode" 
				  parent="urn:ogc:def:ebRIM-ClassificationNode:ISO-19119:2003:Service:Feature-Access" 
				  code="WFS" 
				  id="urn:ogc:serviceType:WebFeatureService:1.1">
				  <rim:Name>
					<rim:LocalizedString xml:lang="en" value="Web Feature Service (WFS), Version 1.1"/>
				  </rim:Name>
				</rim:ClassificationNode>
			same for :
				code="WMS" 
				  id="urn:ogc:serviceType:WebMapService:1.3.0">

				code="WCS" 
				  id="urn:ogc:serviceType:WebCoverageService:1.1.2">

		Consequence for the Adapters is that ServiceType mapping cannot be defined a priori - instead it must be defined project specific. 
	-->
	<!-- Current context node is the comparison operator. -->
<!--
	<xsl:template name="serviceTypeMapping">
		<xsl:message terminate="yes"><xsl:value-of select="concat('Service type mapping currently not supported: ', text())"/></xsl:message>
	</xsl:template>
-->
	<xsl:template name="serviceTypeMapping">
		<xsl:choose>
			<xsl:when test="ogc:Literal = 'urn:ogc:serviceType:WebMapService:1.3'">
				<xsl:call-template name="serviceTypeWithVersion">
					<xsl:with-param name="serviceType" select="'WMS'"/>
					<xsl:with-param name="version" select="'1.3.0'"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="ogc:Literal = 'urn:ogc:serviceType:WebFeatureService:1.1'">
				<xsl:call-template name="serviceTypeWithVersion">
					<xsl:with-param name="serviceType" select="'WFS'"/>
					<xsl:with-param name="version" select="'1.1.0'"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="ogc:Literal = 'urn:ogc:serviceType:WebCoverageService:1.1.2'">
				<xsl:call-template name="serviceTypeWithVersion">
					<xsl:with-param name="serviceType" select="'WCS'"/>
					<xsl:with-param name="version" select="'1.1.2'"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="ogc:Literal = 'urn:ogc:serviceType:CatalogueService:2.0.2'">
				<xsl:call-template name="serviceTypeWithVersion">
					<xsl:with-param name="serviceType" select="'CSW'"/>
					<xsl:with-param name="version" select="'2.0.2'"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="serviceTypeAndVersion" select="substring-after(ogc:Literal, 'urn:ogc:serviceType:')"/>
				<xsl:call-template name="serviceTypeWithVersion">
					<xsl:with-param name="serviceType" select="substring-before($serviceTypeAndVersion, ':')"/>
					<xsl:with-param name="version" select="substring-after($serviceTypeAndVersion, ':')"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="serviceTypeWithVersion">
		<xsl:param name="serviceType"/>
		<xsl:param name="version"/>
		<ogc:And>
			<xsl:copy>
				<xsl:apply-templates select="@*"/>
				<ogc:PropertyName>apiso:ServiceType</ogc:PropertyName>
				<ogc:Literal><xsl:value-of select="$serviceType"/></ogc:Literal>	
			</xsl:copy>
			<xsl:copy>
				<xsl:apply-templates select="@*"/>
				<ogc:PropertyName>apiso:ServiceTypeVersion</ogc:PropertyName>
				<ogc:Literal><xsl:value-of select="$version"/></ogc:Literal>	
			</xsl:copy>
		</ogc:And>
	</xsl:template>

	<!-- SLOTS-->
	<!-- generic template for slots with @name predicate -->
	<xsl:template match="*[tmp:PropertyName[tmp:step[2]/tmp:localName/text() = 'Slot'] and tmp:PropertyName[tmp:step[2]/tmp:nsUri/text() = 'urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0']]">
		<xsl:call-template name="mapSlotName">
			<xsl:with-param name="name" select="tmp:PropertyName/tmp:step[2]/tmp:predicate/tmp:text"/>
		</xsl:call-template>
	</xsl:template>
	
	<!-- generic template for slots represented by variable -->
	<xsl:template match="*[tmp:PropertyName/tmp:step[2]/tmp:variable]">
		<xsl:variable name="slotVariable" select="tmp:PropertyName/tmp:step[2]/tmp:variable/text()"/>
		<xsl:variable name="slotName" select="../*[tmp:PropertyName/tmp:step[1]/tmp:variable/text() = $slotVariable and tmp:PropertyName/tmp:step[2]/tmp:localName/text() = '@name']/ogc:Literal"/>
		<xsl:for-each select="../*[tmp:PropertyName/tmp:step[2]/tmp:variable/text() = $slotVariable]">
			<xsl:call-template name="mapSlotName">
				<xsl:with-param name="name" select="$slotName"/>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>

	<!-- map the name of the slot to the corresponding INSPIRE queryable -->
	<xsl:template name="mapSlotName">
		<xsl:param name="name"/>
		<xsl:choose>
			<xsl:when test="$name = 'http://purl.org/dc/terms/created' or $name = 'http://purl.org/dc/terms/modified' or $name = 'http://purl.org/dc/terms/issued'">
				<xsl:call-template name="mapAmbiguousSlotNameAssoc">
					<xsl:with-param name="name" select="$name"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="mapUnambiguousSlotName">
					<xsl:with-param name="name" select="$name"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- use association as indicator to determine correct queryable -->
	<xsl:template name="mapAmbiguousSlotNameAssoc">
		<xsl:param name="name"/>
		<!-- find out if the the variable in this condition -->
		<xsl:variable name="otVariable" select="tmp:PropertyName/tmp:step[1]/tmp:variable/text()"/>
		<xsl:choose>
			<!-- association to object that holds this slot, must be specification -->
			<xsl:when test="//*[tmp:PropertyName/tmp:step[1]/tmp:variable = $otVariable and tmp:PropertyName/tmp:step[2]/tmp:localName = '@targetObject']">
				<xsl:choose>
					<xsl:when test="$name = 'http://purl.org/dc/terms/created'">
						<xsl:call-template name="specDateComparison">
							<xsl:with-param name="type" select="'creation'"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:when test="$name = 'http://purl.org/dc/terms/modified'">
						<xsl:call-template name="specDateComparison">
							<xsl:with-param name="type" select="'revision'"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:when test="$name = 'http://purl.org/dc/terms/issued'">
						<xsl:call-template name="specDateComparison">
							<xsl:with-param name="type" select="'publication'"/>
						</xsl:call-template>
					</xsl:when>
				</xsl:choose>
			</xsl:when>
			<!-- no association, slot should be contained in the requested *Metadata object -->
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="$name = 'http://purl.org/dc/terms/created'">
						<xsl:call-template name="slotComparison">
							<xsl:with-param name="name" select="'apiso:CreationDate'"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:when test="$name = 'http://purl.org/dc/terms/modified'">
						<xsl:call-template name="slotComparison">
							<xsl:with-param name="name" select="'apiso:RevisionDate'"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:when test="$name = 'http://purl.org/dc/terms/issued'">
						<xsl:call-template name="slotComparison">
							<xsl:with-param name="name" select="'apiso:PublicationDate'"/>
						</xsl:call-template>
					</xsl:when>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- map the name of the slot to the corresponding INSPIRE queryable for a slot with unambiguous name -->
	<xsl:template name="mapUnambiguousSlotName">
		<xsl:param name="name"/>
		<xsl:choose>
			<!-- TODO: is this mapping correct? -->
			<xsl:when test="$name = 'http://purl.org/dc/terms/type'">
				<xsl:call-template name="slotComparison">
					<xsl:with-param name="name" select="'apiso:type'"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$name = 'http://purl.org/dc/terms/title'">
				<xsl:call-template name="slotComparison">
					<xsl:with-param name="name" select="'apiso:AlternateTitle'"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$name = 'urn:ogc:def:ebRIM-slot:OGC-I15::Lineage'">
				<xsl:call-template name="slotComparison">
					<xsl:with-param name="name" select="'apiso:Lineage'"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$name = 'urn:ogc:def:ebRIM-slot:OGC-I15::Resolution'">
				<xsl:call-template name="slotComparison">
					<xsl:with-param name="name" select="'apiso:DistanceValue'"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$name = 'urn:ogc:def:ebRIM-slot:OGC-I15::ScaleDenominator'">
				<xsl:call-template name="slotComparison">
					<xsl:with-param name="name" select="'apiso:Denominator'"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$name = 'urn:ogc:def:ebRIM-slot:OGC-I15::Conformance'">
				<xsl:call-template name="slotComparison">
					<xsl:with-param name="name" select="'apiso:Degree'"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$name = 'http://purl.org/dc/elements/1.1/language'">
				<xsl:call-template name="slotComparison">
					<xsl:with-param name="name" select="'apiso:Language'"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$name = 'http://purl.org/dc/elements/1.1/abstract'">
				<xsl:call-template name="slotComparison">
					<xsl:with-param name="name" select="'apiso:ConditionApplyingToAccessAndUse'"/>
				</xsl:call-template>
			</xsl:when>
 			<xsl:when test="$name = 'http://purl.org/dc/elements/1.1/rights'">
				<xsl:call-template name="slotComparison">
					<xsl:with-param name="name" select="'apiso:OtherConstraints'"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$name = 'urn:ogc:def:ebRIM-slot:OGC-I15::Envelope'">
				<xsl:call-template name="slotComparison">
					<xsl:with-param name="name" select="'apiso:BoundingBox'"/>
				</xsl:call-template>
			</xsl:when>
 			<xsl:when test="$name = 'urn:ogc:def:ebRIM-slot:OGC-I15::TemporalBegin'">
				<xsl:call-template name="slotComparison">
					<xsl:with-param name="name" select="'apiso:TempExtent_begin'"/>
				</xsl:call-template>
			</xsl:when>
 			<xsl:when test="$name = 'urn:ogc:def:ebRIM-slot:OGC-I15::TemporalEnd'">
				<xsl:call-template name="slotComparison">
					<xsl:with-param name="name" select="'apiso:TempExtent_end'"/>
				</xsl:call-template>
			</xsl:when>
 			<xsl:when test="$name = 'http://purl.org/dc/elements/1.1/source'">
				<!-- Map the thesaurus concept URI, but only if this queryable is supported (non-empty concept_uri). -->
				<xsl:if test="$concept_uri">
					<xsl:call-template name="slotComparison">
						<xsl:with-param name="name" select="$concept_uri"/>
					</xsl:call-template>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:message terminate="yes"><xsl:value-of select="concat('Invalid slot name: ', $name)"/></xsl:message>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- temporal extent -->
	<!-- create a filter for specification date and date type -->
	<xsl:template name="specDateComparison">
		<xsl:param name="type"/>
		<ogc:And>
			<xsl:copy>
				<xsl:apply-templates select="@*"/>
				<ogc:PropertyName>
					<xsl:text>apiso:SpecificationDate</xsl:text>
				</ogc:PropertyName>
				<xsl:apply-templates select="ogc:Literal"/>
			</xsl:copy>
			<ogc:PropertyIsEqualTo>
				<ogc:PropertyName>apiso:SpecificationDateType</ogc:PropertyName>
				<ogc:Literal><xsl:value-of select="$type"/></ogc:Literal>
			</ogc:PropertyIsEqualTo>
		</ogc:And>
	</xsl:template>

	<!-- generate the comparison for a slot with the respective name -->
	<xsl:template name="slotComparison">
		<xsl:param name="name"/>
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<ogc:PropertyName><xsl:value-of select="$name"/></ogc:PropertyName>
			<xsl:apply-templates select="*[position() != 1 and namespace-uri() != 'urn:aadd40b1-c384-41a1-bb5f-b9730a90daae']"/>
		</xsl:copy>
	</xsl:template>
	
	<!-- unknown property name, stop processing with an error message -->
	<xsl:template match="tmp:PropertyName">
		<xsl:message terminate="yes"><xsl:value-of select="concat('Invalid PropertyName: ', ../ogc:PropertyName)"/></xsl:message>
	</xsl:template>

	<!-- +++++++++++++ -->
	<!-- GetRecordById -->
	<!-- +++++++++++++ -->

	<!-- GetRecordById for ebRIM requests, map to corresponding GetRecords -->
	<xsl:template match="csw:GetRecordById[@outputSchema = 'urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0']">
		<csw:GetRecords maxRecords="{count(csw:Id)}" outputFormat="application/xml" outputSchema="http://www.isotc211.org/2005/gmd" resultType="results" service="CSW" startPosition="1" version="2.0.2">
			<csw:Query typeNames="gmd:MD_Metadata">
			<csw:ElementSetName typeNames="gmd:MD_Metadata">full</csw:ElementSetName>
				<csw:Constraint version="1.1.0">
					<ogc:Filter>
						<xsl:choose>
							<xsl:when test="count(csw:Id) = 0">
								<xsl:message terminate="yes">Missing Id element</xsl:message>
							</xsl:when>
							<xsl:when test="count(csw:Id) = 1">
								<xsl:apply-templates select="csw:Id" mode="rimId"/>
							</xsl:when>
							<xsl:otherwise>
								<ogc:Or>
									<xsl:apply-templates select="csw:Id" mode="rimId"/>
								</ogc:Or>
							</xsl:otherwise>
						</xsl:choose>
					</ogc:Filter>
				</csw:Constraint>
			</csw:Query>
		</csw:GetRecords>
	</xsl:template>

	<!-- ID references DataMatadata or ServiceMetadata ExtrinsicObject/@id -->
	<xsl:template match="csw:Id[starts-with(text(), 'RM:') or starts-with(text(), 'DM:') or starts-with(text(), 'SM:')]" mode="rimId">
		<ogc:PropertyIsEqualTo>
			<ogc:PropertyName>apiso:Identifier</ogc:PropertyName>
			<ogc:Literal><xsl:value-of select="substring-after(text(), ':')"/></ogc:Literal>
		</ogc:PropertyIsEqualTo>
	</xsl:template>

	<!-- ID references ExternalIdentifier -->
	<xsl:template match="csw:Id" mode="rimId">
		<ogc:PropertyIsEqualTo>
			<ogc:PropertyName>apiso:ResourceIdentifier</ogc:PropertyName>
			<ogc:Literal><xsl:value-of select="text()"/></ogc:Literal>
		</ogc:PropertyIsEqualTo>
	</xsl:template>

	<!-- +++++++++++++ -->
	<!-- GetRepositoryItem -->
	<!-- +++++++++++++ -->

	<!-- GetRepositoryItem HTTP/GET, map to corresponding GetRecords -->
	<xsl:template match="tmp:parameters[tmp:parameter[tmp:name = 'request' and tmp:value = 'GetRepositoryItem']]">
		<soap12:Envelope>
			<soap12:Header/>
			<soap12:Body>
				<csw:GetRecords maxRecords="1" outputFormat="application/xml" outputSchema="http://www.isotc211.org/2005/gmd" resultType="results" service="CSW" startPosition="1" version="2.0.2">
					<csw:Query typeNames="gmd:MD_Metadata">
					<csw:ElementSetName typeNames="gmd:MD_Metadata">full</csw:ElementSetName>
						<csw:Constraint version="1.1.0">
							<ogc:Filter>
								<ogc:PropertyIsEqualTo>
									<ogc:PropertyName>apiso:Identifier</ogc:PropertyName>
									<ogc:Literal>
										<xsl:variable name="id" select="tmp:parameter[tmp:name = 'id']/tmp:value"/>
										<xsl:choose>
											<xsl:when test="starts-with($id, 'RM:')">
												<xsl:value-of select="substring-after($id, 'RM:')"/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="$id"/>
											</xsl:otherwise>
										</xsl:choose>
									</ogc:Literal>
								</ogc:PropertyIsEqualTo>
							</ogc:Filter>
						</csw:Constraint>
					</csw:Query>
				</csw:GetRecords>
			</soap12:Body>
		</soap12:Envelope>
	</xsl:template>

	<!-- ++++++++++++ -->
	<!-- GetCapabilities -->
	<!-- ++++++++++++ -->

	<!-- we do not generate a new request for the wrapped CSW, instead load capabilities response from file and signal local processing -->
	<xsl:template match="csw:GetCapabilities | tmp:parameters[tmp:parameter[tmp:name = 'request' and tmp:value = 'GetCapabilities']]">
		<xsl:call-template name="checkGetParams"/>
		<xsl:message>local.processing</xsl:message>
		<xsl:apply-templates select="document('/cimepCapabilities.xml')"/>
	</xsl:template>

	<!-- checks additional parameters for HTTP GET requests -->
	<xsl:template name="checkGetParams">
		<xsl:if test="tmp:parameter[tmp:name = 'version' and not(tmp:value = '2.0.2')]">
			<xsl:message terminate="yes">Invalid version parameter</xsl:message>
		</xsl:if>
	</xsl:template>

	<!-- unknown request via HTTP GET -->
	<xsl:template match="tmp:parameters">
		<xsl:message terminate="yes">Unknown or missing request parameter</xsl:message>
	</xsl:template>
	
	<!-- identity transform for all remaining objects -->
	<xsl:template match="node()|@*">
		<xsl:copy>
			<xsl:apply-templates select="node()|@*"/>
		</xsl:copy>
	</xsl:template>

</xsl:stylesheet>

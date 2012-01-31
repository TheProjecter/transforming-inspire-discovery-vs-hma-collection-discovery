<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
Transforms a CIM EP request to an ISO AP request.

 Author: Udo Einspanier, con terra GmbH
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:gmd="http://www.isotc211.org/2005/gmd" xmlns:gml="http://www.opengis.net/gml" xmlns:csw="http://www.opengis.net/cat/csw/2.0.2" xmlns:ogc="http://www.opengis.net/ogc" xmlns:rim="urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0" xmlns:apiso="http://www.opengis.net/cat/csw/apiso/1.0" xmlns:tmp="urn:aadd40b1-c384-41a1-bb5f-b9730a90daae" >
	<xsl:output method="xml" encoding="utf-8"/>

	<!-- Support for thesaurus concept URI. Youhave to modify BOTH the following variable and template to allow this queryable in AP ISO catalogues -->
	
	<!-- The variable that defines the name of the concept URI queryable to support -->
	<!-- If you want to support this queryable, leave the variable empty by deleting concept_uri. -->
	<xsl:variable name="concept_uri">concept_uri</xsl:variable>

	<!-- The template for thesaurus concept URI queryable used by ISO client. -->
	<!-- If you want to support this queryable, replace concept_uri in the match attribute with the name of the queryable used by the client. -->
	<!-- If you do not want to support this queryable, remove this template. -->
	<xsl:template match="*[tmp:PropertyName/tmp:step/tmp:localName/text() = 'concept_uri']">
		<xsl:choose>
			<xsl:when test="local-name(..) = 'Or' or local-name(..) = 'Not'">
				<ogc:And>
					<xsl:call-template name="conceptUriIntern"/>
				</ogc:And>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="conceptUriIntern"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- +++++++++++++ -->
	<!-- GetRecords -->
	<!-- +++++++++++++ -->

	<!-- first check if this is an ebRIM request or a CSW base request (in which case we have nothing to do) -->
	<xsl:template match="csw:GetRecords[csw:Query/tmp:ElementSetName/tmp:typeName/tmp:nsUri/text() = 'http://www.opengis.net/cat/csw/2.0.2' and csw:Query/tmp:ElementSetName/tmp:typeName/tmp:localName/text() = 'Record']">
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

	<!-- ExtrinsicObject is in CIM the only type that can be requested -->
	<!-- always request full -->
	<xsl:template match="csw:ElementSetName">
		<xsl:copy>
			<xsl:attribute name="typeNames">
				<xsl:value-of select="'$e1'"/>
			</xsl:attribute>
			<xsl:text>full</xsl:text>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="@outputSchema">
		<xsl:attribute name="outputSchema"><xsl:value-of select="'urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0'"/></xsl:attribute>
	</xsl:template>

	<!-- Set up variables for types in filter
		e1: ResourceMetadata
		e2: MetadataInformation
		e3: ReferenceSpecification
		e4: Rights
		e5: LegalConstraints
		e6: SecurityConstraints

		o1: Organization

		a2: ResourceMetadataInformation
		a3: Specification
		a4: ResourceConstraints
		a5: ResourceConstraints
		a6: ResourceConstraints
		a7: Publisher
		a8: Originator
		a9: Author
		a10: PointOfContact
		a11: Organization unclassified

		c1: KeywordType
		c2: TopicCategory
		c3: AccessConstraints
		c4: Classification
		c5: KeywordScheme
		c6: ThesaurusKeywordScheme
	-->
	<xsl:template match="csw:Query[csw:Constraint]/@typeNames">
		<xsl:attribute name="typeNames">
			<xsl:call-template name="generateTypeNames"/>
			<!--
			<xsl:value-of select="'rim:ExtrinsicObject_e1_e2_e3_e4_e5_e6 rim:Organization_o1 rim:Association_a2_a3_a4_a5_a6_a7_a8_a9_a10_a11 rim:Classification_c1_c2_c3_c4_c5_c6'"/>
-->
		</xsl:attribute>
	</xsl:template>
	<xsl:template match="csw:Query[not(csw:Constraint)]/@typeNames">
		<xsl:attribute name="typeNames">
			<xsl:value-of select="'rim:ExtrinsicObject_e1'"/>
		</xsl:attribute>
	</xsl:template>
	
	<xsl:template name="generateTypeNames">
		<xsl:text>rim:ExtrinsicObject_e1</xsl:text>
		<xsl:if test="//tmp:localName[text() = 'Language' or text() = 'ParentIdentifier']">
			<xsl:text>_e2</xsl:text>
		</xsl:if>
		<xsl:if test="//tmp:localName[text() = 'SpecificationTitle' or text() = 'Degree' or text() = 'SpecificationDateType'or text() = 'SpecificationDate']">
			<xsl:text>_e3</xsl:text>
		</xsl:if>
		<xsl:if test="//tmp:localName[text() = 'ConditionApplyingToAccessAndUse']">
			<xsl:text>_e4</xsl:text>
		</xsl:if>
		<xsl:if test="//tmp:localName[text() = 'OtherConstraints' or text() = 'AccessConstraints']">
			<xsl:text>_e5</xsl:text>
		</xsl:if>
		<xsl:if test="//tmp:localName[text() = 'Classification']">
			<xsl:text>_e6</xsl:text>
		</xsl:if>
		<xsl:if test="//tmp:localName[text() = 'OrganisationName']">
			<xsl:text> rim:Organization_o1</xsl:text>
		</xsl:if>
		<!-- associations -->
		<xsl:if test="//tmp:localName[text() = 'Language' or text() = 'ParentIdentifier' or text() = 'SpecificationTitle' or text() = 'Degree' or text() = 'SpecificationDateType'or text() = 'SpecificationDate' or text() = 'ConditionApplyingToAccessAndUse' or text() = 'OtherConstraints' or text() = 'AccessConstraints' or text() = 'Classification' or text() = 'OrganisationName']">
			<xsl:text> rim:Association</xsl:text>
		</xsl:if>
		<xsl:if test="//tmp:localName[text() = 'Language' or text() = 'ParentIdentifier']">
			<xsl:text>_a2</xsl:text>
		</xsl:if>
		<xsl:if test="//tmp:localName[text() = 'SpecificationTitle' or text() = 'Degree' or text() = 'SpecificationDateType'or text() = 'SpecificationDate']">
			<xsl:text>_a3</xsl:text>
		</xsl:if>
		<xsl:if test="//tmp:localName[text() = 'ConditionApplyingToAccessAndUse']">
			<xsl:text>_a4</xsl:text>
		</xsl:if>
		<xsl:if test="//tmp:localName[text() = 'OtherConstraints' or text() = 'AccessConstraints']">
			<xsl:text>_a5</xsl:text>
		</xsl:if>
		<xsl:if test="//tmp:localName[text() = 'Classification']">
			<xsl:text>_a6</xsl:text>
		</xsl:if>
		<xsl:if test="//tmp:localName[text() = 'OrganisationName']">
			<xsl:choose>
				<xsl:when test="//*[tmp:PropertyName/tmp:step/tmp:localName/text() = 'ResponsiblePartyRole' and ogc:Literal/text() = 'publisher']">
					<xsl:text>_a7</xsl:text>
				</xsl:when>
				<xsl:when test="//*[tmp:PropertyName/tmp:step/tmp:localName/text() = 'ResponsiblePartyRole' and ogc:Literal/text() = 'originator']">
					<xsl:text>_a8</xsl:text>
				</xsl:when>
				<xsl:when test="//*[tmp:PropertyName/tmp:step/tmp:localName/text() = 'ResponsiblePartyRole' and ogc:Literal/text() = 'author']">
					<xsl:text>_a9</xsl:text>
				</xsl:when>
				<xsl:when test="//*[tmp:PropertyName/tmp:step/tmp:localName/text() = 'ResponsiblePartyRole' and ogc:Literal/text() = 'pointOfContact']">
					<xsl:text>_a10</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>_a11</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
		<!-- classifications -->
		<xsl:if test="//tmp:localName[text() = 'KeywordType' or text() = 'TopicCategory' or text() = 'AccessConstraints' or text() = 'Classification' or text() = 'subject' or text() = $concept_uri]">
			<xsl:text> rim:Classification</xsl:text>
		</xsl:if>
		<xsl:if test="//tmp:localName/text() = 'KeywordType'">
			<xsl:text>_c1</xsl:text>
		</xsl:if>
		<xsl:if test="//tmp:localName/text() = 'TopicCategory'">
			<xsl:text>_c2</xsl:text>
		</xsl:if>
		<xsl:if test="//tmp:localName/text() = 'AccessConstraints'">
			<xsl:text>_c3</xsl:text>
		</xsl:if>
		<xsl:if test="//tmp:localName/text() = 'Classification'">
			<xsl:text>_c4</xsl:text>
		</xsl:if>
		<xsl:if test="//tmp:localName/text() = 'subject'">
			<xsl:text>_c5</xsl:text>
		</xsl:if>
		<xsl:if test="//tmp:localName/text() = $concept_uri">
			<xsl:text>_c6</xsl:text>
		</xsl:if>
	</xsl:template>

	<!-- remove all temporary elements used for parsing the filter -->
	<xsl:template match="tmp:*"/>

	<!-- if there is a filter without root And, create the root And and add the "joins" -->
	<xsl:template match="ogc:Filter[not(ogc:And)]">
		<xsl:copy>
			<ogc:And>
				<xsl:call-template name="createJoins"/>
				<xsl:apply-templates select="*"/>
			</ogc:And>
		</xsl:copy>
	</xsl:template>
	
	<!-- if there is already a filter root And, just add the "joins" -->
	<xsl:template match="ogc:Filter/ogc:And">
		<xsl:copy>
			<xsl:call-template name="createJoins"/>
			<xsl:apply-templates select="*"/>
		</xsl:copy>
	</xsl:template>
	
	<!-- creates a filter for the object type of resource metadata -->
	<xsl:template name="resourceMetadata">
		<xsl:param name="objectType"/>
		<ogc:PropertyIsEqualTo>
			<ogc:PropertyName>$e1/@objectType</ogc:PropertyName>
			<ogc:Literal><xsl:value-of select="$objectType"/></ogc:Literal>
		</ogc:PropertyIsEqualTo>
	</xsl:template>

	<!-- creates necessary "joins" for the filter -->
	<xsl:template name="createJoins">
	<!--
		<xsl:choose>
			<xsl:when test="//*[tmp:PropertyName/tmp:step/tmp:localName[text() = 'type'] and ogc:Literal[text() = 'service']]">
					<xsl:call-template name="serviceMetadata"/>
			</xsl:when>
			<xsl:when test="//*[tmp:PropertyName/tmp:step/tmp:localName[text() = 'type'] and ogc:Literal[text() = 'dataset']]">
					<xsl:call-template name="datasetMetadata"/>
			</xsl:when>
			<xsl:when test="not(//tmp:localName[text() = 'type'])">
				<ogc:Or>
					<xsl:call-template name="datasetMetadata"/>
					<xsl:call-template name="serviceMetadata"/>
				</ogc:Or>
			</xsl:when>
		</xsl:choose>
		-->
		<xsl:if test="not(//tmp:localName[text() = 'type'])">
			<ogc:Or>
				<xsl:call-template name="resourceMetadata">
					<xsl:with-param name="objectType" select="'urn:ogc:def:objectType:OGC-CSW-ebRIM-CIM::DataMetadata'"/>
				</xsl:call-template>
				<xsl:call-template name="resourceMetadata">
					<xsl:with-param name="objectType" select="'urn:ogc:def:objectType:OGC-CSW-ebRIM-CIM::ServiceMetadata'"/>
				</xsl:call-template>
				<xsl:call-template name="resourceMetadata">
					<xsl:with-param name="objectType" select="'urn:ogc:def:objectType:OGC-CSW-ebRIM-CIM::DatasetCollection'"/>
				</xsl:call-template>
				<xsl:call-template name="resourceMetadata">
					<xsl:with-param name="objectType" select="'urn:ogc:def:objectType:OGC-CSW-ebRIM-CIM::Application'"/>
				</xsl:call-template>
			</ogc:Or>
		</xsl:if>
		<xsl:if test="//tmp:localName[text() = 'Language' or text() = 'ParentIdentifier']">
			<!-- identifier is mapped to ExtrinsicObject/@id -->
			<xsl:call-template name="createJoin">
				<xsl:with-param name="targetObject" select="'$e2'"/>
				<xsl:with-param name="assoc" select="'$a2'"/>
				<xsl:with-param name="assocType" select="'urn:ogc:def:associationType:OGC-CSW-ebRIM-CIM::ResourceMetadataInformation'"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="//tmp:localName[text() = 'SpecificationTitle' or text() = 'Degree' or text() = 'SpecificationDateType'or text() = 'SpecificationDate']">
			<xsl:call-template name="createJoin">
				<xsl:with-param name="targetObject" select="'$e3'"/>
				<xsl:with-param name="assoc" select="'$a3'"/>
				<xsl:with-param name="assocType" select="'urn:ogc:def:objectType:OGC-CSW-ebRIM-CIM::Specification'"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="//tmp:localName[text() = 'ConditionApplyingToAccessAndUse']">
			<xsl:call-template name="createJoin">
				<xsl:with-param name="targetObject" select="'$e4'"/>
				<xsl:with-param name="assoc" select="'$a4'"/>
				<xsl:with-param name="assocType" select="'urn:ogc:def:objectType:OGC-CSW-ebRIM-CIM::ResourceConstraints'"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="//tmp:localName[text() = 'OtherConstraints' or text() = 'AccessConstraints']">
			<xsl:call-template name="createJoin">
				<xsl:with-param name="targetObject" select="'$e5'"/>
				<xsl:with-param name="assoc" select="'$a5'"/>
				<xsl:with-param name="assocType" select="'urn:ogc:def:objectType:OGC-CSW-ebRIM-CIM::ResourceConstraints'"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="//tmp:localName[text() = 'Classification']">
			<xsl:call-template name="createJoin">
				<xsl:with-param name="targetObject" select="'$e6'"/>
				<xsl:with-param name="assoc" select="'$a6'"/>
				<xsl:with-param name="assocType" select="'urn:ogc:def:objectType:OGC-CSW-ebRIM-CIM::ResourceConstraints'"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="//tmp:localName[text() = 'OrganisationName']">
			<xsl:choose>
				<xsl:when test="//*[tmp:PropertyName/tmp:step/tmp:localName/text() = 'ResponsiblePartyRole' and ogc:Literal/text() = 'publisher']">
					<xsl:call-template name="createJoin">
						<xsl:with-param name="targetObject" select="'$o1'"/>
						<xsl:with-param name="assoc" select="'$a7'"/>
						<xsl:with-param name="assocType" select="'urn:ogc:def:objectType:OGC-CSW-ebRIM-CIM::Publisher'"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:when test="//*[tmp:PropertyName/tmp:step/tmp:localName/text() = 'ResponsiblePartyRole' and ogc:Literal/text() = 'originator']">
					<xsl:call-template name="createJoin">
						<xsl:with-param name="targetObject" select="'$o1'"/>
						<xsl:with-param name="assoc" select="'$a8'"/>
						<xsl:with-param name="assocType" select="'urn:ogc:def:objectType:OGC-CSW-ebRIM-CIM::Originator'"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:when test="//*[tmp:PropertyName/tmp:step/tmp:localName/text() = 'ResponsiblePartyRole' and ogc:Literal/text() = 'author']">
					<xsl:call-template name="createJoin">
						<xsl:with-param name="targetObject" select="'$o1'"/>
						<xsl:with-param name="assoc" select="'$a9'"/>
						<xsl:with-param name="assocType" select="'urn:ogc:def:objectType:OGC-CSW-ebRIM-CIM::Author'"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:when test="//*[tmp:PropertyName/tmp:step/tmp:localName/text() = 'ResponsiblePartyRole' and ogc:Literal/text() = 'pointOfContact']">
					<xsl:call-template name="createJoin">
						<xsl:with-param name="targetObject" select="'$o1'"/>
						<xsl:with-param name="assoc" select="'$a10'"/>
						<xsl:with-param name="assocType" select="'urn:ogc:def:objectType:OGC-CSW-ebRIM-CIM::PointOfContact'"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="createJoin">
						<xsl:with-param name="targetObject" select="'$o1'"/>
						<xsl:with-param name="assoc" select="'$a11'"/>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>
	
	<!-- generic template for one "join" -->
	<xsl:template name="createJoin">
		<xsl:param name="sourceObject" select="'$e1'"/>
		<xsl:param name="targetObject"/>
		<xsl:param name="assoc"/>
		<xsl:param name="assocType"/>
		<xsl:if test="$assocType">
			<ogc:PropertyIsEqualTo>
				<ogc:PropertyName><xsl:value-of select="concat($assoc, '/@associationType')"/></ogc:PropertyName>
				<ogc:Literal><xsl:value-of select="$assocType"/></ogc:Literal>
			</ogc:PropertyIsEqualTo>
		</xsl:if>
		<ogc:PropertyIsEqualTo>
			<ogc:PropertyName><xsl:value-of select="concat($assoc, '/@sourceObject')"/></ogc:PropertyName>
			<ogc:PropertyName><xsl:value-of select="concat($sourceObject, '/@id')"/></ogc:PropertyName>
		</ogc:PropertyIsEqualTo>
		<ogc:PropertyIsEqualTo>
			<ogc:PropertyName><xsl:value-of select="concat($assoc, '/@targetObject')"/></ogc:PropertyName>
			<ogc:PropertyName><xsl:value-of select="concat($targetObject, '/@id')"/></ogc:PropertyName>
		</ogc:PropertyIsEqualTo>
	</xsl:template>

	<!-- spatial constraints in ebRIM always on Boundingbox -->
	<xsl:template match="ogc:BBOX | ogc:Equals | ogc:Disjoint | ogc:Touches | ogc:Within | ogc:Overlaps | ogc:Crosses | ogc:Intersects | ogc:Contains | ogc:DWithin | ogc:Beyond">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<xsl:apply-templates select="*[position() != 1]"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="tmp:PropertyName[tmp:step/tmp:localName/text() = 'BoundingBox']">
		<ogc:PropertyName>$e1/rim:Slot[@name='urn:ogc:def:slot:OGC-CSW-ebRIM-CIM::Envelope']/wrs:ValueList/wrs:Value</ogc:PropertyName>
	</xsl:template>

	<!-- we use the temporary annotations for mapping PropertyName -->
	<xsl:template match="ogc:PropertyName"/>
	
	<!-- TODO: map service type and service type version to classification Services-->
	<!-- Current context node is the temporary property name. -->
	<xsl:template match="tmp:PropertyName[tmp:step/tmp:localName/text() = 'ServiceType' or tmp:step/tmp:localName/text() = 'ServiceTypeVersion']">
		<xsl:message terminate="yes"><xsl:value-of select="'Service type mapping currently not supported'"/></xsl:message>
	</xsl:template>

	<!-- TODO: ParentIdentifier -->

	<!-- identifier -->
	<xsl:template match="tmp:PropertyName[tmp:step/tmp:localName/text() = 'identifier']">
		<ogc:PropertyName>$e1/@id</ogc:PropertyName>
	</xsl:template>

	<!-- title -->
	<xsl:template match="tmp:PropertyName[tmp:step/tmp:localName/text() = 'title']">
		<ogc:PropertyName>$e1/rim:Name/rim:LocalizedString/@value</ogc:PropertyName>
	</xsl:template>

	<!-- abstract -->
	<xsl:template match="tmp:PropertyName[tmp:step/tmp:localName/text() = 'abstract']">
		<ogc:PropertyName>$e1/rim:Description/rim:LocalizedString/@value</ogc:PropertyName>
	</xsl:template>

	<!-- resource identifier -->
	<xsl:template match="tmp:PropertyName[tmp:step/tmp:localName/text() = 'ResourceIdentifier']">
		<ogc:PropertyName>$e1/rim:ExternalIdentifier/@value</ogc:PropertyName>
	</xsl:template>

	<!-- type -->
	<xsl:template match="*[tmp:PropertyName/tmp:step/tmp:localName/text() = 'type' and ogc:Literal = 'service']">
		<xsl:call-template name="resourceMetadata">
			<xsl:with-param name="objectType" select="'urn:ogc:def:objectType:OGC-CSW-ebRIM-CIM::ServiceMetadata'"/>
		</xsl:call-template>
	</xsl:template>
	<xsl:template match="*[tmp:PropertyName/tmp:step/tmp:localName/text() = 'type' and ogc:Literal = 'dataset']">
		<xsl:call-template name="resourceMetadata">
			<xsl:with-param name="objectType" select="'urn:ogc:def:objectType:OGC-CSW-ebRIM-CIM::DataMetadata'"/>
		</xsl:call-template>
	</xsl:template>
	<xsl:template match="*[tmp:PropertyName/tmp:step/tmp:localName/text() = 'type' and (ogc:Literal = 'series' or ogc:Literal = 'datasetcollection')]">
		<xsl:call-template name="resourceMetadata">
			<xsl:with-param name="objectType" select="'urn:ogc:def:objectType:OGC-CSW-ebRIM-CIM::DatasetCollection'"/>
		</xsl:call-template>
	</xsl:template>
	<xsl:template match="*[tmp:PropertyName/tmp:step/tmp:localName/text() = 'type' and ogc:Literal = 'application']">
		<xsl:call-template name="resourceMetadata">
			<xsl:with-param name="objectType" select="'urn:ogc:def:objectType:OGC-CSW-ebRIM-CIM::Application'"/>
		</xsl:call-template>
	</xsl:template>

	<!-- creation date -->
	<xsl:template match="tmp:PropertyName[tmp:step/tmp:localName/text() = 'CreationDate']">
		<ogc:PropertyName>$e1/rim:Slot[@name='http://purl.org/dc/terms/created']/rim:ValueList/rim:Value</ogc:PropertyName>
	</xsl:template>

	<!-- publication date -->
	<xsl:template match="tmp:PropertyName[tmp:step/tmp:localName/text() = 'PublicationDate']">
		<ogc:PropertyName>$e1/rim:Slot[@name='http://purl.org/dc/terms/issued']/rim:ValueList/rim:Value</ogc:PropertyName>
	</xsl:template>

	<!-- revision date -->
	<xsl:template match="tmp:PropertyName[tmp:step/tmp:localName/text() = 'RevisionDate']">
		<ogc:PropertyName>$e1/rim:Slot[@name='http://purl.org/dc/terms/modified']/rim:ValueList/rim:Value</ogc:PropertyName>
	</xsl:template>

	<!-- topic category -->
	<xsl:template match="*[tmp:PropertyName[tmp:step/tmp:localName/text() = 'TopicCategory']]">
		<xsl:call-template name="classification">
			<xsl:with-param name="classification" select="'$c2'"/>
			<xsl:with-param name="classificationScheme" select="'TopicCategory'"/>
		</xsl:call-template>
	</xsl:template>

	<!-- keywordtype -->
	<xsl:template match="*[tmp:PropertyName[tmp:step/tmp:localName/text() = 'KeywordType']]">
		<xsl:call-template name="classification">
			<xsl:with-param name="classification" select="'$c1'"/>
			<xsl:with-param name="classificationScheme" select="'KeywordType'"/>
		</xsl:call-template>
	</xsl:template>

	<!-- keyword -->
	<xsl:template match="*[tmp:PropertyName[tmp:step/tmp:localName/text() = 'subject']]">
		<xsl:call-template name="classification">
			<xsl:with-param name="classification" select="'$c5'"/>
			<xsl:with-param name="classificationScheme" select="'KeywordScheme'"/>
		</xsl:call-template>
	</xsl:template>

	<!-- lineage -->
	<xsl:template match="tmp:PropertyName[tmp:step/tmp:localName/text() = 'Lineage']">
		<ogc:PropertyName>$e1/rim:Slot[@name='urn:ogc:def:slot:OGC-CSW-ebRIM-CIM::Lineage']/wrs:ValueList/wrs:Value</ogc:PropertyName>
	</xsl:template>
	
	<!-- tempextent_begin -->
	<xsl:template match="tmp:PropertyName[tmp:step/tmp:localName/text() = 'TempExtent_begin']">
		<ogc:PropertyName>$e1/rim:Slot[@name='http://purl.org/dc/terms/temporal']/wrs:ValueList/wrs:AnyValue/gml:TimePeriod/gml:begin/gml:TimeInstant/gml:timePosition</ogc:PropertyName>
	</xsl:template>

	<!-- tempextent_end -->
	<xsl:template match="tmp:PropertyName[tmp:step/tmp:localName/text() = 'TempExtent_end']">
		<ogc:PropertyName>$e1/rim:Slot[@name='http://purl.org/dc/terms/temporal']/wrs:ValueList/wrs:AnyValue/gml:TimePeriod/gml:end/gml:TimeInstant/gml:timePosition</ogc:PropertyName>
	</xsl:template>

	<!-- denominator -->
	<xsl:template match="tmp:PropertyName[tmp:step/tmp:localName/text() = 'Denominator']">
		<ogc:PropertyName>$e1/rim:Slot[@name='urn:ogc:def:slot:OGC-CSW-ebRIM-CIM::ScaleDenominator']/rim:ValueList/rim:Value</ogc:PropertyName>
	</xsl:template>
	
	<!-- distance value, TODO uom -->
	<xsl:template match="tmp:PropertyName[tmp:step/tmp:localName/text() = 'DistanceValue']">
		<ogc:PropertyName>$e1/rim:Slot[@name='urn:ogc:def:slot:OGC-CSW-ebRIM-CIM::Resolution']/wrs:ValueList/wrs:Value</ogc:PropertyName>
	</xsl:template>
	
	<!--  organisation name -->
	<xsl:template match="tmp:PropertyName[tmp:step/tmp:localName/text() = 'OrganisationName']">
		<ogc:PropertyName>$o1/rim:Name/rim:LocalizedString/@value</ogc:PropertyName>
	</xsl:template>
	
	<!-- metadata language -->
	<xsl:template match="tmp:PropertyName[tmp:step/tmp:localName/text() = 'Language']">
		<ogc:PropertyName>$e2/rim:Slot[@name='http://purl.org/dc/elements/1.1/language']/rim:ValueList/rim:Value</ogc:PropertyName>
	</xsl:template>
	
	<!-- metadata date -->
	<xsl:template match="tmp:PropertyName[tmp:step/tmp:localName/text() = 'modified']">
		<ogc:PropertyName>$e2/rim:Slot[@name='http://purl.org/dc/elements/1.1/date']/rim:ValueList/rim:Value</ogc:PropertyName>
	</xsl:template>

	<!-- specification title -->
	<xsl:template match="tmp:PropertyName[tmp:step/tmp:localName/text() = 'SpecificationTitle']">
		<ogc:PropertyName>$e3/rim:Name/rim:LocalizedString/@value</ogc:PropertyName>
	</xsl:template>

	<!-- degree -->
	<xsl:template match="tmp:PropertyName[tmp:step/tmp:localName/text() = 'Degree']">
		<ogc:PropertyName>$e3/rim:Slot[@name='urn:ogc:def:slot:OGC-CSW-ebRIM-CIM::Conformance']/rim:ValueList/rim:Value</ogc:PropertyName>
	</xsl:template>
	
	<!-- specification date, we can only map this queryable correctly if there is also the type -->
	<xsl:template match="tmp:PropertyName[tmp:step/tmp:localName/text() = 'SpecificationDate']">
		<ogc:PropertyName>
			<xsl:choose>
				<xsl:when test="../../*[tmp:PropertyName/tmp:step/tmp:localName[text() = 'SpecificationDateType'] and ogc:Literal[text() = 'creation']]">
					<xsl:text>$e3/rim:Slot[@name='http://purl.org/dc/terms/created']/rim:ValueList/rim:Value</xsl:text>
				</xsl:when>
				<xsl:when test="../../*[tmp:PropertyName/tmp:step/tmp:localName[text() = 'SpecificationDateType'] and ogc:Literal[text() = 'publication']]">
					<xsl:text>$e3/rim:Slot[@name='http://purl.org/dc/terms/issued']/rim:ValueList/rim:Value</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>$e3/rim:Slot[@name='http://purl.org/dc/terms/modified']/rim:ValueList/rim:Value</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</ogc:PropertyName>
	</xsl:template>
	<xsl:template match="*[tmp:PropertyName[tmp:step/tmp:localName/text() = 'SpecificationDateType']]"/>
	
	<!-- condition applying to access and use -->
	<xsl:template match="tmp:PropertyName[tmp:step/tmp:localName/text() = 'ConditionApplyingToAccessAndUse']">
		<ogc:PropertyName>$e4/rim:Slot[@name='http://purl.org/dc/elements/1.1/abstract']/rim:ValueList/rim:Value</ogc:PropertyName>
	</xsl:template>
	
	<!-- other constraints -->
	<xsl:template match="tmp:PropertyName[tmp:step/tmp:localName/text() = 'OtherConstraints']">
		<ogc:PropertyName>$e5/rim:Slot[@name='http://purl.org/dc/elements/1.1/rights']/wrs:ValueList/wrs:Value</ogc:PropertyName>
	</xsl:template>
	
	<!-- access constraints -->
	<xsl:template match="*[tmp:PropertyName[tmp:step/tmp:localName/text() = 'AccessConstraints']]">
		<xsl:call-template name="classification">
			<xsl:with-param name="classification" select="'$c3'"/>
			<xsl:with-param name="classificationScheme" select="'RestrictionCode'"/>
			<xsl:with-param name="classifiedObject" select="'$e5'"/>
		</xsl:call-template>
	</xsl:template>

	<!-- classification -->
	<xsl:template match="*[tmp:PropertyName[tmp:step/tmp:localName/text() = 'Classification']]">
		<xsl:call-template name="classification">
			<xsl:with-param name="classification" select="'$c4'"/>
			<xsl:with-param name="classificationScheme" select="'ClassificationCode'"/>
			<xsl:with-param name="classifiedObject" select="'e6'"/>
		</xsl:call-template>
	</xsl:template>

	<!-- generic template for classifications, context node is a comparison -->
	<xsl:template name="classification">
		<xsl:param name="classification"/>
		<xsl:param name="classificationScheme"/>
		<xsl:param name="classifiedObject" select="'$e1'"/>
		<xsl:choose>
			<xsl:when test="local-name(..) = 'Or' or local-name(..) = 'Not'">
				<ogc:And>
					<xsl:call-template name="classificationComps">
						<xsl:with-param name="classification" select="$classification"/>
						<xsl:with-param name="classificationScheme" select="$classificationScheme"/>
						<xsl:with-param name="classifiedObject" select="$classifiedObject"/>
					</xsl:call-template>
				</ogc:And>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="classificationComps">
					<xsl:with-param name="classification" select="$classification"/>
					<xsl:with-param name="classificationScheme" select="$classificationScheme"/>
					<xsl:with-param name="classifiedObject" select="$classifiedObject"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- generic template for classifications, context node is a comparison -->
	<xsl:template name="classificationComps">
		<xsl:param name="classification"/>
		<xsl:param name="classificationScheme"/>
		<xsl:param name="classifiedObject"/>
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<ogc:PropertyName><xsl:value-of select="concat($classification, '/@classificationNode')"/></ogc:PropertyName>
			<ogc:Literal><xsl:value-of select="concat('urn:ogc:def:classificationScheme:OGC-CSW-ebRIM-CIM::', $classificationScheme, ':', ogc:Literal)"/></ogc:Literal>
		</xsl:copy>
		<ogc:PropertyIsEqualTo>
			<ogc:PropertyName><xsl:value-of select="concat($classifiedObject, '/@id')"/></ogc:PropertyName>
			<ogc:PropertyName><xsl:value-of select="concat($classification, '/@classifiedObject')"/></ogc:PropertyName>
		</ogc:PropertyIsEqualTo>
	</xsl:template>
	
	<xsl:template name="conceptUriIntern">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<ogc:PropertyName>$c6/rim:Slot[@name='urn:ogc:def:slot:OGC-CSW-ebRIM-CIM::url']/rim:ValueList/rim:Value</ogc:PropertyName>
			<ogc:Literal><xsl:value-of select="ogc:Literal"/></ogc:Literal>
		</xsl:copy>
		<ogc:PropertyIsEqualTo>
			<ogc:PropertyName><xsl:value-of select="'$e1/@id'"/></ogc:PropertyName>
			<ogc:PropertyName><xsl:value-of select="'$c6/@classifiedObject'"/></ogc:PropertyName>
		</ogc:PropertyIsEqualTo>
	</xsl:template>

	<!-- some queryable we can not map -->
	<xsl:template match="tmp:PropertyName">
		<xsl:message terminate="yes"><xsl:value-of select="concat('Unknown queryable: ', tmp:step/tmp:localName)"/></xsl:message>
	</xsl:template>


	<!-- +++++++++++++ -->
	<!-- GetRecordById -->
	<!-- +++++++++++++ -->

	<!-- +++++++++++++ -->
	<!-- GetRepositoryItem -->
	<!-- +++++++++++++ -->

	<!-- identity transform for all remaining objects -->
	<xsl:template match="node()|@*">
		<xsl:copy>
			<xsl:apply-templates select="node()|@*"/>
		</xsl:copy>
	</xsl:template>

</xsl:stylesheet>

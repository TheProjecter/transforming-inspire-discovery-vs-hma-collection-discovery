<?xml version="1.0" encoding="ISO-8859-1"?>
<!--
This stylesheet preprocesses a CIM EP request. No transformations are done regarding INSPIRE are included in this preprocessing step.
Instead, the request analyses and decomposes ebRIM property paths, including variables, and annotates the request with this extracted information by means of temporary elements.
These annotations are removed again by another stylesheet during the second transformation step, when the transformation to the INSPIRE request is executed.

 Author: Udo Einspanier, con terra GmbH
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:gml="http://www.opengis.net/gml" xmlns:csw="http://www.opengis.net/cat/csw/2.0.2" xmlns:ogc="http://www.opengis.net/ogc" xmlns:tmp="urn:aadd40b1-c384-41a1-bb5f-b9730a90daae" xmlns:rim="urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	<xsl:output method="xml"/>

	<!-- auxilliary variable to process text with single quote -->
	<xsl:variable name="apos">'</xsl:variable>

	<!-- remove schema location to avoid validation errors -->
	<xsl:template match="@xsi:schemaLocation"/>

	<!-- parse the typeNames in the query -->
	<xsl:template match="csw:Query">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<tmp:Query>
				<xsl:call-template name="parseTnList"/>
			</tmp:Query>
			<xsl:apply-templates select="node()"/>
		</xsl:copy>
	</xsl:template>
	
	<!-- parse the typeNames in the element set -->
	<xsl:template match="csw:ElementSetName">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
		<tmp:ElementSetName>
			<xsl:call-template name="parseTnList"/>
		</tmp:ElementSetName>
	</xsl:template>
	
	<!-- initial template to parse the whole string containing a list of typeName elements in csw:Query/@typeNames -->
	<xsl:template name="parseTnList">
		<xsl:variable name="tn" select="@typeNames"/>
		<xsl:call-template name="parseRemainingTnList">
			<xsl:with-param name="tn" select="$tn"/>
		</xsl:call-template>
	</xsl:template>

	<!-- parses remaining elements in the typeNames list -->
	<xsl:template name="parseRemainingTnList">
		<xsl:param name="tn"/>
		<xsl:choose>
			<xsl:when test="contains($tn, ' ')">
				<!-- more than one element in list -->
				<xsl:call-template name="parseTn">
					<xsl:with-param name="tn" select="substring-before($tn, ' ')"/>
				</xsl:call-template>
				<xsl:call-template name="parseRemainingTnList">
					<xsl:with-param name="tn" select="substring-after($tn, ' ')"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<!-- only one element left -->
				<xsl:call-template name="parseTn">
					<xsl:with-param name="tn" select="$tn"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- parses a single element in the typeNames list -->
	<xsl:template name="parseTn">
		<xsl:param name="tn"/>
		<tmp:typeName>
			<xsl:choose>
				<!-- check for variable -->
				<xsl:when test="contains($tn, '_')">
					<xsl:call-template name="parseTnVariable">
						<xsl:with-param name="tn" select="substring-after($tn, '_')"/>
					</xsl:call-template>
					<xsl:call-template name="parseQName">
						<xsl:with-param name="qn" select="substring-before($tn, '_')"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<!-- no variable for typeName -->
					<xsl:call-template name="parseQName">
						<xsl:with-param name="qn" select="$tn"/>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</tmp:typeName>
	</xsl:template>

	<!-- the typeName binds one or more variables, will only be called for typeNames with variables -->
	<xsl:template name="parseTnVariable">
		<xsl:param name="tn"/>
		<xsl:choose>
			<xsl:when test="contains($tn, '_')">
				<!--more than one variable binding in one typeName -->
				<xsl:call-template name="parseTnVariable">
					<xsl:with-param name="tn" select="substring-before($tn, '_')"/>
				</xsl:call-template>
				<xsl:call-template name="parseTnVariable">
					<xsl:with-param name="tn" select="substring-after($tn, '_')"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<!-- write an element for this single variable -->
				<tmp:variable>
					<xsl:value-of select="$tn"/>
				</tmp:variable>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- gets the local typename, ns prefix and ns uri of a single typeName element without variable bindings,
          will eventually be called for all typeNames -->
	<xsl:template name="parseQName">
		<xsl:param name="qn"/>
		<xsl:choose>
			<!-- check for prefix -->
			<xsl:when test="contains($qn, ':')">
				<xsl:variable name="prefix" select="substring-before($qn,':')"/>
				<tmp:nsPrefix>
					<xsl:value-of select="$prefix"/>
				</tmp:nsPrefix>
				<xsl:call-template name="parseNsUri">
					<xsl:with-param name="prefix" select="$prefix"/>
				</xsl:call-template>
				<tmp:localName>
					<xsl:value-of select="substring-after($qn,':')"/>
				</tmp:localName>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="parseNsUri"/>
				<tmp:localName>
					<xsl:value-of select="$qn"/>
				</tmp:localName>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- emits the namespace URI for a prefix -->
	<xsl:template name="parseNsUri">
		<xsl:param name="prefix"/>
		<tmp:nsUri>
			<xsl:value-of select="namespace::*[name() = $prefix]"/>
		</tmp:nsUri>
	</xsl:template>

	<!-- check if the comparison is a value comparison or just necessary for joins -->
	<xsl:template match="ogc:PropertyIsEqualTo">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
			<tmp:type>
				<xsl:choose>
					<xsl:when test="count(ogc:PropertyName) = 2">
						<xsl:text>join</xsl:text>
					</xsl:when>
					<xsl:when test="ogc:PropertyName[contains(text(), '/@objectType')]">
						<xsl:text>objectType</xsl:text>
					</xsl:when>
					<xsl:when test="ogc:PropertyName[contains(text(), '/@associationType')]">
						<xsl:text>associationType</xsl:text>
					</xsl:when>
					<xsl:when test="ogc:PropertyName[contains(text(), '/@name')]">
						<xsl:text>slotName</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>comparison</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</tmp:type>
		</xsl:copy>
	</xsl:template>
	
	<!-- annotate each property name  with a corresponding temporary element that represents a compasition of the ebRIM name -->
	<xsl:template match="ogc:PropertyName">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
		<tmp:PropertyName>
			<xsl:call-template name="parsePn">
				<xsl:with-param name="pn" select="text()"/>
			</xsl:call-template>
		</tmp:PropertyName>
	</xsl:template>

	<!-- parses the full property ebRIM path -->
	<xsl:template name="parsePn">
		<xsl:param name="pn"/>
		<xsl:choose>
			<xsl:when test="starts-with($pn, '/')">
				<!-- absolute XPath, make relative and parse again -->
				<xsl:call-template name="parsePn">
					<xsl:with-param name="pn" select="substring-after($pn,'/')"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="not(contains($pn, '/'))">
				<!-- the last step in the XPath -->
				<xsl:call-template name="parsePnStep">
					<xsl:with-param name="pn" select="$pn"/>
				</xsl:call-template>
			</xsl:when>			
			<xsl:when test="string-length(substring-before($pn, '[')) &lt; string-length(substring-before($pn, '/')) and string-length(substring-before($pn, '/')) &lt; string-length(substring-before($pn, ']'))">
				<!-- check for slot names that contain slashes! - only a single step -->
				<xsl:call-template name="parsePnStep">
					<xsl:with-param name="pn" select="concat(substring-before($pn, ']'), ']')"/>
				</xsl:call-template>
				<!-- parse the remaining part of the XPath -->
				<xsl:call-template name="parsePn">
					<xsl:with-param name="pn" select="substring-after($pn,']/')"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<!-- still more than one step in the XPath remaining -->
				<!-- parse the first step in the XPath -->
				<xsl:call-template name="parsePnStep">
					<xsl:with-param name="pn" select="substring-before($pn,'/')"/>
				</xsl:call-template>
				<!-- parse the remaining part of the XPath -->
				<xsl:call-template name="parsePn">
					<xsl:with-param name="pn" select="substring-after($pn,'/')"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- parses one step of an XPath -->	
	<xsl:template name="parsePnStep">
		<xsl:param name="pn"/>
		<tmp:step>
			<xsl:choose>
				<xsl:when test="starts-with($pn, '$')">
					<!-- step references a variable -->
					<xsl:call-template name="parseVariableStep">
						<xsl:with-param name="pn" select="$pn"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<!-- no variable -->
					<xsl:call-template name="parseAbbrevAxisStep">
						<xsl:with-param name="pn" select="$pn"/>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</tmp:step>
	</xsl:template>

	<!-- parses a step of on XPath that represents a variable (from typeNames list) -->
	<xsl:template name="parseVariableStep">
		<xsl:param name="pn"/>
		<!-- remove leading '$' -->
		<tmp:variable>
			<xsl:value-of select="substring-after($pn,'$')"/>
		</tmp:variable>
	</xsl:template>
	
	<!-- parses an abbreviated XPath step with optional simple predicate that is not a variable -->
	<xsl:template name="parseAbbrevAxisStep">
		<xsl:param name="pn"/>
		<xsl:choose>
			<xsl:when test="contains($pn,'[')">
				<!-- step contains predicate expression -->
				<xsl:call-template name="parseQName">
					<xsl:with-param name="qn" select="substring-before($pn,'[')"/>
				</xsl:call-template>
				<xsl:call-template name="parsePredicate">
					<xsl:with-param name="pn" select="substring-before(substring-after($pn,'['),']')"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<!-- step contains only a qName -->
				<xsl:call-template name="parseQName">
					<xsl:with-param name="qn" select="$pn"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- parses a simple predicate ([first=second]) expression with the brackets already removed -->
	<xsl:template name="parsePredicate">
		<xsl:param name="pn"/>
		<tmp:predicate>
			<!-- remove white space characters to simplify parsing -->
			<xsl:variable name="predicate" select="translate($pn,' ','')"/>
			<xsl:choose>
				<xsl:when test="contains($predicate,'=')">
					<!-- predicate equality expression -->
					<xsl:call-template name="parsePredicateFirst">
						<xsl:with-param name="first" select="substring-before($predicate,'=')"/>
					</xsl:call-template>
					<xsl:call-template name="parsePredicateSecond">
						<xsl:with-param name="second" select="substring-after($predicate,'=')"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<!-- presumably abbreviated expression -->
					<xsl:call-template name="parsePredicateSecond">
						<xsl:with-param name="second" select="$predicate"/>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</tmp:predicate>
	</xsl:template>
	
	<!-- parses the first part of a predicate equality expression (if present) -->
	<xsl:template name="parsePredicateFirst">
		<xsl:param name="first"/>
		<xsl:choose>
			<!-- ignore position function, same as abbreviated form -->
			<xsl:when test="not($first='position()')">
				<tmp:first>
					<xsl:value-of select="$first"/>
				</tmp:first>
			</xsl:when>
		</xsl:choose>		
	</xsl:template>

	<!-- parses the second part of a predicate expression, or whole expression if no first part is present -->
	<xsl:template name="parsePredicateSecond">
		<xsl:param name="second"/>
		<xsl:choose>
			<!-- string value -->
			<xsl:when test="starts-with($second, $apos)">
				<tmp:text>
					<xsl:value-of select="substring-before(substring-after($second, $apos), $apos)"/>
				</tmp:text>
			</xsl:when>
			<!-- other value, presumably a number for position -->
			<xsl:otherwise>
				<tmp:position>
					<xsl:value-of select="$second"/>
				</tmp:position>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="node()|@*">
		<xsl:copy>
			<xsl:apply-templates select="node()|@*"/>
		</xsl:copy>
	</xsl:template>

</xsl:stylesheet>

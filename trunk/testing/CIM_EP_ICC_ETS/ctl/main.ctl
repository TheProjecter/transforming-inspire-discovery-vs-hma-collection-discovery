<?xml version="1.0" encoding="UTF-8"?>
<!--
 * Project:		ESA HMA-T / SMAAD
 * Sub-Project:		CSW 2.0.2 AP ebRIM EP CIM (V 0.1.12) ICC Compliance Test Suite
 * Description:		Main-CTL-File
 * Organisation:  	con terra GmbH
 * Author:		Dr. Uwe Voges (u.voges@conterra.de)
 * Version:		2.0
-->
<ctl:package xmlns:ctl="http://www.occamlab.com/ctl" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xi="http://www.w3.org/2001/XInclude" xmlns:saxon="http://saxon.sf.net/" xmlns:ctlp="http://www.occamlab.com/te/parsers" xmlns:dct="http://purl.org/dc/terms/" xmlns:parsers="http://www.occamlab.com/te/parsers" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:sec="http://www.intecs.it/sec" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:csw="http://www.opengis.net/cat/csw/2.0.2" xmlns:util="http://www.occamlab.com/te/util" xmlns:ows="http://www.opengis.net/ows" xmlns:wrs="http://www.opengis.net/cat/wrs/1.0" xsi:schemaLocation="http://www.occamlab.com/ctl  ../apps/engine/resources/com/occamlab/te/schemas/ctl.xsd">
<!--
<package
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns="http://www.occamlab.com/ctl"
   xmlns:parsers="http://www.occamlab.com/te/parsers"
   xmlns:p="http://teamengine.sourceforge.net/parsers"
   xmlns:gmd="http://www.isotc211.org/2005/gmd"
   xmlns:soap="http://www.w3.org/2003/05/soap-envelope"
   xmlns:saxon="http://saxon.sf.net/"
   xmlns:csw="http://www.opengis.net/cat/csw/2.0.2"
   xmlns:csw2="http://www.opengis.net/cat/csw/2.0.2"
   xmlns:ows="http://www.opengis.net/ows"
   xmlns:dc="http://purl.org/dc/elements/1.1/"
   xmlns:dct="http://purl.org/dc/terms/"
   xmlns:xi="http://www.w3.org/2001/XInclude"
   xmlns:wrs="http://www.opengis.net/cat/wrs/1.0"
   xmlns:xsd="http://www.w3.org/2001/XMLSchema">
-->

	<xi:include href="common.xml"/>
   <xi:include href="icc.ctl"/>

  <ctl:suite name="csw:csw_2.0.2_ebRIM_CIM_ICC">
    <ctl:title>CSW 2.0.2 AP ebRIM EP CIM 0.1.12 ICC Compliance Test Suite</ctl:title>
    <ctl:description>
      Validates an OGC catalogue implementation against the CSW 2.0.2 AP ebRIM EP CIM ICC
    </ctl:description>
    <ctl:starting-test>csw:csw-main</ctl:starting-test>
  </ctl:suite>

  <ctl:test name="csw:csw-main">
    <ctl:assertion>Run the CSW 2.0.2 AP ebRIM EP CIM 0.1.12 ICC compliance tests</ctl:assertion>
    <ctl:code>
		<!-- ************************************************************************************************* -->
		<!-- DEFINITION OF COMMON PARAMETERS -->
		<!--
		<xsl:variable name="csw.capabilities.url">http://46.51.189.235/inspiretm/cimep?</xsl:variable>
		<xsl:variable name="csw.getrecords.url">http://46.51.189.235/inspiretm/cimep</xsl:variable>
		<xsl:variable name="csw.getrepositoryitem.url">http://46.51.189.235/inspiretm/cimep?</xsl:variable>
		-->
		<xsl:variable name="csw.capabilities.url">http://veoportal.eumetsat.int/inspiretm/cimep?</xsl:variable>
		<xsl:variable name="csw.getrecords.url">http://veoportal.eumetsat.int/inspiretm/cimep</xsl:variable>
		<xsl:variable name="csw.getrepositoryitem.url">http://veoportal.eumetsat.int/inspiretm/cimep?</xsl:variable>
          <ctl:message>URL og getCapabilities:</ctl:message>
          <ctl:message><xsl:value-of select="$csw.capabilities.url"/></ctl:message>
    
      <!-- Attempt to retrieve capabilities document -->
      <xsl:variable name="csw.GetCapabilities.document">
        <ctl:request>
          <ctl:url>
            <xsl:value-of select="$csw.capabilities.url"/>
          </ctl:url>
          <ctl:method>GET</ctl:method>
          <ctl:param name="service">CSW-ebRIM</ctl:param>
          <ctl:param name="request">GetCapabilities</ctl:param>
          <ctl:param name="acceptversion">2.0.2</ctl:param>
        </ctl:request>
      </xsl:variable>

      <xsl:choose>
        <xsl:when test="not($csw.GetCapabilities.document/wrs:Capabilities)">
          <ctl:message>FAILURE: Did not receive a wrs:Capabilities document! Skipping remaining tests.</ctl:message>
          <ctl:fail/>
        </xsl:when>
        <xsl:otherwise>
        <ctl:call-test name="csw:ICC">
            <ctl:with-param name="csw.capabilities.url" select="$csw.capabilities.url"/>  
            <ctl:with-param name="csw.getrecords.url" select="$csw.getrecords.url"/>  
            <ctl:with-param name="csw.getrepositoryitem.url" select="$csw.getrepositoryitem.url"/>  
          </ctl:call-test>
        </xsl:otherwise>
      </xsl:choose>
    </ctl:code>
  </ctl:test>
</ctl:package>

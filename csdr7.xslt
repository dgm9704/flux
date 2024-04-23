<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:exsl="http://exslt.org/common" xmlns:func="http://exslt.org/functions"
	xmlns:str="http://exslt.org/strings" xmlns:my="http://example.org/my"
	xmlns:date="http://exslt.org/dates-and-times"
	xmlns:p="urn:iso:std:iso:20022:tech:xsd:auth.100.001.01" exclude-result-prefixes="my p"
	extension-element-prefixes="func str exsl date">

	<xsl:output indent="yes" method="xml" />
	<xsl:variable name="eeacountrycodes" select="document('lookup/eea-countries.xml')/codes/code" />
	<xsl:variable name="countrycodes" select="document('lookup/iso-3166-1.xml')/codes/code" />
	<xsl:include href="common.xslt" />

	<xsl:variable name="csdr7validations" select="document('lookup/csdr7-validations.xml')" />

	<xsl:key name="validationlookup" match="rule" use="error_code" />

	<xsl:template name="CSDR7Error">
		<xsl:param name="code" />
		<xsl:param name="context" />
		<error>
			<code>
				<xsl:value-of select="$code" />
			</code>
			<xsl:for-each select="$csdr7validations">
				<xsl:for-each select="key('validationlookup', $code)">
					<control>
						<xsl:value-of select="control" />
					</control>
					<message>
						<xsl:value-of select="error_message" />
					</message>
				</xsl:for-each>
			</xsl:for-each>
			<context>
				<xsl:for-each select="exsl:node-set($context)">
					<field>
						<name>
							<xsl:call-template name="path" />
						</name>
						<value>
							<xsl:value-of select="." />
						</value>
					</field>
				</xsl:for-each>
			</context>
		</error>
	</xsl:template>

	<xsl:template match="/">
		<result>
			<xsl:apply-templates />
		</result>
	</xsl:template>

	<xsl:template match="p:RptgPrd/p:FrDt">
		<xsl:if test="date:day-in-month(.) != 1">
			<xsl:call-template name="CSDR7Error">
				<xsl:with-param name="code" select="'MSF-001'" />
				<xsl:with-param name="context" select="." />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="p:RptgPrd/p:ToDt">
		<xsl:variable name="date" select="." />
		<xsl:choose>
			<xsl:when test="date:time($date) != ''">
				<xsl:call-template name="CSDR7Error">
					<xsl:with-param name="code" select="'MSF-002'" />
					<xsl:with-param name="context" select="." />
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="monthadded" select="date:add($date, 'P1M')" />
				<xsl:variable name="firstofnext"
					select="concat(date:year($monthadded),'-',str:align(date:month-in-year($monthadded),'00', 'right'),'-01')" />
				<xsl:variable name="lastofmonth" select="date:add($firstofnext,'-P1D')" />
				<xsl:if test="$date != $lastofmonth">
					<xsl:call-template name="CSDR7Error">
						<xsl:with-param name="code" select="'MSF-003'" />
						<xsl:with-param name="context" select="." />
					</xsl:call-template>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- MSF-004 requires filename -->

	<!-- MSF-005 requires lookup -->

	<!-- MSF-006 requires LEI check -->

	<!-- MSF-007 requires lookup -->

	<!-- MSF-008 requires lookup -->

	<!-- MSF-009 requires lookup -->

	<!-- MSF-010 requires lookup -->

	<xsl:template match="p:MnthlyAggt/p:Ttl">
		<xsl:if test="p:Sttld/p:Vol + p:Faild/p:Vol != p:Ttl/p:Vol ">
			<xsl:call-template name="CSDR7Error">
				<xsl:with-param name="code" select="'MSF-011'" />
				<xsl:with-param name="context" select="p:Ttl/p:Vol|p:Sttld/p:Vol|p:Faild/p:Vol" />
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="p:Faild/p:Vol div p:Ttl/p:Vol != p:FaildRate/p:Vol">
			<xsl:call-template name="CSDR7Error">
				<xsl:with-param name="code" select="'MSF-012'" />
				<xsl:with-param name="context" select="p:Faild/p:Vol|p:Ttl/p:Vol|p:FaildRate/p:Vol" />
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="p:Sttld/p:Val + p:Faild/p:Val != p:Ttl/p:Val ">
			<xsl:call-template name="CSDR7Error">
				<xsl:with-param name="code" select="'MSF-013'" />
				<xsl:with-param name="context" select="p:Ttl/p:Val|p:Sttld/p:Val|p:Faild/p:Val" />
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="p:Faild/p:Val div p:Ttl/p:Val != p:FaildRate/p:Val">
			<xsl:call-template name="CSDR7Error">
				<xsl:with-param name="code" select="'MSF-014'" />
				<xsl:with-param name="context" select="p:Faild/p:Val|p:Ttl/p:Val|p:FaildRate/p:Val" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<!-- MSF-015 requires LEI check -->

	<!-- MSF-016 requires lookup -->

	<xsl:template match="text()|@*">
		<!-- <xsl:value-of select="."/> -->
	</xsl:template>

</xsl:transform>
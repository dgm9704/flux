<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:exsl="http://exslt.org/common" xmlns:func="http://exslt.org/functions"
	xmlns:str="http://exslt.org/strings" xmlns:my="http://example.org/my"
	xmlns:h="urn:iso:std:iso:20022:tech:xsd:head.001.001.01"
	exclude-result-prefixes="my" extension-element-prefixes="func str exsl">

	<xsl:output indent="yes" method="xml" />
	<xsl:variable name="eeacountrycodes" select="document('lookup/eea-countries.xml')/codes/code" />
	<xsl:variable name="countrycodes" select="document('lookup/iso-3166-1.xml')/codes/code" />
	<xsl:include href="common.xslt" />

	<xsl:variable name="mmf9validations" select="document('lookup/mmf-validations.xml')" />

	<xsl:key name="validationlookup" match="rule" use="error_code" />

	<xsl:template name="MMFError">
		<xsl:param name="code" />
		<xsl:param name="context" />
		<error>
			<code>
				<xsl:value-of select="$code" />
			</code>
			<xsl:for-each select="$mmf9validations">
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

	<xsl:template match="h:AppHdr/h:To/h:OrgId/h:Id/h:OrgId/h:Othr/h:Id">
		<xsl:if test=". != 'EU'">
			<xsl:call-template name="MMFError">
				<xsl:with-param name="code" select="'1'" />
				<xsl:with-param name="context" select="." />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="text()|@*">
		<!-- <xsl:value-of select="."/> -->
	</xsl:template>

</xsl:transform>
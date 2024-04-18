<xsl:transform version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:exsl="http://exslt.org/common" 
	xmlns:func="http://exslt.org/functions"
	xmlns:str="http://exslt.org/strings" 
	xmlns:my="http://example.org/my"
	
	xmlns:ix="http://www.xbrl.org/2013/inlineXBRL" 
	xmlns:xbrli="http://www.xbrl.org/2003/instance"

	exclude-result-prefixes="my" extension-element-prefixes="func str exsl">

	<xsl:output indent="yes" method="xml" />
	<xsl:variable name="eeacountrycodes" select="document('lookup/eea-countries.xml')/codes/code" />
	<xsl:variable name="countrycodes" select="document('lookup/iso-3166-1.xml')/codes/code" />
	<xsl:include href="common.xslt" />

	<xsl:variable name="esefvalidations" select="document('lookup/esef-validations.xml')" />

	<xsl:key name="validationlookup" match="rule" use="error_code" />

	<xsl:template name="ESEFError">
		<xsl:param name="code" />
		<xsl:param name="context" />
		<error>
			<code>
				<xsl:value-of select="$code" />
			</code>
			<xsl:for-each select="$esefvalidations">
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

	<xsl:template match="ix:resources/xbrli:context/xbrli:entity/xbrli:identifier">
		<xsl:if test="@scheme != 'http://standards.iso.org/iso/17442'">
			<xsl:call-template name="ESEFError">
				<xsl:with-param name="code" select="'G2_1_1'" />
				<xsl:with-param name="context" select="@scheme" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="text()|@*">
		<!-- <xsl:value-of select="."/> -->
	</xsl:template>

</xsl:transform>
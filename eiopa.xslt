<xsl:transform version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:exsl="http://exslt.org/common"
	xmlns:func="http://exslt.org/functions"
	xmlns:str="http://exslt.org/strings"
	xmlns:my="http://example.org/my"
	xmlns:xbrli="http://www.xbrl.org/2003/instance"
	xmlns:xbrldi="http://xbrl.org/2006/xbrldi"
	xmlns:link="http://www.xbrl.org/2003/linkbase"
	xmlns:find="http://www.eurofiling.info/xbrl/ext/filing-indicators"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:xi="http://www.w3.org/2001/XInclude"
	xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:utr="http://www.xbrl.org/2009/utr"
	exclude-result-prefixes="my xbrli xbrldi link find xsi xi xlink utr"
	extension-element-prefixes="func str exsl my">

	<xsl:output indent="yes" method="xml" omit-xml-declaration="yes" />

	<xsl:include href="common.xslt" />

	<xsl:variable name="eiopavalidations" select="document('lookup/eiopa-filing-rules.xml')" />
	<xsl:variable name="entrypoints" select="document('lookup/eiopa-entrypoints.xml')/entrypoints/entrypoint" />

	<xsl:key name="validationlookup" match="rule" use="number" />

	<xsl:template name="EIOPAError">
		<xsl:param name="number" />
		<xsl:param name="context" />
		<error>
			<xsl:for-each select="$eiopavalidations">
				<xsl:for-each select="key('validationlookup', $number)">
					<number>
						<xsl:value-of select="number" />
					</number>
					<code>
						<xsl:value-of select="code" />
					</code>
					<severity>
						<xsl:value-of select="severity" />
					</severity>
					<message>
						<xsl:value-of select="message" />
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

	<xsl:template match="/xbrli:xbrl">

		<xsl:apply-templates select="@*" />

		<xsl:if test="count(//link:schemaRef) &gt; 1 or not($entrypoints[./href = $href])">
			<xsl:call-template name="EIOPAError">
				<xsl:with-param name="number" select="'1.5.(a)'" />
				<xsl:with-param name="context" select="//link:schemaRef/@xlink:href" />
			</xsl:call-template>
		</xsl:if>

		<xsl:apply-templates />

	</xsl:template>



	<xsl:template match="text()|@*">
		<!-- <xsl:value-of select="." /> -->
	</xsl:template>

</xsl:transform>
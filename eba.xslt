<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:exsl="http://exslt.org/common" xmlns:func="http://exslt.org/functions"
	xmlns:str="http://exslt.org/strings" xmlns:my="http://example.org/my"
	xmlns:xbrli="http://www.xbrl.org/2003/instance" xmlns:link="http://www.xbrl.org/2003/linkbase"
	xmlns:find="http://www.eurofiling.info/xbrl/ext/filing-indicators"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xi="http://www.w3.org/2001/XInclude"
	xmlns:xml="http://www.w3.org/XML/1998/namespace" xmlns:xlink="http://www.w3.org/1999/xlink"
	exclude-result-prefixes="my xbrli link find xsi xi xlink"
	extension-element-prefixes="func str exsl">

	<xsl:output indent="yes" method="xml" omit-xml-declaration="yes" />
	<xsl:variable name="eeacountrycodes" select="document('lookup/eea-countries.xml')/codes/code" />
	<xsl:variable name="countrycodes" select="document('lookup/iso-3166-1.xml')/codes/code" />
	<xsl:include href="common.xslt" />

	<xsl:variable name="ebavalidations" select="document('lookup/eba-validations.xml')" />

	<xsl:key name="validationlookup" match="rule" use="error_code" />

	<xsl:template name="EBAError">
		<xsl:param name="code" />
		<xsl:param name="context" />
		<error>
			<code>
				<xsl:value-of select="$code" />
			</code>
			<xsl:for-each select="$ebavalidations">
				<xsl:for-each select="key('validationlookup', $code)">
					<control>
						<xsl:value-of select="control" />
					</control>
					<message>
						<xsl:value-of select="error_message" />
					</message>
					<severity>
						<xsl:value-of select="severity" />
					</severity>
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

	<!-- 1.1 requires file name -->

	<!-- 1.4 requires XML declaration -->

	<xsl:template match="xbrli:xbrl">
		<xsl:if test="count(//link:schemaRef) &gt; 1">
			<xsl:call-template name="EBAError">
				<xsl:with-param name="code" select="'1.5.a'" />
				<xsl:with-param name="context" select="//link:schemaRef/@xlink:href" />
			</xsl:call-template>
			<xsl:call-template name="EBAError">
				<xsl:with-param name="code" select="'2.3'" />
				<xsl:with-param name="context" select="//link:schemaRef/@xlink:href" />
			</xsl:call-template>
		</xsl:if>
		<!-- 1.5.2 requires lookup -->

		<xsl:if test="count(//find:fIndicators) &gt; 1">
			<xsl:call-template name="EBAError">
				<xsl:with-param name="code" select="'1.6.2'" />
				<xsl:with-param name="context" select="//find:fIndicators" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="@xsi:schemaLocation">
			<xsl:call-template name="EBAError">
				<xsl:with-param name="code" select="'1.14.a'" />
				<xsl:with-param name="context" select="@xsi:schemaLocation" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="@xsi:noNamespaceSchemaLocation">
			<xsl:call-template name="EBAError">
				<xsl:with-param name="code" select="'1.14.b'" />
				<xsl:with-param name="context" select="@xsi:noNamespaceSchemaLocation" />
			</xsl:call-template>
		</xsl:if>

		<xsl:apply-templates />

	</xsl:template>

	<xsl:template match="find:fIndicators">
		<xsl:variable name="contextRefs"
			select="//find:filingIndicator[not(@contextRef=preceding::find:filingIndicator/@contextRef)]/@contextRef" />
		<xsl:for-each select="$contextRefs">
			<xsl:variable name="id" select="." />
			<xsl:if test="/xbrli:xbrl/xbrli:context[@id=$id]/xbrli:scenario|xbrli:segment">
				<xsl:call-template name="EBAError">
					<xsl:with-param name="code" select="'1.6.c'" />
					<xsl:with-param name="context" select="." />
				</xsl:call-template>
			</xsl:if>
		</xsl:for-each>

		<xsl:variable name="templates"
			select="//find:filingIndicator[not(text()=preceding::find:filingIndicator/text())]" />
		<xsl:for-each select="$templates">
			<xsl:variable name="template" select="." />
			<xsl:if
				test="count(/xbrli:xbrl/find:fIndicators/find:filingIndicator[text()=$template]) &gt; 1">
				<xsl:call-template name="EBAError">
					<xsl:with-param name="code" select="'1.6.1'" />
					<xsl:with-param name="context" select="$template" />
				</xsl:call-template>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<!-- 1.6.3 requires taxonomy -->
	<!-- 1.7.a requires taxonomy -->
	<!-- 1.7.b requires taxonomy -->
	<!-- 1.7.1 requires taxonomy -->
	<!-- 1.9 requires schema validations -->
	<!-- 1.10 requires content validations -->
	<!-- 1.11 requires lookup/taxonomy -->
	<!-- 1.12 requires information outside the report -->
	<!-- 1.13 requires information not available in xslt -->

	<xsl:template match="xi:include">
		<xsl:call-template name="EBAError">
			<xsl:with-param name="code" select="'1.15'" />
			<xsl:with-param name="context" select="." />
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="@xml:base">
		<xsl:call-template name="EBAError">
			<xsl:with-param name="code" select="'2.1'" />
			<xsl:with-param name="context" select="." />
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="/xbrli:xbrl/link:schemaRef">
		<xsl:variable name="href" select="@xlink:href" />
		<xsl:if test="not(starts-with($href,'http://'))">
			<xsl:call-template name="EBAError">
				<xsl:with-param name="code" select="'2.2'" />
				<xsl:with-param name="context" select="$href" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="link:linkbaseRef">
		<xsl:call-template name="EBAError">
			<xsl:with-param name="code" select="'2.4'" />
			<xsl:with-param name="context" select="." />
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="xbrli:xbrl/comment()">
		<xsl:call-template name="EBAError">
			<xsl:with-param name="code" select="'2.5'" />
			<xsl:with-param name="context" select="." />
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="link:footnote">
		<xsl:call-template name="EBAError">
			<xsl:with-param name="code" select="'2.25'" />
			<xsl:with-param name="context" select="." />
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="/">
		<result>
			<xsl:variable name="pi" select="processing-instruction('instance-generator')" />
			<xsl:variable name="id" select="substring-before(substring-after($pi,'id=&quot;'),'&quot;')"/>
			<xsl:variable name="version" select="substring-before(substring-after($pi,'version=&quot;'),'&quot;')"/>
			<xsl:variable name="creationdate" select="substring-before(substring-after($pi,'creationdate=&quot;'),'&quot;')"/>
			<xsl:if test="not($pi) or not($id) or not($version) or not($creationdate)">
				<xsl:call-template name="EBAError">
					<xsl:with-param name="code" select="'2.26'" />
					<xsl:with-param name="context" select="$pi" />
				</xsl:call-template>
			</xsl:if>
			<xsl:apply-templates />
			<xsl:apply-templates select="//@*" />
		</result>
	</xsl:template>

	<xsl:template match="xbrli:context">
		<xsl:if test="string-length(@id) &gt; 40"> 
			<xsl:call-template name="EBAError">
				<xsl:with-param name="code" select="'2.6.a'" />
				<xsl:with-param name="context" select="@id" />
			</xsl:call-template>
			<xsl:call-template name="EBAError">
				<xsl:with-param name="code" select="'2.6.b'" />
				<xsl:with-param name="context" select="@id" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
	<xsl:template match="text()|@*">
		<!-- <xsl:value-of select="."/> -->
	</xsl:template>

</xsl:transform>
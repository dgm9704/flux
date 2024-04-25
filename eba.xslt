<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:exsl="http://exslt.org/common" xmlns:func="http://exslt.org/functions"
	xmlns:str="http://exslt.org/strings" xmlns:my="http://example.org/my"
	xmlns:xbrli="http://www.xbrl.org/2003/instance" xmlns:xbrldi="http://xbrl.org/2006/xbrldi"
	xmlns:link="http://www.xbrl.org/2003/linkbase"
	xmlns:find="http://www.eurofiling.info/xbrl/ext/filing-indicators"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xi="http://www.w3.org/2001/XInclude"
	xmlns:xml="http://www.w3.org/XML/1998/namespace" xmlns:xlink="http://www.w3.org/1999/xlink"
	exclude-result-prefixes="my xbrli xbrldi link find xsi xi xlink"
	extension-element-prefixes="func str exsl my">

	<xsl:output indent="yes" method="xml" omit-xml-declaration="yes" />
	<xsl:variable name="eeacountrycodes" select="document('lookup/eea-countries.xml')/codes/code" />
	<xsl:variable name="countrycodes" select="document('lookup/iso-3166-1.xml')/codes/code" />
	<xsl:include href="common.xslt" />

	<xsl:variable name="ebavalidations" select="document('lookup/eba-validations.xml')" />

	<xsl:key name="validationlookup" match="rule" use="error_code" />

	<xsl:key name="scenario" match="/xbrli:xbrl/xbrli:context" use="my:cid(.)" />

	<func:function name="my:cid">
		<xsl:param name="context" />
		<xsl:variable name="result">
			<xsl:for-each select="$context/xbrli:scenario/xbrldi:explicitMember">
				<xsl:value-of select="substring-after(@dimension, ':')" />=<xsl:value-of
					select="text()" />,</xsl:for-each>
			<xsl:for-each select="$context/xbrli:scenario/xbrldi:typedMember">
				<xsl:value-of select="substring-after(@dimension, ':')" />=<xsl:value-of
					select="*[1]/text()" />,</xsl:for-each>
		</xsl:variable>
		<func:result select="substring($result, 1, string-length($result)-1)" />
	</func:function>


	<!-- <func:function name="my:cid">
		<xsl:param name="context" />
		<xsl:variable name="result">
			<xsl:for-each select="$context/xbrli:scenario/xbrldi:explicitMember">
				<xsl:value-of select="@dimension" />=<xsl:value-of select="text()" />,</xsl:for-each>
			<xsl:for-each select="$context/xbrli:scenario/xbrldi:typedMember">
				<xsl:value-of select="@dimension" />=<xsl:value-of select="name(*[1])" />:<xsl:value-of
					select="*[1]/text()" />,</xsl:for-each>
		</xsl:variable>
		<func:result select="substring($result, 1, string-length($result)-1)" />
	</func:function> -->

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

		<xsl:variable name="identifiers" select="xbrli:context/xbrli:entity/xbrli:identifier" />
		<xsl:variable name="distinct_identifiers"
			select="$identifiers[not(text()=preceding::xbrli:identifier/text())]" />
		<xsl:if test="count($distinct_identifiers) &gt; 1">
			<xsl:call-template name="EBAError">
				<xsl:with-param name="code" select="'2.9'" />
				<xsl:with-param name="context" select="$distinct_identifiers" />
			</xsl:call-template>
		</xsl:if>

		<xsl:variable name="distinct_schemes"
			select="$identifiers[not(@scheme=preceding::xbrli:identifier/@scheme)]/@scheme" />
		<xsl:if test="count($distinct_schemes) &gt; 1">
			<xsl:call-template name="EBAError">
				<xsl:with-param name="code" select="'2.9'" />
				<xsl:with-param name="context" select="$distinct_schemes" />
			</xsl:call-template>
		</xsl:if>

		<xsl:variable name="instants" select="xbrli:context/xbrli:period/xbrli:instant" />
		<xsl:variable name="distinct_instants"
			select="$instants[not(text()=preceding::xbrli:instant/text())]" />
		<xsl:if test="count($distinct_instants) &gt; 1">
			<xsl:call-template name="EBAError">
				<xsl:with-param name="code" select="'2.13.a'" />
				<xsl:with-param name="context" select="$distinct_instants" />
			</xsl:call-template>
		</xsl:if>

		<xsl:variable name="noninstants"
			select="xbrli:context/xbrli:period/*[name()!='xbrli:instant']" />
		<xsl:if test="noninstants">
			<xsl:call-template name="EBAError">
				<xsl:with-param name="code" select="'2.13.b'" />
				<xsl:with-param name="context" select="$noninstants" />
			</xsl:call-template>
		</xsl:if>
		<!-- /root/*[not(name()='terminate')] -->

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
			<xsl:variable name="id"
				select="substring-before(substring-after($pi,'id=&quot;'),'&quot;')" />
			<xsl:variable name="version"
				select="substring-before(substring-after($pi,'version=&quot;'),'&quot;')" />
			<xsl:variable name="creationdate"
				select="substring-before(substring-after($pi,'creationdate=&quot;'),'&quot;')" />
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

	<xsl:template match="/xbrli:xbrl/xbrli:context">
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
		<xsl:variable name="id" select="@id" />
		<xsl:if
			test="not(/xbrli:xbrl/*[@contextRef=$id] or /xbrli:xbrl/find:fIndicators/find:filingIndicator[@contextRef=$id])">
			<xsl:call-template name="EBAError">
				<xsl:with-param name="code" select="'2.7.a'" />
				<xsl:with-param name="context" select="$id" />
			</xsl:call-template>
		</xsl:if>
		<xsl:variable name="cid" select="my:cid(.)" />
		<xsl:variable name="matching" select="key('scenario', $cid)" />
		<xsl:if test="count($matching) &gt; 1 and $matching[1]/@id=$id">
			<xsl:call-template name="EBAError">
				<xsl:with-param name="code" select="'2.7.b'" />
				<xsl:with-param name="context" select="exsl:node-set($cid)|$matching/@id" />
			</xsl:call-template>
		</xsl:if>

		<xsl:apply-templates />
	</xsl:template>

	<!-- 2.8.a requires lookup etc -->
	<!-- 2.8.b requires lookup etc -->
	<!-- 2.8.c requires lookup etc -->

	<xsl:template match="/xbrli:xbrl/xbrli:context/xbrli:period/xbrli:instant">
		<xsl:if test="contains(text(),'T')">
			<xsl:call-template name="EBAError">
				<xsl:with-param name="code" select="'2.10.a'" />
				<xsl:with-param name="context" select="." />
			</xsl:call-template>
		</xsl:if>
		<xsl:if
			test="contains(substring-after(text(),'T'), '+') or contains(substring-after(text(),'T'), '-') or contains(substring-after(text(),'T'), 'Z')">
			<xsl:call-template name="EBAError">
				<xsl:with-param name="code" select="'2.10.b'" />
				<xsl:with-param name="context" select="." />
			</xsl:call-template>
		</xsl:if>

	</xsl:template>

	<xsl:template match="xbrli:forever">
		<xsl:call-template name="EBAError">
			<xsl:with-param name="code" select="'2.11'" />
			<xsl:with-param name="context" select="." />
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="xbrli:segment">
		<xsl:call-template name="EBAError">
			<xsl:with-param name="code" select="'2.14'" />
			<xsl:with-param name="context" select="." />
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="text()|@*">
		<!-- <xsl:value-of select="."/> -->
	</xsl:template>

</xsl:transform>
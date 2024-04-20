<xsl:transform version="1.0" xmlns:xml="http://www.w3.org/XML/1998/namespace"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exsl="http://exslt.org/common"
	xmlns:func="http://exslt.org/functions" xmlns:str="http://exslt.org/strings"
	xmlns:my="http://example.org/my" xmlns:ix="http://www.xbrl.org/2013/inlineXBRL"
	xmlns:xbrli="http://www.xbrl.org/2003/instance" xmlns:xbrldi="http://xbrl.org/2006/xbrldi"
	xmlns:xhtml="http://www.w3.org/1999/xhtml"
	exclude-result-prefixes="my ix xbrli xbrldi xhtml" extension-element-prefixes="func str exsl">

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

	<xsl:template
		match="ix:resources/xbrli:context/xbrli:period/xbrli:startDate|xbrli:endDate|xbrli:instant">
		<xsl:variable name="date" select="." />
		<xsl:if test="string-length($date) != 10">
			<xsl:call-template name="ESEFError">
				<xsl:with-param name="code" select="'G2_1_2'" />
				<xsl:with-param name="context" select="." />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="ix:resources/xbrli:context/xbrli:entity/xbrli:segment">
		<xsl:call-template name="ESEFError">
			<xsl:with-param name="code" select="'G2_1_3_1'" />
			<xsl:with-param name="context" select="." />
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="ix:resources/xbrli:context/xbrli:scenario/*">
		<xsl:if test="not(name() = 'xbrldi:explicitMember' or name() = 'xbrldi:typedMember')">
			<xsl:call-template name="ESEFError">
				<xsl:with-param name="code" select="'G2_1_3_2'" />
				<xsl:with-param name="context" select="." />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="ix:resources/xbrli:context/xbrli:entity/xbrli:identifier">
		<xsl:variable name="firstValue"
			select="//ix:resources/xbrli:context[1]/xbrli:entity/xbrli:identifier" />
		<xsl:if test=". != $firstValue">
			<xsl:call-template name="ESEFError">
				<xsl:with-param name="code" select="'G2_1_4'" />
				<xsl:with-param name="context" select="$firstValue|." />
			</xsl:call-template>
		</xsl:if>
		<xsl:variable name="firstScheme"
			select="//ix:resources/xbrli:context[1]/xbrli:entity/xbrli:identifier/@scheme" />
		<xsl:if test="@scheme != $firstScheme">
			<xsl:call-template name="ESEFError">
				<xsl:with-param name="code" select="'G2_1_4'" />
				<xsl:with-param name="context" select="$firstScheme|@scheme" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="ix:*[@contextRef!=''][@precision]">
		<xsl:call-template name="ESEFError">
			<xsl:with-param name="code" select="'G2_2_1'" />
			<xsl:with-param name="context" select=".|@precision" />
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="ix:*[@contextRef!=''][@format]">
		<xsl:variable name="prefix" select="substring-before(@format, ':')" />
		<xsl:variable name="uri" select="namespace::node()[local-name()=$prefix]" />
		<xsl:if test="$uri != 'http://www.xbrl.org/inlineXBRL/transformation/2020-02-12'">
			<xsl:call-template name="ESEFError">
				<xsl:with-param name="code" select="'G2_2_3'" />
				<xsl:with-param name="context" select="$uri" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="ix:*[@contextRef!='' and @decimals]">
		<xsl:variable name="metric" select="@name" />
		<xsl:variable name="context" select="@contextRef" />
		<xsl:variable name="value" select="." />
		<xsl:variable name="other" select="//*[@name=$metric and @contextRef=$context]" />
		<xsl:if test="$other[1] != $value">
			<xsl:call-template name="ESEFError">
				<xsl:with-param name="code" select="'G2_2_4_1'" />
				<xsl:with-param name="context" select="$metric|$context|$value|$other" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="ix:nonNumeric[@contextRef!='']">
		<xsl:variable name="metric" select="@name" />
		<xsl:variable name="context" select="@contextRef" />
		<xsl:variable name="value" select="." />
		<xsl:variable name="other" select="//ix:nonNumeric[@name=$metric and @contextRef=$context]" />
		<xsl:if test="$other[1] != $value">
			<xsl:call-template name="ESEFError">
				<xsl:with-param name="code" select="'G2_2_4_2'" />
				<xsl:with-param name="context" select="$metric|$context|$value|$other" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="ix:footnote">
		<xsl:variable name="id" select="@id" />
		<xsl:if test="not(//ix:relationship[@toRefs=$id])">
			<xsl:call-template name="ESEFError">
				<xsl:with-param name="code" select="'G2_3_1'" />
				<xsl:with-param name="context" select="." />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<!-- <xsl:template match="ix:relationship">
		<xsl:variable name="id" select="@id" />
		<xsl:if test="not(//ix:relationship[@toRefs=$id])" > 
			<xsl:call-template name="ESEFError">
				<xsl:with-param name="code" select="'G2_3_2'" />
				<xsl:with-param name="context" select="." />
			</xsl:call-template>
		</xsl:if>
	</xsl:template> -->

	<xsl:template match="ix:relationship">
		<xsl:variable name="lang" select="/xhtml:html/@xml:lang" />
		<xsl:variable name="foo" select="/*/@xml:lang" />
		<xsl:variable name="id" select="@toRefs" />
		<xsl:variable name="footnote" select="//ix:footnote[@id=$id]" />
		<xsl:if test="$footnote/@xml:lang != $lang" >
			<xsl:call-template name="ESEFError">
				<xsl:with-param name="code" select="'G2_3_3'" />
				<xsl:with-param name="context" select="$lang|$footnote" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="text()|@*">
		<!-- <xsl:value-of select="."/> -->
	</xsl:template>

</xsl:transform>
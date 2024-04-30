<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:exsl="http://exslt.org/common" xmlns:func="http://exslt.org/functions"
	xmlns:str="http://exslt.org/strings" xmlns:my="http://example.org/my"
	xmlns:xbrli="http://www.xbrl.org/2003/instance" xmlns:xbrldi="http://xbrl.org/2006/xbrldi"
	xmlns:link="http://www.xbrl.org/2003/linkbase"
	xmlns:find="http://www.eurofiling.info/xbrl/ext/filing-indicators"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xi="http://www.w3.org/2001/XInclude"
	xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:eba_met="http://www.eba.europa.eu/xbrl/crr/dict/met"
	xmlns:eba_typ="http://www.eba.europa.eu/xbrl/crr/dict/typ"
	xmlns:utr="http://www.xbrl.org/2009/utr"
	exclude-result-prefixes="my xbrli xbrldi link find xsi xi xlink eba_met eba_typ utr"
	extension-element-prefixes="func str exsl my">

	<xsl:output indent="yes" method="xml" omit-xml-declaration="yes" />
	<xsl:variable name="eeacountrycodes" select="document('lookup/eea-countries.xml')/codes/code" />
	<xsl:variable name="countrycodes" select="document('lookup/iso-3166-1.xml')/codes/code" />
	<xsl:variable name="entrypoints" select="document('lookup/eba-entrypoints.xml')/entrypoints/entrypoint" />
	<xsl:variable name="units" select="document('lookup/utr.xml')/utr:utr/utr:units/utr:unit/utr:unitId" />
	<xsl:include href="common.xslt" />

	<xsl:variable name="ebavalidations" select="document('lookup/eba-filing-rules.xml')" />

	<xsl:key name="validationlookup" match="rule" use="number" />

	<xsl:key name="scenario" match="/xbrli:xbrl/xbrli:context" use="my:cid(.)" />
	<xsl:key name="context" match="/xbrli:xbrl/xbrli:context" use="@id" />
	<xsl:key name="cid-fact" match="eba_met:*" use="my:cid-byref(@contextRef)" />
	<xsl:key name="namespace" match="/xbrli:xbrl/namespace::*" use="." />

	<xsl:variable name="reportcurrency" select="'iso4217:EUR'" />

	<func:function name="my:cid" cache="yes">
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

	<func:function name="my:cid-byref" cache="yes">
		<xsl:param name="id" />
		<func:result select="my:cid(/xbrli:xbrl/xbrli:context[@id=$id][1])" />
	</func:function>

	<xsl:template name="EBAError">
		<xsl:param name="number" />
		<xsl:param name="context" />
		<error>
			<xsl:for-each select="$ebavalidations">
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


		<xsl:if test="count(//link:schemaRef) &gt; 1">
			<xsl:call-template name="EBAError">
				<xsl:with-param name="number" select="'1.5.a'" />
				<xsl:with-param name="context" select="//link:schemaRef/@xlink:href" />
			</xsl:call-template>
			<xsl:call-template name="EBAError">
				<xsl:with-param name="number" select="'2.3'" />
				<xsl:with-param name="context" select="//link:schemaRef/@xlink:href" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="count(//find:fIndicators) &gt; 1">
			<xsl:call-template name="EBAError">
				<xsl:with-param name="number" select="'1.6.2'" />
				<xsl:with-param name="context" select="//find:fIndicators" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="@xsi:schemaLocation">
			<xsl:call-template name="EBAError">
				<xsl:with-param name="number" select="'1.14.a'" />
				<xsl:with-param name="context" select="@xsi:schemaLocation" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="@xsi:noNamespaceSchemaLocation">
			<xsl:call-template name="EBAError">
				<xsl:with-param name="number" select="'1.14.b'" />
				<xsl:with-param name="context" select="@xsi:noNamespaceSchemaLocation" />
			</xsl:call-template>
		</xsl:if>

		<xsl:variable name="identifiers" select="xbrli:context/xbrli:entity/xbrli:identifier" />
		<xsl:variable name="distinct_identifiers"
			select="$identifiers[not(text()=preceding::xbrli:identifier/text())]" />
		<xsl:if test="count($distinct_identifiers) &gt; 1">
			<xsl:call-template name="EBAError">
				<xsl:with-param name="number" select="'2.9'" />
				<xsl:with-param name="context" select="$distinct_identifiers" />
			</xsl:call-template>
		</xsl:if>

		<xsl:variable name="distinct_schemes"
			select="$identifiers[not(@scheme=preceding::xbrli:identifier/@scheme)]/@scheme" />
		<xsl:if test="count($distinct_schemes) &gt; 1">
			<xsl:call-template name="EBAError">
				<xsl:with-param name="number" select="'2.9'" />
				<xsl:with-param name="context" select="$distinct_schemes" />
			</xsl:call-template>
		</xsl:if>

		<xsl:variable name="instants" select="xbrli:context/xbrli:period/xbrli:instant" />
		<xsl:variable name="distinct_instants"
			select="$instants[not(text()=preceding::xbrli:instant/text())]" />
		<xsl:if test="count($distinct_instants) &gt; 1">
			<xsl:call-template name="EBAError">
				<xsl:with-param name="number" select="'2.13.a'" />
				<xsl:with-param name="context" select="$distinct_instants" />
			</xsl:call-template>
		</xsl:if>

		<xsl:for-each select="namespace::*">
			<xsl:if test="not(local-name()='xml')">
				<xsl:if test="not(//*[namespace-uri()=current()])">
					<xsl:if
						test="not(/xbrli:xbrl/xbrli:context/xbrli:scenario/xbrldi:explicitMember[substring-before(.,':')=local-name(current())])">
						<xsl:if
							test="not(/xbrli:xbrl//*[substring-before(.,':')=local-name(current())])">
							<xsl:if
								test="not(/*//*[substring-before(@dimension,':')=local-name(current())])">
								<xsl:if test="not(/*//@*[namespace-uri()=current()])">
									<xsl:call-template name="EBAError">
										<xsl:with-param name="number" select="'3.4'" />
										<xsl:with-param name="context" select="." />
									</xsl:call-template>
								</xsl:if>
							</xsl:if>
						</xsl:if>
					</xsl:if>
				</xsl:if>
			</xsl:if>
		</xsl:for-each>

		<xsl:for-each select="//*[not(contains(name(),':'))]">
			<xsl:call-template name="EBAError">
				<xsl:with-param name="number" select="'3.9'" />
				<xsl:with-param name="context" select="exsl:node-set(namespace-uri(.))|." />
			</xsl:call-template>
		</xsl:for-each>

		<xsl:apply-templates />


	</xsl:template>

	<xsl:template match="/xbrli:xbrl/find:fIndicators">
		<xsl:variable name="contextRefs"
			select="//find:filingIndicator[not(@contextRef=preceding::find:filingIndicator/@contextRef)]/@contextRef" />
		<xsl:for-each select="$contextRefs">
			<xsl:variable name="id" select="." />
			<xsl:if test="/xbrli:xbrl/xbrli:context[@id=$id]/xbrli:scenario|xbrli:segment">
				<xsl:call-template name="EBAError">
					<xsl:with-param name="number" select="'1.6.c'" />
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
					<xsl:with-param name="number" select="'1.6.1'" />
					<xsl:with-param name="context" select="$template" />
				</xsl:call-template>
			</xsl:if>
		</xsl:for-each>

		<xsl:apply-templates />
	</xsl:template>

	<xsl:template match="/xbrli:xbrl/find:fIndicators/find:filingIndicator">
		<xsl:variable name="href" select="/xbrli:xbrl/link:schemaRef/@xlink:href" />
		<xsl:if test="not($entrypoints[./href=$href]/filing-indicators[./code=current()])">
			<xsl:call-template name="EBAError">
				<xsl:with-param name="number" select="'1.6.3'" />
				<xsl:with-param name="context" select="." />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="xi:include">
		<xsl:call-template name="EBAError">
			<xsl:with-param name="number" select="'1.15'" />
			<xsl:with-param name="context" select="." />
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="@xml:base">
		<xsl:call-template name="EBAError">
			<xsl:with-param name="number" select="'2.1'" />
			<xsl:with-param name="context" select="." />
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="/xbrli:xbrl/link:schemaRef">
		<xsl:variable name="href" select="@xlink:href" />
		<xsl:if test="not(starts-with($href,'http://'))">
			<xsl:call-template name="EBAError">
				<xsl:with-param name="number" select="'2.2'" />
				<xsl:with-param name="context" select="$href" />
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="not($entrypoints[./href = $href])">
			<xsl:call-template name="EBAError">
				<xsl:with-param name="number" select="'1.5.b'" />
				<xsl:with-param name="context" select="$href" />
			</xsl:call-template>
			<xsl:call-template name="EBAError">
				<xsl:with-param name="number" select="'1.11'" />
				<xsl:with-param name="context" select="$href" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="link:linkbaseRef">
		<xsl:call-template name="EBAError">
			<xsl:with-param name="number" select="'2.4'" />
			<xsl:with-param name="context" select="." />
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="xbrli:xbrl//comment()">
		<xsl:call-template name="EBAError">
			<xsl:with-param name="number" select="'2.5'" />
			<xsl:with-param name="context" select="." />
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="link:footnote">
		<xsl:call-template name="EBAError">
			<xsl:with-param name="number" select="'2.25'" />
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
					<xsl:with-param name="number" select="'2.26'" />
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
				<xsl:with-param name="number" select="'2.6.a'" />
				<xsl:with-param name="context" select="@id" />
			</xsl:call-template>
			<xsl:call-template name="EBAError">
				<xsl:with-param name="number" select="'2.6.b'" />
				<xsl:with-param name="context" select="@id" />
			</xsl:call-template>
		</xsl:if>
		<xsl:variable name="id" select="@id" />
		<xsl:if
			test="not(/xbrli:xbrl/eba_met:*[@contextRef=$id] or /xbrli:xbrl/find:fIndicators/find:filingIndicator[@contextRef=$id])">
			<xsl:call-template name="EBAError">
				<xsl:with-param name="number" select="'2.7.a'" />
				<xsl:with-param name="context" select="$id" />
			</xsl:call-template>
		</xsl:if>
		<xsl:variable name="cid" select="my:cid(.)" />
		<xsl:variable name="matching" select="key('scenario', $cid)" />
		<xsl:if test="count($matching) &gt; 1 and $matching[1]/@id=$id">
			<xsl:call-template name="EBAError">
				<xsl:with-param name="number" select="'2.7.b'" />
				<xsl:with-param name="context" select="exsl:node-set($cid)|$matching/@id" />
			</xsl:call-template>
		</xsl:if>

		<xsl:apply-templates />
	</xsl:template>

	<xsl:template match="/xbrli:xbrl/xbrli:context/xbrli:period/xbrli:instant">
		<xsl:if test="contains(text(),'T')">
			<xsl:call-template name="EBAError">
				<xsl:with-param name="number" select="'2.10.a'" />
				<xsl:with-param name="context" select="." />
			</xsl:call-template>
		</xsl:if>
		<xsl:if
			test="contains(substring-after(text(),'T'), '+') or contains(substring-after(text(),'T'), '-') or contains(substring-after(text(),'T'), 'Z')">
			<xsl:call-template name="EBAError">
				<xsl:with-param name="number" select="'2.10.b'" />
				<xsl:with-param name="context" select="." />
			</xsl:call-template>
		</xsl:if>

	</xsl:template>

	<xsl:template match="xbrli:forever">
		<xsl:call-template name="EBAError">
			<xsl:with-param name="number" select="'2.11'" />
			<xsl:with-param name="context" select="." />
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="/xbrli:xbrl/xbrli:context/xbrli:period[child::*[name()!='xbrli:instant']]">
		<xsl:call-template name="EBAError">
			<xsl:with-param name="number" select="'2.13.b'" />
			<xsl:with-param name="context" select="*" />
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="xbrli:segment">
		<xsl:call-template name="EBAError">
			<xsl:with-param name="number" select="'2.14'" />
			<xsl:with-param name="context" select="." />
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="/xbrli:xbrl/xbrli:context/xbrli:scenario[child::*[not(name()='xbrldi:explicitMember' or name()='xbrldi:typedMember')]]">
		<xsl:call-template name="EBAError">
			<xsl:with-param name="number" select="'2.15'" />
			<xsl:with-param name="context"
				select="child::*[not(name()='xbrldi:explicitMember' or name()='xbrldi:typedMember')]" />
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="/xbrli:xbrl/eba_met:*">
		<xsl:variable name="cid" select="my:cid-byref(@contextRef)" />
		<xsl:variable name="metric" select="name()" />
		<xsl:variable name="unitRef" select="@unitRef" />
		<xsl:variable name="contextRef" select="@contextRef" />
		<xsl:variable name="id" select="generate-id()" />

		<xsl:variable name="context-facts" select="key('cid-fact', my:cid-byref(@contextRef))[name()=$metric]" />

		<xsl:variable name="matches" select="$context-facts[@unitRef=$unitRef]" />
		<xsl:if test="count($matches) &gt; 1 and $id=generate-id($matches[last()])">
			<xsl:call-template name="EBAError">
				<xsl:with-param name="number" select="'2.16'" />
				<xsl:with-param name="context" select=".|exsl:node-set($matches)|exsl:node-set($cid)|$contextRef|$matches/@contextRef" />
			</xsl:call-template>
		</xsl:if>

		<xsl:variable name="partial_matches" select="$context-facts[@unitRef!=$unitRef or generate-id()=$id]" />
		<xsl:if test="count($partial_matches) &gt; 1 and $partial_matches[last()]/@unitRef=$unitRef">
			<xsl:call-template name="EBAError">
				<xsl:with-param name="number" select="'2.16.1'" />
				<xsl:with-param name="context" select="$partial_matches|exsl:node-set($cid)|$partial_matches/@contextRef|$partial_matches/@unitRef" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="@precision and not(@decimals)">
			<xsl:call-template name="EBAError">
				<xsl:with-param name="number" select="'2.17'" />
				<xsl:with-param name="context" select="@precision" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="contains('impr', substring(local-name(),1,1)) and not(@decimals)">
			<xsl:call-template name="EBAError">
				<xsl:with-param name="number" select="'2.18.a'" />
				<xsl:with-param name="context" select=".|./@*" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="@xsi:nil">
			<xsl:call-template name="EBAError">
				<xsl:with-param name="number" select="'2.19.a'" />
				<xsl:with-param name="context" select=".|./@*" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="starts-with(local-name(),'s') and not(string(.))">
			<xsl:call-template name="EBAError">
				<xsl:with-param name="number" select="'2.19.b'" />
				<xsl:with-param name="context" select=".|./@*" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="contains('ipr', substring(local-name(),1,1)) and not(/xbrli:xbrl/xbrli:unit[@id=current()/@unitRef]/xbrli:measure/text()='xbrli:pure')">
			<xsl:call-template name="EBAError">
				<xsl:with-param name="number" select="'3.2.a'" />
				<xsl:with-param name="context" select=".|./@*|/xbrli:xbrl/xbrli:unit[@id=current()/@unitRef]/xbrli:measure/text()" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="starts-with(local-name(),'m')">
			<xsl:variable name="context" select="key('context', @contextRef)" />
			<xsl:variable name="currency" select="/xbrli:xbrl/xbrli:unit[@id=current()/@unitRef]/xbrli:measure" />
			<xsl:variable name="cca" select="$context/xbrli:scenario/xbrldi:explicitMember[@dimension='eba_dim:CCA']" />

			<xsl:choose>
				<xsl:when test="$cca='eba_CA:x1'">
					<xsl:choose>
						<xsl:when test="$currency = $reportcurrency">
							<xsl:call-template name="EBAError">
								<xsl:with-param name="number" select="'3.1.b'" />
								<xsl:with-param name="context" select=".|@*" />
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>
							<xsl:variable name="cus" select="$context/xbrli:scenario/xbrldi:explicitMember[@dimension='eba_dim:CUS']" />
							<xsl:if test="$cus">
								<xsl:choose>
									<xsl:when test="$cus='eba_CU:x46'">
										<xsl:call-template name="EBAError">
											<xsl:with-param name="number" select="'3.1.x'" />
											<xsl:with-param name="context" select=".|@*|$cus" />
										</xsl:call-template>
									</xsl:when>
									<xsl:when test="$cus='eba_CU:x0'">
										<xsl:if test="$cus!=$reportcurrency">
											<xsl:call-template name="EBAError">
												<xsl:with-param name="number" select="'3.1.c'" />
												<xsl:with-param name="context" select=".|@*|$cus|$cca" />
											</xsl:call-template>
										</xsl:if>
									</xsl:when>
									<xsl:otherwise>
										<xsl:if test="$cus != $currency">
											<xsl:call-template name="EBAError">
												<xsl:with-param name="number" select="'3.1.c'" />
												<xsl:with-param name="context" select=".|@*" />
											</xsl:call-template>
										</xsl:if>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:if>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:if test="$currency != $reportcurrency">
						<xsl:call-template name="EBAError">
							<xsl:with-param name="number" select="'3.1.a'" />
							<xsl:with-param name="context" select=".|@*" />
						</xsl:call-template>
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
		<xsl:apply-templates />
		<xsl:apply-templates select="@*" />
	</xsl:template>

	<xsl:template match="/xbrli:xbrl/xbrli:unit">
		<xsl:variable name="measure" select="xbrli:measure/text()" />
		<xsl:variable name="matches" select="preceding::xbrli:unit[xbrli:measure/text()=$measure]" />
		<xsl:if test="$matches">
			<xsl:call-template name="EBAError">
				<xsl:with-param name="number" select="'2.21'" />
				<xsl:with-param name="context" select="$measure|@id|$matches/@id" />
			</xsl:call-template>
		</xsl:if>
		<xsl:apply-templates />
	</xsl:template>

	<xsl:template match="/xbrli:xbrl/xbrli:unit/xbrli:measure">
		<xsl:if test="not($units[. = substring-after(current(),':')])">
			<xsl:call-template name="EBAError">
				<xsl:with-param name="number" select="'2.23'" />
				<xsl:with-param name="context" select=".|@*" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="/xbrli:xbrl/xbrli:unit[not(/xbrli:xbrl/eba_met:*[@unitRef=current()/@id])]">
		<xsl:call-template name="EBAError">
			<xsl:with-param name="number" select="'2.22'" />
			<xsl:with-param name="context" select=".|./@*" />
		</xsl:call-template>
	</xsl:template>

	<xsl:template
		match="eba_met:*[starts-with(local-name(),'s') and normalize-space(.) != text()] | eba_typ:*[normalize-space(.) != text()]">
		<xsl:call-template name="EBAError">
			<xsl:with-param name="number" select="'3.11'" />
			<xsl:with-param name="context" select="text()|./@*" />
		</xsl:call-template>
	</xsl:template>

	<!-- this produces the correct error but for the offending node AND all it's children plus it's slow -->
	<!-- <xsl:template match="*">
		<xsl:for-each select="namespace::node()[not(. = /xbrli:xbrl/namespace::node())]">
			<xsl:call-template name="EBAError">
				<xsl:with-param name="number" select="'3.9'" />
				<xsl:with-param name="context" select="." />
			</xsl:call-template>
		</xsl:for-each>

		<xsl:apply-templates />
	</xsl:template> -->

	<!-- not 100% sure that this is correct in all cases -->
	<xsl:template match="*">
		<xsl:for-each select="namespace::node()[key('namespace',.) = '']">
			<xsl:call-template name="EBAError">
				<xsl:with-param name="number" select="'3.9'" />
				<xsl:with-param name="context" select="." />
			</xsl:call-template>
		</xsl:for-each>

		<xsl:apply-templates />
	</xsl:template>

	<xsl:template match="text()|@*">
		<!-- <xsl:value-of select="." /> -->
	</xsl:template>

</xsl:transform>
<xsl:transform
		version="1.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:exsl="http://exslt.org/common"
		xmlns:func="http://exslt.org/functions"
		xmlns:str="http://exslt.org/strings"
		xmlns:my="http://example.org/my"
		exclude-result-prefixes="my"
		extension-element-prefixes="func str exsl">

	<xsl:output
			indent="yes"
			method="xml" />
	<xsl:variable
			name="countrycodes"
			select="document('data/iso-3166-1.xml')/codes/code" />
	<xsl:variable
			name="currencycodes"
			select="document('data/iso-4217.xml')/codes/code" />
	<xsl:variable
			name="eeacountrycodes"
			select="document('data/eea-countries.xml')/codes/code" />
	<xsl:variable
			name="aifmregister"
			select="document('data/aifm-register.xml')/codes/code" />
	<xsl:variable
			name="aifregister"
			select="document('data/aif-register.xml')/codes/code" />
	<xsl:variable
			name="micregister"
			select="document('data/mic-register.xml')/codes/code" />
	<xsl:include href="common.xslt" />
	<xsl:include href="aifm.xslt" />
	<xsl:include href="aif.xslt" />

	<xsl:variable
			name="aifmerrors"
			select="document('data/cam-errors.xml')" />

	<xsl:key
			name="errorlookup"
			match="error"
			use="code" />

	<xsl:template name="AIFMError">
		<xsl:param name="code" />
		<xsl:param name="context" />
		<error>
			<record>
				<xsl:value-of select="./ancestor-or-self::AIFMRecordInfo/AIFMNationalCode" />
			</record>
			<code>
				<xsl:value-of select="$code" />
			</code>
			<message>
				<xsl:for-each select="$aifmerrors">
					<xsl:for-each select="key('errorlookup', $code)">
						<xsl:value-of select="message" />
					</xsl:for-each>
				</xsl:for-each>
			</message>
			<context>
				<xsl:for-each select="exsl:node-set($context)">
					<field>
						<name>
							<!-- <xsl:value-of select="name()" /> -->
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

	<xsl:variable
			name="aiferrors"
			select="document('data/caf-errors.xml')" />

	<xsl:template name="AIFError">
		<xsl:param name="code" />
		<xsl:param name="context" />
		<error>
			<record>
				<xsl:value-of select="./ancestor-or-self::AIFRecordInfo/AIFNationalCode" />
			</record>
			<code>
				<xsl:value-of select="$code" />
			</code>
			<message>
				<xsl:for-each select="$aiferrors">
					<xsl:for-each select="key('errorlookup', $code)">
						<xsl:value-of select="message" />
					</xsl:for-each>
				</xsl:for-each>
			</message>
			<context>
				<xsl:for-each select="exsl:node-set($context)">
					<field>
						<name>
							<!-- <xsl:value-of select="name()" /> -->
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
</xsl:transform>
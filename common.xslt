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

	<func:function name="my:ISO17442">
		<xsl:param name="lei" />
		<func:result select="my:modulo(my:convert($lei), 97) = 1" />
	</func:function>

	<func:function name="my:ISO6166">
		<xsl:param name="isin" />

		<xsl:variable
				name="checkdigit"
				select="substring($isin,12,1)" />

		<xsl:variable
				name="digits"
				select="my:convert(substring($isin,1,11))" />
		<xsl:variable
				name="weightedsum"
				select="my:weightedsum($digits)" />

		<func:result select="my:modulo(10 - my:modulo($weightedsum,10),10) = $checkdigit" />
	</func:function>

	<func:function name="my:weightedsum">
		<xsl:param name="digits" />
		<xsl:variable
				name="d"
				select="substring(concat(substring('0000000000000000000000',1,22 - string-length($digits) ),$digits),1,22)" />

		<xsl:variable
				name="twice"
				select="
                                concat(
                                        2*substring($d,2,1),
                                        2*substring($d,4,1),
                                        2*substring($d,6,1),
                                        2*substring($d,8,1),
                                        2*substring($d,10,1),
                                        2*substring($d,12,1),
                                        2*substring($d,14,1),
                                        2*substring($d,16,1),
                                        2*substring($d,18,1),
                                        2*substring($d,20,1),
                                        2*substring($d,22,1))" />

		<xsl:variable
				name="once"
				select="substring($d,1,1) + 
                                        substring($d,3,1) +
                                        substring($d,5,1) +
                                        substring($d,7,1) +
                                        substring($d,9,1) +
                                        substring($d,11,1) +
                                        substring($d,13,1) + 
                                        substring($d,15,1) +
                                        substring($d,17,1) +
                                        substring($d,19,1) +
                                        substring($d,21,1)" />

		<func:result select="sum(str:split($twice,'')) + $once" />
		<!-- <func:result select="sum(str:split($twice,''))" /> -->

	</func:function>

	<func:function name="my:convert">
		<xsl:param name="value" />
		<func:result select="
        str:replace(
        str:replace(
        str:replace(
        str:replace(
        str:replace(
        str:replace(
        str:replace(
        str:replace(
        str:replace(
        str:replace(
        str:replace(
        str:replace(
        str:replace(
        str:replace(
        str:replace(
        str:replace(
        str:replace(
        str:replace(
        str:replace(
        str:replace(
        str:replace(
        str:replace(
        str:replace(
        str:replace(
        str:replace(
        str:replace($value,
            'A','10'),
            'B','11'),
            'C','12'),
            'D','13'),
            'E','14'),
            'F','15'),
            'G','16'),
            'H','17'),
            'I','18'),
            'J','19'),
            'K','20'),
            'L','21'),
            'M','22'),
            'N','23'),
            'O','24'),
            'P','25'),
            'Q','26'),
            'R','27'),
            'S','28'),
            'T','29'),
            'U','30'),
            'V','31'),
            'W','32'),
            'X','33'),
            'Y','34'),
            'Z','35')" />
	</func:function>

	<func:function name="my:modulo">
		<xsl:param name="dividend" />
		<xsl:param name="divisor" />

		<xsl:choose>
			<xsl:when test="not($dividend > 9999999999999999)">
				<func:result select="$dividend mod $divisor" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable
						name="vLen"
						select="string-length($dividend)" />

				<xsl:variable
						name="vLen1"
						select="$vLen -1" />

				<xsl:variable
						name="vPart1"
						select="substring($dividend, 1, $vLen1)" />

				<xsl:variable
						name="vPart2"
						select="substring($dividend, $vLen1 +1)" />

				<xsl:variable
						name="vMod1"
						select="my:modulo($vPart1, $divisor)" />

				<xsl:variable
						name="vMod2"
						select="$vPart2 mod $divisor" />

				<func:result select="(10*$vMod1 + $vMod2) mod $divisor" />
			</xsl:otherwise>
		</xsl:choose>
	</func:function>

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
			<field>
				<xsl:value-of select="name(exsl:node-set($context))" />
			</field>
			<value>
				<xsl:value-of select="$context" />
			</value>
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
							<xsl:value-of select="name()" />
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
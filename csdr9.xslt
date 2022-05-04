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
			name="eeacountrycodes"
			select="document('data/eea-countries.xml')/codes/code" />
	<xsl:variable
			name="countrycodes"
			select="document('data/iso-3166-1.xml')/codes/code" />
	<xsl:include href="common.xslt" />

	<xsl:variable
			name="csdr9rrors"
			select="document('data/csdr9-errors.xml')" />

	<xsl:key
			name="errorlookup"
			match="error"
			use="code" />

	<xsl:template name="CSDR9Error">
		<xsl:param name="code" />
		<xsl:param name="context" />
		<error>
			<record>
				<!-- <xsl:value-of select="./ancestor-or-self::AIFMRecordInfo/AIFMNationalCode" /> -->
			</record>
			<code>
				<xsl:value-of select="$code" />
			</code>
			<message>
				<xsl:for-each select="$csdr9rrors">
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

	<xsl:template match="/">
		<result>
			<xsl:apply-templates />
		</result>
	</xsl:template>

	<xsl:template match="/Document/SttlmIntlrRpt/RptHdr">
		<xsl:if test="Ccy != 'EUR'">
			<xsl:call-template name="CSDR9Error">
				<xsl:with-param
						name="code"
						select="'INS-001'" />
				<xsl:with-param
						name="context"
						select="Ccy" />
			</xsl:call-template>
		</xsl:if>
		<xsl:variable
				name="reportingperiod"
				select="RptgDt" />
		<xsl:variable
				name="date"
				select="substring($reportingperiod,6,5)" />
		<xsl:if test="not($date='03-31' or $date='06-30' or $date='09-30' or $date='12-31')">
			<xsl:call-template name="CSDR9Error">
				<xsl:with-param
						name="code"
						select="'INS-002'" />
				<xsl:with-param
						name="context"
						select="RptgDt" />
			</xsl:call-template>
		</xsl:if>

	</xsl:template>

	<!-- INS-003 requires filename -->

	<xsl:template match="/Document/SttlmIntlrRpt/SttlmIntlr/Id">
		<xsl:if test="not(my:ISO17442(LEI))">
			<xsl:call-template name="CSDR9Error">
				<xsl:with-param
						name="code"
						select="'INS-013'" />
				<xsl:with-param
						name="context"
						select="LEI" />
			</xsl:call-template>
		</xsl:if>

		<!-- INS-014.1 requires filename -->

		<!-- INS-014.2 requires filename -->

		<xsl:variable
				name="branchid"
				select="BrnchId" />

		<xsl:if test="boolean($branchid) and not($eeacountrycodes[. = $branchid] or $branchid = 'TS')">
			<xsl:call-template name="CSDR9Error">
				<xsl:with-param
						name="code"
						select="'INS-014.3'" />
				<xsl:with-param
						name="context"
						select="BrnchId" />
			</xsl:call-template>
		</xsl:if>

		<!-- INS-015 requires external lookup -->

		<!-- INS-016 requires external lookup -->

		<!-- INS-016 requires external lookup -->

	</xsl:template>

	<xsl:template match="/Document/SttlmIntlrRpt/SttlmIntlr/FinInstrm/Eqty">

		<xsl:if test="Aggt/Sttld/Vol + Aggt/Faild/Vol != Aggt/Ttl/Vol">
			<xsl:call-template name="CSDR9Error">
				<xsl:with-param
						name="code"
						select="'INS-021.1'" />
				<xsl:with-param
						name="context"
						select="Aggt/Sttld/Vol|Aggt/Faild/Vol|Aggt/Ttl/Vol" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="Aggt/Sttld/Val + Aggt/Faild/Val != Aggt/Ttl/Val">
			<xsl:call-template name="CSDR9Error">
				<xsl:with-param
						name="code"
						select="'INS-022.1'" />
				<xsl:with-param
						name="context"
						select="Aggt/Sttld/Val|Aggt/Faild/Val|Aggt/Ttl/Val" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="Aggt/Faild/Vol * 100 div Aggt/Ttl/Vol != FaildRate/VolPctg">
			<xsl:call-template name="CSDR9Error">
				<xsl:with-param
						name="code"
						select="'INS-023.1'" />
				<xsl:with-param
						name="context"
						select="Aggt/Faild/Vol|Aggt/Ttl/Vol|FaildRate/VolPctg" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="Aggt/Faild/Val * 100 div Aggt/Ttl/Val != FaildRate/Val">
			<xsl:call-template name="CSDR9Error">
				<xsl:with-param
						name="code"
						select="'INS-024.1'" />
				<xsl:with-param
						name="context"
						select="Aggt/Faild/Val|Aggt/Ttl/Val|FaildRate/Val" />
			</xsl:call-template>
		</xsl:if>


		<xsl:if test="Aggt/Ttl/Vol != sum(/Document/SttlmIntlrRpt/IssrCSD/FinInstrm/Eqty/Aggt/Ttl/Vol)">
			<xsl:call-template name="CSDR9Error">
				<xsl:with-param
						name="code"
						select="'INS-071.1'" />
				<xsl:with-param
						name="context"
						select="Aggt/Ttl/Vol|/Document/SttlmIntlrRpt/IssrCSD/FinInstrm/Eqty/Aggt/Ttl/Vol" />
			</xsl:call-template>
		</xsl:if>

	</xsl:template>

	<xsl:template match="/Document/SttlmIntlrRpt/SttlmIntlr/FinInstrm/SvrgnDebt">
		<xsl:if test="Aggt/Sttld/Vol + Aggt/Faild/Vol != Aggt/Ttl/Vol">
			<xsl:call-template name="CSDR9Error">
				<xsl:with-param
						name="code"
						select="'INS-021.2'" />
				<xsl:with-param
						name="context"
						select="Aggt/Sttld/Vol|Aggt/Faild/Vol|Aggt/Ttl/Vol" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="Aggt/Sttld/Val + Aggt/Faild/Val != Aggt/Ttl/Val">
			<xsl:call-template name="CSDR9Error">
				<xsl:with-param
						name="code"
						select="'INS-022.2'" />
				<xsl:with-param
						name="context"
						select="Aggt/Sttld/Val|Aggt/Faild/Val|Aggt/Ttl/Val" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="Aggt/Faild/Vol * 100 div Aggt/Ttl/Vol != FaildRate/VolPctg">
			<xsl:call-template name="CSDR9Error">
				<xsl:with-param
						name="code"
						select="'INS-023.2'" />
				<xsl:with-param
						name="context"
						select="Aggt/Faild/Vol|Aggt/Ttl/Vol|FaildRate/VolPctg" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="Aggt/Faild/Val * 100 div Aggt/Ttl/Val != FaildRate/Val">
			<xsl:call-template name="CSDR9Error">
				<xsl:with-param
						name="code"
						select="'INS-024.2'" />
				<xsl:with-param
						name="context"
						select="Aggt/Faild/Val|Aggt/Ttl/Val|FaildRate/Val" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="Aggt/Ttl/Vol != sum(/Document/SttlmIntlrRpt/IssrCSD/FinInstrm/SvrgnDebt/Aggt/Ttl/Vol)">
			<xsl:call-template name="CSDR9Error">
				<xsl:with-param
						name="code"
						select="'INS-071.2'" />
				<xsl:with-param
						name="context"
						select="Aggt/Ttl/Vol|/Document/SttlmIntlrRpt/IssrCSD/FinInstrm/SvrgnDebt/Aggt/Ttl/Vol" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="/Document/SttlmIntlrRpt/SttlmIntlr/FinInstrm/Bd">
		<xsl:if test="Aggt/Sttld/Vol + Aggt/Faild/Vol != Aggt/Ttl/Vol">
			<xsl:call-template name="CSDR9Error">
				<xsl:with-param
						name="code"
						select="'INS-021.3'" />
				<xsl:with-param
						name="context"
						select="Aggt/Sttld/Vol|Aggt/Faild/Vol|Aggt/Ttl/Vol" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="Aggt/Sttld/Val + Aggt/Faild/Val != Aggt/Ttl/Val">
			<xsl:call-template name="CSDR9Error">
				<xsl:with-param
						name="code"
						select="'INS-022.3'" />
				<xsl:with-param
						name="context"
						select="Aggt/Sttld/Val|Aggt/Faild/Val|Aggt/Ttl/Val" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="Aggt/Faild/Vol * 100 div Aggt/Ttl/Vol != FaildRate/VolPctg">
			<xsl:call-template name="CSDR9Error">
				<xsl:with-param
						name="code"
						select="'INS-023.3'" />
				<xsl:with-param
						name="context"
						select="Aggt/Faild/Vol|Aggt/Ttl/Vol|FaildRate/VolPctg" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="Aggt/Faild/Vol * 100 div Aggt/Ttl/Val != FaildRate/Val">
			<xsl:call-template name="CSDR9Error">
				<xsl:with-param
						name="code"
						select="'INS-024.3'" />
				<xsl:with-param
						name="context"
						select="Aggt/Faild/Vol|Aggt/Ttl/Val|FaildRate/Val" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="/Document/SttlmIntlrRpt/SttlmIntlr/FinInstrm/OthrTrfblScties">
		<xsl:if test="Aggt/Sttld/Vol + Aggt/Faild/Vol != Aggt/Ttl/Vol">
			<xsl:call-template name="CSDR9Error">
				<xsl:with-param
						name="code"
						select="'INS-021.4'" />
				<xsl:with-param
						name="context"
						select="Aggt/Sttld/Vol|Aggt/Faild/Vol|Aggt/Ttl/Vol" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="Aggt/Sttld/Val + Aggt/Faild/Val != Aggt/Ttl/Val">
			<xsl:call-template name="CSDR9Error">
				<xsl:with-param
						name="code"
						select="'INS-022.4'" />
				<xsl:with-param
						name="context"
						select="Aggt/Sttld/Val|Aggt/Faild/Val|Aggt/Ttl/Val" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="Aggt/Faild/Vol * 100 div Aggt/Ttl/Vol != FaildRate/VolPctg">
			<xsl:call-template name="CSDR9Error">
				<xsl:with-param
						name="code"
						select="'INS-023.4'" />
				<xsl:with-param
						name="context"
						select="Aggt/Faild/Vol|Aggt/Ttl/Vol|FaildRate/VolPctg" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="Aggt/Faild/Val * 100 div Aggt/Ttl/Val != FaildRate/Val">
			<xsl:call-template name="CSDR9Error">
				<xsl:with-param
						name="code"
						select="'INS-024.4'" />
				<xsl:with-param
						name="context"
						select="Aggt/Faild/Val|Aggt/Ttl/Val|FaildRate/Val" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="/Document/SttlmIntlrRpt/SttlmIntlr/FinInstrm/XchgTradgFnds">
		<xsl:if test="Aggt/Sttld/Vol + Aggt/Faild/Vol != Aggt/Ttl/Vol">
			<xsl:call-template name="CSDR9Error">
				<xsl:with-param
						name="code"
						select="'INS-021.5'" />
				<xsl:with-param
						name="context"
						select="Aggt/Sttld/Vol|Aggt/Faild/Vol|Aggt/Ttl/Vol" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="Aggt/Sttld/Val + Aggt/Faild/Val != Aggt/Ttl/Val">
			<xsl:call-template name="CSDR9Error">
				<xsl:with-param
						name="code"
						select="'INS-022.5'" />
				<xsl:with-param
						name="context"
						select="Aggt/Sttld/Val|Aggt/Faild/Val|Aggt/Ttl/Val" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="Aggt/Faild/Vol * 100 div Aggt/Ttl/Vol != FaildRate/VolPctg">
			<xsl:call-template name="CSDR9Error">
				<xsl:with-param
						name="code"
						select="'INS-023.5'" />
				<xsl:with-param
						name="context"
						select="Aggt/Faild/Vol|Aggt/Ttl/Vol|FaildRate/VolPctg" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="Aggt/Faild/Val * 100 div Aggt/Ttl/Val != FaildRate/Val">
			<xsl:call-template name="CSDR9Error">
				<xsl:with-param
						name="code"
						select="'INS-024.5'" />
				<xsl:with-param
						name="context"
						select="Aggt/Faild/Val|Aggt/Ttl/Val|FaildRate/Val" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="/Document/SttlmIntlrRpt/SttlmIntlr/FinInstrm/CllctvInvstmtUdrtkgs">
		<xsl:if test="Aggt/Sttld/Vol + Aggt/Faild/Vol != Aggt/Ttl/Vol">
			<xsl:call-template name="CSDR9Error">
				<xsl:with-param
						name="code"
						select="'INS-021.6'" />
				<xsl:with-param
						name="context"
						select="Aggt/Sttld/Vol|Aggt/Faild/Vol|Aggt/Ttl/Vol" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="Aggt/Sttld/Val + Aggt/Faild/Val != Aggt/Ttl/Val">
			<xsl:call-template name="CSDR9Error">
				<xsl:with-param
						name="code"
						select="'INS-022.6'" />
				<xsl:with-param
						name="context"
						select="Aggt/Sttld/Val|Aggt/Faild/Val|Aggt/Ttl/Val" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="Aggt/Faild/Vol * 100 div Aggt/Ttl/Vol != FaildRate/VolPctg">
			<xsl:call-template name="CSDR9Error">
				<xsl:with-param
						name="code"
						select="'INS-023.6'" />
				<xsl:with-param
						name="context"
						select="Aggt/Faild/Vol|Aggt/Ttl/Vol|FaildRate/VolPctg" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="Aggt/Faild/Val * 100 div Aggt/Ttl/Val != FaildRate/Val">
			<xsl:call-template name="CSDR9Error">
				<xsl:with-param
						name="code"
						select="'INS-024.6'" />
				<xsl:with-param
						name="context"
						select="Aggt/Faild/Val|Aggt/Ttl/Val|FaildRate/Val" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="/Document/SttlmIntlrRpt/SttlmIntlr/FinInstrm/MnyMktInstrm">
		<xsl:if test="Aggt/Sttld/Vol + Aggt/Faild/Vol != Aggt/Ttl/Vol">
			<xsl:call-template name="CSDR9Error">
				<xsl:with-param
						name="code"
						select="'INS-021.7'" />
				<xsl:with-param
						name="context"
						select="Aggt/Sttld/Vol|Aggt/Faild/Vol|Aggt/Ttl/Vol" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="Aggt/Sttld/Val + Aggt/Faild/Val != Aggt/Ttl/Val">
			<xsl:call-template name="CSDR9Error">
				<xsl:with-param
						name="code"
						select="'INS-022.7'" />
				<xsl:with-param
						name="context"
						select="Aggt/Sttld/Val|Aggt/Faild/Val|Aggt/Ttl/Val" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="Aggt/Faild/Vol * 100 div Aggt/Ttl/Vol != FaildRate/VolPctg">
			<xsl:call-template name="CSDR9Error">
				<xsl:with-param
						name="code"
						select="'INS-023.7'" />
				<xsl:with-param
						name="context"
						select="Aggt/Faild/Vol|Aggt/Ttl/Vol|FaildRate/VolPctg" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="Aggt/Faild/Val * 100 div Aggt/Ttl/Val != FaildRate/Val">
			<xsl:call-template name="CSDR9Error">
				<xsl:with-param
						name="code"
						select="'INS-024.7'" />
				<xsl:with-param
						name="context"
						select="Aggt/Faild/Val|Aggt/Ttl/Val|FaildRate/Val" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="/Document/SttlmIntlrRpt/SttlmIntlr/FinInstrm/EmssnAllwnc">
		<xsl:if test="Aggt/Sttld/Vol + Aggt/Faild/Vol != Aggt/Ttl/Vol">
			<xsl:call-template name="CSDR9Error">
				<xsl:with-param
						name="code"
						select="'INS-021.8'" />
				<xsl:with-param
						name="context"
						select="Aggt/Sttld/Vol|Aggt/Faild/Vol|Aggt/Ttl/Vol" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="Aggt/Sttld/Val + Aggt/Faild/Val != Aggt/Ttl/Val">
			<xsl:call-template name="CSDR9Error">
				<xsl:with-param
						name="code"
						select="'INS-022.8'" />
				<xsl:with-param
						name="context"
						select="Aggt/Sttld/Val|Aggt/Faild/Val|Aggt/Ttl/Val" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="Aggt/Faild/Vol * 100 div Aggt/Ttl/Vol != FaildRate/VolPctg">
			<xsl:call-template name="CSDR9Error">
				<xsl:with-param
						name="code"
						select="'INS-023.8'" />
				<xsl:with-param
						name="context"
						select="Aggt/Faild/Vol|Aggt/Ttl/Vol|FaildRate/VolPctg" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="Aggt/Faild/Val * 100 div Aggt/Ttl/Val != FaildRate/Val">
			<xsl:call-template name="CSDR9Error">
				<xsl:with-param
						name="code"
						select="'INS-024.8'" />
				<xsl:with-param
						name="context"
						select="Aggt/Faild/Val|Aggt/Ttl/Val|FaildRate/Val" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="/Document/SttlmIntlrRpt/SttlmIntlr/FinInstrm/OthrFinInstrms">
		<xsl:if test="Aggt/Sttld/Vol + Aggt/Faild/Vol != Aggt/Ttl/Vol">
			<xsl:call-template name="CSDR9Error">
				<xsl:with-param
						name="code"
						select="'INS-021.9'" />
				<xsl:with-param
						name="context"
						select="Aggt/Sttld/Vol|Aggt/Faild/Vol|Aggt/Ttl/Vol" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="Aggt/Sttld/Val + Aggt/Faild/Val != Aggt/Ttl/Val">
			<xsl:call-template name="CSDR9Error">
				<xsl:with-param
						name="code"
						select="'INS-022.9'" />
				<xsl:with-param
						name="context"
						select="Aggt/Sttld/Val|Aggt/Faild/Val|Aggt/Ttl/Val" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="Aggt/Faild/Vol * 100 div Aggt/Ttl/Vol != FaildRate/VolPctg">
			<xsl:call-template name="CSDR9Error">
				<xsl:with-param
						name="code"
						select="'INS-023.9'" />
				<xsl:with-param
						name="context"
						select="Aggt/Faild/Vol|Aggt/Ttl/Vol|FaildRate/VolPctg" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="Aggt/Faild/Val * 100 div Aggt/Ttl/Val != FaildRate/Val">
			<xsl:call-template name="CSDR9Error">
				<xsl:with-param
						name="code"
						select="'INS-024.9'" />
				<xsl:with-param
						name="context"
						select="Aggt/Faild/Val|Aggt/Ttl/Val|FaildRate/Val" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="/Document/SttlmIntlrRpt/SttlmIntlr/TxTp/SctiesBuyOrSell">
		<xsl:if test="Aggt/Sttld/Vol + Aggt/Faild/Vol != Aggt/Ttl/Vol">
			<xsl:call-template name="CSDR9Error">
				<xsl:with-param
						name="code"
						select="'INS-031.1'" />
				<xsl:with-param
						name="context"
						select="Aggt/Sttld/Vol|Aggt/Faild/Vol|Aggt/Ttl/Vol" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="Aggt/Sttld/Val + Aggt/Faild/Val != Aggt/Ttl/Val">
			<xsl:call-template name="CSDR9Error">
				<xsl:with-param
						name="code"
						select="'INS-032.1'" />
				<xsl:with-param
						name="context"
						select="Aggt/Sttld/Val|Aggt/Faild/Val|Aggt/Ttl/Val" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="Aggt/Faild/Vol * 100 div Aggt/Ttl/Vol != FaildRate/VolPctg">
			<xsl:call-template name="CSDR9Error">
				<xsl:with-param
						name="code"
						select="'INS-033.1'" />
				<xsl:with-param
						name="context"
						select="Aggt/Faild/Vol|Aggt/Ttl/Vol|FaildRate/VolPctg" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="Aggt/Faild/Val * 100 div Aggt/Ttl/Val != FaildRate/Val">
			<xsl:call-template name="CSDR9Error">
				<xsl:with-param
						name="code"
						select="'INS-034.1'" />
				<xsl:with-param
						name="context"
						select="Aggt/Faild/Val|Aggt/Ttl/Val|FaildRate/Val" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="/Document/SttlmIntlrRpt/SttlmIntlr/TxTp/CollMgmtOpr">
		<xsl:if test="Aggt/Sttld/Vol + Aggt/Faild/Vol != Aggt/Ttl/Vol">
			<xsl:call-template name="CSDR9Error">
				<xsl:with-param
						name="code"
						select="'INS-031.2'" />
				<xsl:with-param
						name="context"
						select="Aggt/Sttld/Vol|Aggt/Faild/Vol|Aggt/Ttl/Vol" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="Aggt/Sttld/Val + Aggt/Faild/Val != Aggt/Ttl/Val">
			<xsl:call-template name="CSDR9Error">
				<xsl:with-param
						name="code"
						select="'INS-034.2'" />
				<xsl:with-param
						name="context"
						select="Aggt/Sttld/Val|Aggt/Faild/Val|Aggt/Ttl/Val" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="Aggt/Faild/Vol * 100 div Aggt/Ttl/Vol != FaildRate/VolPctg">
			<xsl:call-template name="CSDR9Error">
				<xsl:with-param
						name="code"
						select="'INS-033.2'" />
				<xsl:with-param
						name="context"
						select="Aggt/Faild/Vol|Aggt/Ttl/Vol|FaildRate/VolPctg" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="Aggt/Faild/Val * 100 div Aggt/Ttl/Val != FaildRate/Val">
			<xsl:call-template name="CSDR9Error">
				<xsl:with-param
						name="code"
						select="'INS-034.2'" />
				<xsl:with-param
						name="context"
						select="Aggt/Faild/Val|Aggt/Ttl/Val|FaildRate/Val" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="/Document/SttlmIntlrRpt/SttlmIntlr/TxTp/SctiesLndgOrBrrwg">
		<xsl:if test="Aggt/Sttld/Vol + Aggt/Faild/Vol != Aggt/Ttl/Vol">
			<xsl:call-template name="CSDR9Error">
				<xsl:with-param
						name="code"
						select="'INS-031.3'" />
				<xsl:with-param
						name="context"
						select="Aggt/Sttld/Vol|Aggt/Faild/Vol|Aggt/Ttl/Vol" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="Aggt/Sttld/Val + Aggt/Faild/Val != Aggt/Ttl/Val">
			<xsl:call-template name="CSDR9Error">
				<xsl:with-param
						name="code"
						select="'INS-032.3'" />
				<xsl:with-param
						name="context"
						select="Aggt/Sttld/Val|Aggt/Faild/Val|Aggt/Ttl/Val" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="Aggt/Faild/Vol * 100 div Aggt/Ttl/Vol != FaildRate/VolPctg">
			<xsl:call-template name="CSDR9Error">
				<xsl:with-param
						name="code"
						select="'INS-033.3'" />
				<xsl:with-param
						name="context"
						select="Aggt/Faild/Vol|Aggt/Ttl/Vol|FaildRate/VolPctg" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="Aggt/Faild/Val * 100 div Aggt/Ttl/Val != FaildRate/Val">
			<xsl:call-template name="CSDR9Error">
				<xsl:with-param
						name="code"
						select="'INS-034.3'" />
				<xsl:with-param
						name="context"
						select="Aggt/Faild/Val|Aggt/Ttl/Val|FaildRate/Val" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="/Document/SttlmIntlrRpt/SttlmIntlr/TxTp/RpAgrmt">
		<xsl:if test="Aggt/Sttld/Vol + Aggt/Faild/Vol != Aggt/Ttl/Vol">
			<xsl:call-template name="CSDR9Error">
				<xsl:with-param
						name="code"
						select="'INS-031.4'" />
				<xsl:with-param
						name="context"
						select="Aggt/Sttld/Vol|Aggt/Faild/Vol|Aggt/Ttl/Vol" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="Aggt/Sttld/Val + Aggt/Faild/Val != Aggt/Ttl/Val">
			<xsl:call-template name="CSDR9Error">
				<xsl:with-param
						name="code"
						select="'INS-032.4'" />
				<xsl:with-param
						name="context"
						select="Aggt/Sttld/Val|Aggt/Faild/Val|Aggt/Ttl/Val" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="Aggt/Faild/Vol * 100 div Aggt/Ttl/Vol != FaildRate/VolPctg">
			<xsl:call-template name="CSDR9Error">
				<xsl:with-param
						name="code"
						select="'INS-033.4'" />
				<xsl:with-param
						name="context"
						select="Aggt/Faild/Vol|Aggt/Ttl/Vol|FaildRate/VolPctg" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="Aggt/Faild/Val * 100 div Aggt/Ttl/Val != FaildRate/Val">
			<xsl:call-template name="CSDR9Error">
				<xsl:with-param
						name="code"
						select="'INS-034.4'" />
				<xsl:with-param
						name="context"
						select="Aggt/Faild/Val|Aggt/Ttl/Val|FaildRate/Val" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="/Document/SttlmIntlrRpt/SttlmIntlr/TxTp/OthrTxs">
		<xsl:if test="Aggt/Sttld/Vol + Aggt/Faild/Vol != Aggt/Ttl/Vol">
			<xsl:call-template name="CSDR9Error">
				<xsl:with-param
						name="code"
						select="'INS-031.5'" />
				<xsl:with-param
						name="context"
						select="Aggt/Sttld/Vol|Aggt/Faild/Vol|Aggt/Ttl/Vol" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="Aggt/Sttld/Val + Aggt/Faild/Val != Aggt/Ttl/Val">
			<xsl:call-template name="CSDR9Error">
				<xsl:with-param
						name="code"
						select="'INS-032.5'" />
				<xsl:with-param
						name="context"
						select="Aggt/Sttld/Val|Aggt/Faild/Val|Aggt/Ttl/Val" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="Aggt/Faild/Vol * 100 div Aggt/Ttl/Vol != FaildRate/VolPctg">
			<xsl:call-template name="CSDR9Error">
				<xsl:with-param
						name="code"
						select="'INS-033.5'" />
				<xsl:with-param
						name="context"
						select="Aggt/Faild/Vol|Aggt/Ttl/Vol|FaildRate/VolPctg" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="Aggt/Faild/Val * 100 div Aggt/Ttl/Val != FaildRate/Val">
			<xsl:call-template name="CSDR9Error">
				<xsl:with-param
						name="code"
						select="'INS-034.5'" />
				<xsl:with-param
						name="context"
						select="Aggt/Faild/Val|Aggt/Ttl/Val|FaildRate/Val" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="/Document/SttlmIntlrRpt/SttlmIntlr/ClntTp/Prfssnl">
		<xsl:if test="Aggt/Sttld/Vol + Aggt/Faild/Vol != Aggt/Ttl/Vol">
			<xsl:call-template name="CSDR9Error">
				<xsl:with-param
						name="code"
						select="'INS-041.1'" />
				<xsl:with-param
						name="context"
						select="Aggt/Sttld/Vol|Aggt/Faild/Vol|Aggt/Ttl/Vol" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="Aggt/Sttld/Val + Aggt/Faild/Val != Aggt/Ttl/Val">
			<xsl:call-template name="CSDR9Error">
				<xsl:with-param
						name="code"
						select="'INS-042.1'" />
				<xsl:with-param
						name="context"
						select="Aggt/Sttld/Val|Aggt/Faild/Val|Aggt/Ttl/Val" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="Aggt/Faild/Vol * 100 div Aggt/Ttl/Vol != FaildRate/VolPctg">
			<xsl:call-template name="CSDR9Error">
				<xsl:with-param
						name="code"
						select="'INS-043.1'" />
				<xsl:with-param
						name="context"
						select="Aggt/Faild/Vol|Aggt/Ttl/Vol|FaildRate/VolPctg" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="Aggt/Faild/Val * 100 div Aggt/Ttl/Val != FaildRate/Val">
			<xsl:call-template name="CSDR9Error">
				<xsl:with-param
						name="code"
						select="'INS-044.1'" />
				<xsl:with-param
						name="context"
						select="Aggt/Faild/Val|Aggt/Ttl/Val|FaildRate/Val" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="/Document/SttlmIntlrRpt/SttlmIntlr/ClntTp/Rtl">
		<xsl:if test="Aggt/Sttld/Vol + Aggt/Faild/Vol != Aggt/Ttl/Vol">
			<xsl:call-template name="CSDR9Error">
				<xsl:with-param
						name="code"
						select="'INS-041.2'" />
				<xsl:with-param
						name="context"
						select="Aggt/Sttld/Vol|Aggt/Faild/Vol|Aggt/Ttl/Vol" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="Aggt/Sttld/Val + Aggt/Faild/Val != Aggt/Ttl/Val">
			<xsl:call-template name="CSDR9Error">
				<xsl:with-param
						name="code"
						select="'INS-042.2'" />
				<xsl:with-param
						name="context"
						select="Aggt/Sttld/Val|Aggt/Faild/Val|Aggt/Ttl/Val" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="Aggt/Faild/Vol * 100 div Aggt/Ttl/Vol != FaildRate/VolPctg">
			<xsl:call-template name="CSDR9Error">
				<xsl:with-param
						name="code"
						select="'INS-043.2'" />
				<xsl:with-param
						name="context"
						select="Aggt/Faild/Vol|Aggt/Ttl/Vol|FaildRate/VolPctg" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="Aggt/Faild/Val * 100 div Aggt/Ttl/Val != FaildRate/Val">
			<xsl:call-template name="CSDR9Error">
				<xsl:with-param
						name="code"
						select="'INS-044.2'" />
				<xsl:with-param
						name="context"
						select="Aggt/Faild/Val|Aggt/Ttl/Val|FaildRate/Val" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="/Document/SttlmIntlrRpt/SttlmIntlr/TtlCshTrf">
		<xsl:if test="Aggt/Sttld/Vol + Aggt/Faild/Vol != Aggt/Ttl/Vol">
			<xsl:call-template name="CSDR9Error">
				<xsl:with-param
						name="code"
						select="'INS-051'" />
				<xsl:with-param
						name="context"
						select="Aggt/Sttld/Vol|Aggt/Faild/Vol|Aggt/Ttl/Vol" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="Aggt/Sttld/Val + Aggt/Faild/Val != Aggt/Ttl/Val">
			<xsl:call-template name="CSDR9Error">
				<xsl:with-param
						name="code"
						select="'INS-052'" />
				<xsl:with-param
						name="context"
						select="Aggt/Sttld/Val|Aggt/Faild/Val|Aggt/Ttl/Val" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="Aggt/Faild/Vol * 100 div Aggt/Ttl/Vol != FaildRate/VolPctg">
			<xsl:call-template name="CSDR9Error">
				<xsl:with-param
						name="code"
						select="'INS-053'" />
				<xsl:with-param
						name="context"
						select="Aggt/Faild/Vol|Aggt/Ttl/Vol|FaildRate/VolPctg" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="Aggt/Faild/Val * 100 div Aggt/Ttl/Val != FaildRate/Val">
			<xsl:call-template name="CSDR9Error">
				<xsl:with-param
						name="code"
						select="'INS-054'" />
				<xsl:with-param
						name="context"
						select="Aggt/Faild/Val|Aggt/Ttl/Val|FaildRate/Val" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="/Document/SttlmIntlrRpt/IssrCSD/Id">

		<xsl:variable
				name="lei"
				select="LEI" />
		<xsl:variable
				name="cc"
				select="FrstTwoCharsInstrmId" />

		<xsl:if test="boolean($lei) and not(my:ISO17442($lei))">
			<xsl:call-template name="CSDR9Error">
				<xsl:with-param
						name="code"
						select="'INS-062'" />
				<xsl:with-param
						name="context"
						select="$lei" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="not($cc) or not($countrycodes[. = $cc])">
			<xsl:call-template name="CSDR9Error">
				<xsl:with-param
						name="code"
						select="'INS-063'" />
				<xsl:with-param
						name="context"
						select="$cc" />
			</xsl:call-template>
		</xsl:if>

		<xsl:choose>
			<xsl:when test="boolean($lei)">
				<xsl:if test="count(../../IssrCSD/Id[LEI = $lei and FrstTwoCharsInstrmId = $cc]) &gt; 1">
					<xsl:call-template name="CSDR9Error">
						<xsl:with-param
								name="code"
								select="'INS-064'" />
						<xsl:with-param
								name="context"
								select="$cc|$lei" />
					</xsl:call-template>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="count(../../IssrCSD/Id[FrstTwoCharsInstrmId = $cc]) &gt; 1">
					<xsl:call-template name="CSDR9Error">
						<xsl:with-param
								name="code"
								select="'INS-064'" />
						<xsl:with-param
								name="context"
								select="$cc" />
					</xsl:call-template>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>

		<!-- INS-065 requires external lookup -->

		<!-- INS-066 requires external lookup -->

	</xsl:template>

	<xsl:template match="text()|@*">
		<!-- <xsl:value-of select="."/> -->
	</xsl:template>

</xsl:transform>
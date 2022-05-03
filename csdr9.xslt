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
		<xsl:if test="Ccy != 'EUR'"></xsl:if>
		<xsl:call-template name="CSDR9Error">
			<xsl:with-param
					name="code"
					select="'INS-001'" />
			<xsl:with-param
					name="context"
					select="Ccy" />
		</xsl:call-template>

		<xsl:variable
				name="reportingperiod"
				select="RptgDt" />
		<xsl:variable
				name="date"
				select="substring($reportingperiod,6,5)" />
		<xsl:if test="not($date='03-31' or $date='06-30' or $date='09-30' or $date='12-31')">
			<error>
				INS-002 The date [
				<xsl:value-of select="RptgDt" />
				] is not valid. One of YYYY-03-31, YYYY-06-30, YYYY-09-30 or YYYY-12-31 is expected, where YYYY is the year of the report.
			</error>
		</xsl:if>

	</xsl:template>

	<!-- INS-003 requires filename -->

	<xsl:template match="/Document/SttlmIntlrRpt/SttlmIntlr/Id">
		<xsl:if test="not(my:ISO17442(LEI))">
			<error>
				INS-013 The LEI [
				<xsl:value-of select="LEI" />
				] is not valid according to ISO 17442.
			</error>
		</xsl:if>

		<!-- INS-014.1 requires filename -->

		<!-- INS-014.2 requires filename -->

		<xsl:variable
				name="branchid"
				select="BrnchId" />

		<xsl:if test="boolean($branchid) and not($eeacountrycodes[. = $branchid] or $branchid = 'TS')">
			<error>
				INS-014.3 The branch country code [
				<xsl:value-of select="$branchid" />
				] is not valid, since it must relate either to an EEA country code or to a Third Country State (i.e. 'TS').
			</error>
		</xsl:if>

		<!-- INS-015 requires external lookup -->

		<!-- INS-016 requires external lookup -->

		<!-- INS-016 requires external lookup -->

	</xsl:template>

	<xsl:template match="/Document/SttlmIntlrRpt/SttlmIntlr/FinInstrm/Eqty">
		<xsl:if test="Aggt/Sttld/Vol + Aggt/Faild/Vol != Aggt/Ttl/Vol">
			<error>
INS-021.1 For the financial instrument "Transferable securities referred to in point (a) of Article 4(1)(44) of Directive 2014/65/EU" the sum of settled volume plus failed volume is not equal to the total volume.
 </error>
		</xsl:if>
		<xsl:if test="Aggt/Sttld/Val + Aggt/Faild/Val != Aggt/Ttl/Val">
			<error>
INS-022.1 For the financial instrument "Transferable securities referred to in point (a) of Article 4(1)(44) of Directive 2014/65/EU" the sum of settled value plus failed value is not equal to the total value.
</error>
		</xsl:if>
		<xsl:if test="Aggt/Faild/Vol * 100 div Aggt/Ttl/Vol != FaildRate/VolPctg">
			<error>
INS-023.1 For the financial instrument "Transferable securities referred to in point (a) of Article 4(1)(44) of Directive 2014/65/EU" the Failed Rate Volume % is not consistent to the corresponding Aggregate Failed and Aggregate Total data.
</error>
		</xsl:if>
		<xsl:if test="Aggt/Faild/Val * 100 div Aggt/Ttl/Val != FaildRate/Val">
			<error>
INS-024.1 For the financial instrument "Transferable securities referred to in point (a) of Article 4(1)(44) of Directive 2014/65/EU" the Failed Rate Value % is not consistent to the corresponding Aggregate Failed and Aggregate Total data.
</error>
		</xsl:if>

		<!-- <xsl:variable
				name="total"
				select="Aggt/Ttl/Vol" />
		<xsl:variable
				name="sum"
				select="sum(/Document/SttlmIntlrRpt/IssrCSD/FinInstrm/Eqty/Aggt/Ttl/Vol)" />
		<debug>
			total:
			<xsl:value-of select="$total" />
			sum:
			<xsl:value-of select="$sum" />
		</debug> -->

		<xsl:if test="Aggt/Ttl/Vol != sum(/Document/SttlmIntlrRpt/IssrCSD/FinInstrm/Eqty/Aggt/Ttl/Vol)">
			<error>
INS-071.1 For the financial instrument "Transferable securities referred to in point (a) of Article 4(1)(44) of Directive 2014/65/EU" the sum of total volumes reported for all Issuer CSDs is not equal to the overall total volume of this type of instrument, reported under the Settlement Internaliser block.
</error>
		</xsl:if>

	</xsl:template>

	<xsl:template match="/Document/SttlmIntlrRpt/SttlmIntlr/FinInstrm/SvrgnDebt">
		<xsl:if test="Aggt/Sttld/Vol + Aggt/Faild/Vol != Aggt/Ttl/Vol">
			<error>
INS-021.2 For the financial instrument "Sovereign debt referred to in Article 4(1)(61) of Directive2014/65/EU" the sum of settled volume plus failed volume is not equal to the total volume.
 </error>
		</xsl:if>
		<xsl:if test="Aggt/Sttld/Val + Aggt/Faild/Val != Aggt/Ttl/Val">
			<error>
INS-022.2 For the financial instrument "Sovereign debt referred to in Article 4(1)(61) of Directive2014/65/EU" the sum of settled value plus failed value is not equal to the total value.
</error>
		</xsl:if>
		<xsl:if test="Aggt/Faild/Vol * 100 div Aggt/Ttl/Vol != FaildRate/VolPctg">
			<error>
INS-023.2 For the financial instrument "Sovereign debt referred to in Article 4(1)(61) of Directive 2014/65/EU" the Failed Rate Volume % is not consistent to the corresponding Aggregate Failed and Aggregate Total data.
</error>
		</xsl:if>
		<xsl:if test="Aggt/Faild/Val * 100 div Aggt/Ttl/Val != FaildRate/Val">
			<error>
INS-024.2 For the financial instrument "Sovereign debt referred to in Article 4(1)(61) of Directive 2014/65/EU" the Failed Rate Value % is not consistent to the corresponding Aggregate Failed and Aggregate Total data.
</error>
		</xsl:if>
		<xsl:if test="Aggt/Ttl/Vol != sum(/Document/SttlmIntlrRpt/IssrCSD/FinInstrm/SvrgnDebt/Aggt/Ttl/Vol)">
			<error>
INS-071.2 For the financial instrument "Sovereign debt referred to in Article 4(1)(61) of Directive 2014/65/EU" the sum of total volumes reported for all Issuer CSDs is not equal to the overall total volume of this type of instrument, reported under the Settlement Internaliser block.
</error>
		</xsl:if>
	</xsl:template>

	<xsl:template match="/Document/SttlmIntlrRpt/SttlmIntlr/FinInstrm/Bd">
		<xsl:if test="Aggt/Sttld/Vol + Aggt/Faild/Vol != Aggt/Ttl/Vol">
			<error>
INS-021.3 For the financial instrument "Transferable securities referred to in point (b) of Article 4(1)(44) of Directive 2014/65/EU other than sovereign debt referred to in Article 4(1)(61) of Directive 2014/65/EU" the sum of settled volume plus failed volume is not equal to the total volume.
</error>
		</xsl:if>
		<xsl:if test="Aggt/Sttld/Val + Aggt/Faild/Val != Aggt/Ttl/Val">
			<error>
INS-022.3 For the financial instrument "Transferable securities referred to in point (b) of Article 4(1)(44) of Directive 2014/65/EU other than sovereign debt referred to in Article 4(1)(61) of Directive 2014/65/EU" the sum of settled value plus failed value is not equal to the total value.
</error>
		</xsl:if>
		<xsl:if test="Aggt/Faild/Vol * 100 div Aggt/Ttl/Vol != FaildRate/VolPctg">
			<error>
INS-023.3 For the financial instrument "Transferable securities referred to in point (b) of Article 4(1)(44) of Directive 2014/65/EU other than sovereign debt referred to in Article 4(1)(61) of Directive 2014/65/EU" the Failed Rate Volume % is not consistent to the corresponding Aggregate Failed and Aggregate Total data.
</error>
		</xsl:if>
		<xsl:if test="Aggt/Faild/Val * 100 div Aggt/Ttl/Val != FaildRate/Val">
			<error>
INS-024.3 For the financial instrument "Transferable securities referred to in point (b) of Article 4(1)(44) of Directive 2014/65/EU other than sovereign debt referred to in Article 4(1)(61) of Directive 2014/65/EU" the Failed Rate Value % is not consistent to the corresponding Aggregate Failed and Aggregate Total data.
</error>
		</xsl:if>
	</xsl:template>

	<xsl:template match="/Document/SttlmIntlrRpt/SttlmIntlr/FinInstrm/OthrTrfblScties">
		<xsl:if test="Aggt/Sttld/Vol + Aggt/Faild/Vol != Aggt/Ttl/Vol">
			<error>
INS-021.4 For the financial instrument "Transferable securities referred to in point (c) of Article 4(1)(44) of Directive 2014/65/EU" the sum of settled volume plus failed volume is not equal to the total volume.
</error>
		</xsl:if>
		<xsl:if test="Aggt/Sttld/Val + Aggt/Faild/Val != Aggt/Ttl/Val">
			<error>
INS-022.4 For the financial instrument "Transferable securities referred to in point (c) of Article 4(1)(44) of Directive 2014/65/EU" the sum of settled value plus failed value is not equal to the total value.
</error>
		</xsl:if>
		<xsl:if test="Aggt/Faild/Vol * 100 div Aggt/Ttl/Vol != FaildRate/VolPctg">
			<error>
INS-023.4 For the financial instrument "Transferable securities referred to in point (c) of Article 4(1)(44) of Directive 2014/65/EU" the Failed Rate Volume % is not consistent to the corresponding Aggregate Failed and Aggregate Total data.
</error>
		</xsl:if>
		<xsl:if test="Aggt/Faild/Val * 100 div Aggt/Ttl/Val != FaildRate/Val">
			<error>
INS-024.4 For the financial instrument "Transferable securities referred to in point (c) of Article 4(1)(44) of Directive 2014/65/EU" the Failed Rate Value % is not consistent to the corresponding Aggregate Failed and Aggregate Total data.
</error>
		</xsl:if>
	</xsl:template>

	<xsl:template match="/Document/SttlmIntlrRpt/SttlmIntlr/FinInstrm/XchgTradgFnds">
		<xsl:if test="Aggt/Sttld/Vol + Aggt/Faild/Vol != Aggt/Ttl/Vol">
			<error>
INS-021.5 For the financial instrument "Exchange-traded funds as defined in point (46) of Article 4(1) of Directive 2014/65/EU" the sum of settled volume plus failed volume is not equal to the total volume.
</error>
		</xsl:if>
		<xsl:if test="Aggt/Sttld/Val + Aggt/Faild/Val != Aggt/Ttl/Val">
			<error>
INS-022.5 For the financial instrument "Exchange-traded funds as defined in point (46) of Article 4(1) of Directive 2014/65/EU" the sum of settled value plus failed value is not equal to the total value.
</error>
		</xsl:if>
		<xsl:if test="Aggt/Faild/Vol * 100 div Aggt/Ttl/Vol != FaildRate/VolPctg">
			<error>
INS-023.5 For the financial instrument "Exchange-traded funds as defined in point (46) of Article 4(1) of Directive 2014/65/EU" the Failed Rate Volume % is not consistent to the corresponding Aggregate Failed and Aggregate Total data.
</error>
		</xsl:if>
		<xsl:if test="Aggt/Faild/Val * 100 div Aggt/Ttl/Val != FaildRate/Val">
			<error>
INS-024.5 For the financial instrument "Exchange-traded funds as defined in point (46) of Article 4(1) of Directive 2014/65/EU" the Failed Rate Value % is not consistent to the corresponding Aggregate Failed and Aggregate Total data.
</error>
		</xsl:if>
	</xsl:template>

	<xsl:template match="/Document/SttlmIntlrRpt/SttlmIntlr/FinInstrm/CllctvInvstmtUdrtkgs">
		<xsl:if test="Aggt/Sttld/Vol + Aggt/Faild/Vol != Aggt/Ttl/Vol">
			<error>
INS-021.6 For the financial instrument "Units in collective investment undertakings other than ETFs" the sum of settled volume plus failed volume is not equal to the total volume.
</error>
		</xsl:if>
		<xsl:if test="Aggt/Sttld/Val + Aggt/Faild/Val != Aggt/Ttl/Val">
			<error>
INS-022.6 For the financial instrument "Units in collective investment undertakings other than ETFs" the sum of settled value plus failed value is not equal to the total value.
</error>
		</xsl:if>
		<xsl:if test="Aggt/Faild/Vol * 100 div Aggt/Ttl/Vol != FaildRate/VolPctg">
			<error>
INS-023.6 For the financial instrument "Units in collective investment undertakings other than ETFs" the Failed Rate Volume % is not consistent to the corresponding Aggregate Failed and Aggregate Total data.
</error>
		</xsl:if>
		<xsl:if test="Aggt/Faild/Val * 100 div Aggt/Ttl/Val != FaildRate/Val">
			<error>
INS-024.6 For the financial instrument "Units in collective investment undertakings other than ETFs" the Failed Rate Value % is not consistent to the corresponding Aggregate Failed and Aggregate Total data.
</error>
		</xsl:if>
	</xsl:template>

	<xsl:template match="/Document/SttlmIntlrRpt/SttlmIntlr/FinInstrm/MnyMktInstrm">
		<xsl:if test="Aggt/Sttld/Vol + Aggt/Faild/Vol != Aggt/Ttl/Vol">
			<error>
INS-021.7 For the financial instrument "Money market instruments other than sovereign debt referred to in Article 4(1)(61) of Directive 2014/65/EU" the sum of settled volume plus failed volume is not equal to the total volume.
</error>
		</xsl:if>
		<xsl:if test="Aggt/Sttld/Val + Aggt/Faild/Val != Aggt/Ttl/Val">
			<error>
INS-022.7 For the financial instrument "Money market instruments other than sovereign debt referred to in Article 4(1)(61) of Directive 2014/65/EU" the sum of settled value plus failed value is not equal to the total value.
</error>
		</xsl:if>
		<xsl:if test="Aggt/Faild/Vol * 100 div Aggt/Ttl/Vol != FaildRate/VolPctg">
			<error>
INS-023.7 For the financial instrument "Money market instruments other than sovereign debt referred to in Article 4(1)(61) of Directive 2014/65/EU" the Failed Rate Volume % is not consistent to the corresponding Aggregate Failed and Aggregate Total data.
</error>
		</xsl:if>
		<xsl:if test="Aggt/Faild/Val * 100 div Aggt/Ttl/Val != FaildRate/Val">
			<error>
INS-024.7 For the financial instrument "Money market instruments other than sovereign debt referred to in Article 4(1)(61) of Directive 2014/65/EU" the Failed Rate Value % is not consistent to the corresponding Aggregate Failed and Aggregate Total data.
</error>
		</xsl:if>
	</xsl:template>

	<xsl:template match="/Document/SttlmIntlrRpt/SttlmIntlr/FinInstrm/EmssnAllwnc">
		<xsl:if test="Aggt/Sttld/Vol + Aggt/Faild/Vol != Aggt/Ttl/Vol">
			<error>
INS-021.8 For the financial instrument "Emission allowances" the sum of settled volume plus failed volume is not equal to the total volume.
</error>
		</xsl:if>
		<xsl:if test="Aggt/Sttld/Val + Aggt/Faild/Val != Aggt/Ttl/Val">
			<error>
INS-022.8 For the financial instrument "Emission allowances" the sum of settled value plus failed value is not equal to the total value.
</error>
		</xsl:if>
		<xsl:if test="Aggt/Faild/Vol * 100 div Aggt/Ttl/Vol != FaildRate/VolPctg">
			<error>
INS-023.8 For the financial instrument "Emission allowances" the Failed Rate Volume % is not consistent to the corresponding Aggregate Failed and Aggregate Total data.
</error>
		</xsl:if>
		<xsl:if test="Aggt/Faild/Val * 100 div Aggt/Ttl/Val != FaildRate/Val">
			<error>
INS-024.8 For the financial instrument "Emission allowances" the Failed Rate Value % is not consistent to the corresponding Aggregate Failed and Aggregate Total data.
</error>
		</xsl:if>
	</xsl:template>

	<xsl:template match="/Document/SttlmIntlrRpt/SttlmIntlr/FinInstrm/OthrFinInstrms">
		<xsl:if test="Aggt/Sttld/Vol + Aggt/Faild/Vol != Aggt/Ttl/Vol">
			<error>
INS-021.9 For the financial instrument "Other financial instruments" the sum of settled volume plus failed volume is not equal to the total volume.
</error>
		</xsl:if>
		<xsl:if test="Aggt/Sttld/Val + Aggt/Faild/Val != Aggt/Ttl/Val">
			<error>
INS-022.9 For the financial instrument "Other financial instruments" the sum of settled value plus failed value is not equal to the total value.
</error>
		</xsl:if>
		<xsl:if test="Aggt/Faild/Vol * 100 div Aggt/Ttl/Vol != FaildRate/VolPctg">
			<error>
INS-023.9 For the financial instrument "Other financial instruments" the Failed Rate Volume % is not consistent to the corresponding Aggregate Failed and Aggregate Total data.
</error>
		</xsl:if>
		<xsl:if test="Aggt/Faild/Val * 100 div Aggt/Ttl/Val != FaildRate/Val">
			<error>
INS-024.9 For the financial instrument "Other financial instruments" the FailedRate Value % is not consistent to the corresponding Aggregate Failed and Aggregate Total data.
</error>
		</xsl:if>
	</xsl:template>

	<xsl:template match="/Document/SttlmIntlrRpt/SttlmIntlr/TxTp/SctiesBuyOrSell">
		<xsl:if test="Aggt/Sttld/Vol + Aggt/Faild/Vol != Aggt/Ttl/Vol">
			<error>
INS-031.1 For the type of transaction "Purchase or sale of securities" the sum of settled volume plus failed volume is not equal to the total volume.
 </error>
		</xsl:if>
		<xsl:if test="Aggt/Sttld/Val + Aggt/Faild/Val != Aggt/Ttl/Val">
			<error>
INS-032.1 For the type of transaction "Purchase or sale of securities" the sum of settled value plus failed value is not equal to the total value.
</error>
		</xsl:if>
		<xsl:if test="Aggt/Faild/Vol * 100 div Aggt/Ttl/Vol != FaildRate/VolPctg">
			<error>
INS-033.1 For the type of transaction "Purchase or sale of securities" the Failed Rate Volume % is not consistent to the corresponding Aggregate Failed and Aggregate Total data.
</error>
		</xsl:if>
		<xsl:if test="Aggt/Faild/Val * 100 div Aggt/Ttl/Val != FaildRate/Val">
			<error>
INS-034.1 For the type of transaction "Purchase or sale of securities" the Failed Rate Value % is not consistent to the corresponding Aggregate Failed and Aggregate Total data.
</error>
		</xsl:if>
	</xsl:template>

	<xsl:template match="/Document/SttlmIntlrRpt/SttlmIntlr/TxTp/CollMgmtOpr">
		<xsl:if test="Aggt/Sttld/Vol + Aggt/Faild/Vol != Aggt/Ttl/Vol">
			<error>
INS-031.2 For the type of transaction "Collateral management operations" the sum of settled volume plus failed volume is not equal to the total volume.
</error>
		</xsl:if>
		<xsl:if test="Aggt/Sttld/Val + Aggt/Faild/Val != Aggt/Ttl/Val">
			<error>
INS-032.2 For the type of transaction "Collateral management operations" the sum of settled value plus failed value is not equal to the total value.
</error>
		</xsl:if>
		<xsl:if test="Aggt/Faild/Vol * 100 div Aggt/Ttl/Vol != FaildRate/VolPctg">
			<error>
INS-033.2 For the type of transaction "Collateral management operations" the Failed Rate Volume % is not consistent to the corresponding Aggregate Failed and Aggregate Total data.
</error>
		</xsl:if>
		<xsl:if test="Aggt/Faild/Val * 100 div Aggt/Ttl/Val != FaildRate/Val">
			<error>
INS-034.2 For the type of transaction "Collateral management operations" the Failed Rate Value % is not consistent to the corresponding Aggregate Failed and Aggregate Total data.
</error>
		</xsl:if>
	</xsl:template>

	<xsl:template match="/Document/SttlmIntlrRpt/SttlmIntlr/TxTp/SctiesLndgOrBrrwg">
		<xsl:if test="Aggt/Sttld/Vol + Aggt/Faild/Vol != Aggt/Ttl/Vol">
			<error>
INS-031.3 For the type of transaction "Securities lending and securities borrowing" the sum of settled volume plus failed volume is not equal to the total volume.
</error>
		</xsl:if>
		<xsl:if test="Aggt/Sttld/Val + Aggt/Faild/Val != Aggt/Ttl/Val">
			<error>
INS-032.3 For the type of transaction "Securities lending and securities borrowing" the sum of settled value plus failed value is not equal to the total value.
</error>
		</xsl:if>
		<xsl:if test="Aggt/Faild/Vol * 100 div Aggt/Ttl/Vol != FaildRate/VolPctg">
			<error>
INS-033.3 For the type of transaction "Securities lending and securities borrowing" the Failed Rate Volume % is not consistent to the corresponding Aggregate Failed and Aggregate Total data.
</error>
		</xsl:if>
		<xsl:if test="Aggt/Faild/Val * 100 div Aggt/Ttl/Val != FaildRate/Val">
			<error>
INS-034.3 For the type of transaction "Securities lending and securities borrowing" the Failed Rate Value % is not consistent to the corresponding Aggregate Failed and Aggregate Total data.
</error>
		</xsl:if>
	</xsl:template>

	<xsl:template match="/Document/SttlmIntlrRpt/SttlmIntlr/TxTp/RpAgrmt">
		<xsl:if test="Aggt/Sttld/Vol + Aggt/Faild/Vol != Aggt/Ttl/Vol">
			<error>
INS-031.4 For the type of transaction "Repurchase transactions" the sum of settled volume plus failed volume is not equal to the total volume.
</error>
		</xsl:if>
		<xsl:if test="Aggt/Sttld/Val + Aggt/Faild/Val != Aggt/Ttl/Val">
			<error>
INS-032.4 For the type of transaction "Repurchase transactions" the sum of settled value plus failed value is not equal to the total value.
</error>
		</xsl:if>
		<xsl:if test="Aggt/Faild/Vol * 100 div Aggt/Ttl/Vol != FaildRate/VolPctg">
			<error>
INS-033.4 For the type of transaction "Repurchase transactions" the Failed Rate Volume % is not consistent to the corresponding Aggregate Failed and Aggregate Total data.
</error>
		</xsl:if>
		<xsl:if test="Aggt/Faild/Val * 100 div Aggt/Ttl/Val != FaildRate/Val">
			<error>
INS-034.4 For the type of transaction "Repurchase transactions" the Failed Rate Value % is not consistent to the corresponding Aggregate Failed and Aggregate Total data.
</error>
		</xsl:if>
	</xsl:template>

	<xsl:template match="/Document/SttlmIntlrRpt/SttlmIntlr/TxTp/OthrTxs">
		<xsl:if test="Aggt/Sttld/Vol + Aggt/Faild/Vol != Aggt/Ttl/Vol">
			<error>
INS-031.5 For the type of transaction "Other securities transactions" the sum of settled volume plus failed volume is not equal to the total volume.
</error>
		</xsl:if>
		<xsl:if test="Aggt/Sttld/Val + Aggt/Faild/Val != Aggt/Ttl/Val">
			<error>
INS-032.5 For the type of transaction "Other securities transactions" the sum of settled value plus failed value is not equal to the total value.
</error>
		</xsl:if>
		<xsl:if test="Aggt/Faild/Vol * 100 div Aggt/Ttl/Vol != FaildRate/VolPctg">
			<error>
INS-033.5 For the type of transaction "Other securities transactions" the Failed Rate Volume % is not consistent to the corresponding Aggregate Failed and Aggregate Total data.
</error>
		</xsl:if>
		<xsl:if test="Aggt/Faild/Val * 100 div Aggt/Ttl/Val != FaildRate/Val">
			<error>
INS-034.5 For the type of transaction "Other securities transactions" the Failed Rate Value % is not consistent to the corresponding Aggregate Failed and Aggregate Total data.
</error>
		</xsl:if>
	</xsl:template>

	<xsl:template match="/Document/SttlmIntlrRpt/SttlmIntlr/ClntTp/Prfssnl">
		<xsl:if test="Aggt/Sttld/Vol + Aggt/Faild/Vol != Aggt/Ttl/Vol">
			<error>
INS-041.1 For the type of client "Professional clients as defined in point (10) of Article 4(1) of Directive 2014/65/EU" the sum of settled volume plus failed volume is not equal to the total volume.
</error>
		</xsl:if>
		<xsl:if test="Aggt/Sttld/Val + Aggt/Faild/Val != Aggt/Ttl/Val">
			<error>
INS-042.1 For the type of client "Professional clients as defined in point (10) of Article 4(1) of Directive 2014/65/EU" the sum of settled value and failed value is not equal to the total value.
</error>
		</xsl:if>
		<xsl:if test="Aggt/Faild/Vol * 100 div Aggt/Ttl/Vol != FaildRate/VolPctg">
			<error>
INS-043.1 For the type of client "Professional clients as defined in point (10) of Article 4(1) of Directive 2014/65/EU" the Failed Rate Volume % is not consistent to the corresponding Aggregate Failed and Aggregate Total data.
</error>
		</xsl:if>
		<xsl:if test="Aggt/Faild/Val * 100 div Aggt/Ttl/Val != FaildRate/Val">
			<error>
INS-044.1 For the type of client "Professional clients as defined in point (10) of Article 4(1) of Directive 2014/65/EU" the Failed Rate Value % is not consistent to the corresponding Aggregate Failed and Aggregate Total data.
</error>
		</xsl:if>
	</xsl:template>

	<xsl:template match="/Document/SttlmIntlrRpt/SttlmIntlr/ClntTp/Rtl">
		<xsl:if test="Aggt/Sttld/Vol + Aggt/Faild/Vol != Aggt/Ttl/Vol">
			<error>
INS-041.2 For the type of client "Retail clients as defined in point (11) of Article 4(1) of Directive 2014/65/EU" the sum of settled volume plus failed volume is not equal to the total volume.
</error>
		</xsl:if>
		<xsl:if test="Aggt/Sttld/Val + Aggt/Faild/Val != Aggt/Ttl/Val">
			<error>
INS-042.2 For the type of client "Retail clients as defined in point (11) of Article 4(1) of Directive 2014/65/EU" the sum of settled value and failed value is not equal to the total value.
</error>
		</xsl:if>
		<xsl:if test="Aggt/Faild/Vol * 100 div Aggt/Ttl/Vol != FaildRate/VolPctg">
			<error>
INS-043.2 For the type of client "Retail clients as defined in point (11) ofArticle 4(1) of Directive 2014/65/EU" the Failed Rate Volume % is not consistent to the corresponding Aggregate Failed and Aggregate Total data.
</error>
		</xsl:if>
		<xsl:if test="Aggt/Faild/Val * 100 div Aggt/Ttl/Val != FaildRate/Val">
			<error>
INS-044.2 For the type of client "Retail clients as defined in point (11) of Article 4(1) of Directive 2014/65/EU" the Failed Rate Value % is not consistent to the corresponding Aggregate Failed and Aggregate Total data.
</error>
		</xsl:if>
	</xsl:template>

	<xsl:template match="/Document/SttlmIntlrRpt/SttlmIntlr/TtlCshTrf">
		<xsl:if test="Aggt/Sttld/Vol + Aggt/Faild/Vol != Aggt/Ttl/Vol">
			<error>
INS-051 The sum of settled volume plus failed volume of the cash transfers is not equal to the total volume.
</error>
		</xsl:if>
		<xsl:if test="Aggt/Sttld/Val + Aggt/Faild/Val != Aggt/Ttl/Val">
			<error>
INS-052 The sum of settled value and failed value of the cash transfers is not equal to the total value.
</error>
		</xsl:if>
		<xsl:if test="Aggt/Faild/Vol * 100 div Aggt/Ttl/Vol != FaildRate/VolPctg">
			<error>
INS-053 For cash transfers, the Failed Rate Volume % is not consistent to the corresponding Aggregate Failed and Aggregate Totaldata
</error>
		</xsl:if>
		<xsl:if test="Aggt/Faild/Val * 100 div Aggt/Ttl/Val != FaildRate/Val">
			<error>
INS-054 For cash transfers, the Failed Rate Value % is not consistent to the corresponding Aggregate Failed and Aggregate Totaldata
</error>
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
			<error>
				INS-062 The LEI [
				<xsl:value-of select="LEI" />
				] is not valid.
			</error>
		</xsl:if>

		<xsl:if test="not($cc) or not($countrycodes[. = $cc])">
			<error>
				INS-063 The ISIN code of the Issuer CSD is not valid. In case of new ISINs, please make sure to inform ESMA before submitting them in the report
			</error>
		</xsl:if>

		<xsl:choose>
			<xsl:when test="boolean($lei)">
				<xsl:if test="count(../../IssrCSD/Id[LEI = $lei and FrstTwoCharsInstrmId = $cc]) &gt; 1">
					<error>
						INS-064 There are more than one Issuer CSDs with an ISIN Code starting with
						<xsl:value-of select="$cc" />
						and LEI:
						<xsl:value-of select="$lei" />
					</error>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="count(../../IssrCSD/Id[FrstTwoCharsInstrmId = $cc]) &gt; 1">
					<error>
						INS-064 There are more than one Issuer CSDs with ISIN Code starting with:
						<xsl:value-of select="$cc" />
					</error>
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
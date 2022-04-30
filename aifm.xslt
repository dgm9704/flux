<xsl:transform
		version="1.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:func="http://exslt.org/functions"
		xmlns:str="http://exslt.org/strings"
		xmlns:my="http://example.org/my"
		exclude-result-prefixes="my"
		extension-element-prefixes="func str">

	<xsl:output
			indent="yes"
			method="xml" />

	<xsl:template match="AIFMReportingInfo">
		<aifm>
			<xsl:variable
					name="reportingmemberstate"
					select="@ReportingMemberState" />
			<xsl:if test="not($eeacountrycodes[. = $reportingmemberstate])">
				<xsl:call-template name="Error">
					<xsl:with-param
							name="record"
							select="''" />
					<xsl:with-param
							name="code"
							select="'FIL-015'" />
					<xsl:with-param
							name="node"
							select="$reportingmemberstate" />
					<xsl:with-param
							name="message"
							select="'The authority key file attribute is invalid and should an EU or EEA country'" />
				</xsl:call-template>
			</xsl:if>
			<xsl:apply-templates />
		</aifm>
	</xsl:template>

	<xsl:template match="AIFMRecordInfo">
		<xsl:variable
				name="manager"
				select="AIFMNationalCode" />
		<xsl:variable
				name="reportingperiodstartdate"
				select="ReportingPeriodStartDate" />
		<xsl:variable
				name="startdate"
				select="translate($reportingperiodstartdate,'-','')" />
		<xsl:variable
				name="year"
				select="substring($startdate,1,4)" />
		<xsl:variable
				name="month"
				select="substring($startdate,5,2)" />
		<xsl:variable
				name="day"
				select="substring($startdate,7,2)" />
		<xsl:variable
				name="periodtype"
				select="ReportingPeriodType" />
		<xsl:variable
				name="reportingyear"
				select="ReportingPeriodYear" />
		<xsl:variable name="CAM-002">
			<xsl:choose>
				<xsl:when test="not($day='01') or not($year=$reportingyear)">true</xsl:when>
				<xsl:when test="$periodtype='Q1' or $periodtype='Q2' or $periodtype='Q3' or $periodtype='Q4'">
					<xsl:if test="not($month='10' or $month='07' or $month='01')">true</xsl:if>
				</xsl:when>
				<xsl:when test="$periodtype='H1' or $periodtype='H2'">
					<xsl:if test="not($month='07' or $month='01')">true</xsl:if>
				</xsl:when>
				<xsl:when test="$periodtype='Y1'">
					<xsl:if test="not($month='01')">true</xsl:if>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="$CAM-002 = 'true'">
			<xsl:call-template name="Error">
				<xsl:with-param
						name="record"
						select="$manager" />
				<xsl:with-param
						name="code"
						select="'CAM-002'" />
				<xsl:with-param
						name="node"
						select="$reportingperiodstartdate" />
				<xsl:with-param
						name="message"
						select="'The reporting period start date is not allowed.'" />
			</xsl:call-template>
		</xsl:if>

		<xsl:variable
				name="reportingperiodenddate"
				select="ReportingPeriodEndDate" />
		<xsl:variable
				name="enddate"
				select="translate($reportingperiodenddate,'-','')" />
		<xsl:variable
				name="q1end"
				select="concat($year,'0331')" />
		<xsl:variable
				name="q2end"
				select="concat($year,'0630')" />
		<xsl:variable
				name="q3end"
				select="concat($year,'0930')" />
		<xsl:variable
				name="q4end"
				select="concat($year,'1231')" />
		<xsl:variable
				name="transition"
				select="LastReportingFlag='true'" />

		<xsl:variable name="CAM-003">
			<xsl:choose>
				<xsl:when test="not($enddate&gt;$startdate)">true</xsl:when>
				<xsl:when test="$periodtype='Q1'">
					<xsl:if test="not($enddate=$q1end or ($transition and $enddate&lt;$q1end))">true</xsl:if>
				</xsl:when>
				<xsl:when test="$periodtype='Q2' or $periodtype='H1'">
					<xsl:if test="not($enddate=$q2end or ($transition and $enddate&lt;$q2end))">true</xsl:if>
				</xsl:when>
				<xsl:when test="$periodtype='Q3'">
					<xsl:if test="not($enddate=$q3end or ($transition and $enddate&lt;$q3end))">true</xsl:if>
				</xsl:when>
				<xsl:when test="$periodtype='Q4' or $periodtype='H2' or $periodtype='Y1'">
					<xsl:if test="not($enddate=$q4end or ($transition and $enddate&lt;$q4end))">true</xsl:if>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="$CAM-003 = 'true'">
			<xsl:call-template name="Error">
				<xsl:with-param
						name="record"
						select="$manager" />
				<xsl:with-param
						name="code"
						select="'CAM-003'" />
				<xsl:with-param
						name="node"
						select="$reportingperiodenddate" />
				<xsl:with-param
						name="message"
						select="'The reporting period end date is not allowed'" />
			</xsl:call-template>
		</xsl:if>
		<xsl:variable
				name="changequarter"
				select="AIFMReportingObligationChangeQuarter" />
		<xsl:variable name="CAM-004">
			<xsl:choose>
				<xsl:when test="AIFMReportingObligationChangeFrequencyCode or AIFMReportingObligationChangeContentsCode">
					<xsl:if test="not($changequarter)">true</xsl:if>
				</xsl:when>
				<xsl:otherwise>
					<xsl:if test="$changequarter">true</xsl:if>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="$CAM-004 = 'true'">
			<xsl:call-template name="Error">
				<xsl:with-param
						name="record"
						select="$manager" />
				<xsl:with-param
						name="code"
						select="'CAM-004'" />
				<xsl:with-param
						name="node"
						select="$changequarter" />
				<xsl:with-param
						name="message"
						select="'The quarter for the AIMF reporting obligation change should not be reported'" />
			</xsl:call-template>
		</xsl:if>
		<xsl:variable
				name="jurisdiction"
				select="AIFMJurisdiction" />
		<xsl:if test="not($countrycodes[. = $jurisdiction])">
			<xsl:call-template name="Error">
				<xsl:with-param
						name="record"
						select="$manager" />
				<xsl:with-param
						name="code"
						select="'CAM-005'" />
				<xsl:with-param
						name="node"
						select="$jurisdiction" />
				<xsl:with-param
						name="message"
						select="'The jurisdiction of the AIF is not correct.'" />
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="not($aifmregister[. = $manager])">
			<xsl:call-template name="Error">
				<xsl:with-param
						name="record"
						select="$manager" />
				<xsl:with-param
						name="code"
						select="'CAM-006'" />
				<xsl:with-param
						name="node"
						select="$manager" />
				<xsl:with-param
						name="message"
						select="'The AIFM national code does not exist in the ESMA Register.'" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="AIFMCompleteDescription/AIFMBaseCurrencyDescription/BaseCurrency and not(AIFMCompleteDescription/AIFMBaseCurrencyDescription/BaseCurrency = 'EUR')">
			<xsl:variable
					name="amountbase"
					select="AIFMCompleteDescription/AIFMBaseCurrencyDescription/AUMAmountInBaseCurrency" />
			<xsl:variable
					name="amounteuro"
					select="AIFMCompleteDescription/AUMAmountInEuro" />
			<xsl:variable
					name="rateeuro"
					select="AIFMCompleteDescription/AIFMBaseCurrencyDescription/FXEURRate" />
			<xsl:variable
					name="result"
					select="$amounteuro * $rateeuro" />
			<xsl:if test="not($amountbase = $result)">
				<xsl:call-template name="Error">
					<xsl:with-param
							name="record"
							select="$manager" />
					<xsl:with-param
							name="code"
							select="'CAM-016'" />
					<xsl:with-param
							name="node"
							select="$amountbase" />
					<xsl:with-param
							name="message"
							select="'The total AuM amount in base currency is not consistent with the total AuM amount in Euro.'" />
				</xsl:call-template>
			</xsl:if>
		</xsl:if>

		<xsl:apply-templates>
			<xsl:with-param
					name="manager"
					select="$manager" />
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="AIFMCompleteDescription/AIFMPrincipalMarkets/AIFMFivePrincipalMarket/MarketIdentification">
		<xsl:param name="manager" />
		<xsl:variable
				name="mic"
				select="MarketCode" />
		<xsl:if test="(boolean(MarketCodeType = 'MIC') != boolean($mic)) or ($mic and not($micregister[. = $mic]))">
			<xsl:call-template name="Error">
				<xsl:with-param
						name="record"
						select="$manager" />
				<xsl:with-param
						name="code"
						select="'CAM-010'" />
				<xsl:with-param
						name="node"
						select="$mic" />
				<xsl:with-param
						name="message"
						select="'The MIC code is not correct'" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="AIFMCompleteDescription/AIFMIdentifier/OldAIFMIdentifierNCA">
		<xsl:param name="manager" />

		<xsl:variable
				name="state"
				select="ReportingMemberState" />
		<xsl:if test="$state and not($countrycodes[. = $state])">
			<xsl:call-template name="Error">
				<xsl:with-param
						name="record"
						select="$manager" />
				<xsl:with-param
						name="code"
						select="'CAM-008'" />
				<xsl:with-param
						name="node"
						select="$state" />
				<xsl:with-param
						name="message"
						select="'The country code does not exist in the reference table of countries'" />
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="$state and not(AIFMNationalCode)">
			<xsl:call-template name="Error">
				<xsl:with-param
						name="record"
						select="$manager" />
				<xsl:with-param
						name="code"
						select="'CAM-009'" />
				<xsl:with-param
						name="node"
						select="./AIFMNationalCode" />
				<xsl:with-param
						name="message"
						select="'The field is mandatory when the old AIFM national identifier - Reporting Member State is filled in.'" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="AIFMCompleteDescription/AIFMBaseCurrencyDescription">
		<xsl:param name="manager" />

		<xsl:variable
				name="currency"
				select="BaseCurrency" />
		<xsl:if test="$currency and not($currencycodes[. = $currency])">
			<xsl:call-template name="Error">
				<xsl:with-param
						name="record"
						select="$manager" />
				<xsl:with-param
						name="code"
						select="'CAM-017'" />
				<xsl:with-param
						name="node"
						select="$currency" />
				<xsl:with-param
						name="message"
						select="'The currency code does not exist in the reference table of currencies'" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="($currency = 'EUR' and FXEURReferenceRateType = 'OTH') != boolean(FXEUROtherReferenceRateDescription)">
			<error>
				<record>
					<xsl:value-of select="$manager" />
				</record>
				<code>CAM-020</code>
				<message>The reference rate description is not consistent with the reference rate type.</message>
				<field>FXEUROtherReferenceRateDescription</field>
				<value>
					<xsl:value-of select="FXEUROtherReferenceRateDescription" />
				</value>
			</error>
		</xsl:if>

	</xsl:template>

	<xsl:template match="AIFMCompleteDescription/AIFMIdentifier/AIFMIdentifierLEI">
		<xsl:param name="manager" />
		<xsl:variable
				name="lei"
				select="." />

		<xsl:if test="not(my:ISO17442($lei))">
			<error>
				<record>
					<xsl:value-of select="$manager" />
				</record>
				<code>CAM-007</code>
				<message>Verify the correctness of the LEI code format rules following the calculation methodology of the 2-last check digits</message>
				<field>AIFMIdentifierLEI</field>
				<value>
					<xsl:value-of select="$lei" />
				</value>
			</error>
		</xsl:if>
	</xsl:template>

	<xsl:template match="AIFMCompleteDescription/AIFMPrincipalInstruments/AIFMPrincipalInstrument">
		<xsl:param name="manager" />
		<xsl:variable
				name="value"
				select="AggregatedValueAmount" />
		<xsl:variable
				name="rank"
				select="Ranking" />

		<xsl:if test="not(SubAssetType = 'NTA_NTA_NOTA') and not($value)">
			<error>
				<record>
					<xsl:value-of select="$manager" />
				</record>
				<code>CAM-013</code>
				<message>The aggregated value is not consistent with the sub-asset type. </message>
				<field>AggregatedValueAmount</field>
				<value>
					<xsl:value-of select="$value" />
				</value>
			</error>
		</xsl:if>

		<xsl:if test="$value &lt; ../AIFMPrincipalInstrument[Ranking=($rank + 1)]/AggregatedValueAmount">
			<error>
				<record>
					<xsl:value-of select="$manager" />
				</record>
				<code>CAM-014</code>
				<message>The reported value is not consistent with the rank.</message>
				<field>AggregatedValueAmount</field>
				<value>
					<xsl:value-of select="$value" />
				</value>
			</error>
		</xsl:if>
	</xsl:template>

	<xsl:template match="AIFMCompleteDescription/AIFMPrincipalMarkets/AIFMFivePrincipalMarket">
		<xsl:param name="manager" />
		<xsl:variable
				name="value"
				select="AggregatedValueAmount" />
		<xsl:variable
				name="rank"
				select="Ranking" />

		<xsl:if test="not(MarketIdentification/MarketCodeType = 'NOT') and not($value)">
			<error>
				<record>
					<xsl:value-of select="$manager" />
				</record>
				<code>CAM-011</code>
				<message>The field is mandatory for market code type different from "NOT".</message>
				<field>MarketCode</field>
				<value>
					<xsl:value-of select="$value" />
				</value>
			</error>
		</xsl:if>

		<xsl:if test="$value &lt; ../AIFMFivePrincipalMarket[Ranking=($rank + 1)]/AggregatedValueAmount">
			<error>
				<record>
					<xsl:value-of select="$manager" />
				</record>
				<code>CAM-012</code>
				<message>The reported value is not consistent with the rank.</message>
				<field>AggregatedValueAmount</field>
				<value>
					<xsl:value-of select="$value" />
				</value>
			</error>
		</xsl:if>
		<xsl:apply-templates>
			<xsl:with-param
					name="manager"
					select="$manager" />
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="text()|@*">
		<!-- <xsl:value-of select="."/> -->
	</xsl:template>


</xsl:transform>
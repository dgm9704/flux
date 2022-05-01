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
				<xsl:call-template name="AIFMError">
					<xsl:with-param
							name="code"
							select="'FIL-015'" />
					<xsl:with-param
							name="context"
							select="$reportingmemberstate" />
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
			<xsl:call-template name="AIFMError">
				<xsl:with-param
						name="code"
						select="'CAM-002'" />
				<xsl:with-param
						name="context"
						select="$reportingperiodstartdate" />
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
			<xsl:call-template name="AIFMError">
				<xsl:with-param
						name="code"
						select="'CAM-003'" />
				<xsl:with-param
						name="context"
						select="$reportingperiodenddate" />
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
			<xsl:call-template name="AIFMError">
				<xsl:with-param
						name="code"
						select="'CAM-004'" />
				<xsl:with-param
						name="context"
						select="$changequarter" />
			</xsl:call-template>
		</xsl:if>
		<xsl:variable
				name="jurisdiction"
				select="AIFMJurisdiction" />
		<xsl:if test="not($countrycodes[. = $jurisdiction])">
			<xsl:call-template name="AIFMError">
				<xsl:with-param
						name="code"
						select="'CAM-005'" />
				<xsl:with-param
						name="context"
						select="$jurisdiction" />
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="not($aifmregister[. = $manager])">
			<xsl:call-template name="AIFMError">
				<xsl:with-param
						name="code"
						select="'CAM-006'" />
				<xsl:with-param
						name="context"
						select="$manager" />
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
				<xsl:call-template name="AIFMError">
					<xsl:with-param
							name="code"
							select="'CAM-016'" />
					<xsl:with-param
							name="context"
							select="$amountbase" />
				</xsl:call-template>
			</xsl:if>
		</xsl:if>

		<xsl:apply-templates />
	</xsl:template>

	<xsl:template match="AIFMCompleteDescription/AIFMPrincipalMarkets/AIFMFivePrincipalMarket/MarketIdentification">
		<xsl:param name="manager" />
		<xsl:variable
				name="mic"
				select="MarketCode" />
		<xsl:if test="(boolean(MarketCodeType = 'MIC') != boolean($mic)) or ($mic and not($micregister[. = $mic]))">
			<xsl:call-template name="AIFMError">
				<xsl:with-param
						name="code"
						select="'CAM-010'" />
				<xsl:with-param
						name="context"
						select="$mic" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="AIFMCompleteDescription/AIFMIdentifier/OldAIFMIdentifierNCA">
		<xsl:variable
				name="state"
				select="ReportingMemberState" />
		<xsl:if test="$state and not($countrycodes[. = $state])">
			<xsl:call-template name="AIFMError">
				<xsl:with-param
						name="code"
						select="'CAM-008'" />
				<xsl:with-param
						name="context"
						select="$state" />
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="$state and not(AIFMNationalCode)">
			<xsl:call-template name="AIFMError">
				<xsl:with-param
						name="code"
						select="'CAM-009'" />
				<xsl:with-param
						name="context"
						select="./AIFMNationalCode" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="AIFMCompleteDescription/AIFMBaseCurrencyDescription">
		<xsl:variable
				name="currency"
				select="BaseCurrency" />
		<xsl:if test="$currency and not($currencycodes[. = $currency])">
			<xsl:call-template name="AIFMError">
				<xsl:with-param
						name="code"
						select="'CAM-017'" />
				<xsl:with-param
						name="context"
						select="$currency" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="($currency = 'EUR' and FXEURReferenceRateType = 'OTH') != boolean(FXEUROtherReferenceRateDescription)">
			<xsl:call-template name="AIFMError">
				<xsl:with-param
						name="code"
						select="'CAM-020'" />
				<xsl:with-param
						name="context"
						select="FXEUROtherReferenceRateDescription" />
			</xsl:call-template>
		</xsl:if>

	</xsl:template>

	<xsl:template match="AIFMCompleteDescription/AIFMIdentifier/AIFMIdentifierLEI">
		<xsl:variable
				name="lei"
				select="." />

		<xsl:if test="not(my:ISO17442($lei))">
			<xsl:call-template name="AIFMError">
				<xsl:with-param
						name="code"
						select="'CAM-007'" />
				<xsl:with-param
						name="context"
						select="$lei" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="AIFMCompleteDescription/AIFMPrincipalInstruments/AIFMPrincipalInstrument">
		<xsl:variable
				name="value"
				select="AggregatedValueAmount" />
		<xsl:variable
				name="rank"
				select="Ranking" />

		<xsl:if test="not(SubAssetType = 'NTA_NTA_NOTA') and not($value)">
			<xsl:call-template name="AIFMError">
				<xsl:with-param
						name="code"
						select="'CAM-013'" />
				<xsl:with-param
						name="context"
						select="$value" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="$value &lt; ../AIFMPrincipalInstrument[Ranking=($rank + 1)]/AggregatedValueAmount">
			<xsl:call-template name="AIFMError">
				<xsl:with-param
						name="code"
						select="'CAM-014'" />
				<xsl:with-param
						name="context"
						select="$value" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="AIFMCompleteDescription/AIFMPrincipalMarkets/AIFMFivePrincipalMarket">
		<xsl:variable
				name="value"
				select="AggregatedValueAmount" />
		<xsl:variable
				name="rank"
				select="Ranking" />

		<xsl:if test="not(MarketIdentification/MarketCodeType = 'NOT') and not($value)">
			<xsl:call-template name="AIFMError">
				<xsl:with-param
						name="code"
						select="'CAM-011'" />
				<xsl:with-param
						name="context"
						select="$value" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="$value &lt; ../AIFMFivePrincipalMarket[Ranking=($rank + 1)]/AggregatedValueAmount">
			<xsl:call-template name="AIFMError">
				<xsl:with-param
						name="code"
						select="'CAM-012'" />
				<xsl:with-param
						name="context"
						select="$value" />
			</xsl:call-template>
		</xsl:if>
		<xsl:apply-templates />
	</xsl:template>

	<xsl:template match="text()|@*">
		<!-- <xsl:value-of select="."/> -->
	</xsl:template>


</xsl:transform>
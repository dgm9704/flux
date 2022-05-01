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

	<xsl:template match="AIFReportingInfo">
		<aif>
			<xsl:variable
					name="reportingmemberstate"
					select="@ReportingMemberState" />
			<xsl:if test="not($eeacountrycodes[. = $reportingmemberstate])">
				<xsl:call-template name="AIFError">
					<xsl:with-param
							name="code"
							select="'FIL-015'" />
					<xsl:with-param
							name="context"
							select="$reportingmemberstate" />
				</xsl:call-template>
			</xsl:if>
			<xsl:apply-templates />
		</aif>
	</xsl:template>

	<xsl:template match="AIFRecordInfo">
		<xsl:variable
				name="noreporting"
				select="AIFNoReportingFlag" />
		<xsl:if test="$noreporting = 'false'">
			<xsl:variable name="contenterror">
				<xsl:if test="(AIFContentType = '2' or AIFContentType = '4') and not(AIFCompleteDescription/AIFIndividualInfo)">true</xsl:if>
				<xsl:if test="(AIFContentType = '2' or AIFContentType = '4') and not(AIFCompleteDescription/AIFLeverageInfo/AIFLeverageArticle24-2)">true</xsl:if>
				<xsl:if test="(AIFContentType = '4' or AIFContentType = '5') and not(AIFCompleteDescription/AIFLeverageInfo/AIFLeverageArticle24-4)">true</xsl:if>
			</xsl:variable>
			<xsl:if test="$contenterror = 'true'">
				<xsl:call-template name="AIFError">
					<xsl:with-param
							name="code"
							select="'CAF-002'" />
					<xsl:with-param
							name="context"
							select="AIFContentType" />
				</xsl:call-template>
			</xsl:if>
		</xsl:if>

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
		<xsl:variable name="starterror">
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

		<xsl:if test="$starterror = 'true'">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-003'" />
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
				select="translate(reportingperiodenddate,'-','')" />
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
		<xsl:variable name="enderror">
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

		<xsl:if test="$enderror = 'true'">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-004'" />
				<xsl:with-param
						name="context"
						select="$reportingperiodenddate" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="(AIFReportingObligationChangeFrequencyCode or AIFReportingObligationChangeContentsCode) != boolean(AIFReportingObligationChangeQuarter)">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-006'" />
				<xsl:with-param
						name="context"
						select="AIFReportingObligationChangeQuarter" />
			</xsl:call-template>
		</xsl:if>

		<xsl:variable
				name="manager"
				select="AIFMNationalCode" />
		<xsl:if test="not($aifmregister[. = $manager])">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-007'" />
				<xsl:with-param
						name="context"
						select="$manager" />
			</xsl:call-template>
		</xsl:if>

		<xsl:variable
				name="fund"
				select="./ancestor-or-self::AIFRecordInfo/AIFNationalCode" />

		<xsl:if test="not($aifregister[. = $fund])">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-008'" />
				<xsl:with-param
						name="context"
						select="$fund" />
			</xsl:call-template>
		</xsl:if>
		<xsl:variable
				name="eeaflag"
				select="boolean(AIFEEAFlag='true')" />
		<xsl:variable
				name="domicile"
				select="AIFDomicile" />
		<xsl:variable
				name="iseea"
				select="boolean($eeacountrycodes[.=$domicile])" />

		<xsl:if test="$eeaflag != $iseea">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-009'" />
				<xsl:with-param
						name="context"
						select="AIFEEAFlag" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="not($countrycodes[. = $domicile])">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-010'" />
				<xsl:with-param
						name="context"
						select="$domicile" />
			</xsl:call-template>
		</xsl:if>

		<xsl:variable
				name="inceptiondate"
				select="translate(InceptionDate,'-','')" />
		<xsl:if test="not($inceptiondate &lt; $startdate)">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-011'" />
				<xsl:with-param
						name="context"
						select="InceptionDate" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="AIFNoReportingFlag = 'true' = boolean(AIFCompleteDescription)">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-012'" />
				<xsl:with-param
						name="context"
						select="AIFNoReportingFlag" />
			</xsl:call-template>
		</xsl:if>

		<xsl:apply-templates>
			<xsl:with-param
					name="periodtype"
					select="$periodtype" />
			<xsl:with-param
					name="noreporting"
					select="$noreporting" />
		</xsl:apply-templates>

	</xsl:template>

	<xsl:template match="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription">
		<xsl:variable
				name="predominantaiftype"
				select="PredominantAIFType" />

		<xsl:choose>
			<xsl:when test="$predominantaiftype = 'HFND'">
				<xsl:if test="not(HedgeFundInvestmentStrategies/HedgeFundStrategy)">
					<xsl:call-template name="AIFError">
						<xsl:with-param
								name="code"
								select="'CAF-036'" />
						<xsl:with-param
								name="context"
								select="HedgeFundStrategy" />
					</xsl:call-template>
				</xsl:if>
			</xsl:when>
			<xsl:when test="$predominantaiftype = 'PEQF'">
				<xsl:if test="not(PrivateEquityFundInvestmentStrategies/PrivateEquityFundInvestmentStrategy)">
					<xsl:call-template name="AIFError">
						<xsl:with-param
								name="code"
								select="'CAF-036'" />
						<xsl:with-param
								name="context"
								select="PrivateEquityFundInvestmentStrategy" />
					</xsl:call-template>
				</xsl:if>
			</xsl:when>
			<xsl:when test="$predominantaiftype = 'RESF'">
				<xsl:if test="not(RealEstateFundInvestmentStrategies/RealEstateFundStrategy)">
					<xsl:call-template name="AIFError">
						<xsl:with-param
								name="code"
								select="'CAF-036'" />
						<xsl:with-param
								name="context"
								select="RealEstateFundStrategy" />
					</xsl:call-template>
				</xsl:if>
			</xsl:when>
			<xsl:when test="$predominantaiftype = 'FOFS'">
				<xsl:if test="not(FundOfFundsInvestmentStrategies/FundOfFundsStrategy)">
					<xsl:call-template name="AIFError">
						<xsl:with-param
								name="code"
								select="'CAF-036'" />
						<xsl:with-param
								name="context"
								select="FundOfFundsStrategy" />
					</xsl:call-template>
				</xsl:if>
			</xsl:when>
			<xsl:when test="$predominantaiftype = 'OTHR'">
				<xsl:if test="not(OtherFundInvestmentStrategies/OtherFundStrategy)">
					<xsl:call-template name="AIFError">
						<xsl:with-param
								name="code"
								select="'CAF-036'" />
						<xsl:with-param
								name="context"
								select="OtherFundStrategy" />
					</xsl:call-template>
				</xsl:if>
			</xsl:when>
		</xsl:choose>
		<xsl:if test="not(PredominantAIFType = 'NONE')">
			<xsl:variable
					name="count"
					select="count(HedgeFundInvestmentStrategies | RealEstateFundInvestmentStrategies | PrivateEquityFundInvestmentStrategies | FundOfFundsInvestmentStrategies | OtherFundInvestmentStrategies)" />
			<xsl:if test="$count &gt; 1">
				<xsl:call-template name="AIFError">
					<xsl:with-param
							name="code"
							select="'CAF-037'" />
					<xsl:with-param
							name="context"
							select="''" />
				</xsl:call-template>
			</xsl:if>
		</xsl:if>

		<xsl:variable
				name="ratesum"
				select="sum(*/*/StrategyNAVRate)" />
		<xsl:if test="not($ratesum = 100)">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-039'" />
				<xsl:with-param
						name="context"
						select="$ratesum" />
			</xsl:call-template>
		</xsl:if>

		<xsl:apply-templates />
	</xsl:template>

	<xsl:template match="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/FundOfFundsInvestmentStrategies/FundOfFundsStrategy">

		<xsl:if test="(FundOfFundsStrategyType = 'OTHR_FOFS') != boolean(StrategyTypeOtherDescription)">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-041'" />
				<xsl:with-param
						name="context"
						select="StrategyTypeOtherDescription" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/OtherFundInvestmentStrategies/OtherFundStrategy">

		<xsl:if test="(OtherFundStrategyType  = 'OTHR_OTHF') != boolean(StrategyTypeOtherDescription)">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-041'" />
				<xsl:with-param
						name="context"
						select="StrategyTypeOtherDescription" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/MasterAIFsIdentification/MasterAIFIdentification">

		<xsl:variable
				name="aifname"
				select="AIFName" />
		<xsl:variable
				name="masterfeederstatus"
				select="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/AIFMasterFeederStatus" />
		<xsl:if test="($masterfeederstatus = 'FEEDER') != boolean($aifname)">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-024'" />
				<xsl:with-param
						name="context"
						select="$aifname" />
			</xsl:call-template>
		</xsl:if>

		<xsl:variable
				name="aifmemberstate"
				select="AIFIdentifierNCA/ReportingMemberState" />
		<xsl:if test="$aifmemberstate and not($eeacountrycodes[. = $aifmemberstate])">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-025'" />
				<xsl:with-param
						name="context"
						select="$aifmemberstate" />
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="not($masterfeederstatus = 'FEEDER')">
			<xsl:if test="AIFIdentifierNCA/ReportingMemberState">
				<xsl:call-template name="AIFError">
					<xsl:with-param
							name="code"
							select="'CAF-026'" />
					<xsl:with-param
							name="context"
							select="$aifmemberstate" />
				</xsl:call-template>
			</xsl:if>
		</xsl:if>
		<xsl:if test="not($masterfeederstatus = 'FEEDER')">
			<xsl:variable
					name="aifnationalcode"
					select="AIFIdentifierNCA/AIFNationalCode" />
			<xsl:if test="$aifnationalcode">
				<xsl:call-template name="AIFError">
					<xsl:with-param
							name="code"
							select="'CAF-027'" />
					<xsl:with-param
							name="context"
							select="$aifnationalcode" />
				</xsl:call-template>
			</xsl:if>
		</xsl:if>

		<xsl:apply-templates />
	</xsl:template>

	<xsl:template match="AIFCompleteDescription/AIFPrincipalInfo/AIFIdentification/AIFIdentifierLEI">
		<xsl:variable
				name="fund"
				select="./ancestor-or-self::AIFRecordInfo/AIFNationalCode" />
		<xsl:variable
				name="lei"
				select="." />
		<xsl:if test="not(my:ISO17442($lei))">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-013'" />
				<xsl:with-param
						name="context"
						select="$lei" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="AIFCompleteDescription/AIFPrincipalInfo/AIFIdentification/AIFIdentifierISIN">
		<xsl:variable
				name="isin"
				select="." />
		<xsl:if test="not(my:ISO6166($isin))">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-014'" />
				<xsl:with-param
						name="context"
						select="$isin" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/MasterAIFsIdentification/MasterAIFIdentification/AIFIdentifierNCA/ReportingMemberState">
		<xsl:variable
				name="fund"
				select="./ancestor-or-self::AIFRecordInfo/AIFNationalCode" />
		<xsl:variable
				name="aifmemberstate"
				select="." />
		<xsl:if test="not($eeacountrycodes[. = $aifmemberstate])">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-015'" />
				<xsl:with-param
						name="context"
						select="$aifmemberstate" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="AIFCompleteDescription/AIFPrincipalInfo">
		<xsl:param name="periodtype" />
		<xsl:param name="noreporting" />
		<xsl:variable
				name="shareclassflag"
				select="AIFCompleteDescription/AIFPrincipalInfo/ShareClassFlag = 'true'" />
		<xsl:apply-templates>
			<xsl:with-param
					name="fund"
					select="$fund" />
			<xsl:with-param
					name="periodtype"
					select="$periodtype" />
			<xsl:with-param
					name="noreporting"
					select="$noreporting" />
			<xsl:with-param name="shareclassflag" />
		</xsl:apply-templates>

	</xsl:template>

	<xsl:template match="AIFCompleteDescription/AIFPrincipalInfo/ShareClassIdentification/ShareClassIdentifier">
		<xsl:param name="shareclassflag" />

		<xsl:if test="not($shareclassflag)">
			<xsl:variable
					name="shareclassnationalcode"
					select="ShareClassNationalCode" />
			<xsl:if test="$shareclassnationalcode">
				<xsl:call-template name="AIFError">
					<xsl:with-param
							name="code"
							select="'CAF-016'" />
					<xsl:with-param
							name="context"
							select="$shareclassnationalcode" />
				</xsl:call-template>
			</xsl:if>
		</xsl:if>

		<xsl:variable
				name="isin"
				select="ShareClassIdentifierISIN" />
		<xsl:if test="not(my:ISO6166($isin))">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-017'" />
				<xsl:with-param
						name="context"
						select="$isin" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="not($shareclassflag) and $isin">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-018'" />
				<xsl:with-param
						name="context"
						select="$isin" />
			</xsl:call-template>

		</xsl:if>

		<xsl:variable
				name="cusip"
				select="ShareClassIdentifierCUSIP" />
		<xsl:if test="not($shareclassflag) and $cusip">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-019'" />
				<xsl:with-param
						name="context"
						select="$cusip" />
			</xsl:call-template>
		</xsl:if>

		<xsl:variable
				name="sedol"
				select="ShareClassIdentifierSEDOL" />
		<xsl:if test="not($shareclassflag) and $sedol">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-020'" />
				<xsl:with-param
						name="context"
						select="$sedol" />
			</xsl:call-template>
		</xsl:if>

		<xsl:variable
				name="ticker"
				select="ShareClassIdentifierTicker" />
		<xsl:if test="not($shareclassflag) and $ticker">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-021'" />
				<xsl:with-param
						name="context"
						select="$ticker" />
			</xsl:call-template>
		</xsl:if>

		<xsl:variable
				name="ric"
				select="ShareClassIdentifierRIC" />
		<xsl:if test="not($shareclassflag) and $ric">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-022'" />
				<xsl:with-param
						name="context"
						select="$ric" />
			</xsl:call-template>
		</xsl:if>

		<xsl:variable
				name="shareclassname"
				select="ShareClassName" />
		<xsl:if test="$shareclassflag != boolean($shareclassname)">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-023'" />
				<xsl:with-param
						name="context"
						select="$shareclassname" />
			</xsl:call-template>
		</xsl:if>

	</xsl:template>

	<xsl:template match="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/PrimeBrokers/PrimeBrokerIdentification/EntityIdentificationLEI">
		<xsl:variable
				name="lei"
				select="." />

		<xsl:if test="not(my:ISO17442($lei))">
			<error>
				<record></record>
				<code>CAF-028</code>
				<message>The check digits of the LEI code are not correct.</message>
				<field>EntityIdentificationLEI</field>
				<value>
					<xsl:value-of select="$lei" />
				</value>
			</error>
		</xsl:if>
	</xsl:template>

	<xsl:template match="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/AIFBaseCurrencyDescription">
		<xsl:param name="noreporting" />
		<xsl:variable
				name="basecurrency"
				select="BaseCurrency" />
		<xsl:if test="not($currencycodes[. = $basecurrency])">
			<error>
				<record></record>
				<code>CAF-029</code>
				<message>The currency code is not correct.</message>
				<field>BaseCurrency</field>
				<value>
					<xsl:value-of select="$basecurrency" />
				</value>
			</error>
		</xsl:if>

		<xsl:if test="($noreporting = 'false' and not($basecurrency = 'EUR')) != boolean(FXEURRate)">
			<error>
				<record></record>
				<code>CAF-030</code>
				<message></message>
				<field>FXEURRate</field>
				<value>
					<xsl:value-of select="FXEURRate" />
				</value>
			</error>
		</xsl:if>

		<xsl:if test="($noreporting = 'false' and not($basecurrency = 'EUR')) != boolean(FXEURReferenceRateType)">
			<error>
				<record></record>
				<code>CAF-031</code>
				<message></message>
				<field>FXEURReferenceRateType</field>
				<value>
					<xsl:value-of select="FXEURReferenceRateType" />
				</value>
			</error>
		</xsl:if>

		<xsl:if test="(FXEURReferenceRateType = 'OTH') != boolean(FXEUROtherReferenceRateDescription)">
			<error>
				<record></record>
				<code>CAF-032</code>
				<message></message>
				<field>FXEUROtherReferenceRateDescription</field>
				<value>
					<xsl:value-of select="FXEUROtherReferenceRateDescription" />
				</value>
			</error>
		</xsl:if>
	</xsl:template>

	<xsl:template match="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/FirstFundingSourceCountry">
		<xsl:variable
				name="firstfundingsourcecountry"
				select="." />
		<xsl:if test="$firstfundingsourcecountry and not($countrycodes[. = $firstfundingsourcecountry])">
			<error>
				<record></record>
				<code>CAF-033</code>
				<message>The first funding country is not correct.</message>
				<field>FirstFundingSourceCountry</field>
				<value>
					<xsl:value-of select="$firstfundingsourcecountry" />
				</value>
			</error>
		</xsl:if>
	</xsl:template>

	<xsl:template match="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/SecondFundingSourceCountry">
		<xsl:variable
				name="secondfundingsourcecountry"
				select="." />
		<xsl:if test="$secondfundingsourcecountry and not($countrycodes[. = $secondfundingsourcecountry])">
			<error>
				<record></record>
				<code>CAF-034</code>
				<message>The second funding country is not correct.</message>
				<field>SecondFundingSourceCountry</field>
				<value>
					<xsl:value-of select="$secondfundingsourcecountry" />
				</value>
			</error>
		</xsl:if>
	</xsl:template>

	<xsl:template match="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/ThirdFundingSourceCountry">
		<xsl:variable
				name="thirdfundingsourcecountry"
				select="." />
		<xsl:if test="$thirdfundingsourcecountry and not($countrycodes[. = $thirdfundingsourcecountry])">
			<error>
				<record></record>
				<code>CAF-035</code>
				<message>The third funding country is not correct.</message>
				<field>ThirdFundingSourceCountry</field>
				<value>
					<xsl:value-of select="$thirdfundingsourcecountry" />
				</value>
			</error>
		</xsl:if>
	</xsl:template>

	<xsl:template match="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/HedgeFundInvestmentStrategies/HedgeFundStrategy">
		<xsl:if test="(HedgeFundStrategyType = 'MULT_HFND') and boolean(StrategyNAVRate)">
			<error>
				<record></record>
				<code>CAF-040</code>
				<message>There is no NAV percentage reported for multi strategies investment strategies.</message>
				<field>StrategyNAVRate</field>
				<value>
					<xsl:value-of select="StrategyNAVRate" />
				</value>
			</error>
		</xsl:if>

		<xsl:if test="(HedgeFundStrategyType = 'OTHER_HFND') != boolean(StrategyTypeOtherDescription)">
			<error>
				<record></record>
				<code>CAF-041</code>
				<message>The investement strategy code description is not consistent with the reported investment strategy code.</message>
				<field>StrategyTypeOtherDescription</field>
				<value>
					<xsl:value-of select="StrategyTypeOtherDescription" />
				</value>
			</error>
		</xsl:if>

		<xsl:if test="HedgeFundStrategyType = 'MULT_HFND'">

			<xsl:if test="count(../HedgeFundStrategy[HedgeFundStrategyType != 'MULT_HFND']) &lt; 2">
				<error>
					<record></record>
					<code>CAF-037</code>
					<message>The investment strategy code is not allowed.</message>
					<field>HedgeFundStrategyType</field>
					<value>
						<xsl:value-of select="HedgeFundStrategyType" />
					</value>
				</error>
			</xsl:if>

			<xsl:if test="PrimaryStrategyFlag != 'true'">
				<error>
					<record></record>
					<code>CAF-038</code>
					<message>Multi strategies investment strategies should be primary strategies.</message>
					<field>PrimaryStrategyFlag</field>
					<value>
						<xsl:value-of select="PrimaryStrategyFlag" />
					</value>
				</error>
			</xsl:if>
		</xsl:if>

		<xsl:apply-templates />
	</xsl:template>

	<xsl:template match="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/PrivateEquityFundInvestmentStrategies/PrivateEquityFundInvestmentStrategy">
		<xsl:if test="(PrivateEquityFundStrategyType = 'MULT_PEQF') and boolean(StrategyNAVRate)">
			<error>
				<record></record>
				<code>CAF-040</code>
				<message>There is no NAV percentage reported for multi strategies investment strategies.</message>
				<field>StrategyNAVRate</field>
				<value>
					<xsl:value-of select="StrategyNAVRate" />
				</value>
			</error>
		</xsl:if>

		<xsl:if test="(PrivateEquityFundStrategyType = 'OTHR_PEQF') != boolean(StrategyTypeOtherDescription)">
			<error>
				<record></record>
				<code>CAF-041</code>
				<message>The investement strategy code description is not consistent with the reported investment strategy code.</message>
				<field>StrategyTypeOtherDescription</field>
				<value>
					<xsl:value-of select="StrategyTypeOtherDescription" />
				</value>
			</error>
		</xsl:if>

		<xsl:if test="PrivateEquityFundStrategyType = 'MULT_PEQF'">

			<xsl:if test="count(../PrivateEquityFundInvestmentStrategy[PrivateEquityFundStrategyType != 'MULT_PEQF']) &lt; 2">
				<error>
					<record></record>
					<code>CAF-037</code>
					<message>The investment strategy code is not allowed.</message>
					<field>PrivateEquityFundStrategyType</field>
					<value>
						<xsl:value-of select="PrivateEquityFundStrategyType" />
					</value>
				</error>
			</xsl:if>

			<xsl:if test="PrimaryStrategyFlag != 'true'">
				<error>
					<record></record>
					<code>CAF-038</code>
					<message>Multi strategies investment strategies should be primary strategies.</message>
					<field>PrimaryStrategyFlag</field>
					<value>
						<xsl:value-of select="PrimaryStrategyFlag" />
					</value>
				</error>
			</xsl:if>
		</xsl:if>
	</xsl:template>

	<xsl:template match="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/RealEstateFundInvestmentStrategies/RealEstateFundStrategy">
		<xsl:if test="(RealEstateFundStrategyType = 'MULT_REST') and boolean(StrategyNAVRate)">
			<error>
				<record></record>
				<code>CAF-040</code>
				<message>There is no NAV percentage reported for multi strategies investment strategies.</message>
				<field>StrategyNAVRate</field>
				<value>
					<xsl:value-of select="$strategynavrate" />
				</value>
			</error>
		</xsl:if>

		<xsl:if test="(RealEstateFundStrategyType = 'OTHR_REST') != boolean(StrategyTypeOtherDescription)">
			<error>
				<record></record>
				<code>CAF-041</code>
				<message>The investement strategy code description is not consistent with the reported investment strategy code.</message>
				<field>StrategyTypeOtherDescription</field>
				<value>
					<xsl:value-of select="StrategyTypeOtherDescription" />
				</value>
			</error>
		</xsl:if>

		<xsl:if test="RealEstateFundStrategyType = 'MULT_REST'">

			<xsl:if test="count(../RealEstateFundStrategy[RealEstateFundStrategyType != 'MULT_REST']) &lt; 2">
				<error>
					<record></record>
					<code>CAF-037</code>
					<message>The investment strategy code is not allowed.</message>
					<field>RealEstateFundStrategyType</field>
					<value>
						<xsl:value-of select="RealEstateFundStrategyType" />
					</value>
				</error>
			</xsl:if>

			<xsl:if test="PrimaryStrategyFlag != 'true'">
				<error>
					<record></record>
					<code>CAF-038</code>
					<message>Multi strategies investment strategies should be primary strategies.</message>
					<field>PrimaryStrategyFlag</field>
					<value>
						<xsl:value-of select="PrimaryStrategyFlag" />
					</value>
				</error>
			</xsl:if>

		</xsl:if>

	</xsl:template>

	<xsl:template match="AIFCompleteDescription/AIFPrincipalInfo/MainInstrumentsTraded/MainInstrumentTraded">
		<xsl:variable
				name="subassettype"
				select="SubAssetType" />
		<xsl:variable
				name="isnota"
				select="$subassettype = 'NTA_NTA_NOTA'" />
		<xsl:variable
				name="instrumentcodetype"
				select="InstrumentCodeType" />
		<xsl:variable
				name="hascodetype"
				select="boolean($instrumentcodetype)" />
		<xsl:if test="$hascodetype = $isnota">
			<error>
				<record></record>
				<code>CAF-042</code>
				<message>The instrument code type is not consistent with the sub-asset type.</message>
				<field>InstrumentCodeType</field>
				<value>
					<xsl:value-of select="$instrumentcodetype" />
				</value>
			</error>
		</xsl:if>

		<xsl:variable
				name="instrumentname"
				select="InstrumentName" />
		<xsl:variable
				name="hasname"
				select="boolean($instrumentname)" />
		<xsl:if test="$hasname = $isnota">
			<error>
				<record></record>
				<code>CAF-043</code>
				<message>The instrument name is not consistent with the sub-asset type.</message>
				<field>InstrumentName</field>
				<value>
					<xsl:value-of select="$instrumentname" />
				</value>
			</error>
		</xsl:if>

		<xsl:variable
				name="isin"
				select="ISINInstrumentIdentification" />
		<xsl:if test="not(my:ISO6166($isin))">
			<error>
				<record></record>
				<code>CAF-044</code>
				<message>The check digit of the ISIN code is not correct.</message>
				<field>ISINInstrumentIdentification</field>
				<value>
					<xsl:value-of select="$isin" />
				</value>
			</error>
		</xsl:if>

		<xsl:if test="boolean(InstrumentCodeType = 'ISIN') != boolean(ISINInstrumentIdentification)">
			<error>
				<record></record>
				<code>CAF-045</code>
				<message>The instrument ISIN code is not consistent with the instrument code type.</message>
				<field>ISINInstrumentIdentification</field>
				<value>
					<xsl:value-of select="ISINInstrumentIdentification" />
				</value>
			</error>
		</xsl:if>

		<xsl:variable
				name="mic"
				select="AIIInstrumentIdentification/AIIExchangeCode" />
		<xsl:if test="$mic and not($micregister[. = $mic])">
			<error>
				<record></record>
				<code>CAF-046</code>
				<message>The MIC code is not correct</message>
				<field>AIIExchangeCode</field>
				<value>
					<xsl:value-of select="$mic" />
				</value>
			</error>
		</xsl:if>

		<xsl:if test="boolean(InstrumentCodeType = 'AII') != boolean($mic)">
			<error>
				<record></record>
				<code>CAF-047</code>
				<message>The instrument AII exchange code is not consistent with the instrument code type.</message>
				<field>AIIExchangeCode</field>
				<value>
					<xsl:value-of select="AIIInstrumentIdentification/AIIExchangeCode" />
				</value>
			</error>
		</xsl:if>

		<xsl:if test="boolean(InstrumentCodeType = 'AII') != boolean(AIIInstrumentIdentification/AIIProductCode)">
			<error>
				<record></record>
				<code>CAF-048</code>
				<message>The instrument AII exchange product code is not consistent with the instrument code type.</message>
				<field>AIIProductCode</field>
				<value>
					<xsl:value-of select="AIIInstrumentIdentification/AIIProductCode" />
				</value>
			</error>
		</xsl:if>

		<xsl:if test="boolean(InstrumentCodeType = 'AII') != boolean(AIIInstrumentIdentification/AIIDerivativeType)">
			<error>
				<record></record>
				<code>CAF-049</code>
				<message>The instrument AII derivative type is not consistent with the instrument code type.</message>
				<field>AIIDerivativeType</field>
				<value>
					<xsl:value-of select="AIIInstrumentIdentification/AIIDerivativeType" />
				</value>
			</error>
		</xsl:if>

		<xsl:if test="boolean(InstrumentCodeType = 'AII') != boolean(AIIInstrumentIdentification/AIIPutCallIdentifier)">
			<error>
				<record></record>
				<code>CAF-050</code>
				<message>The instrument put/call identifier is not consistent with the instrument code type.</message>
				<field>AIIPutCallIdentifier</field>
				<value>
					<xsl:value-of select="AIIInstrumentIdentification/AIIPutCallIdentifier" />
				</value>
			</error>
		</xsl:if>

		<xsl:if test="boolean(InstrumentCodeType = 'AII') != boolean(AIIInstrumentIdentification/AIIExpiryDate)">
			<error>
				<record></record>
				<code>CAF-051</code>
				<message>The instrument AII expiry date is not consistent with the instrument code type.</message>
				<field>AIIExpiryDate</field>
				<value>
					<xsl:value-of select="AIIInstrumentIdentification/AIIExpiryDate" />
				</value>
			</error>
		</xsl:if>

		<xsl:if test="boolean(InstrumentCodeType = 'AII') != boolean(AIIInstrumentIdentification/AIIStrikePrice)">
			<error>
				<record></record>
				<code>CAF-052</code>
				<message>The instrument AII strike price is not consistent with the instrument code type.</message>
				<field>AIIStrikePrice</field>
				<value>
					<xsl:value-of select="AIIInstrumentIdentification/AIIStrikePrice" />
				</value>
			</error>
		</xsl:if>

		<xsl:if test="boolean(SubAssetType = 'NTA_NTA_NOTA') = boolean(PositionType)">
			<error>
				<record></record>
				<code>CAF-053</code>
				<message>The position type is not consistent with the sub-asset type.</message>
				<field>PositionType</field>
				<value>
					<xsl:value-of select="PositionType" />
				</value>
			</error>
		</xsl:if>

		<xsl:if test="boolean(SubAssetType = 'NTA_NTA_NOTA') = boolean(PositionValue)">
			<error>
				<record></record>
				<code>CAF-054</code>
				<message>The position value is not consistent with the sub-asset type.</message>
				<field>PositionValue</field>
				<value>
					<xsl:value-of select="PositionValue" />
				</value>
			</error>
		</xsl:if>

		<xsl:variable
				name="rank"
				select="Ranking" />
		<xsl:variable
				name="value"
				select="PositionValue" />
		<xsl:if test="$value &lt; ../MainInstrumentTraded[Ranking=($rank + 1)]/PositionValue">
			<error>
				<record></record>
				<code>CAF-055</code>
				<message>The reported value is not consistent with the rank.</message>
				<field>PositionValue</field>
				<value>
					<xsl:value-of select="$value" />
				</value>
			</error>
		</xsl:if>

		<xsl:if test="not(PositionType = 'S') and boolean(ShortPositionHedgingRate)">
			<error>
				<record></record>
				<code>CAF-056</code>
				<message>The position value is not consistent with the position type.</message>
				<field>ShortPositionHedgingRate</field>
				<value>
					<xsl:value-of select="ShortPositionHedgingRate" />
				</value>
			</error>
		</xsl:if>

		<xsl:apply-templates />

	</xsl:template>

	<xsl:template match="AIFCompleteDescription/AIFPrincipalInfo/NAVGeographicalFocus">

		<xsl:variable
				name="navregions"
				select="*" />
		<xsl:if test="$navregions and not(sum($navregions) = 100)">
			<error>
				<record></record>
				<code>CAF-057</code>
				<message>The sum of the percentages should be equal to 100%.</message>
				<field>NAVGeographicalFocus</field>
				<value>
					<xsl:value-of select="sum($navregions)" />
				</value>
			</error>
		</xsl:if>
	</xsl:template>

	<xsl:template match="AIFCompleteDescription/AIFPrincipalInfo/AUMGeographicalFocus">

		<xsl:variable
				name="aumregions"
				select="*" />
		<xsl:if test="$aumregions and not(sum($aumregions) = 100)">
			<error>
				<record></record>
				<code>CAF-058</code>
				<message>The sum of the percentages should be equal to 100%.</message>
				<field>AUMGeographicalFocus</field>
				<value>
					<xsl:value-of select="sum($aumregions)" />
				</value>
			</error>
		</xsl:if>
	</xsl:template>

	<xsl:template match="AIFCompleteDescription/AIFPrincipalInfo/PrincipalExposures/PrincipalExposure">

		<xsl:if test="boolean(AssetMacroType = 'NTA') = boolean(SubAssetType)">
			<error>
				<record></record>
				<code>CAF-059</code>
				<message>The sub-asset type is not consistent with the macro-asset type.</message>
				<field>SubAssetType</field>
				<value>
					<xsl:value-of select="SubAssetType" />
				</value>
			</error>
		</xsl:if>

		<xsl:if test="boolean(AssetMacroType = 'NTA') = boolean(PositionType)">
			<error>
				<record></record>
				<code>CAF-060</code>
				<message>The position type is not consistent with the macro-asset type.</message>
				<field>PositionType</field>
				<value>
					<xsl:value-of select="PositionType" />
				</value>
			</error>
		</xsl:if>

		<xsl:if test="boolean(AssetMacroType = 'NTA') = boolean(AggregatedValueAmount)">
			<error>
				<record></record>
				<code>CAF-061</code>
				<message>The aggregated value is not consistent with the macro-asset type.</message>
				<field>AggregatedValueAmount</field>
				<value>
					<xsl:value-of select="AggregatedValueAmount" />
				</value>
			</error>
		</xsl:if>

		<xsl:variable
				name="rank"
				select="Ranking" />
		<xsl:variable
				name="value"
				select="AggregatedValueAmount" />
		<xsl:if test="$value &lt; ../PrincipalExposure[Ranking=($rank + 1)]/AggregatedValueAmount">
			<error>
				<record></record>
				<code>CAF-062</code>
				<message>The reported value is not consistent with the rank.</message>
				<field>AggregatedValueAmount</field>
				<value>
					<xsl:value-of select="$value" />
				</value>
			</error>
		</xsl:if>

		<xsl:if test="boolean(AssetMacroType = 'NTA') = boolean(AggregatedValueRate)">
			<error>
				<record></record>
				<code>CAF-063</code>
				<message>The aggregated value percentage is not consistent with the macro-asset type.</message>
				<field>AggregatedValueRate</field>
				<value>
					<xsl:value-of select="AggregatedValueRate" />
				</value>
			</error>
		</xsl:if>

		<xsl:apply-templates>
			<with-param
					name="fund"
					select="$fund" />
		</xsl:apply-templates>

	</xsl:template>

	<xsl:template match="AIFCompleteDescription/AIFPrincipalInfo/PrincipalExposures/PrincipalExposure/CounterpartyIdentification">

		<xsl:if test="not(EntityName) and EntityIdentificationLEI">
			<error>
				<record></record>
				<code>CAF-064</code>
				<message>The LEI code is not consistent with the counterparty name.</message>
				<field>EntityIdentificationLEI</field>
				<value>
					<xsl:value-of select="EntityIdentificationLEI" />
				</value>
			</error>
		</xsl:if>

		<xsl:variable
				name="lei"
				select="EntityIdentificationLEI" />

		<xsl:if test="not(my:ISO17442($lei))">
			<error>
				<record></record>
				<code>CAF-065</code>
				<message>The check digits of the LEI code are not correct.</message>
				<field>EntityIdentificationLEI</field>
				<value>
					<xsl:value-of select="$lei" />
				</value>
			</error>
		</xsl:if>

		<xsl:if test="not(EntityName) and EntityIdentificationBIC">
			<error>
				<record></record>
				<code>CAF-066</code>
				<message>The BIC code is not consistent with the counterparty name.</message>
				<field>EntityIdentificationBIC</field>
				<value>
					<xsl:value-of select="EntityIdentificationBIC" />
				</value>
			</error>
		</xsl:if>
	</xsl:template>

	<xsl:template match="AIFCompleteDescription/AIFPrincipalInfo/MostImportantConcentration/PortfolioConcentrations/PortfolioConcentration">

		<xsl:if test="boolean(AssetType = 'NTA_NTA') = boolean(PositionType)">
			<error>
				<record></record>
				<code>CAF-067</code>
				<message>The position type is not consistent with the asset type.</message>
				<field>PositionType</field>
				<value>
					<xsl:value-of select="PositionType" />
				</value>
			</error>
		</xsl:if>

		<xsl:if test="boolean(AssetType = 'NTA_NTA') = boolean(MarketIdentification/MarketCodeType)">
			<error>
				<record></record>
				<code>CAF-068</code>
				<message>TThe market code type is not consistent with the asset type.</message>
				<field>MarketCodeType</field>
				<value>
					<xsl:value-of select="MarketIdentification/MarketCodeType" />
				</value>
			</error>
		</xsl:if>

		<xsl:variable
				name="mic"
				select="MarketIdentification/MarketCode" />
		<xsl:if test="$mic and not($micregister[. = $mic])">
			<error>
				<record></record>
				<code>CAF-069</code>
				<message>The MIC code is not correct</message>
				<field>MarketIdentification</field>
				<value>
					<xsl:value-of select="$mic" />
				</value>
			</error>
		</xsl:if>

		<xsl:if test="boolean(MarketIdentification/MarketCodeType = 'MIC') != boolean(MarketIdentification/MarketCode)">
			<error>
				<record></record>
				<code>CAF-070</code>
				<message>The MIC code is not consistent with the market code type.</message>
				<field>MarketCode</field>
				<value>
					<xsl:value-of select="MarketCode" />
				</value>
			</error>
		</xsl:if>

		<xsl:if test="boolean(AssetType = 'NTA_NTA') = boolean(AggregatedValueAmount)">
			<error>
				<record></record>
				<code>CAF-071</code>
				<message>The aggregated value is not consistent with the asset type.</message>
				<field>AggregatedValueAmount</field>
				<value>
					<xsl:value-of select="AggregatedValueAmount" />
				</value>
			</error>
		</xsl:if>

		<xsl:variable
				name="rank"
				select="Ranking" />
		<xsl:variable
				name="value"
				select="AggregatedValueAmount" />
		<xsl:if test="$value &lt; ../PortfolioConcentration[Ranking=($rank + 1)]/AggregatedValueAmount">
			<error>
				<record></record>
				<code>CAF-072</code>
				<message>The reported value is not consistent with the rank.</message>
				<field>AggregatedValueAmount</field>
				<value>
					<xsl:value-of select="$value" />
				</value>
			</error>
		</xsl:if>

		<xsl:if test="boolean(AssetType = 'NTA_NTA') = boolean(AggregatedValueRate)">
			<error>
				<record></record>
				<code>CAF-073</code>
				<message>The aggregated value percentage is not consistent with the asset type.</message>
				<field>AggregatedValueRate</field>
				<value>
					<xsl:value-of select="AggregatedValueRate" />
				</value>
			</error>
		</xsl:if>

		<xsl:if test="not(MarketIdentification/MarketCodeType = 'OTC') and boolean(CounterpartyIdentification/EntityName)">
			<error>
				<record></record>
				<code>CAF-074</code>
				<message>The counterparty name is not consistent with the market code type.</message>
				<field>EntityName</field>
				<value>
					<xsl:value-of select="EntityName" />
				</value>
			</error>
		</xsl:if>

		<xsl:if test="(not(CounterpartyIdentification/EntityName) or not(MarketIdentification/MarketCodeType = 'OTC')) and boolean(CounterpartyIdentification/EntityIdentificationLEI)">
			<error>
				<record></record>
				<code>CAF-075</code>
				<message>The LEI code is not consistent with the counterparty name.</message>
				<field>EntityIdentificationLEI</field>
				<value>
					<xsl:value-of select="CounterpartyIdentification/EntityIdentificationLEI" />
				</value>
			</error>
		</xsl:if>

		<xsl:if test="not(CounterpartyIdentification/EntityName) and boolean(CounterpartyIdentification/EntityIdentificationBIC)">
			<error>
				<record></record>
				<code>CAF-077</code>
				<message>The BIC code is not consistent with the counterparty name.</message>
				<field>EntityIdentificationBIC</field>
				<value>
					<xsl:value-of select="CounterPartyIdentification/EntityIdentificationBIC" />
				</value>
			</error>
		</xsl:if>

		<xsl:if test="not(MarketIdentification/MarketCodeType = 'OTC') and boolean(CounterpartyIdentification/EntityIdentificationBIC)">
			<error>
				<record></record>
				<code>CAF-078</code>
				<message>The counterparty BIC code is not consistent with the counterparty name.</message>
				<field>EntityIdentificationBIC</field>
				<value>
					<xsl:value-of select="CounterpartyIdentification/EntityIdentificationBIC" />
				</value>
			</error>
		</xsl:if>
		<xsl:apply-templates />
	</xsl:template>

	<xsl:template match="CounterpartyIdentification/EntityIdentificationLEI">

		<xsl:variable
				name="lei"
				select="." />

		<xsl:if test="not(my:ISO17442($lei))">
			<error>
				<record></record>
				<code>CAF-076</code>
				<message>The counterparty LEI code is not consistent with the counterparty name.</message>
				<field>EntityIdentificationLEI</field>
				<value>
					<xsl:value-of select="$lei" />
				</value>
			</error>
		</xsl:if>
	</xsl:template>

	<xsl:template match="AIFCompleteDescription/AIFPrincipalInfo">


		<xsl:if test="boolean(AIFDescription/PredominantAIFType = 'PEQF') != boolean(MostImportantConcentration/TypicalPositionSize)">
			<error>
				<record></record>
				<code>CAF-079</code>
				<message>The position size type is not consistent with the predominant AIF type.</message>
				<field>TypicalPositionSize</field>
				<value>
					<xsl:value-of select="MostImportantConcentration/TypicalPositionSize" />
				</value>
			</error>
		</xsl:if>

		<xsl:apply-templates />

	</xsl:template>

	<xsl:template match="AIFCompleteDescription/AIFPrincipalInfo/MostImportantConcentration/AIFPrincipalMarkets/AIFPrincipalMarket">

		<xsl:variable
				name="mic"
				select="MarketIdentification/MarketCode" />
		<xsl:if test="$mic and not($micregister[. = $mic])">
			<error>
				<record></record>
				<code>CAF-080</code>
				<message>The MIC code is not correct</message>
				<field>MarketCode</field>
				<value>
					<xsl:value-of select="$mic" />
				</value>
			</error>
		</xsl:if>

		<xsl:if test="boolean(MarketIdentification/MarketCodeType = 'MIC') != boolean($mic)">
			<error>
				<record></record>
				<code>CAF-081</code>
				<message>The MIC code is not consistent with the market code type.</message>
				<field>MarketCode</field>
				<value>
					<xsl:value-of select="$mic" />
				</value>
			</error>
		</xsl:if>

		<xsl:if test="boolean(MarketIdentification/MarketCodeType = 'NOT') = boolean(AggregatedValueAmount)">
			<error>
				<record></record>
				<code>CAF-082</code>
				<message>The aggregated value is not consistent with the market code type.</message>
				<field>AggregatedValueAmount</field>
				<value>
					<xsl:value-of select="AggregatedValueAmount" />
				</value>
			</error>
		</xsl:if>

		<xsl:variable
				name="rank"
				select="Ranking" />
		<xsl:variable
				name="value"
				select="AggregatedValueAmount" />
		<xsl:if test="$value &lt; ../AIFPrincipalMarket[Ranking=($rank + 1)]/AggregatedValueAmount">
			<error>
				<record></record>
				<code>CAF-083</code>
				<message>The reported value is not consistent with the rank.</message>
				<field>AggregatedValueAmount</field>
				<value>
					<xsl:value-of select="$value" />
				</value>
			</error>
		</xsl:if>
	</xsl:template>

	<xsl:template match="AIFCompleteDescription/AIFPrincipalInfo/MostImportantConcentration/InvestorConcentration">

		<xsl:variable
				name="ratesum"
				select="ProfessionalInvestorConcentrationRate + RetailInvestorConcentrationRate" />
		<xsl:if test="$ratesum != 100 and $ratesum != 0">
			<error>
				<record></record>
				<code>CAF-084</code>
				<message>The sum of the percentages should be equal to 0% or 100%.</message>
				<field>ProfessionalInvestorConcentrationRate + RetailInvestorConcentrationRate</field>
				<value>
					<xsl:value-of select="$ratesum" />
				</value>
			</error>
		</xsl:if>
	</xsl:template>

	<xsl:template match="AIFCompleteDescription/AIFIndividualInfo/IndividualExposure/AssetTypeExposures/AssetTypeExposure">

		<xsl:choose>
			<xsl:when test="SubAssetType='DER_FEX_INVT' or SubAssetType='DER_FEX_HEDG' or SubAssetType='DER_IRD_INTR'">
				<xsl:if test="LongValue">
					<error>
						<record></record>
						<code>CAF-086</code>
						<message>The long value is not consistent with the sub-asset type.</message>
						<field>LongValue</field>
						<value>
							<xsl:value-of select="LongValue" />
						</value>
					</error>
				</xsl:if>
				<xsl:if test="ShortValue">
					<error>
						<record></record>
						<code>CAF-087</code>
						<message>The short value is not consistent with the sub-asset type.</message>
						<field>ShortValue</field>
						<value>
							<xsl:value-of select="ShortValue" />
						</value>
					</error>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="GrossValue">
					<error>
						<record></record>
						<code>CAF-085</code>
						<message>The gross value is not consistent with the sub-asset type.</message>
						<field>GrossValue</field>
						<value>
							<xsl:value-of select="GrossValue" />
						</value>
					</error>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="AIFCompleteDescription/AIFIndividualInfo/IndividualExposure/AssetTypeTurnovers/AssetTypeTurnover">

		<xsl:variable
				name="t"
				select="TurnoverSubAssetType" />
		<xsl:if test="not($t='DER_EQD_EQD' or $t='DER_FEX_INV' or $t='DER_EQD_EQD' or $t='DER_CDS_CDS' or $t='DER_FEX_HED' or $t='DER_IRD_IRD' or $t='DER_CTY_CTY' or $t='DER_OTH_OTH')">
			<xsl:if test="NotionalValue">
				<error>
					<record></record>
					<code>CAF-088</code>
					<message>The notional value is not consistent with the sub-asset type.</message>
					<field>NotionalValue</field>
					<value>
						<xsl:value-of select="NotionalValue" />
					</value>
				</error>
			</xsl:if>
		</xsl:if>
	</xsl:template>

	<xsl:template match="AIFCompleteDescription/AIFIndividualInfo/IndividualExposure/CurrencyExposures/CurrencyExposure">

		<xsl:variable
				name="currency"
				select="ExposureCurrency" />
		<xsl:choose>
			<xsl:when test="$currency">
				<xsl:if test="not($currencycodes[. = $currency])">
					<error>
						<record></record>
						<code>CAF-089</code>
						<message>The currency code is not correct.</message>
						<field>ExposureCurrency</field>
						<value>
							<xsl:value-of select="$currency" />
						</value>
					</error>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="LongPositionValue">
					<error>
						<record></record>
						<code>CAF-090</code>
						<message>The long position value is not consistent with the currency of exposure.</message>
						<field>LongPositionValue</field>
						<value>
							<xsl:value-of select="LongPositionValue" />
						</value>
					</error>
				</xsl:if>
				<xsl:if test="ShortPositionValue">
					<error>
						<record></record>
						<code>CAF-091</code>
						<message>The short position value is not consistent with the currency of exposure.</message>
						<field>ShortPositionValue</field>
						<value>
							<xsl:value-of select="ShortPositionValue" />
						</value>
					</error>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="AIFCompleteDescription/AIFIndividualInfo/IndividualExposure/CompaniesDominantInfluence/CompanyDominantInfluence">

		<xsl:param name="predominantaiftype" />

		<xsl:if test="boolean($predominantaiftype='PEQF') != boolean(CompanyIdentification/EntityName)">
			<error>
				<record></record>
				<code>CAF-092</code>
				<message>The company name is not consistent with the AIF predominant type.</message>
				<field>EntityName</field>
				<value>
					<xsl:value-of select="CompanyIdentification/EntityName" />
				</value>
			</error>
		</xsl:if>
		<xsl:variable
				name="lei"
				select="CompanyIdentification/EntityIdentificationLEI" />
		<xsl:if test="not(my:ISO17442($lei))">
			<error>
				<record></record>
				<code>CAF-093</code>
				<message>The check digits of the LEI code are not correct.</message>
				<field>EntityIdentificationLEI</field>
				<value>
					<xsl:value-of select="$lei" />
				</value>
			</error>
		</xsl:if>
		<xsl:if test="$predominantaiftype!='PEQF' and boolean($lei)">
			<error>
				<record></record>
				<code>CAF-094</code>
				<message>The LEI code is not consistent with the AIF predominant type.</message>
				<field>EntityIdentificationLEI</field>
				<value>
					<xsl:value-of select="$lei" />
				</value>
			</error>
		</xsl:if>
		<xsl:if test="$predominantaiftype!='PEQF' and boolean(CompanyIdentification/EntityIdentificationBIC)">
			<error>
				<record></record>
				<code>CAF-095</code>
				<message>The BIC code is not consistent with the AIF predominant type.</message>
				<field>EntityIdentificationBIC</field>
				<value>
					<xsl:value-of select="CompanyIdentification/EntityIdentificationBIC" />
				</value>
			</error>
		</xsl:if>
		<xsl:if test="boolean($predominantaiftype='PEQF') != boolean(TransactionType)">
			<error>
				<record></record>
				<code>CAF-096</code>
				<message>The transaction type is not consistent with the AIF predominant type.</message>
				<field>TransactionType</field>
				<value>
					<xsl:value-of select="TransactionType" />
				</value>
			</error>
		</xsl:if>
		<xsl:if test="boolean(TransactionType='OTHR') != boolean(OtherTransactionTypeDescription)">
			<error>
				<record></record>
				<code>CAF-097</code>
				<message>The description for other transaction type is not consistent with the transaction type.</message>
				<field>OtherTransactionTypeDescription</field>
				<value>
					<xsl:value-of select="OtherTransactionTypeDescription" />
				</value>
			</error>
		</xsl:if>
		<xsl:if test="boolean($predominantaiftype='PEQF') != boolean(VotingRightsRate)">
			<error>
				<record></record>
				<code>CAF-098</code>
				<message>The percentage of voting rights is not consistent with the AIF predominant type.</message>
				<field>VotingRightsRate</field>
				<value>
					<xsl:value-of select="VotingRightsRate" />
				</value>
			</error>
		</xsl:if>
	</xsl:template>

	<xsl:template match="AIFCompleteDescription/AIFIndividualInfo/RiskProfile/MarketRiskProfile/MarketRiskMeasures/MarketRiskMeasure">

		<xsl:if test="not(RiskMeasureType='NET_EQTY_DELTA' or RiskMeasureType='NET_FX_DELTA' or RiskMeasureType='NET_CTY_DELTA') and boolean(RiskMeasureValue)">
			<error>
				<record></record>
				<code>CAF-099</code>
				<message>The risk measure value is not consistent with the risk measure type.</message>
				<field>RiskMeasureValue</field>
				<value>
					<xsl:value-of select="RiskMeasureValue" />
				</value>
			</error>
		</xsl:if>
		<xsl:if test="not(RiskMeasureType='NET_DV01' or RiskMeasureType='NET_CS01') and boolean(BucketRiskMeasureValues/LessFiveYearsRiskMeasureValue)">
			<error>
				<record></record>
				<code>CAF-100</code>
				<message>The risk measure value is not consistent with the risk measure type.</message>
				<field>LessFiveYearsRiskMeasureValue</field>
				<value>
					<xsl:value-of select="BucketRiskMeasureValues/LessFiveYearsRiskMeasureValue" />
				</value>
			</error>
		</xsl:if>
		<xsl:if test="not(RiskMeasureType='NET_DV01' or RiskMeasureType='NET_CS01') and boolean(BucketRiskMeasureValues/FifthteenYearsRiskMeasureValue)">
			<error>
				<record></record>
				<code>CAF-101</code>
				<message>The risk measure value is not consistent with the risk measure type.</message>
				<field>FifthteenYearsRiskMeasureValue</field>
				<value>
					<xsl:value-of select="BucketRiskMeasureValues/FifthteenYearsRiskMeasureValue" />
				</value>
			</error>
		</xsl:if>
		<xsl:if test="not(RiskMeasureType='NET_DV01' or RiskMeasureType='NET_CS01') and boolean(BucketRiskMeasureValues/MoreFifthteenYearsRiskMeasureValue)">
			<error>
				<record></record>
				<code>CAF-102</code>
				<message>The risk measure value is not consistent with the risk measure type.</message>
				<field>MoreFifthteenYearsRiskMeasureValue</field>
				<value>
					<xsl:value-of select="BucketRiskMeasureValues/MoreFifthteenYearsRiskMeasureValue" />
				</value>
			</error>
		</xsl:if>
		<xsl:if test="RiskMeasureType!='VEGA_EXPO' and boolean(VegaRiskMeasureValues/CurrentMarketRiskMeasureValue)">
			<error>
				<record></record>
				<code>CAF-103</code>
				<message>The risk measure value is not consistent with the risk measure type.</message>
				<field>CurrentMarketRiskMeasureValue</field>
				<value>
					<xsl:value-of select="VegaRiskMeasureValues/CurrentMarketRiskMeasureValue" />
				</value>
			</error>
		</xsl:if>
		<xsl:if test="RiskMeasureType!='VEGA_EXPO' and boolean(VegaRiskMeasureValues/LowerMarketRiskMeasureValue)">
			<error>
				<record></record>
				<code>CAF-104</code>
				<message>The risk measure value is not consistent with the risk measure type.</message>
				<field>LowerMarketRiskMeasureValue</field>
				<value>
					<xsl:value-of select="VegaRiskMeasureValues/LowerMarketRiskMeasureValue" />
				</value>
			</error>
		</xsl:if>
		<xsl:if test="RiskMeasureType!='VEGA_EXPO' and boolean(VegaRiskMeasureValues/HigherMarketRiskMeasureValue)">
			<error>
				<record></record>
				<code>CAF-105</code>
				<message>The risk measure value is not consistent with the risk measure type.</message>
				<field>HigherMarketRiskMeasureValue</field>
				<value>
					<xsl:value-of select="VegaRiskMeasureValues/HigherMarketRiskMeasureValue" />
				</value>
			</error>
		</xsl:if>
		<xsl:if test="boolean(RiskMeasureType='VAR') != boolean(VARRiskMeasureValues/VARValue)">
			<error>
				<record></record>
				<code>CAF-106</code>
				<message>The risk measure value is not consistent with the risk measure type.</message>
				<field>VARValue</field>
				<value>
					<xsl:value-of select="VARRiskMeasureValues/VARValue" />
				</value>
			</error>
		</xsl:if>
		<xsl:if test="boolean(RiskMeasureType='VAR') != boolean(VARRiskMeasureValues/VARCalculationMethodCodeType)">
			<error>
				<record></record>
				<code>CAF-107</code>
				<message>The VAR calculation method is not consistent with the risk measure type.</message>
				<field>VARCalculationMethodCodeType</field>
				<value>
					<xsl:value-of select="VARRiskMeasureValues/VARCalculationMethodCodeType" />
				</value>
			</error>
		</xsl:if>
		<xsl:if test="RiskMeasureValue=0 and not(RiskMeasureDescription)">
			<error>
				<record></record>
				<code>CAF-108</code>
				<message>The Risk measure description is not consistent with the risk measure value.</message>
				<field>RiskMeasureDescription</field>
				<value>
					<xsl:value-of select="RiskMeasureDescription" />
				</value>
			</error>
		</xsl:if>
	</xsl:template>

	<xsl:template match="AIFCompleteDescription/AIFIndividualInfo/RiskProfile/CounterpartyRiskProfile/TradingClearingMechanism/TradedSecurities">

		<xsl:if test="RegulatedMarketRate + OTCRate != 100">
			<error>
				<record></record>
				<code>CAF-109</code>
				<message>The sum of the percentages should be equal to 100%.</message>
				<field>TradedSecurities</field>
				<value>
					<xsl:value-of select="TradedSecurities" />
				</value>
			</error>
		</xsl:if>
	</xsl:template>

	<xsl:template match="AIFCompleteDescription/AIFIndividualInfo/RiskProfile/CounterpartyRiskProfile/TradingClearingMechanism/TradedDerivatives">

		<xsl:if test="RegulatedMarketRate + OTCRate != 100">
			<error>
				<record></record>
				<code>CAF-111</code>
				<message>The sum of the percentages should be equal to 100%.</message>
				<field>TradedDerivatives</field>
				<value>
					<xsl:value-of select="TradedDerivatives" />
				</value>
			</error>
		</xsl:if>
	</xsl:template>

	<xsl:template match="AIFCompleteDescription/AIFIndividualInfo/RiskProfile/CounterpartyRiskProfile/TradingClearingMechanism/ClearedDerivativesRate">

		<xsl:if test="CCPRate + BilateralClearingRate != 100">
			<error>
				<record></record>
				<code>WAF-001</code>
				<message>The sum of the percentages should be equal to 100%.</message>
				<field>ClearedDerivativesRate</field>
				<value>
					<xsl:value-of select="ClearedDerivativesRate" />
				</value>
			</error>
		</xsl:if>
	</xsl:template>

	<xsl:template match="AIFCompleteDescription/AIFIndividualInfo/RiskProfile/CounterpartyRiskProfile/TradingClearingMechanism/ClearedReposRate">

		<xsl:if test="CCPRate + BilateralClearingRate + TriPartyRepoClearingRate != 100">
			<error>
				<record></record>
				<code>WAF-002</code>
				<message>The sum of the percentages should be equal to 100%.</message>
				<field>ClearedReposRate</field>
				<value>
					<xsl:value-of select="ClearedReposRate" />
				</value>
			</error>
		</xsl:if>
	</xsl:template>

	<xsl:template match="AIFCompleteDescription/AIFIndividualInfo/RiskProfile/CounterpartyRiskProfile/FundToCounterpartyExposures/FundToCounterpartyExposure">

		<xsl:if test="boolean(CounterpartyExposureFlag='true') != boolean(CounterpartyIdentification/EntityName)">
			<error>
				<record></record>
				<code>CAF-113</code>
				<message>The counterparty name is not consistent with the counterparty exposure flag.</message>
				<field>EntityName</field>
				<value>
					<xsl:value-of select="CounterpartyIdentification/EntityName" />
				</value>
			</error>
		</xsl:if>
		<xsl:variable
				name="lei"
				select="CounterpartyIdentification/EntityIdentificationLEI" />
		<xsl:if test="not(my:ISO17442($lei))">
			<error>
				<record></record>
				<code>CAF-114</code>
				<message>The check digits of the LEI code are not correct.</message>
				<field>EntityIdentificationLEI</field>
				<value>
					<xsl:value-of select="$lei" />
				</value>
			</error>
		</xsl:if>
		<xsl:if test="boolean(CounterpartyExposureFlag='false') and boolean(CounterpartyIdentification/EntityIdentificationLEI)">
			<error>
				<record></record>
				<code>CAF-115</code>
				<message>The LEI code is not consistent with the counterparty exposure flag.</message>
				<field>EntityIdentificationLEI</field>
				<value>
					<xsl:value-of select="CounterpartyIdentification/EntityIdentificationLEI" />
				</value>
			</error>
		</xsl:if>
		<xsl:if test="boolean(CounterpartyExposureFlag='false') and boolean(CounterpartyIdentification/EntityIdentificationBIC)">
			<error>
				<record></record>
				<code>CAF-116</code>
				<message>The BIC code is not consistent with the counterparty exposure flag.</message>
				<field>EntityIdentificationBIC</field>
				<value>
					<xsl:value-of select="CounterpartyIdentification/EntityIdentificationBIC" />
				</value>
			</error>
		</xsl:if>
		<xsl:if test="boolean(CounterpartyExposureFlag='true') != boolean(CounterpartyTotalExposureRate)">
			<error>
				<record></record>
				<code>CAF-117</code>
				<message>The NAV percentage is not consistent with the counterparty exposure flag.</message>
				<field>CounterpartyTotalExposureRate</field>
				<value>
					<xsl:value-of select="CounterpartyTotalExposureRate" />
				</value>
			</error>
		</xsl:if>
		<xsl:variable
				name="rank"
				select="Ranking" />
		<xsl:variable
				name="value"
				select="CounterpartyTotalExposureRate" />
		<xsl:if test="$value &lt; ../FundToCounterpartyExposure[Ranking=($rank + 1)]/CounterpartyTotalExposureRate">
			<error>
				<record></record>
				<code>CAF-118</code>
				<message>The reported value is not consistent with the rank.</message>
				<field>AggregatedValueAmount</field>
				<value>
					<xsl:value-of select="$value" />
				</value>
			</error>
		</xsl:if>
	</xsl:template>

	<xsl:template match="AIFCompleteDescription/AIFIndividualInfo/RiskProfile/CounterpartyRiskProfile/CounterpartyToFundExposures/CounterpartyToFundExposure">

		<xsl:if test="boolean(CounterpartyExposureFlag='true') != boolean(CounterpartyIdentification/EntityName)">
			<error>
				<record></record>
				<code>CAF-119</code>
				<message>The counterparty name is not consistent with the counterparty exposure flag.</message>
				<field>EntityName</field>
				<value>
					<xsl:value-of select="CounterpartyIdentification/EntityName" />
				</value>
			</error>
		</xsl:if>
		<xsl:variable
				name="lei"
				select="CounterpartyIdentification/EntityIdentificationLEI" />
		<xsl:if test="not(my:ISO17442($lei))">
			<error>
				<record></record>
				<code>CAF-120</code>
				<message>The check digits of the LEI code are not correct.</message>
				<field>EntityIdentificationLEI</field>
				<value>
					<xsl:value-of select="$lei" />
				</value>
			</error>
		</xsl:if>

		<xsl:variable
				name="eilei"
				select="CounterpartyIdentification/EntityIdentificationLEI" />
		<xsl:if test="boolean(CounterpartyExposureFlag='false') and boolean($eilei)">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-121'" />
				<xsl:with-param
						name="context"
						select="$eilei" />
			</xsl:call-template>
		</xsl:if>

		<xsl:variable
				name="eibic"
				select="CounterpartyIdentification/EntityIdentificationBIC" />
		<xsl:if test="boolean(CounterpartyExposureFlag='false') and boolean($eibic)">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-122'" />
				<xsl:with-param
						name="context"
						select="$eibic" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="boolean(CounterpartyExposureFlag='true') != boolean(CounterpartyTotalExposureRate)">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-123'" />
				<xsl:with-param
						name="context"
						select="CounterpartyTotalExposureRate" />
			</xsl:call-template>
		</xsl:if>

		<xsl:variable
				name="rank"
				select="Ranking" />
		<xsl:variable
				name="value"
				select="CounterpartyTotalExposureRate" />
		<xsl:if test="$value &lt; ../CounterpartyToFundExposure[Ranking=($rank + 1)]/CounterpartyTotalExposureRate">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-124'" />
				<xsl:with-param
						name="context"
						select="CounterpartyTotalExposureRate" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="AIFCompleteDescription/AIFIndividualInfo/RiskProfile/CounterpartyRiskProfile">

		<xsl:param name="periodtype" />
		<xsl:variable
				name="directclearing"
				select="string(ClearTransactionsThroughCCPFlag)" />
		<xsl:if test="$directclearing = 'true' and not(AIFCompleteDescription/AIFIndividualInfo/RiskProfile/CounterpartyRiskProfile/CCPExposures/CCPExposure[Ranking = 1])">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-125'" />
				<xsl:with-param
						name="context"
						select="ClearTransactionsThroughCCPFlag" />
			</xsl:call-template>
		</xsl:if>
		<xsl:apply-templates>
			<xsl:with-param
					name="periodtype"
					select="$periodtype" />
			<xsl:with-param
					name="directclearing"
					select="$directclearing" />
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="AIFCompleteDescription/AIFIndividualInfo/RiskProfile/CounterpartyRiskProfile/CCPExposures/CCPExposure">

		<xsl:param name="directclearing" />
		<!-- <xsl:if test="$directclearing = 'false' and boolean(CCPIdentification/EntityIdentificationLEI)">
			<error>
				<record>
					
				</record>
				<code>CAF-126</code>
				<message>The LEI code is not consistent with the counterparty exposure flag.</message>
				<field>EntityIdentificationLEI</field>
				<value>
					<xsl:value-of select="CCPIdentification/EntityIdentificationLEI" />
				</value>
			</error>
		</xsl:if> -->
		<xsl:variable
				name="lei"
				select="CCPIdentification/EntityIdentificationLEI" />
		<xsl:if test="not(my:ISO17442($lei))">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-126'" />
				<xsl:with-param
						name="context"
						select="EntityIdentificationLEI" />
			</xsl:call-template>
		</xsl:if>
		<xsl:variable
				name="rank"
				select="Ranking" />
		<xsl:variable
				name="value"
				select="CCPExposureValue" />
		<xsl:if test="$value &lt; ../CCPExposure[Ranking=($rank + 1)]/CCPExposureValue">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-127'" />
				<xsl:with-param
						name="context"
						select="CCPExposureValue" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="AIFCompleteDescription/AIFIndividualInfo/RiskProfile/LiquidityRiskProfile/PortfolioLiquidityProfile">

		<xsl:variable
				name="portfoliosum"
				select="PortfolioLiquidityInDays0to1Rate + PortfolioLiquidityInDays2to7Rate + PortfolioLiquidityInDays8to30Rate + PortfolioLiquidityInDays31to90Rate + PortfolioLiquidityInDays91to180Rate + PortfolioLiquidityInDays181to365Rate + PortfolioLiquidityInDays365MoreRate" />
		<xsl:if test="$portfoliosum != 100">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-128'" />
				<xsl:with-param
						name="context"
						select="$portfoliosum" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="AIFCompleteDescription/AIFIndividualInfo/RiskProfile/LiquidityRiskProfile/InvestorLiquidityProfile">

		<xsl:variable
				name="liquiditysum"
				select="InvestorLiquidityInDays0to1Rate + InvestorLiquidityInDays2to7Rate + InvestorLiquidityInDays8to30Rate + InvestorLiquidityInDays31to90Rate + InvestorLiquidityInDays91to180Rate + InvestorLiquidityInDays181to365Rate + InvestorLiquidityInDays365MoreRate" />
		<xsl:if test="$liquiditysum != 100">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-129'" />
				<xsl:with-param
						name="context"
						select="$liquiditysum" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="AIFCompleteDescription/AIFIndividualInfo/RiskProfile/LiquidityRiskProfile/InvestorRedemption">

		<xsl:if test="ProvideWithdrawalRightsFlag = 'false' and boolean(InvestorRedemptionFrequency)">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-130'" />
				<xsl:with-param
						name="context"
						select="InvestorRedemptionFrequency" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="ProvideWithdrawalRightsFlag = 'false' and boolean(InvestorRedemptionNoticePeriod)">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-131'" />
				<xsl:with-param
						name="context"
						select="InvestorRedemptionNoticePeriod" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="ProvideWithdrawalRightsFlag = 'false' and boolean(InvestorRedemptionLockUpPeriod)">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-132'" />
				<xsl:with-param
						name="context"
						select="InvestorRedemptionLockUpPeriod" />
			</xsl:call-template>
		</xsl:if>

	</xsl:template>

	<xsl:template match="AIFCompleteDescription/AIFIndividualInfo/RiskProfile/LiquidityRiskProfile/FinancingLiquidityProfile">

		<xsl:variable
				name="financingsum"
				select="TotalFinancingInDays0to1Rate + TotalFinancingInDays2to7Rate + TotalFinancingInDays8to30Rate + TotalFinancingInDays31to90Rate + TotalFinancingInDays91to180Rate + TotalFinancingInDays181to365Rate + TotalFinancingInDays365MoreRate" />
		<xsl:if test="$financingsum != 100">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-133'" />
				<xsl:with-param
						name="context"
						select="FinancingLiquidityProfile" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="AIFCompleteDescription/AIFIndividualInfo/RiskProfile/OperationalRisk/HistoricalRiskProfile/GrossInvestmentReturnsRate">
		<xsl:param name="periodtype" />
		<xsl:variable name="error">
			<xsl:choose>
				<xsl:when test="$periodtype = 'Q1'">
					<xsl:if test="RateApril or RateMay or RateJune or RateJuly or RateAugust or RateSeptember or RateOctober or RateNovember or RateDecember">true</xsl:if>
				</xsl:when>
				<xsl:when test="$periodtype = 'Q2'">
					<xsl:if test="RateJanuary or RateFebruary or RateMarch or RateJuly or RateAugust or RateSeptember or RateOctober or RateNovember or RateDecember">true</xsl:if>
				</xsl:when>
				<xsl:when test="$periodtype = 'Q3'">
					<xsl:if test="RateJanuary or RateFebruary or RateMarch or RateApril or RateMay or RateJune or RateOctober or RateNovember or RateDecember">true</xsl:if>
				</xsl:when>
				<xsl:when test="$periodtype = 'Q4'">
					<xsl:if test="RateJanuary or RateFebruary or RateMarch or RateApril or RateMay or RateJune or RateJuly or RateAugust or RateSeptember">true</xsl:if>
				</xsl:when>
				<xsl:when test="$periodtype = 'H1'">
					<xsl:if test="RateJuly or RateAugust or RateSeptember or RateOctober or RateNovember or RateDecember">true</xsl:if>
				</xsl:when>
				<xsl:when test="$periodtype = 'H2'">
					<xsl:if test="RateJanuary or RateFebruary or RateMarch or RateApril or RateMay or RateJune">true</xsl:if>
				</xsl:when>
				<xsl:when test="$periodtype = 'X1'">
					<xsl:if test="RateOctober or RateNovember or RateDecember">true</xsl:if>
				</xsl:when>
				<xsl:when test="$periodtype = 'X2'">
					<xsl:if test="RateJanuary or RateFebruary or RateMarch">true</xsl:if>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="$error = 'true'">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-134'" />
				<xsl:with-param
						name="context"
						select="GrossInvestmentReturnsRate" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="AIFCompleteDescription/AIFIndividualInfo/RiskProfile/OperationalRisk/HistoricalRiskProfile/NetInvestmentReturnsRate">
		<xsl:param name="periodtype" />
		<xsl:variable name="error">
			<xsl:choose>
				<xsl:when test="$periodtype = 'Q1'">
					<xsl:if test="RateApril or RateMay or RateJune or RateJuly or RateAugust or RateSeptember or RateOctober or RateNovember or RateDecember">true</xsl:if>
				</xsl:when>
				<xsl:when test="$periodtype = 'Q2'">
					<xsl:if test="RateJanuary or RateFebruary or RateMarch or RateJuly or RateAugust or RateSeptember or RateOctober or RateNovember or RateDecember">true</xsl:if>
				</xsl:when>
				<xsl:when test="$periodtype = 'Q3'">
					<xsl:if test="RateJanuary or RateFebruary or RateMarch or RateApril or RateMay or RateJune or RateOctober or RateNovember or RateDecember">true</xsl:if>
				</xsl:when>
				<xsl:when test="$periodtype = 'Q4'">
					<xsl:if test="RateJanuary or RateFebruary or RateMarch or RateApril or RateMay or RateJune or RateJuly or RateAugust or RateSeptember">true</xsl:if>
				</xsl:when>
				<xsl:when test="$periodtype = 'H1'">
					<xsl:if test="RateJuly or RateAugust or RateSeptember or RateOctober or RateNovember or RateDecember">true</xsl:if>
				</xsl:when>
				<xsl:when test="$periodtype = 'H2'">
					<xsl:if test="RateJanuary or RateFebruary or RateMarch or RateApril or RateMay or RateJune">true</xsl:if>
				</xsl:when>
				<xsl:when test="$periodtype = 'X1'">
					<xsl:if test="RateOctober or RateNovember or RateDecember">true</xsl:if>
				</xsl:when>
				<xsl:when test="$periodtype = 'X2'">
					<xsl:if test="RateJanuary or RateFebruary or RateMarch">true</xsl:if>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="$error = 'true'">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-135'" />
				<xsl:with-param
						name="context"
						select="NetInvestmentReturnsRate" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="AIFCompleteDescription/AIFIndividualInfo/RiskProfile/OperationalRisk/HistoricalRiskProfile/NAVChangeRate">
		<xsl:param name="periodtype" />
		<xsl:variable name="error">
			<xsl:choose>
				<xsl:when test="$periodtype = 'Q1'">
					<xsl:if test="RateApril or RateMay or RateJune or RateJuly or RateAugust or RateSeptember or RateOctober or RateNovember or RateDecember">true</xsl:if>
				</xsl:when>
				<xsl:when test="$periodtype = 'Q2'">
					<xsl:if test="RateJanuary or RateFebruary or RateMarch or RateJuly or RateAugust or RateSeptember or RateOctober or RateNovember or RateDecember">true</xsl:if>
				</xsl:when>
				<xsl:when test="$periodtype = 'Q3'">
					<xsl:if test="RateJanuary or RateFebruary or RateMarch or RateApril or RateMay or RateJune or RateOctober or RateNovember or RateDecember">true</xsl:if>
				</xsl:when>
				<xsl:when test="$periodtype = 'Q4'">
					<xsl:if test="RateJanuary or RateFebruary or RateMarch or RateApril or RateMay or RateJune or RateJuly or RateAugust or RateSeptember">true</xsl:if>
				</xsl:when>
				<xsl:when test="$periodtype = 'H1'">
					<xsl:if test="RateJuly or RateAugust or RateSeptember or RateOctober or RateNovember or RateDecember">true</xsl:if>
				</xsl:when>
				<xsl:when test="$periodtype = 'H2'">
					<xsl:if test="RateJanuary or RateFebruary or RateMarch or RateApril or RateMay or RateJune">true</xsl:if>
				</xsl:when>
				<xsl:when test="$periodtype = 'X1'">
					<xsl:if test="RateOctober or RateNovember or RateDecember">true</xsl:if>
				</xsl:when>
				<xsl:when test="$periodtype = 'X2'">
					<xsl:if test="RateJanuary or RateFebruary or RateMarch">true</xsl:if>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="$error = 'true'">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-136'" />
				<xsl:with-param
						name="context"
						select="NAVChangeRate" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="AIFCompleteDescription/AIFIndividualInfo/RiskProfile/OperationalRisk/HistoricalRiskProfile/Subscription">

		<xsl:param name="periodtype" />
		<xsl:variable name="error">
			<xsl:choose>
				<xsl:when test="$periodtype = 'Q1'">
					<xsl:if test="QuantityApril or QuantityMay or QuantityJune or QuantityJuly or QuantityAugust or QuantitySeptember or QuantityOctober or QuantityNovember or QuantityDecember">true</xsl:if>
				</xsl:when>
				<xsl:when test="$periodtype = 'Q2'">
					<xsl:if test="QuantityJanuary or QuantityFebruary or QuantityMarch or QuantityJuly or QuantityAugust or QuantitySeptember or QuantityOctober or QuantityNovember or QuantityDecember">true</xsl:if>
				</xsl:when>
				<xsl:when test="$periodtype = 'Q3'">
					<xsl:if test="QuantityJanuary or QuantityFebruary or QuantityMarch or QuantityApril or QuantityMay or QuantityJune or QuantityOctober or QuantityNovember or QuantityDecember">true</xsl:if>
				</xsl:when>
				<xsl:when test="$periodtype = 'Q4'">
					<xsl:if test="QuantityJanuary or QuantityFebruary or QuantityMarch or QuantityApril or QuantityMay or QuantityJune or QuantityJuly or QuantityAugust or QuantitySeptember">true</xsl:if>
				</xsl:when>
				<xsl:when test="$periodtype = 'H1'">
					<xsl:if test="QuantityJuly or QuantityAugust or QuantitySeptember or QuantityOctober or QuantityNovember or QuantityDecember">true</xsl:if>
				</xsl:when>
				<xsl:when test="$periodtype = 'H2'">
					<xsl:if test="QuantityJanuary or QuantityFebruary or QuantityMarch or QuantityApril or QuantityMay or QuantityJune">true</xsl:if>
				</xsl:when>
				<xsl:when test="$periodtype = 'X1'">
					<xsl:if test="QuantityOctober or QuantityNovember or QuantityDecember">true</xsl:if>
				</xsl:when>
				<xsl:when test="$periodtype = 'X2'">
					<xsl:if test="QuantityJanuary or QuantityFebruary or QuantityMarch">true</xsl:if>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="$error = 'true'">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-137'" />
				<xsl:with-param
						name="context"
						select="Subscription" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="AIFCompleteDescription/AIFLeverageInfo/AIFLeverageArticle24-2">
		<xsl:variable
				name="accrrate"
				select="AllCounterpartyCollateralRehypothecatedRate" />
		<xsl:if test="AllCounterpartyCollateralRehypothecationFlag = 'false' and $accrrate ">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-139'" />
				<xsl:with-param
						name="context"
						select="$accrrate" />
			</xsl:call-template>
		</xsl:if>

		<xsl:apply-templates />

	</xsl:template>

	<xsl:template match="AIFCompleteDescription/AIFIndividualInfo/RiskProfile/OperationalRisk/HistoricalRiskProfile/Redemption">
		<xsl:param name="periodtype" />
		<xsl:variable name="caf-138">
			<xsl:choose>
				<xsl:when test="$periodtype = 'Q1'">
					<xsl:if test="QuantityApril or QuantityMay or QuantityJune or QuantityJuly or QuantityAugust or QuantitySeptember or QuantityOctober or QuantityNovember or QuantityDecember">true</xsl:if>
				</xsl:when>
				<xsl:when test="$periodtype = 'Q2'">
					<xsl:if test="QuantityJanuary or QuantityFebruary or QuantityMarch or QuantityJuly or QuantityAugust or QuantitySeptember or QuantityOctober or QuantityNovember or QuantityDecember">true</xsl:if>
				</xsl:when>
				<xsl:when test="$periodtype = 'Q3'">
					<xsl:if test="QuantityJanuary or QuantityFebruary or QuantityMarch or QuantityApril or QuantityMay or QuantityJune or QuantityOctober or QuantityNovember or QuantityDecember">true</xsl:if>
				</xsl:when>
				<xsl:when test="$periodtype = 'Q4'">
					<xsl:if test="QuantityJanuary or QuantityFebruary or QuantityMarch or QuantityApril or QuantityMay or QuantityJune or QuantityJuly or QuantityAugust or QuantitySeptember">true</xsl:if>
				</xsl:when>
				<xsl:when test="$periodtype = 'H1'">
					<xsl:if test="QuantityJuly or QuantityAugust or QuantitySeptember or QuantityOctober or QuantityNovember or QuantityDecember">true</xsl:if>
				</xsl:when>
				<xsl:when test="$periodtype = 'H2'">
					<xsl:if test="QuantityJanuary or QuantityFebruary or QuantityMarch or QuantityApril or QuantityMay or QuantityJune">true</xsl:if>
				</xsl:when>
				<xsl:when test="$periodtype = 'X1'">
					<xsl:if test="QuantityOctober or QuantityNovember or QuantityDecember">true</xsl:if>
				</xsl:when>
				<xsl:when test="$periodtype = 'X2'">
					<xsl:if test="QuantityJanuary or QuantityFebruary or QuantityMarch">true</xsl:if>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="$caf-138 = 'true'">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-138'" />
				<xsl:with-param
						name="context"
						select="Redemption" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="AIFCompleteDescription/AIFLeverageInfo/AIFLeverageArticle24-2/ControlledStructures/ControlledStructure/ControlledStructureIdentification/EntityIdentificationLEI">

		<xsl:variable
				name="lei"
				select="." />
		<xsl:if test="not(my:ISO17442($lei))">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-140'" />
				<xsl:with-param
						name="context"
						select="$lei" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="AIFCompleteDescription/AIFLeverageInfo/AIFLeverageArticle24-4/BorrowingSource">

		<xsl:variable
				name="lei"
				select="SourceIdentification/EntityIdentificationLEI" />

		<xsl:variable
				name="siename"
				select="SourceIdentification/EntityName" />
		<xsl:if test="boolean(BorrowingSourceFlag = 'true') != boolean($siename)">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-141'" />
				<xsl:with-param
						name="context"
						select="$siename" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="not(my:ISO17442($lei))">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-142'" />
				<xsl:with-param
						name="context"
						select="$lei" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="boolean(BorrowingSourceFlag = 'false') and $lei">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-143'" />
				<xsl:with-param
						name="context"
						select="$lei" />
			</xsl:call-template>
		</xsl:if>

		<xsl:variable
				name="eibic"
				select="SourceIdentification/EntityIdentificationBIC" />
		<xsl:if test="boolean(BorrowingSourceFlag = 'false') and $eibic">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-144'" />
				<xsl:with-param
						name="context"
						select="$eibic" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="boolean(BorrowingSourceFlag = 'true') != LeverageAmount">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-145'" />
				<xsl:with-param
						name="context"
						select="LeverageAmount" />
			</xsl:call-template>
		</xsl:if>

		<xsl:variable
				name="rank"
				select="Ranking" />
		<xsl:variable
				name="value"
				select="LeverageAmount" />
		<xsl:if test="$value &lt; ../BorrowingSource[Ranking=($rank + 1)]/LeverageAmount">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-146'" />
				<xsl:with-param
						name="context"
						select="$value" />
			</xsl:call-template>

		</xsl:if>
	</xsl:template>

</xsl:transform>
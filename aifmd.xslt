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
			select="document('data/manager-register.xml')/codes/code" />
	<xsl:variable
			name="aifregister"
			select="document('data/fund-register.xml')/codes/code" />
	<xsl:variable
			name="micregister"
			select="document('data/mic-register.xml')/codes/code" />
	<xsl:include href="common.xslt" />

	<xsl:variable
			name="aifmdvalidations"
			select="document('data/aifmd-validations.xml')" />

	<xsl:key
			name="validationlookup"
			match="rule"
			use="error_reference" />

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
			<xsl:for-each select="$aifmdvalidations">
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
			<xsl:for-each select="$aifmdvalidations">
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
						select="$periodtype|$reportingperiodstartdate" />
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
						select="ReportingPeriodType|LastReportingFlag|ReportingPeriodStartDate|ReportingPeriodEndDate" />
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
						select="AIFMReportingObligationChangeFrequencyCode|AIFMReportingObligationChangeContentsCode|AIFMReportingObligationChangeQuarter" />
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
		<xsl:apply-templates />
	</xsl:template>

	<xsl:template match="AIFMCompleteDescription">

		<xsl:variable
				name="basecurrency"
				select="AIFMBaseCurrencyDescription/BaseCurrency" />

		<xsl:if test="$basecurrency and not($basecurrency = 'EUR')">

			<xsl:variable
					name="amountbase"
					select="AIFMBaseCurrencyDescription/AUMAmountInBaseCurrency" />
			<xsl:variable
					name="amounteuro"
					select="AUMAmountInEuro" />
			<xsl:variable
					name="rateeuro"
					select="AIFMBaseCurrencyDescription/FXEURRate" />
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
							select="$basecurrency|$amountbase|$amounteuro|$rateeuro" />
				</xsl:call-template>
			</xsl:if>
		</xsl:if>

		<xsl:apply-templates />
	</xsl:template>

	<xsl:template match="AIFMCompleteDescription/AIFMPrincipalMarkets/AIFMFivePrincipalMarket/MarketIdentification">

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
						select="MarketCodeType|$mic" />
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
						select="ReportingMemberState|AIFMNationalCode" />
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
						select="BaseCurrency|FXEURReferenceRateType|FXEUROtherReferenceRateDescription" />
			</xsl:call-template>
		</xsl:if>

	</xsl:template>

	<xsl:template match="AIFMCompleteDescription/AIFMIdentifier/AIFMIdentifierLEI">
		<xsl:variable
				name="lei"
				select="." />

		<xsl:if test="boolean($lei) and not(my:ISO17442($lei))">
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
						select="SubAssetType|$value" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="$value &lt; ../AIFMPrincipalInstrument[Ranking=($rank + 1)]/AggregatedValueAmount">
			<xsl:call-template name="AIFMError">
				<xsl:with-param
						name="code"
						select="'CAM-014'" />
				<xsl:with-param
						name="context"
						select="Ranking|$value" />
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
						select="MarketIdentification/MarketCodeType|$value" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="$value &lt; ../AIFMFivePrincipalMarket[Ranking=($rank + 1)]/AggregatedValueAmount">
			<xsl:call-template name="AIFMError">
				<xsl:with-param
						name="code"
						select="'CAM-012'" />
				<xsl:with-param
						name="context"
						select="Ranking|$value" />
			</xsl:call-template>
		</xsl:if>
		<xsl:apply-templates />
	</xsl:template>

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
							select="@ReportingMemberState" />
				</xsl:call-template>
			</xsl:if>
			<xsl:apply-templates />
		</aif>
	</xsl:template>

	<xsl:template match="AIFRecordInfo">
		<xsl:if test="AIFNoReportingFlag = 'false'">
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
							select="AIFNoReportingFlag|AIFContentType" />
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
						select="ReportingPeriodType|ReportingPeriodStartDate" />
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
		<xsl:variable name="enderror">
			<xsl:choose>
				<xsl:when test="not($enddate &gt; $startdate)">true</xsl:when>
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
						select="LastReportingFlag|ReportingPeriodType|ReportingPeriodEndDate|ReportingPeriodStartDate" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="(AIFReportingObligationChangeFrequencyCode or AIFReportingObligationChangeContentsCode) != boolean(AIFReportingObligationChangeQuarter)">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-006'" />
				<xsl:with-param
						name="context"
						select="AIFReportingObligationChangeFrequencyCode|AIFReportingObligationChangeContentsCode|AIFReportingObligationChangeQuarter" />
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
						select="AIFMNationalCode" />
			</xsl:call-template>
		</xsl:if>

		<xsl:variable
				name="fund"
				select="AIFNationalCode" />

		<xsl:if test="not($aifregister[. = $fund])">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-008'" />
				<xsl:with-param
						name="context"
						select="AIFNationalCode" />
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
						select="AIFEEAFlag|AIFDomicile" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="not($countrycodes[. = $domicile])">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-010'" />
				<xsl:with-param
						name="context"
						select="AIFDomicile" />
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
						select="InceptionDate|ReportingPeriodStartDate" />
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

		<xsl:apply-templates />

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
								select="PredominantAIFType|HedgeFundInvestmentStrategies/HedgeFundStrategy" />
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
								select="PredominantAIFType|PrivateEquityFundInvestmentStrategies/PrivateEquityFundInvestmentStrategy" />
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
								select="PredominantAIFType|RealEstateFundInvestmentStrategies/RealEstateFundStrategy" />
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
								select="PredominantAIFType|FundOfFundsInvestmentStrategies/FundOfFundsStrategy" />
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
								select="PredominantAIFType|OtherFundInvestmentStrategies/OtherFundStrategy" />
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
							select="PredominantAIFType|.//*[contains(local-name(), 'FundStrategyType')]" />
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
						select="*/*/StrategyNAVRate" />
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
						select="FundOfFundsStrategyType|StrategyTypeOtherDescription" />
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
						select="OtherFundStrategyType|StrategyTypeOtherDescription" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/MasterAIFsIdentification/MasterAIFIdentification">

		<xsl:variable
				name="aifname"
				select="AIFName" />
		<xsl:variable
				name="masterfeederstatus"
				select="../../AIFMasterFeederStatus" />
		<xsl:if test="($masterfeederstatus = 'FEEDER') != boolean($aifname)">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-024'" />
				<xsl:with-param
						name="context"
						select="../../AIFMasterFeederStatus|AIFName" />
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
						select="AIFIdentifierNCA/ReportingMemberState" />
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
							select="../../AIFMasterFeederStatus|AIFIdentifierNCA/ReportingMemberState" />
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
							select="../../AIFMasterFeederStatus|AIFIdentifierNCA/AIFNationalCode" />
				</xsl:call-template>
			</xsl:if>
		</xsl:if>

		<xsl:apply-templates />
	</xsl:template>

	<xsl:template match="AIFCompleteDescription/AIFPrincipalInfo/AIFIdentification/AIFIdentifierLEI">
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
						select="." />
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
						select="." />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/MasterAIFsIdentification/MasterAIFIdentification/AIFIdentifierNCA/ReportingMemberState">
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
						select="." />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="AIFCompleteDescription/AIFPrincipalInfo/ShareClassIdentification/ShareClassIdentifier">
		<xsl:variable
				name="shareclassflag"
				select="../../ShareClassFlag" />

		<xsl:if test="$shareclassflag != 'true'">
			<xsl:if test="ShareClassNationalCode">
				<xsl:call-template name="AIFError">
					<xsl:with-param
							name="code"
							select="'CAF-016'" />
					<xsl:with-param
							name="context"
							select="$shareclassflag|ShareClassNationalCode" />
				</xsl:call-template>
			</xsl:if>
		</xsl:if>

		<xsl:variable
				name="isin"
				select="ShareClassIdentifierISIN" />
		<xsl:if test="boolean($isin) and not(my:ISO6166($isin))">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-017'" />
				<xsl:with-param
						name="context"
						select="ShareClassIdentifierISIN" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="($shareclassflag != 'true') and $isin">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-018'" />
				<xsl:with-param
						name="context"
						select="$shareclassflag|ShareClassIdentifierISIN" />
			</xsl:call-template>
		</xsl:if>

		<xsl:variable
				name="cusip"
				select="ShareClassIdentifierCUSIP" />
		<xsl:if test="($shareclassflag != 'true') and $cusip">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-019'" />
				<xsl:with-param
						name="context"
						select="$shareclassflag|ShareClassIdentifierCUSIP" />
			</xsl:call-template>
		</xsl:if>

		<xsl:variable
				name="sedol"
				select="ShareClassIdentifierSEDOL" />
		<xsl:if test="($shareclassflag != 'true') and $sedol">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-020'" />
				<xsl:with-param
						name="context"
						select="$shareclassflag|ShareClassIdentifierSEDOL" />
			</xsl:call-template>
		</xsl:if>

		<xsl:variable
				name="ticker"
				select="ShareClassIdentifierTicker" />
		<xsl:if test="($shareclassflag != 'true') and $ticker">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-021'" />
				<xsl:with-param
						name="context"
						select="$shareclassflag|ShareClassIdentifierTicker" />
			</xsl:call-template>
		</xsl:if>

		<xsl:variable
				name="ric"
				select="ShareClassIdentifierRIC" />
		<xsl:if test="($shareclassflag != 'true') and $ric">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-022'" />
				<xsl:with-param
						name="context"
						select="$shareclassflag|ShareClassIdentifierRIC" />
			</xsl:call-template>
		</xsl:if>

		<xsl:variable
				name="shareclassname"
				select="ShareClassName" />
		<xsl:if test="($shareclassflag = 'true') != boolean($shareclassname)">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-023'" />
				<xsl:with-param
						name="context"
						select="../../ShareClassFlag|ShareClassName" />
			</xsl:call-template>
		</xsl:if>

	</xsl:template>

	<xsl:template match="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/PrimeBrokers/PrimeBrokerIdentification/EntityIdentificationLEI">
		<xsl:variable
				name="lei"
				select="." />

		<xsl:if test="not(my:ISO17442($lei))">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-028'" />
				<xsl:with-param
						name="context"
						select="." />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/AIFBaseCurrencyDescription">
		<xsl:variable
				name="noreporting"
				select="./ancestor-or-self::AIFRecordInfo/AIFNoReportingFlag" />

		<xsl:variable
				name="basecurrency"
				select="BaseCurrency" />

		<xsl:if test="not($currencycodes[. = $basecurrency])">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-029'" />
				<xsl:with-param
						name="context"
						select="BaseCurrency" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="($noreporting = 'false' and not($basecurrency = 'EUR')) != boolean(FXEURRate)">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-030'" />
				<xsl:with-param
						name="context"
						select="$noreporting|BaseCurrency|FXEURRate" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="($noreporting = 'false' and not($basecurrency = 'EUR')) != boolean(FXEURReferenceRateType)">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-031'" />
				<xsl:with-param
						name="context"
						select="$noreporting|BaseCurrency|FXEURReferenceRateType" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="(FXEURReferenceRateType = 'OTH') != boolean(FXEUROtherReferenceRateDescription)">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-032'" />
				<xsl:with-param
						name="context"
						select="FXEURReferenceRateType|FXEUROtherReferenceRateDescription" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/FirstFundingSourceCountry">
		<xsl:variable
				name="firstfundingsourcecountry"
				select="." />
		<xsl:if test="$firstfundingsourcecountry and not($countrycodes[. = $firstfundingsourcecountry])">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-033'" />
				<xsl:with-param
						name="context"
						select="." />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/SecondFundingSourceCountry">
		<xsl:variable
				name="secondfundingsourcecountry"
				select="." />
		<xsl:if test="$secondfundingsourcecountry and not($countrycodes[. = $secondfundingsourcecountry])">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-034'" />
				<xsl:with-param
						name="context"
						select="." />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/ThirdFundingSourceCountry">
		<xsl:variable
				name="thirdfundingsourcecountry"
				select="." />
		<xsl:if test="$thirdfundingsourcecountry and not($countrycodes[. = $thirdfundingsourcecountry])">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-035'" />
				<xsl:with-param
						name="context"
						select="." />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/HedgeFundInvestmentStrategies/HedgeFundStrategy">
		<xsl:variable
				name="strategytype"
				select="HedgeFundStrategyType" />

		<xsl:if test="($strategytype = 'MULT_HFND') and boolean(StrategyNAVRate)">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-040'" />
				<xsl:with-param
						name="context"
						select="$strategytype|StrategyNAVRate" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="($strategytype = 'OTHER_HFND') != boolean(StrategyTypeOtherDescription)">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-041'" />
				<xsl:with-param
						name="context"
						select="$strategytype|StrategyTypeOtherDescription" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="$strategytype = 'MULT_HFND'">

			<xsl:if test="count(../HedgeFundStrategy[HedgeFundStrategyType != 'MULT_HFND']) &lt; 2">
				<xsl:call-template name="AIFError">
					<xsl:with-param
							name="code"
							select="'CAF-037'" />
					<xsl:with-param
							name="context"
							select="$strategytype" />
				</xsl:call-template>
			</xsl:if>

			<xsl:if test="PrimaryStrategyFlag != 'true'">
				<xsl:call-template name="AIFError">
					<xsl:with-param
							name="code"
							select="'CAF-038'" />
					<xsl:with-param
							name="context"
							select="$strategytype|PrimaryStrategyFlag" />
				</xsl:call-template>
			</xsl:if>
		</xsl:if>

		<xsl:apply-templates />
	</xsl:template>

	<xsl:template match="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/PrivateEquityFundInvestmentStrategies/PrivateEquityFundInvestmentStrategy">
		<xsl:variable
				name="strategytype"
				select="PrivateEquityFundStrategyType" />

		<xsl:if test="($strategytype = 'MULT_PEQF') and boolean(StrategyNAVRate)">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-040'" />
				<xsl:with-param
						name="context"
						select="$strategytype|StrategyNAVRate" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="($strategytype = 'OTHR_PEQF') != boolean(StrategyTypeOtherDescription)">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-041'" />
				<xsl:with-param
						name="context"
						select="$strategytype|StrategyTypeOtherDescription" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="$strategytype = 'MULT_PEQF'">

			<xsl:if test="count(../PrivateEquityFundInvestmentStrategy[PrivateEquityFundStrategyType != 'MULT_PEQF']) &lt; 2">
				<xsl:call-template name="AIFError">
					<xsl:with-param
							name="code"
							select="'CAF-037'" />
					<xsl:with-param
							name="context"
							select="$strategytype" />
				</xsl:call-template>
			</xsl:if>

			<xsl:if test="PrimaryStrategyFlag != 'true'">
				<xsl:call-template name="AIFError">
					<xsl:with-param
							name="code"
							select="'CAF-038'" />
					<xsl:with-param
							name="context"
							select="$strategytype|PrimaryStrategyFlag" />
				</xsl:call-template>
			</xsl:if>
		</xsl:if>
	</xsl:template>

	<xsl:template match="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/RealEstateFundInvestmentStrategies/RealEstateFundStrategy">
		<xsl:variable
				name="strategytype"
				select="RealEstateFundStrategyType" />

		<xsl:if test="($strategytype = 'MULT_REST') and boolean(StrategyNAVRate)">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-040'" />
				<xsl:with-param
						name="context"
						select="$strategytype|StrategyNAVRate" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="($strategytype = 'OTHR_REST') != boolean(StrategyTypeOtherDescription)">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-041'" />
				<xsl:with-param
						name="context"
						select="$strategytype|StrategyTypeOtherDescription" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="$strategytype = 'MULT_REST'">

			<xsl:if test="count(../RealEstateFundStrategy[RealEstateFundStrategyType != 'MULT_REST']) &lt; 2">
				<xsl:call-template name="AIFError">
					<xsl:with-param
							name="code"
							select="'CAF-037'" />
					<xsl:with-param
							name="context"
							select="$strategytype" />
				</xsl:call-template>
			</xsl:if>

			<xsl:if test="PrimaryStrategyFlag != 'true'">
				<xsl:call-template name="AIFError">
					<xsl:with-param
							name="code"
							select="'CAF-038'" />
					<xsl:with-param
							name="context"
							select="$strategytype|PrimaryStrategyFlag" />
				</xsl:call-template>
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
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-042'" />
				<xsl:with-param
						name="context"
						select="SubAssetType|InstrumentCodeType" />
			</xsl:call-template>
		</xsl:if>

		<xsl:variable
				name="instrumentname"
				select="InstrumentName" />
		<xsl:variable
				name="hasname"
				select="boolean($instrumentname)" />
		<xsl:if test="$hasname = $isnota">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-043'" />
				<xsl:with-param
						name="context"
						select="SubAssetType|InstrumentName" />
			</xsl:call-template>
		</xsl:if>

		<xsl:variable
				name="isin"
				select="ISINInstrumentIdentification" />

		<xsl:if test="boolean($isin) and not(my:ISO6166($isin))">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-044'" />
				<xsl:with-param
						name="context"
						select="ISINInstrumentIdentification" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="boolean(InstrumentCodeType = 'ISIN') != boolean($isin)">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-045'" />
				<xsl:with-param
						name="context"
						select="InstrumentCodeType|ISINInstrumentIdentification" />
			</xsl:call-template>
		</xsl:if>

		<xsl:variable
				name="mic"
				select="AIIInstrumentIdentification/AIIExchangeCode" />
		<xsl:if test="$mic and not($micregister[. = $mic])">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-046'" />
				<xsl:with-param
						name="context"
						select="AIIInstrumentIdentification/AIIExchangeCode" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="boolean(InstrumentCodeType = 'AII') != boolean($mic)">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-047'" />
				<xsl:with-param
						name="context"
						select="InstrumentCodeType|AIIInstrumentIdentification/AIIExchangeCode" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="boolean(InstrumentCodeType = 'AII') != boolean(AIIInstrumentIdentification/AIIProductCode)">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-048'" />
				<xsl:with-param
						name="context"
						select="InstrumentCodeType|AIIInstrumentIdentification/AIIProductCode" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="boolean(InstrumentCodeType = 'AII') != boolean(AIIInstrumentIdentification/AIIDerivativeType)">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-049'" />
				<xsl:with-param
						name="context"
						select="InstrumentCodeType|AIIInstrumentIdentification/AIIDerivativeType" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="boolean(InstrumentCodeType = 'AII') != boolean(AIIInstrumentIdentification/AIIPutCallIdentifier)">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-050'" />
				<xsl:with-param
						name="context"
						select="InstrumentCodeType|AIIInstrumentIdentification/AIIPutCallIdentifier" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="boolean(InstrumentCodeType = 'AII') != boolean(AIIInstrumentIdentification/AIIExpiryDate)">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-051'" />
				<xsl:with-param
						name="context"
						select="InstrumentCodeType|AIIInstrumentIdentification/AIIExpiryDate" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="boolean(InstrumentCodeType = 'AII') != boolean(AIIInstrumentIdentification/AIIStrikePrice)">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-052'" />
				<xsl:with-param
						name="context"
						select="InstrumentCodeType|AIIInstrumentIdentification/AIIStrikePrice" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="boolean(SubAssetType = 'NTA_NTA_NOTA') = boolean(PositionType)">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-053'" />
				<xsl:with-param
						name="context"
						select="SubAssetType|PositionType" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="boolean(SubAssetType = 'NTA_NTA_NOTA') = boolean(PositionValue)">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-054'" />
				<xsl:with-param
						name="context"
						select="SubAssetType|PositionValue" />
			</xsl:call-template>
		</xsl:if>

		<xsl:variable
				name="rank"
				select="Ranking" />
		<xsl:variable
				name="value"
				select="PositionValue" />
		<xsl:if test="$value &lt; ../MainInstrumentTraded[Ranking=($rank + 1)]/PositionValue">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-055'" />
				<xsl:with-param
						name="context"
						select="Ranking|PositionValue" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="not(PositionType = 'S') and boolean(ShortPositionHedgingRate)">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-056'" />
				<xsl:with-param
						name="context"
						select="PositionType|ShortPositionHedgingRate" />
			</xsl:call-template>
		</xsl:if>

		<xsl:apply-templates />
	</xsl:template>

	<xsl:template match="AIFCompleteDescription/AIFPrincipalInfo/NAVGeographicalFocus">

		<xsl:variable
				name="navregions"
				select="*" />
		<xsl:if test="$navregions and not(sum($navregions) = 100)">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-057'" />
				<xsl:with-param
						name="context"
						select="*" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="AIFCompleteDescription/AIFPrincipalInfo/AUMGeographicalFocus">

		<xsl:variable
				name="aumregions"
				select="*" />
		<xsl:if test="$aumregions and not(sum($aumregions) = 100)">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-058'" />
				<xsl:with-param
						name="context"
						select="*" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="AIFCompleteDescription/AIFPrincipalInfo/PrincipalExposures/PrincipalExposure">

		<xsl:if test="boolean(AssetMacroType = 'NTA') = boolean(SubAssetType)">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-059'" />
				<xsl:with-param
						name="context"
						select="AssetMacroType|SubAssetType" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="boolean(AssetMacroType = 'NTA') = boolean(PositionType)">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-060'" />
				<xsl:with-param
						name="context"
						select="AssetMacroType|PositionType" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="boolean(AssetMacroType = 'NTA') = boolean(AggregatedValueAmount)">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-061'" />
				<xsl:with-param
						name="context"
						select="AssetMacroType|AggregatedValueAmount" />
			</xsl:call-template>
		</xsl:if>

		<xsl:variable
				name="rank"
				select="Ranking" />
		<xsl:variable
				name="value"
				select="AggregatedValueAmount" />
		<xsl:if test="$value &lt; ../PrincipalExposure[Ranking=($rank + 1)]/AggregatedValueAmount">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-062'" />
				<xsl:with-param
						name="context"
						select="Ranking|AggregatedValueAmount" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="boolean(AssetMacroType = 'NTA') = boolean(AggregatedValueRate)">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-063'" />
				<xsl:with-param
						name="context"
						select="AssetMacroType|AggregatedValueRate" />
			</xsl:call-template>
		</xsl:if>

		<xsl:apply-templates />
	</xsl:template>

	<xsl:template match="AIFCompleteDescription/AIFPrincipalInfo/PrincipalExposures/PrincipalExposure/CounterpartyIdentification">

		<xsl:variable
				name="lei"
				select="EntityIdentificationLEI" />

		<xsl:if test="not(EntityName) and $lei">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-064'" />
				<xsl:with-param
						name="context"
						select="EntityName|$lei" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="boolean($lei) and not(my:ISO17442($lei))">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-065'" />
				<xsl:with-param
						name="context"
						select="$lei" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="not(EntityName) and EntityIdentificationBIC">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-066'" />
				<xsl:with-param
						name="context"
						select="EntityName|EntityIdentificationBIC" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="AIFCompleteDescription/AIFPrincipalInfo/MostImportantConcentration/PortfolioConcentrations/PortfolioConcentration">

		<xsl:if test="boolean(AssetType = 'NTA_NTA') = boolean(PositionType)">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-067'" />
				<xsl:with-param
						name="context"
						select="AssetType|PositionType" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="boolean(AssetType = 'NTA_NTA') = boolean(MarketIdentification/MarketCodeType)">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-068'" />
				<xsl:with-param
						name="context"
						select="AssetType|MarketIdentification/MarketCode" />
			</xsl:call-template>
		</xsl:if>

		<xsl:variable
				name="mic"
				select="MarketIdentification/MarketCode" />
		<xsl:if test="$mic and not($micregister[. = $mic])">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-069'" />
				<xsl:with-param
						name="context"
						select="MarketIdentification/MarketCode" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="boolean(MarketIdentification/MarketCodeType = 'MIC') != boolean(MarketIdentification/MarketCode)">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-070'" />
				<xsl:with-param
						name="context"
						select="MarketIdentification/MarketCodeType|MarketIdentification/MarketCode" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="boolean(AssetType = 'NTA_NTA') = boolean(AggregatedValueAmount)">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-071'" />
				<xsl:with-param
						name="context"
						select="AssetType|AggregatedValueAmount" />
			</xsl:call-template>
		</xsl:if>

		<xsl:variable
				name="rank"
				select="Ranking" />
		<xsl:variable
				name="value"
				select="AggregatedValueAmount" />
		<xsl:if test="$value &lt; ../PortfolioConcentration[Ranking=($rank + 1)]/AggregatedValueAmount">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-072'" />
				<xsl:with-param
						name="context"
						select="Ranking|AggregatedValueAmount" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="boolean(AssetType = 'NTA_NTA') = boolean(AggregatedValueRate)">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-073'" />
				<xsl:with-param
						name="context"
						select="AssetType|AggregatedValueRate" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="not(MarketIdentification/MarketCodeType = 'OTC') and boolean(CounterpartyIdentification/EntityName)">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-074'" />
				<xsl:with-param
						name="context"
						select="MarketIdentification/MarketCodeType|CounterpartyIdentification/EntityName" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="(not(CounterpartyIdentification/EntityName) or not(MarketIdentification/MarketCodeType = 'OTC')) and boolean(CounterpartyIdentification/EntityIdentificationLEI)">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-075'" />
				<xsl:with-param
						name="context"
						select="CounterpartyIdentification/EntityName|MarketIdentification/MarketCodeType|CounterpartyIdentification/EntityIdentificationLEI" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="not(CounterpartyIdentification/EntityName) and boolean(CounterpartyIdentification/EntityIdentificationBIC)">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-077'" />
				<xsl:with-param
						name="context"
						select="CounterpartyIdentification/EntityName|CounterpartyIdentification/EntityIdentificationBIC" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="not(MarketIdentification/MarketCodeType = 'OTC') and boolean(CounterpartyIdentification/EntityIdentificationBIC)">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-078'" />
				<xsl:with-param
						name="context"
						select="MarketIdentification/MarketCodeType|CounterpartyIdentification/EntityIdentificationBIC" />
			</xsl:call-template>
		</xsl:if>
		<xsl:apply-templates />
	</xsl:template>

	<xsl:template match="CounterpartyIdentification/EntityIdentificationLEI">

		<xsl:if test="not(my:ISO17442(.))">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-076'" />
				<xsl:with-param
						name="context"
						select="." />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="AIFCompleteDescription/AIFPrincipalInfo">

		<xsl:if test="boolean(AIFDescription/PredominantAIFType = 'PEQF') != boolean(MostImportantConcentration/TypicalPositionSize)">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-079'" />
				<xsl:with-param
						name="context"
						select="AIFDescription/PredominantAIFType|MostImportantConcentration/TypicalPositionSize" />
			</xsl:call-template>
		</xsl:if>

		<xsl:apply-templates />

	</xsl:template>

	<xsl:template match="AIFCompleteDescription/AIFPrincipalInfo/MostImportantConcentration/AIFPrincipalMarkets/AIFPrincipalMarket">

		<xsl:variable
				name="mic"
				select="MarketIdentification/MarketCode" />

		<xsl:if test="$mic and not($micregister[. = $mic])">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-080'" />
				<xsl:with-param
						name="context"
						select="MarketIdentification/MarketCode" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="boolean(MarketIdentification/MarketCodeType = 'MIC') != boolean($mic)">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-081'" />
				<xsl:with-param
						name="context"
						select="MarketIdentification/MarketCodeType|MarketIdentification/MarketCode" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="boolean(MarketIdentification/MarketCodeType = 'NOT') = boolean(AggregatedValueAmount)">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-082'" />
				<xsl:with-param
						name="context"
						select="MarketIdentification/MarketCodeType|AggregatedValueAmount" />
			</xsl:call-template>
		</xsl:if>

		<xsl:variable
				name="rank"
				select="Ranking" />
		<xsl:variable
				name="value"
				select="AggregatedValueAmount" />
		<xsl:if test="$value &lt; ../AIFPrincipalMarket[Ranking=($rank + 1)]/AggregatedValueAmount">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-083'" />
				<xsl:with-param
						name="context"
						select="Ranking|AggregatedValueAmount" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="AIFCompleteDescription/AIFPrincipalInfo/MostImportantConcentration/InvestorConcentration">

		<xsl:variable
				name="ratesum"
				select="ProfessionalInvestorConcentrationRate + RetailInvestorConcentrationRate" />
		<xsl:if test="$ratesum != 100 and $ratesum != 0">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-084'" />
				<xsl:with-param
						name="context"
						select="ProfessionalInvestorConcentrationRate|RetailInvestorConcentrationRate" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="AIFCompleteDescription/AIFIndividualInfo/IndividualExposure/AssetTypeExposures/AssetTypeExposure">

		<xsl:choose>
			<xsl:when test="SubAssetType='DER_FEX_INVT' or SubAssetType='DER_FEX_HEDG' or SubAssetType='DER_IRD_INTR'">
				<xsl:if test="LongValue">
					<xsl:call-template name="AIFError">
						<xsl:with-param
								name="code"
								select="'CAF-086'" />
						<xsl:with-param
								name="context"
								select="SubAssetType|LongValue" />
					</xsl:call-template>
				</xsl:if>
				<xsl:if test="ShortValue">
					<xsl:call-template name="AIFError">
						<xsl:with-param
								name="code"
								select="'CAF-087'" />
						<xsl:with-param
								name="context"
								select="SubAssetType|ShortValue" />
					</xsl:call-template>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="GrossValue">
					<xsl:call-template name="AIFError">
						<xsl:with-param
								name="code"
								select="'CAF-085'" />
						<xsl:with-param
								name="context"
								select="SubAssetType|GrossValue" />
					</xsl:call-template>
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
				<xsl:call-template name="AIFError">
					<xsl:with-param
							name="code"
							select="'CAF-088'" />
					<xsl:with-param
							name="context"
							select="TurnoverSubAssetType|NotionalValue" />
				</xsl:call-template>
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
					<xsl:call-template name="AIFError">
						<xsl:with-param
								name="code"
								select="'CAF-089'" />
						<xsl:with-param
								name="context"
								select="$currency" />
					</xsl:call-template>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="LongPositionValue">
					<xsl:call-template name="AIFError">
						<xsl:with-param
								name="code"
								select="'CAF-090'" />
						<xsl:with-param
								name="context"
								select="ExposureCurrency|LongPositionValue" />
					</xsl:call-template>
				</xsl:if>
				<xsl:if test="ShortPositionValue">
					<xsl:call-template name="AIFError">
						<xsl:with-param
								name="code"
								select="'CAF-091'" />
						<xsl:with-param
								name="context"
								select="ExposureCurrency|ShortPositionValue" />
					</xsl:call-template>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="AIFCompleteDescription/AIFIndividualInfo/IndividualExposure/CompaniesDominantInfluence/CompanyDominantInfluence">

		<xsl:variable
				name="predominantaiftype"
				select="./ancestor::AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/PredominantAIFType" />

		<xsl:if test="boolean($predominantaiftype='PEQF') != boolean(CompanyIdentification/EntityName)">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-092'" />
				<xsl:with-param
						name="context"
						select="$predominantaiftype|CompanyIdentification/EntityName" />
			</xsl:call-template>
		</xsl:if>
		<xsl:variable
				name="lei"
				select="CompanyIdentification/EntityIdentificationLEI" />
		<xsl:if test="boolean($lei) and not(my:ISO17442($lei))">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-093'" />
				<xsl:with-param
						name="context"
						select="$lei" />
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="$predominantaiftype!='PEQF' and boolean($lei)">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-094'" />
				<xsl:with-param
						name="context"
						select="$predominantaiftype|$lei" />
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="$predominantaiftype!='PEQF' and boolean(CompanyIdentification/EntityIdentificationBIC)">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-095'" />
				<xsl:with-param
						name="context"
						select="$predominantaiftype|CompanyIdentification/EntityIdentificationBIC" />
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="boolean($predominantaiftype='PEQF') != boolean(TransactionType)">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-096'" />
				<xsl:with-param
						name="context"
						select="$predominantaiftype|TransactionType" />
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="boolean(TransactionType='OTHR') != boolean(OtherTransactionTypeDescription)">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-097'" />
				<xsl:with-param
						name="context"
						select="TransactionType|OtherTransactionTypeDescription" />
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="boolean($predominantaiftype='PEQF') != boolean(VotingRightsRate)">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-098'" />
				<xsl:with-param
						name="context"
						select="$predominantaiftype|VotingRightsRate" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="AIFCompleteDescription/AIFIndividualInfo/RiskProfile/MarketRiskProfile/MarketRiskMeasures/MarketRiskMeasure">

		<xsl:if test="not(RiskMeasureType='NET_EQTY_DELTA' or RiskMeasureType='NET_FX_DELTA' or RiskMeasureType='NET_CTY_DELTA') and boolean(RiskMeasureValue)">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-099'" />
				<xsl:with-param
						name="context"
						select="RiskMeasureType|RiskMeasureValue" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="not(RiskMeasureType='NET_DV01' or RiskMeasureType='NET_CS01') and boolean(BucketRiskMeasureValues/LessFiveYearsRiskMeasureValue)">

			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-100'" />
				<xsl:with-param
						name="context"
						select="RiskMeasureType|BucketRiskMeasureValues/LessFiveYearsRiskMeasureValue" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="not(RiskMeasureType='NET_DV01' or RiskMeasureType='NET_CS01') and boolean(BucketRiskMeasureValues/FifthteenYearsRiskMeasureValue)">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-101'" />
				<xsl:with-param
						name="context"
						select="RiskMeasureType|BucketRiskMeasureValues/FifthteenYearsRiskMeasureValue" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="not(RiskMeasureType='NET_DV01' or RiskMeasureType='NET_CS01') and boolean(BucketRiskMeasureValues/MoreFifthteenYearsRiskMeasureValue)">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-102'" />
				<xsl:with-param
						name="context"
						select="RiskMeasureType|BucketRiskMeasureValues/MoreFifthteenYearsRiskMeasureValue" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="RiskMeasureType!='VEGA_EXPO' and boolean(VegaRiskMeasureValues/CurrentMarketRiskMeasureValue)">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-103'" />
				<xsl:with-param
						name="context"
						select="RiskMeasureType|VegaRiskMeasureValues/CurrentMarketRiskMeasureValue" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="RiskMeasureType!='VEGA_EXPO' and boolean(VegaRiskMeasureValues/LowerMarketRiskMeasureValue)">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-104'" />
				<xsl:with-param
						name="context"
						select="RiskMeasureType|VegaRiskMeasureValues/LowerMarketRiskMeasureValue" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="RiskMeasureType!='VEGA_EXPO' and boolean(VegaRiskMeasureValues/HigherMarketRiskMeasureValue)">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-105'" />
				<xsl:with-param
						name="context"
						select="RiskMeasureType|VegaRiskMeasureValues/HigherMarketRiskMeasureValue" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="boolean(RiskMeasureType='VAR') != boolean(VARRiskMeasureValues/VARValue)">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-106'" />
				<xsl:with-param
						name="context"
						select="RiskMeasureType|VARRiskMeasureValues/VARValue" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="boolean(RiskMeasureType='VAR') != boolean(VARRiskMeasureValues/VARCalculationMethodCodeType)">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-107'" />
				<xsl:with-param
						name="context"
						select="RiskMeasureType|VARRiskMeasureValues/VARCalculationMethodCodeType" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="RiskMeasureValue=0 and not(RiskMeasureDescription)">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-108'" />
				<xsl:with-param
						name="context"
						select="RiskMeasureValue|RiskMeasureDescription" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="AIFCompleteDescription/AIFIndividualInfo/RiskProfile/CounterpartyRiskProfile/TradingClearingMechanism/TradedSecurities">

		<xsl:if test="RegulatedMarketRate + OTCRate != 100">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-111'" />
				<xsl:with-param
						name="context"
						select="RegulatedMarketRate|OTCRate" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="AIFCompleteDescription/AIFIndividualInfo/RiskProfile/CounterpartyRiskProfile/TradingClearingMechanism/TradedDerivatives">

		<xsl:if test="RegulatedMarketRate + OTCRate != 100">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-111'" />
				<xsl:with-param
						name="context"
						select="RegulatedMarketRate|OTCRate" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="AIFCompleteDescription/AIFIndividualInfo/RiskProfile/CounterpartyRiskProfile/TradingClearingMechanism/ClearedDerivativesRate">

		<xsl:if test="CCPRate + BilateralClearingRate != 100">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'WAF-001'" />
				<xsl:with-param
						name="context"
						select="CCPRate|BilateralClearingRate" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="AIFCompleteDescription/AIFIndividualInfo/RiskProfile/CounterpartyRiskProfile/TradingClearingMechanism/ClearedReposRate">

		<xsl:if test="CCPRate + BilateralClearingRate + TriPartyRepoClearingRate != 100">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'WAF-002'" />
				<xsl:with-param
						name="context"
						select="CCPRate|BilateralClearingRate|TriPartyRepoClearingRate" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="AIFCompleteDescription/AIFIndividualInfo/RiskProfile/CounterpartyRiskProfile/FundToCounterpartyExposures/FundToCounterpartyExposure">

		<xsl:if test="boolean(CounterpartyExposureFlag='true') != boolean(CounterpartyIdentification/EntityName)">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-113'" />
				<xsl:with-param
						name="context"
						select="CounterpartyExposureFlag|CounterpartyIdentification/EntityName" />
			</xsl:call-template>
		</xsl:if>
		<xsl:variable
				name="lei"
				select="CounterpartyIdentification/EntityIdentificationLEI" />
		<xsl:if test="boolean($lei) and not(my:ISO17442($lei))">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-114'" />
				<xsl:with-param
						name="context"
						select="$lei" />
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="boolean(CounterpartyExposureFlag='false') and boolean(CounterpartyIdentification/EntityIdentificationLEI)">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-115'" />
				<xsl:with-param
						name="context"
						select="CounterpartyExposureFlag|CounterpartyIdentification/EntityIdentificationLEI" />
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="boolean(CounterpartyExposureFlag='false') and boolean(CounterpartyIdentification/EntityIdentificationBIC)">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-116'" />
				<xsl:with-param
						name="context"
						select="CounterpartyExposureFlag|CounterpartyIdentification/EntityIdentificationBIC" />
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="boolean(CounterpartyExposureFlag='true') != boolean(CounterpartyTotalExposureRate)">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-117'" />
				<xsl:with-param
						name="context"
						select="CounterpartyExposureFlag|CounterpartyTotalExposureRate" />
			</xsl:call-template>
		</xsl:if>
		<xsl:variable
				name="rank"
				select="Ranking" />
		<xsl:variable
				name="value"
				select="CounterpartyTotalExposureRate" />
		<xsl:if test="$value &lt; ../FundToCounterpartyExposure[Ranking=($rank + 1)]/CounterpartyTotalExposureRate">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-118'" />
				<xsl:with-param
						name="context"
						select="Ranking|CounterpartyTotalExposureRate" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="AIFCompleteDescription/AIFIndividualInfo/RiskProfile/CounterpartyRiskProfile/CounterpartyToFundExposures/CounterpartyToFundExposure">

		<xsl:variable
				name="ciename"
				select="CounterpartyIdentification/EntityName" />
		<xsl:if test="boolean(CounterpartyExposureFlag='true') != boolean($ciename)">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-119'" />
				<xsl:with-param
						name="context"
						select="CounterpartyExposureFlag|CounterpartyIdentification/EntityName" />
			</xsl:call-template>
		</xsl:if>

		<xsl:variable
				name="lei"
				select="CounterpartyIdentification/EntityIdentificationLEI" />
		<xsl:if test="boolean($lei) and not(my:ISO17442($lei))">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-120'" />
				<xsl:with-param
						name="context"
						select="CounterpartyIdentification/EntityIdentificationLEI" />
			</xsl:call-template>
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
						select="CounterpartyExposureFlag|$eilei" />
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
						select="CounterpartyExposureFlag|$eibic" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="boolean(CounterpartyExposureFlag='true') != boolean(CounterpartyTotalExposureRate)">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-123'" />
				<xsl:with-param
						name="context"
						select="CounterpartyExposureFlag|CounterpartyTotalExposureRate" />
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
						select="Ranking|CounterpartyTotalExposureRate" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="AIFCompleteDescription/AIFIndividualInfo/RiskProfile/CounterpartyRiskProfile">

		<xsl:variable
				name="directclearing"
				select="ClearTransactionsThroughCCPFlag" />

		<xsl:if test="$directclearing = 'true' and not(CCPExposures/CCPExposure[Ranking = 1])">
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
					name="directclearing"
					select="$directclearing" />
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="AIFCompleteDescription/AIFIndividualInfo/RiskProfile/CounterpartyRiskProfile/CCPExposures/CCPExposure">

		<xsl:variable
				name="lei"
				select="CCPIdentification/EntityIdentificationLEI" />
		<xsl:if test="boolean($lei) and not(my:ISO17442($lei))">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-126'" />
				<xsl:with-param
						name="context"
						select="$lei" />
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
						select="Ranking|CCPExposureValue" />
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
						select="*[not(self::UnencumberedCash)]" />
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
						select="*" />
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
						select="ProvideWithdrawalRightsFlag|InvestorRedemptionFrequency" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="ProvideWithdrawalRightsFlag = 'false' and boolean(InvestorRedemptionNoticePeriod)">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-131'" />
				<xsl:with-param
						name="context"
						select="ProvideWithdrawalRightsFlag|InvestorRedemptionNoticePeriod" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="ProvideWithdrawalRightsFlag = 'false' and boolean(InvestorRedemptionLockUpPeriod)">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-132'" />
				<xsl:with-param
						name="context"
						select="ProvideWithdrawalRightsFlag|InvestorRedemptionLockUpPeriod" />
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
						select="*[not(self::TotalFinancingAmount)]" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="AIFCompleteDescription/AIFIndividualInfo/RiskProfile/OperationalRisk/HistoricalRiskProfile/GrossInvestmentReturnsRate">
		<xsl:variable
				name="periodtype"
				select="./ancestor-or-self::AIFRecordInfo/ReportingPeriodType" />
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
						select="$periodtype|*" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="AIFCompleteDescription/AIFIndividualInfo/RiskProfile/OperationalRisk/HistoricalRiskProfile/NetInvestmentReturnsRate">

		<xsl:variable
				name="periodtype"
				select="./ancestor-or-self::AIFRecordInfo/ReportingPeriodType" />

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
						select="$periodtype|*" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="AIFCompleteDescription/AIFIndividualInfo/RiskProfile/OperationalRisk/HistoricalRiskProfile/NAVChangeRate">

		<xsl:variable
				name="periodtype"
				select="./ancestor-or-self::AIFRecordInfo/ReportingPeriodType" />

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
						select="$periodtype|*" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="AIFCompleteDescription/AIFIndividualInfo/RiskProfile/OperationalRisk/HistoricalRiskProfile/Subscription">

		<xsl:variable
				name="periodtype"
				select="./ancestor-or-self::AIFRecordInfo/ReportingPeriodType" />

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
						select="$periodtype|*" />
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
						select="AllCounterpartyCollateralRehypothecationFlag|$accrrate" />
			</xsl:call-template>
		</xsl:if>

		<xsl:apply-templates />

	</xsl:template>

	<xsl:template match="AIFCompleteDescription/AIFIndividualInfo/RiskProfile/OperationalRisk/HistoricalRiskProfile/Redemption">
		<xsl:variable
				name="periodtype"
				select="./ancestor-or-self::AIFRecordInfo/ReportingPeriodType" />

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
						select="$periodtype|*" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="AIFCompleteDescription/AIFLeverageInfo/AIFLeverageArticle24-2/ControlledStructures/ControlledStructure/ControlledStructureIdentification/EntityIdentificationLEI">

		<xsl:variable
				name="lei"
				select="." />
		<xsl:if test="boolean($lei) and not(my:ISO17442($lei))">
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
						select="BorrowingSourceFlag|$siename" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="boolean($lei) and not(my:ISO17442($lei))">
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
						select="BorrowingSourceFlag|$lei" />
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
						select="BorrowingSourceFlag|$eibic" />
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="boolean(BorrowingSourceFlag = 'true') != LeverageAmount">
			<xsl:call-template name="AIFError">
				<xsl:with-param
						name="code"
						select="'CAF-145'" />
				<xsl:with-param
						name="context"
						select="BorrowingSourceFlag|LeverageAmount" />
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
						select="Ranking|LeverageAmount" />
			</xsl:call-template>

		</xsl:if>
	</xsl:template>

	<xsl:template match="text()|@*">
		<!-- <xsl:value-of select="."/> -->
	</xsl:template>

</xsl:transform>
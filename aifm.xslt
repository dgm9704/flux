<xsl:transform version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output indent="yes" method="xml" />

	<xsl:template match="AIFMReportingInfo">
		<aifm>
			<xsl:variable name="reportingmemberstate" select="@ReportingMemberState" />
			<xsl:if test="not($eeacountrycodes[. = $reportingmemberstate])">
				<error>
					<record></record>
					<code>FIL-015</code>
					<message>The authority key file attribute is invalid and should an EU or EEA country</message>
					<field>ReportingMemberState</field>
					<value>
						<xsl:value-of select="$reportingmemberstate" />
					</value>
				</error>
			</xsl:if>
			<xsl:apply-templates />
		</aifm>
	</xsl:template>

	<xsl:template match="AIFMRecordInfo">
		<xsl:variable name="manager" select="AIFMNationalCode" />
		<xsl:variable name="reportingperiodstartdate" select="ReportingPeriodStartDate" />
		<xsl:variable name="startdate" select="translate($reportingperiodstartdate,'-','')" />
		<xsl:variable name="year" select="substring($startdate,1,4)" />
		<xsl:variable name="month" select="substring($startdate,5,2)" />
		<xsl:variable name="day" select="substring($startdate,7,2)" />
		<xsl:variable name="periodtype" select="ReportingPeriodType" />
		<xsl:variable name="reportingyear" select="ReportingPeriodYear" />
		<xsl:choose>
			<xsl:when test="not($day='01') or not($year=$reportingyear)">
				<error>
					<record>
						<xsl:value-of select="$manager" />
					</record>
					<code>CAM-002</code>
					<message>The reporting period start date is not allowed.</message>
					<field>ReportingPeriodStartDate</field>
					<value>
						<xsl:value-of select="$reportingperiodstartdate" />
					</value>
				</error>
			</xsl:when>
			<xsl:when test="$periodtype='Q1' or $periodtype='Q2' or $periodtype='Q3' or $periodtype='Q4'">
				<xsl:if test="not($month='10' or $month='07' or $month='01')">
					<error>
						<record>
							<xsl:value-of select="$manager" />
						</record>
						<code>CAM-002</code>
						<message>The reporting period start date is not allowed.</message>
						<field>ReportingPeriodStartDate</field>
						<value>
							<xsl:value-of select="$reportingperiodstartdate" />
						</value>
					</error>
				</xsl:if>
			</xsl:when>
			<xsl:when test="$periodtype='H1' or $periodtype='H2'">
				<xsl:if test="not($month='07' or $month='01')">
					<error>
						<record>
							<xsl:value-of select="$manager" />
						</record>
						<code>CAM-002</code>
						<message>The reporting period start date is not allowed.</message>
						<field>ReportingPeriodStartDate</field>
						<value>
							<xsl:value-of select="$reportingperiodstartdate" />
						</value>
					</error>
				</xsl:if>
			</xsl:when>
			<xsl:when test="$periodtype='Y1'">
				<xsl:if test="not($month='01')">
					<error>
						<record>
							<xsl:value-of select="$manager" />
						</record>
						<code>CAM-002</code>
						<message>The reporting period start date is not allowed.</message>
						<field>ReportingPeriodStartDate</field>
						<value>
							<xsl:value-of select="$reportingperiodstartdate" />
						</value>
					</error>
				</xsl:if>
			</xsl:when>
		</xsl:choose>
		<xsl:variable name="reportingperiodenddate" select="ReportingPeriodEndDate" />
		<xsl:variable name="enddate" select="translate($reportingperiodenddate,'-','')" />
		<xsl:variable name="q1end" select="concat($year,'0331')" />
		<xsl:variable name="q2end" select="concat($year,'0630')" />
		<xsl:variable name="q3end" select="concat($year,'0930')" />
		<xsl:variable name="q4end" select="concat($year,'1231')" />
		<xsl:variable name="transition" select="LastReportingFlag='true'" />
		<xsl:choose>
			<xsl:when test="not($enddate&gt;$startdate)">
				<error>
					<record>
						<xsl:value-of select="$manager" />
					</record>
					<code>CAM-003</code>
					<message>The reporting period end date is not allowed</message>
					<field>ReportingPeriodEndDate</field>
					<value>
						<xsl:value-of select="$reportingperiodenddate" />
					</value>
				</error>
			</xsl:when>
			<xsl:when test="$periodtype='Q1'">
				<xsl:if test="not($enddate=$q1end or ($transition and $enddate&lt;$q1end))">
					<error>
						<record>
							<xsl:value-of select="$manager" />
						</record>
						<code>CAM-003</code>
						<message>The reporting period end date is not allowed</message>
						<field>ReportingPeriodEndDate</field>
						<value>
							<xsl:value-of select="$reportingperiodenddate" />
						</value>
					</error>
				</xsl:if>
			</xsl:when>
			<xsl:when test="$periodtype='Q2' or $periodtype='H1'">
				<xsl:if test="not($enddate=$q2end or ($transition and $enddate&lt;$q2end))">
					<error>
						<record>
							<xsl:value-of select="$manager" />
						</record>
						<code>CAM-003</code>
						<message>The reporting period end date is not allowed</message>
						<field>ReportingPeriodEndDate</field>
						<value>
							<xsl:value-of select="$reportingperiodenddate" />
						</value>
					</error>
				</xsl:if>
			</xsl:when>
			<xsl:when test="$periodtype='Q3'">
				<xsl:if test="not($enddate=$q3end or ($transition and $enddate&lt;$q3end))">
					<error>
						<record>
							<xsl:value-of select="$manager" />
						</record>
						<code>CAM-003</code>
						<message>The reporting period end date is not allowed</message>
						<field>ReportingPeriodEndDate</field>
						<value>
							<xsl:value-of select="$reportingperiodenddate" />
						</value>
					</error>
				</xsl:if>
			</xsl:when>
			<xsl:when test="$periodtype='Q4' or $periodtype='H2' or $periodtype='Y1'">
				<xsl:if test="not($enddate=$q4end or ($transition and $enddate&lt;$q4end))">
					<error>
						<record>
							<xsl:value-of select="$manager" />
						</record>
						<code>CAM-003</code>
						<message>The reporting period end date is not allowed</message>
						<field>ReportingPeriodEndDate</field>
						<value>
							<xsl:value-of select="$reportingperiodenddate" />
						</value>
					</error>
				</xsl:if>
			</xsl:when>
		</xsl:choose>
		<xsl:variable name="changequarter" select="AIFMReportingObligationChangeQuarter" />
		<xsl:choose>
			<xsl:when test="AIFMReportingObligationChangeFrequencyCode or AIFMReportingObligationChangeContentsCode">
				<xsl:if test="not($changequarter)">
					<error>
						<record>
							<xsl:value-of select="$manager" />
						</record>
						<code>CAM-004</code>
						<message>The quarter for the AIMF reporting obligation change should be reported</message>
						<field>AIFMReportingObligationChangeQuarter</field>
						<value>
							<xsl:value-of select="$changequarter" />
						</value>
					</error>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="$changequarter">
					<error>
						<record>
							<xsl:value-of select="$manager" />
						</record>
						<code>CAM-004</code>
						<message>The quarter for the AIMF reporting obligation change should not be reported</message>
						<field>AIFMReportingObligationChangeQuarter</field>
						<value>
							<xsl:value-of select="$changequarter" />
						</value>
					</error>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:variable name ="jurisdiction" select="AIFMJurisdiction" />
		<xsl:if test="not($countrycodes[. = $jurisdiction])">
			<error>
				<record>
					<xsl:value-of select="$manager" />
				</record>
				<code>CAM-005</code>
				<message>The jurisdiction of the AIF is not correct.</message>
				<field>AIFMJurisdiction</field>
				<value>
					<xsl:value-of select="$jurisdiction" />
				</value>
			</error>
		</xsl:if>
		<xsl:if test="not($aifmregister[. = $manager])">
			<error>
				<record>
					<xsl:value-of select="$manager" />
				</record>
				<code>CAM-006</code>
				<message>The AIFM national code does not exist in the ESMA Register.</message>
				<field>AIFMNAtionalCode</field>
				<value>
					<xsl:value-of select="$manager" />
				</value>
			</error>
		</xsl:if>
		
	
		<xsl:if test = "AIFMCompleteDescription/AIFMBaseCurrencyDescription/BaseCurrency and not(AIFMCompleteDescription/AIFMBaseCurrencyDescription/BaseCurrency = 'EUR')">
			<xsl:variable name="amountbase" select="AIFMCompleteDescription/AIFMBaseCurrencyDescription/AUMAmountInBaseCurrency" />
			<xsl:variable name="amounteuro" select="AIFMCompleteDescription/AUMAmountInEuro" />
			<xsl:variable name="rateeuro" select="AIFMCompleteDescription/AIFMBaseCurrencyDescription/FXEURRate"/>
			<xsl:variable name="result" select="$amounteuro * $rateeuro" />
			<xsl:if test="not($amountbase = $result)">
				<error>
					<record>
						<xsl:value-of select="$manager" />
					</record>
					<code>CAM-016</code>
					<message>The total AuM amount in base currency is not consistent with the total AuM amount in Euro.</message>
					<field>AUMAmountInBaseCurrency</field>
					<value>
						<xsl:value-of select="$amountbase" />
					</value>
				</error>
			</xsl:if>
		</xsl:if>

		<xsl:apply-templates>
			<xsl:with-param name="manager" select="$manager" />
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="AIFMCompleteDescription/AIFMPrincipalMarkets/AIFMFivePrincipalMarket/MarketIdentification">
		<xsl:param name="manager" />
		<xsl:variable name="mic" select="MarketCode" />
		<xsl:if test="(boolean(MarketCodeType = 'MIC') != boolean($mic)) or ($mic and not($micregister[. = $mic]))">
			<error>
				<record>
					<xsl:value-of select="$manager" />
				</record>
				<code>CAM-010</code>
				<message>The MIC code is not correct</message>
				<field>MarketCode</field>
				<value>
					<xsl:value-of select="$mic" />
				</value>
			</error>
		</xsl:if>
	</xsl:template>

	<xsl:template match="AIFMCompleteDescription/AIFMIdentifier/OldAIFMIdentifierNCA">
	<xsl:param name="manager" />

		<xsl:variable name="state" select="ReportingMemberState" />
		<xsl:if test="$state and not($countrycodes[. = $state])">
			<error>
				<record>
					<xsl:value-of select="$manager" />
				</record>
				<code>CAM-008</code>
				<message>The country code does not exist in the reference table of countries</message>
				<field>ReportingMemberState</field>
				<value>
					<xsl:value-of select="$state" />
				</value>
			</error>
		</xsl:if>
		<xsl:if test="$state and not(AIFMNationalCode)">
			<error>
				<record>
					<xsl:value-of select="$manager" />
				</record>
				<code>CAM-009</code>
				<message>The field is mandatory when the old AIFM national identifier - Reporting Member State is filled in.</message>
				<field>AIFMNationalCode</field>
				<value>
					<xsl:value-of select="AIFMNationalCode" />
				</value>
			</error>
		</xsl:if>
	</xsl:template>

	<xsl:template match="AIFMCompleteDescription/AIFMBaseCurrencyDescription">
		<xsl:param name="manager" />

		<xsl:variable name="currency" select="BaseCurrency" />
		<xsl:if test="$currency and not($currencycodes[. = $currency])">
			<error>
				<record>
					<xsl:value-of select="$manager" />
				</record>
				<code>CAM-017</code>
				<message>The currency code does not exist in the reference table of currencies</message>
				<field>BaseCurrency</field>
				<value>
					<xsl:value-of select="$currency" />
				</value>
			</error>
		</xsl:if>

		<xsl:if test="($currency = 'EUR' and FXEURReferenceRateType = 'OTH') != boolean(FXEUROtherReferenceRateDescription)" >
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
		<xsl:variable name="lei" select="." />
		<xsl:if test="$lei and not($leiregister[. = $lei])">
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
		<xsl:variable name="value" select="AggregatedValueAmount"/>
		<xsl:variable name="rank" select="Ranking" />

		<xsl:if test = "not(SubAssetType = 'NTA_NTA_NOTA') and not($value)">
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
				<value><xsl:value-of select="$value" /></value>
			</error>
		</xsl:if>
	</xsl:template>

	<xsl:template match="AIFMCompleteDescription/AIFMPrincipalMarkets/AIFMFivePrincipalMarket">
		<xsl:param name="manager" />
		<xsl:variable name="value" select="AggregatedValueAmount"/>
		<xsl:variable name="rank" select="Ranking" />

		<xsl:if test = "not(MarketIdentification/MarketCodeType = 'NOT') and not($value)">
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
				<value><xsl:value-of select="$value" /></value>
			</error>
		</xsl:if>
		<xsl:apply-templates />
	</xsl:template>

	<xsl:template match="text()|@*">
		<!-- <xsl:value-of select="."/> -->
	</xsl:template>


</xsl:transform>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" >
    <xsl:output method="text" />
      
    <xsl:template match="/AIFMReportingInfo">

        <xsl:variable name="reportingmemberstate" select="@ReportingMemberState" />
        <xsl:if test="not($eeacountrycodes[. = $reportingmemberstate])" >
FIL-015  The authority key file attribute is invalid and should an EU or EEA country
        </xsl:if>

        <xsl:for-each select="AIFMRecordInfo">

            <xsl:variable name="manager" select="AIFMNationalCode" />
            <xsl:variable name="startdate" select="translate(ReportingPeriodStartDate,'-','')" />
            <xsl:variable name="year" select="substring($startdate,1,4)" />
            <xsl:variable name="month" select="substring($startdate,5,2)" />
            <xsl:variable name="day" select="substring($startdate,7,2)" />
            <xsl:variable name="periodtype" select="ReportingPeriodType" />
            <xsl:variable name="reportingyear" select="ReportingPeriodYear" />
            <xsl:choose>
                <xsl:when test="not($day='01') or not($year=$reportingyear)">
CAM-002 <xsl:value-of select="$manager"/> The reporting period start date is not allowed. 
                </xsl:when>
                <xsl:when test="$periodtype='Q1' or $periodtype='Q2' or $periodtype='Q3' or $periodtype='Q4'">
                    <xsl:if test="not($month='10' or $month='07' or $month='01')">
CAM-002 <xsl:value-of select="$manager"/> The reporting period start date is not allowed. 
                    </xsl:if>
                </xsl:when>
                <xsl:when test="$periodtype='H1' or $periodtype='H2'">
                    <xsl:if test="not($month='07' or $month='01')">
CAM-002 <xsl:value-of select="$manager"/> The reporting period start date is not allowed. 
                    </xsl:if>
                </xsl:when>
                <xsl:when test="$periodtype='Y1'">
                    <xsl:if test="not($month='01')">
CAM-002 <xsl:value-of select="$manager"/> The reporting period start date is not allowed. 
                    </xsl:if>
                </xsl:when>
            </xsl:choose>

            <xsl:variable name="enddate" select="translate(ReportingPeriodEndDate,'-','')" />
            <xsl:variable name="q1end" select="concat($year,'0331')" />
            <xsl:variable name="q2end" select="concat($year,'0630')" />
            <xsl:variable name="q3end" select="concat($year,'0930')" />
            <xsl:variable name="q4end" select="concat($year,'1231')" />
            <xsl:variable name="transition" select="LastReportingFlag='true'" />
            <xsl:choose>
                <xsl:when test="not($enddate&gt;$startdate)">    
CAM-003 <xsl:value-of select="$manager"/> The reporting period end date is not allowed
                </xsl:when>

                <xsl:when test="$periodtype='Q1'">
                    <xsl:if test="not($enddate=$q1end or ($transition and $enddate&lt;$q1end))">
CAM-003 <xsl:value-of select="$manager"/> The reporting period end date is not allowed
                    </xsl:if>
                </xsl:when>

                <xsl:when test="$periodtype='Q2' or $periodtype='H1'">
                    <xsl:if test="not($enddate=$q2end or ($transition and $enddate&lt;$q2end))">
CAM-003 <xsl:value-of select="$manager"/> The reporting period end date is not allowed
                    </xsl:if>
                </xsl:when>

                <xsl:when test="$periodtype='Q3'">
                    <xsl:if test="not($enddate=$q3end or ($transition and $enddate&lt;$q3end))">
CAM-003 <xsl:value-of select="$manager"/> The reporting period end date is not allowed
                    </xsl:if>
                </xsl:when>

                <xsl:when test="$periodtype='Q4' or $periodtype='H2' or $periodtype='Y1'">
                    <xsl:if test="not($enddate=$q4end or ($transition and $enddate&lt;$q4end))">
CAM-003 <xsl:value-of select="$manager"/> The reporting period end date is not allowed
                    </xsl:if>
                </xsl:when>
            </xsl:choose>

            <xsl:choose> 
                <xsl:when test="AIFMReportingObligationChangeFrequencyCode or AIFMReportingObligationChangeContentsCode"> 
                    <xsl:if test="not(AIFMReportingObligationChangeQuarter)">
CAM-004 <xsl:value-of select="$manager"/> The quarter for the AIMF reporting obligation change should be reported
                    </xsl:if>
                </xsl:when> 
                <xsl:otherwise> 
                    <xsl:if test="AIFMReportingObligationChangeQuarter">
CAM-004 <xsl:value-of select="$manager"/> The quarter for the AIMF reporting obligation change should be reported
                    </xsl:if>
                </xsl:otherwise> 
            </xsl:choose>

            <xsl:variable name ="jurisdiction" select="AIFMJurisdiction" />
            <xsl:if test="not($countrycodes[. = $jurisdiction])" >
CAM-005 <xsl:value-of select="$manager"/> The jurisdiction of the AIF is not correct.
            </xsl:if>

            <xsl:if test="not($aifmregister[. = $manager])" >
CAM-006 <xsl:value-of select="$manager"/> The AIFM national code does not exist in the ESMA Register.
            </xsl:if>

            <!-- <xsl:choose> 
                <xsl:when test = "AIFMNoReportingFlag = 'true' "> 
                    <xsl:if test="AIFMCompleteDescription">
ERROR 21.a <xsl:value-of select="$manager"/>
                    </xsl:if>
                </xsl:when> 
                <xsl:otherwise> 
                    <xsl:if test="not(AIFMCompleteDescription)">
ERROR 21.b <xsl:value-of select="$manager"/>
                    </xsl:if>
                </xsl:otherwise> 
            </xsl:choose> -->

            <xsl:variable name="state" select="AIFMCompleteDescription/AIFMIdentifier/OldAIFMIdentifierNCA/ReportingMemberState" />
            <xsl:if test="$state and not($countrycodes[. = $state])">
CAM-008 <xsl:value-of select="$manager"/> The country code exists in the reference table of countries
            </xsl:if>

            <xsl:if test="AIFMCompleteDescription/AIFMIdentifier/OldAIFMIdentifierNCA/ReportingMemberState" >
                <xsl:if test="not(AIFMCompleteDescription/AIFMIdentifier/OldAIFMIdentifierNCA/AIFMNationalCode)">
                <!-- This case is actually covered by schema, but included here for completeness -->
CAM-009 <xsl:value-of select="$manager"/> The field is mandatory when the  old AIFM national identifier - Reporting Member State is filled in.
                </xsl:if>
            </xsl:if>

            <xsl:for-each select="AIFMCompleteDescription/AIFMPrincipalMarkets/AIFMFivePrincipalMarket/MarketIdentification">
                <xsl:variable name="mic" select="MarketCode" />
                <xsl:choose> 
                    <xsl:when test="MarketCodeType = 'MIC'"> 
                       <xsl:if test="not($mic)">
CAM-010 <xsl:value-of select="$manager"/> The MIC code is not correct <xsl:value-of select="$mic"/>
                        </xsl:if>
                        
                        <xsl:if test="$mic and not($micregister[. = $mic])" >
CAM-010 <xsl:value-of select="$manager"/> The MIC code is not correct <xsl:value-of select="$mic"/>
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:if test="$mic">
CAM-010 <xsl:value-of select="$manager"/> The MIC code is not correct <xsl:value-of select="$mic"/>
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>

            <xsl:for-each select = "AIFMCompleteDescription/AIFMPrincipalMarkets/AIFMFivePrincipalMarket">
                <xsl:choose> 
                    <xsl:when test = "not(MarketIdentification/MarketCodeType = 'NOT')"> 
                        <xsl:if test="not(AggregatedValueAmount)">
CAM-011 <xsl:value-of select="$manager"/> The field is mandatory for market code type different from  “NOT”.
                        </xsl:if>
                    </xsl:when>
                </xsl:choose>
            </xsl:for-each>

            <xsl:for-each select = "AIFMCompleteDescription/AIFMPrincipalInstruments/AIFMPrincipalInstrument">
                <xsl:choose> 
                    <xsl:when test = "not(SubAssetType = 'NTA_NTA_NOTA')"> 
                        <xsl:if test="not(AggregatedValueAmount)">
CAM-013 <xsl:value-of select="$manager"/> The aggregated value is not consistent with the sub-asset type. 
                        </xsl:if>
                    </xsl:when>
                </xsl:choose>
            </xsl:for-each>

            <xsl:if test = "AIFMCompleteDescription/AIFMBaseCurrencyDescription/BaseCurrency and not(AIFMCompleteDescription/AIFMBaseCurrencyDescription/BaseCurrency = 'EUR')">
                <xsl:variable name="amountbase" select="AIFMCompleteDescription/AIFMBaseCurrencyDescription/AUMAmountInBaseCurrency" />
                <xsl:variable name="amounteuro" select="AIFMCompleteDescription/AUMAmountInEuro" />
                <xsl:variable name="rateeuro" select="AIFMCompleteDescription/AIFMBaseCurrencyDescription/FXEURRate"/>
                <xsl:variable name="result" select="$amounteuro * $rateeuro" />
                <xsl:if test="not($amountbase = $result)">
CAM-016 <xsl:value-of select="$manager"/> The total AuM amount in base currency is not consistent with the total AuM amount in Euro.
    <!-- given: <xsl:value-of select="$amountbase" />  
    calculated: <xsl:value-of select="$amounteuro" /> * <xsl:value-of select="$rateeuro" /> = <xsl:value-of select="$result" /> -->
                </xsl:if>
            </xsl:if>

            <xsl:variable name="currency" select="AIFMCompleteDescription/AIFMBaseCurrencyDescription/BaseCurrency" />
            <xsl:if test="$currency and not($currencycodes[. = $currency])">
CAM-017 <xsl:value-of select="$manager"/> The currency code exists in the reference table of countries
            </xsl:if>

            <xsl:for-each select = "AIFMCompleteDescription/AIFMBaseCurrencyDescription">
                <xsl:choose> 
                    <xsl:when test = "BaseCurrency = 'EUR'"> 
                        <xsl:if test="FXEURReferenceRateType">
ERROR 36.a <xsl:value-of select="$manager"/>
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:if test="not(FXEURReferenceRateType)">
ERROR 36.b <xsl:value-of select="$manager"/>
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>

            <xsl:for-each select = "AIFMCompleteDescription/AIFMBaseCurrencyDescription">
                <xsl:choose> 
                    <xsl:when test = "BaseCurrency = 'EUR'"> 
                        <xsl:if test="FXEURRate">
ERROR 37.a <xsl:value-of select="$manager"/>
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:if test="not(FXEURRate)">
ERROR 37.b <xsl:value-of select="$manager"/>
                        </xsl:if>   
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>

            <xsl:for-each select = "AIFMCompleteDescription/AIFMBaseCurrencyDescription">
                <xsl:choose> 
                    <xsl:when test = "BaseCurrency = 'EUR' and FXEURReferenceRateType = 'OTH'"> 
                        <xsl:if test="not(FXEUROtherReferenceRateDescription)">
CAM-020 <xsl:value-of select="$manager"/> The reference rate description is not consistent with the reference rate type.
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:if test="FXEUROtherReferenceRateDescription">
CAM-020 <xsl:value-of select="$manager"/> The reference rate description is not consistent with the reference rate type.
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>

        </xsl:for-each>
        <xsl:text>&#xA;</xsl:text>
    </xsl:template>

</xsl:stylesheet>

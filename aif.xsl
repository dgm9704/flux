<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <xsl:output method="text" />

    <xsl:template match="AIFReportingInfo">

        <xsl:variable name="reportingmemberstate" select="@ReportingMemberState" />
        <xsl:if test="not($eeacountrycodes[. = $reportingmemberstate])" >
FIL-015  The authority key file attribute is invalid and should an EU or EEA country
        </xsl:if>

        <xsl:for-each select = "AIFRecordInfo">

            <xsl:variable name="fund" select="AIFNationalCode" />

            <xsl:if test="AIFNoReportingFlag = 'false'"> 
                <xsl:if test="AIFContentType = '2' or AIFContentType = '4'">
                    <xsl:if test="not(AIFCompleteDescription/AIFIndividualInfo)">
CAF-002 <xsl:value-of select="$fund" /> The reported AIF information does not correspond to the AIF content type.
                    </xsl:if>
                </xsl:if>

                <xsl:if test="AIFContentType = '2' or AIFContentType = '4'">
                    <xsl:if test="not(AIFCompleteDescription/AIFLeverageInfo/AIFLeverageArticle24-2)">
CAF-002 <xsl:value-of select="$fund" /> The reported AIF information does not correspond to the AIF content type.
                    </xsl:if>
                </xsl:if>

                <xsl:if test="AIFContentType = '4' or AIFContentType = '5'">
                    <xsl:if test="not(AIFCompleteDescription/AIFLeverageInfo/AIFLeverageArticle24-4)">
CAF-002 <xsl:value-of select="$fund" /> The reported AIF information does not correspond to the AIF content type.
                    </xsl:if>
                </xsl:if>
            </xsl:if> 

            <xsl:variable name="startdate" select="translate(ReportingPeriodStartDate,'-','')" />
            <xsl:variable name="year" select="substring($startdate,1,4)" />
            <xsl:variable name="month" select="substring($startdate,5,2)" />
            <xsl:variable name="day" select="substring($startdate,7,2)" />
            <xsl:variable name="periodtype" select="ReportingPeriodType" />
            <xsl:variable name="reportingyear" select="ReportingPeriodYear" />
            <xsl:choose>
                <xsl:when test="not($day='01') or not($year=$reportingyear)">
CAF-003 <xsl:value-of select="$fund"/> The reporting period start date is not allowed. 
                </xsl:when>
                <xsl:when test="$periodtype='Q1' or $periodtype='Q2' or $periodtype='Q3' or $periodtype='Q4'">
                    <xsl:if test="not($month='10' or $month='07' or $month='01')">
CAF-003 <xsl:value-of select="$fund"/> The reporting period start date is not allowed. 
                    </xsl:if>
                </xsl:when>
                <xsl:when test="$periodtype='H1' or $periodtype='H2'">
                    <xsl:if test="not($month='07' or $month='01')">
CAF-003 <xsl:value-of select="$fund"/> The reporting period start date is not allowed. 
                    </xsl:if>
                </xsl:when>
                <xsl:when test="$periodtype='Y1'">
                    <xsl:if test="not($month='01')">
CAF-003 <xsl:value-of select="$fund"/> The reporting period start date is not allowed. 
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
CAF-004 <xsl:value-of select="$fund"/> The reporting period end date is not allowed
                </xsl:when>

                <xsl:when test="$periodtype='Q1'">
                    <xsl:if test="not($enddate=$q1end or ($transition and $enddate&lt;$q1end))">
CAF-004 <xsl:value-of select="$fund"/> The reporting period end date is not allowed
                    </xsl:if>
                </xsl:when>

                <xsl:when test="$periodtype='Q2' or $periodtype='H1'">
                    <xsl:if test="not($enddate=$q2end or ($transition and $enddate&lt;$q2end))">
CAF-004 <xsl:value-of select="$fund"/> The reporting period end date is not allowed
                    </xsl:if>
                </xsl:when>

                <xsl:when test="$periodtype='Q3'">
                    <xsl:if test="not($enddate=$q3end or ($transition and $enddate&lt;$q3end))">
CAF-004 <xsl:value-of select="$fund"/> The reporting period end date is not allowed
                    </xsl:if>
                </xsl:when>

                <xsl:when test="$periodtype='Q4' or $periodtype='H2' or $periodtype='Y1'">
                    <xsl:if test="not($enddate=$q4end or ($transition and $enddate&lt;$q4end))">
CAF-004 <xsl:value-of select="$fund"/> The reporting period end date is not allowed
                    </xsl:if>
                </xsl:when>
            </xsl:choose>

            <xsl:choose> 
                <xsl:when test="AIFReportingObligationChangeFrequencyCode or AIFReportingObligationChangeContentsCode"> 
                    <xsl:if test="not(AIFReportingObligationChangeQuarter)">
CAF-006 <xsl:value-of select="$fund"/> The quarter for the AIF reporting obligation change should be reported
                    </xsl:if>
                </xsl:when> 
                <xsl:otherwise>
                    <xsl:if test="AIFReportingObligationChangeQuarter">
CAF-006 <xsl:value-of select="$fund"/> The quarter for the AIF reporting obligation change should be reported
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>

            <xsl:variable name="manager" select="AIFMNationalCode" />
            <xsl:if test="not($aifmregister[. = $manager])" >
CAF-007 <xsl:value-of select="$manager"/> The AIFM national code does not exist in the ESMA Register.
            </xsl:if>

            <xsl:if test="not($aifregister[. = $fund])" >
CAF-008 <xsl:value-of select="$fund"/> The AIF national code does not exist in the ESMA Register.
            </xsl:if>

            <xsl:variable name="eeaflag" select="boolean(AIFEEAFlag='true')" />
            <xsl:variable name="domicile" select="AIFDomicile" />
            <xsl:variable name="iseea" select="boolean($eeacountrycodes[.=$domicile])" />
            <xsl:choose>
                <xsl:when test="$eeaflag">
                    <xsl:if test="not($iseea)">
CAF-009 <xsl:value-of select="$fund"/> The EEA flag is not correct.
                    </xsl:if>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:if test="$iseea">
CAF-009 <xsl:value-of select="$fund"/> The EEA flag is not correct.
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>

            <xsl:if test="not($countrycodes[. = $domicile])" >
CAF-010 <xsl:value-of select="$fund"/> The domicile of the AIF is not correct.
            </xsl:if>

            <xsl:variable name="inceptiondate" select="translate(InceptionDate,'-','')" />
            <xsl:if test="not($inceptiondate &lt; $startdate)">
CAF-011 <xsl:value-of select="$fund"/> The inception date is not allowed as it should be before the reporting start date
            </xsl:if>            

            <xsl:choose> 
                <xsl:when test="AIFNoReportingFlag = 'true'"> 
                    <xsl:if test="AIFCompleteDescription">
CAF-012 <xsl:value-of select="$fund"/> The AIF no reporting flag is not consistent with the reported information.
                    </xsl:if>
                </xsl:when> 
                <xsl:otherwise>
                    <xsl:if test="not(AIFCompleteDescription)">
CAF-012 <xsl:value-of select="$fund"/> The AIF no reporting flag is not consistent with the reported information.
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>

            <xsl:variable name="lei" select="AIFCompleteDescription/AIFPrincipalInfo/AIFIdentification/AIFIdentifierLEI" />
            <xsl:if test="$lei and not($leiregister[. = $lei])" >
CAF-013 <xsl:value-of select="$fund"/> The check digits of the LEI code are not correct.
            </xsl:if>

            <xsl:for-each select="AIFCompleteDescription/AIFPrincipalInfo/MainInstrumentsTraded/MainInstrumentTraded/ISINInstrumentIdentification">
                <xsl:variable name="isin" select="." />
                <!-- <xsl:value-of select="$isin"/>:
                <xsl:variable name="c1" select="substring($isin,1,1)" />
                <xsl:variable name="v1" select="$substitution[char=$c1]/num" /><xsl:value-of select="$c1"/>-><xsl:value-of select="$v1"/>,

                <xsl:variable name="c2" select="substring($isin,2,1)" />
                <xsl:variable name="v2" select="$substitution[char=$c2]/num" /><xsl:value-of select="$c2"/>-><xsl:value-of select="$v2"/>,

                <xsl:variable name="c3" select="substring($isin,3,1)" />
                <xsl:variable name="v3" select="$substitution[char=$c3]/num" /><xsl:value-of select="$c3"/>-><xsl:value-of select="$v3"/>,

                <xsl:variable name="c4" select="substring($isin,4,1)" />
                <xsl:variable name="v4" select="$substitution[char=$c4]/num" /><xsl:value-of select="$c4"/>-><xsl:value-of select="$v4"/>,

                <xsl:variable name="c5" select="substring($isin,5,1)" />
                <xsl:variable name="v5" select="$substitution[char=$c5]/num" /><xsl:value-of select="$c5"/>-><xsl:value-of select="$v5"/>,

                <xsl:variable name="c6" select="substring($isin,6,1)" />
                <xsl:variable name="v6" select="$substitution[char=$c6]/num" /><xsl:value-of select="$c6"/>-><xsl:value-of select="$v6"/>,

                <xsl:variable name="c7" select="substring($isin,7,1)" />
                <xsl:variable name="v7" select="$substitution[char=$c7]/num" /><xsl:value-of select="$c7"/>-><xsl:value-of select="$v7"/>,

                <xsl:variable name="c8" select="substring($isin,8,1)" />
                <xsl:variable name="v8" select="$substitution[char=$c8]/num" /><xsl:value-of select="$c8"/>-><xsl:value-of select="$v8"/>,

                <xsl:variable name="c9" select="substring($isin,9,1)" />
                <xsl:variable name="v9" select="$substitution[char=$c9]/num" /><xsl:value-of select="$c9"/>-><xsl:value-of select="$v9"/>,

                <xsl:variable name="c10" select="substring($isin,10,1)" />
                <xsl:variable name="v10" select="$substitution[char=$c10]/num" /><xsl:value-of select="$c10"/>-><xsl:value-of select="$v10"/>,

                <xsl:variable name="c11" select="substring($isin,11,1)" />
                <xsl:variable name="v11" select="$substitution[char=$c11]/num" /><xsl:value-of select="$c11"/>-><xsl:value-of select="$v11"/>, -->
                <xsl:if test="$isin and not($isinregister[. = $isin])" >
CAF-014 <xsl:value-of select="$fund"/> The check digit of the ISIN code is not correct.
                </xsl:if>
            </xsl:for-each>

        <xsl:for-each select="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/MasterAIFsIdentification/MasterAIFIdentification/AIFIdentifierNCA/ReportingMemberState">
            <xsl:variable name="aifmemberstate" select="." />
            <xsl:if test="not($eeacountrycodes[. = $aifmemberstate])" >
CAF-015 <xsl:value-of select="$fund"/> The country of the old AIF national code is not correct and should be an EEA or EU country.
            </xsl:if>
        </xsl:for-each>

            <xsl:if test="AIFCompleteDescription/AIFPrincipalInfo/ShareClassFlag = 'false'"> 
                <xsl:if test="AIFCompleteDescription/AIFPrincipalInfo/ShareClassIdentification/ShareClassIdentifier/ShareClassNationalCode">
CAF-016 <xsl:value-of select="$fund"/> The share class national code is not consistent with the share class flag.
                </xsl:if>
            </xsl:if>

            <xsl:for-each select="AIFCompleteDescription/AIFPrincipalInfo/ShareClassIdentification/ShareClassIdentifier/ShareClassIdentifierISIN">
                <xsl:variable name="isin" select="." />
                <xsl:if test="$isin and not($isinregister[. = $isin])" >
CAF-017 <xsl:value-of select="$fund"/> The check digit of the ISIN code is not correct.
                </xsl:if>
            </xsl:for-each>


            <xsl:if test="AIFCompleteDescription/AIFPrincipalInfo/ShareClassFlag = 'false'"> 
                <xsl:if test="AIFCompleteDescription/AIFPrincipalInfo/ShareClassIdentification/ShareClassIdentifier/ShareClassIdentifierISIN">
    CAF-018
                </xsl:if>
            </xsl:if>

            <xsl:if test="AIFCompleteDescription/AIFPrincipalInfo/ShareClassFlag = 'false'"> 
                <xsl:if test="AIFCompleteDescription/AIFPrincipalInfo/ShareClassIdentification/ShareClassIdentifier/ShareClassIdentifierCUSIP">
    CAF-019
                </xsl:if>
            </xsl:if> 

            <xsl:if test="AIFCompleteDescription/AIFPrincipalInfo/ShareClassFlag = 'false'"> 
                <xsl:if test="AIFCompleteDescription/AIFPrincipalInfo/ShareClassIdentification/ShareClassIdentifier/ShareClassIdentifierSEDOL">
    CAF-020
                </xsl:if>
            </xsl:if> 

            <xsl:if test="AIFCompleteDescription/AIFPrincipalInfo/ShareClassFlag = 'false'"> 
                <xsl:if test="AIFCompleteDescription/AIFPrincipalInfo/ShareClassIdentification/ShareClassIdentifier/ShareClassIdentifierTicker">
    CAF-021
                </xsl:if>
            </xsl:if> 

            <xsl:if test="AIFCompleteDescription/AIFPrincipalInfo/ShareClassFlag = 'false'"> 
                <xsl:if test="AIFCompleteDescription/AIFPrincipalInfo/ShareClassIdentification/ShareClassIdentifier/ShareClassIdentifierRIC">
    CAF-022
                </xsl:if>
            </xsl:if> 

            <xsl:choose> 
                <xsl:when test="AIFCompleteDescription/AIFPrincipalInfo/ShareClassFlag = 'true'"> 
                    <xsl:if test="not(AIFCompleteDescription/AIFPrincipalInfo/ShareClassIdentification/ShareClassIdentifier/ShareClassName)">
    CAF-023
                    </xsl:if>
                </xsl:when> 
                <xsl:otherwise> 
                    <xsl:if test="AIFCompleteDescription/AIFPrincipalInfo/ShareClassIdentification/ShareClassIdentifier/ShareClassName">
    CAF-023
                    </xsl:if>
                </xsl:otherwise> 
            </xsl:choose>

            <xsl:choose> 
                <xsl:when test="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/AIFMasterFeederStatus = 'FEEDER'"> 
                    <xsl:if test="not(AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/MasterAIFsIdentification/MasterAIFIdentification/AIFName)">
    CAF-024
                    </xsl:if>
                </xsl:when> 
                <xsl:otherwise> 
                    <xsl:if test="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/MasterAIFsIdentification/MasterAIFIdentification/AIFName">
    CAF-024
                    </xsl:if>
                </xsl:otherwise> 
            </xsl:choose>

            <xsl:if test="not(AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/AIFMasterFeederStatus = 'FEEDER')"> 
                <xsl:if test="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/MasterAIFsIdentification/MasterAIFIdentification/AIFIdentifierNCA/ReportingMemberState">
    CAF-026
                </xsl:if>
            </xsl:if> 

            <xsl:choose> 
                <xsl:when test="AIFNoReportingFlag = 'false' and not(AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/AIFBaseCurrencyDescription/BaseCurrency = 'EUR')"> 
                    <xsl:if test="not(AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/AIFBaseCurrencyDescription/FXEURRate)">
    CAF-030
                    </xsl:if>
                </xsl:when> 
                <xsl:otherwise> 
                    <xsl:if test="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/AIFBaseCurrencyDescription/FXEURRate">
    CAF-030
                    </xsl:if>
                </xsl:otherwise> 
            </xsl:choose>

            <xsl:choose> 
                <xsl:when test="AIFNoReportingFlag = 'false' and not(AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/AIFBaseCurrencyDescription/BaseCurrency = 'EUR')"> 
                    <xsl:if test="not(AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/AIFBaseCurrencyDescription/FXEURReferenceRateType)">
    CAF-031
                    </xsl:if>
                </xsl:when> 
                <xsl:otherwise> 
                    <xsl:if test="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/AIFBaseCurrencyDescription/FXEURReferenceRateType">
    CAF-031
                    </xsl:if>
                </xsl:otherwise> 
            </xsl:choose>

            <xsl:choose> 
                <xsl:when test="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/AIFBaseCurrencyDescription/FXEURReferenceRateType = 'OTH'"> 
                    <xsl:if test="not(AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/AIFBaseCurrencyDescription/FXEUROtherReferenceRateDescription)">
    CAF-032
                    </xsl:if>
                </xsl:when> 
                <xsl:otherwise> 
                    <xsl:if test="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/AIFBaseCurrencyDescription/FXEUROtherReferenceRateDescription">
    CAF-032
                    </xsl:if>
                </xsl:otherwise> 
            </xsl:choose>

            <xsl:if test="not(AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/PredominantAIFType = 'NONE')"> 
                <xsl:variable 
                    name="count" 
                    select="count(AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/HedgeFundInvestmentStrategies 
                                | AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/RealEstateFundInvestmentStrategies
                                | AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/PrivateEquityFundInvestmentStrategies
                                | AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/FundOfFundsInvestmentStrategies
                                | AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/OtherFundInvestmentStrategies) "/>
                <xsl:if test="$count &gt; 1">
    ERROR 58.a
                </xsl:if>
            </xsl:if>

            <xsl:if test="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/HedgeFundInvestmentStrategies/HedgeFundStrategy/HedgeFundStrategyType = 'MULT_HFND'"> 
                <xsl:variable name="count" select="count(AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/HedgeFundInvestmentStrategies/HedgeFundStrategy/HedgeFundStrategyType[.!='MULT_HFND'])"/>
                <xsl:if test="$count &lt; 2">
    ERROR 58.b
                </xsl:if>
            </xsl:if> 

            <xsl:if test="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/PrivateEquityFundInvestmentStrategies/PrivateEquityFundInvestmentStrategy/PrivateEquityFundStrategyType = 'MULT_PEQF'"> 
                <xsl:variable name="count" select="count(AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/PrivateEquityFundInvestmentStrategies/PrivateEquityFundInvestmentStrategy/PrivateEquityFundStrategyType[.!='MULT_PEQF'])"/>
                <xsl:if test="$count &lt; 2">
    ERROR 58.c
                </xsl:if>
            </xsl:if> 

            <xsl:if test="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/RealEstateFundInvestmentStrategies/RealEstateFundStrategy/RealEstateFundStrategyType = 'MULT_REST'"> 
                <xsl:variable name="count" select="count(AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/RealEstateFundInvestmentStrategies/RealEstateFundStrategy/RealEstateFundStrategyType[.!='MULT_REST'])"/>
                <xsl:if test="$count &lt; 2">
    ERROR 58.d
                </xsl:if>
            </xsl:if> 

            <xsl:if test="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/PrivateEquityFundInvestmentStrategies/PrivateEquityFundInvestmentStrategy[PrivateEquityFundStrategyType = 'MULT_PEQF' and not(PrimaryStrategyFlag = 'true')]"> 
    CAF-038
            </xsl:if>

            <xsl:if test="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/HedgeFundInvestmentStrategies/HedgeFundStrategy[HedgeFundStrategyType = 'MULT_HFND' and not(PrimaryStrategyFlag = 'true')]"> 
    CAF-038
            </xsl:if>

            <xsl:if test="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/RealEstateFundInvestmentStrategies/RealEstateFundStrategy[RealEstateFundStrategyType = 'MULT_REST' and not(PrimaryStrategyFlag = 'true')]"> 
    CAF-038
            </xsl:if>

            <xsl:variable 
            name="hstrategies" 
            select="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/HedgeFundInvestmentStrategies/HedgeFundStrategy[not(HedgeFundStrategyType = 'MULT_HFND')] " />
            <xsl:if test="$hstrategies">
                <xsl:for-each select="$hstrategies">
                    <xsl:if test="not(StrategyNAVRate)">
    ERROR 60.a.I
                    </xsl:if>
                </xsl:for-each>
                <xsl:if test="not(sum($hstrategies/StrategyNAVRate) = 100)">
    ERROR 60.a.II
                </xsl:if>
            </xsl:if>

            <xsl:variable 
            name="pstrategies" 
            select="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/PrivateEquityFundInvestmentStrategies/PrivateEquityFundInvestmentStrategy[not(PrivateEquityFundStrategyType = 'MULT_PEQF')] " />
            <xsl:if test="$pstrategies">
                <xsl:for-each select="$pstrategies">
                    <xsl:if test="not(StrategyNAVRate)">
    ERROR 60.b.I
                    </xsl:if>
                </xsl:for-each>
                <xsl:if test="not(sum($pstrategies/StrategyNAVRate) = 100)">
    CAF-039
                </xsl:if>
            </xsl:if>

            <xsl:variable 
            name="rstrategies" 
            select="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/RealEstateFundInvestmentStrategies/RealEstateFundStrategy[not(RealEstateFundStrategyType = 'MULT_REST')] " />
            <xsl:if test="$rstrategies">
                <xsl:for-each select="$rstrategies">
                    <xsl:if test="not(StrategyNAVRate)">
    ERROR 60.c.I
                    </xsl:if>
                </xsl:for-each>
                <xsl:if test="not(sum($rstrategies/StrategyNAVRate) = 100)">
    CAF-039
                </xsl:if>
            </xsl:if>

            <xsl:variable 
            name="fstrategies" 
            select="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/FundOfFundsInvestmentStrategies/FundOfFundsStrategy" />
            <xsl:if test="$fstrategies">
                <xsl:for-each select="$fstrategies">
                    <xsl:if test="not(StrategyNAVRate)">
    ERROR 60.d.I
                    </xsl:if>
                </xsl:for-each>
                <xsl:if test="not(sum($fstrategies/StrategyNAVRate) = 100)">
    CAF-039
                </xsl:if>
            </xsl:if>

            <xsl:variable 
            name="ostrategies" 
            select="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/OtherFundInvestmentStrategies/OtherFundStrategy" />
            <xsl:if test="$ostrategies">
                <xsl:for-each select="$ostrategies">
                    <xsl:if test="not(StrategyNAVRate)">
    ERROR 60.e.I
                    </xsl:if>
                </xsl:for-each>
                <xsl:if test="not(sum($ostrategies/StrategyNAVRate) = 100)">
    CAF-039
                </xsl:if>
            </xsl:if>

            <xsl:for-each select="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/HedgeFundInvestmentStrategies/HedgeFundStrategy">
                <xsl:choose>
                    <xsl:when test="HedgeFundStrategyType = 'OTHR_HFND'">
                        <xsl:if test="not(StrategyTypeOtherDescription)">
    CAF-041
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:if test="StrategyTypeOtherDescription">
    ERROR 61.a.II
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>

            <xsl:for-each select="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/PrivateEquityFundInvestmentStrategies/PrivateEquityFundInvestmentStrategy">
                <xsl:choose>
                    <xsl:when test="PrivateEquityFundStrategyType = 'OTHR_PEQF'">
                        <xsl:if test="not(StrategyTypeOtherDescription)">
    CAF-041
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:if test="StrategyTypeOtherDescription">
    ERROR 61.b.II
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>

            <xsl:for-each select="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/RealEstateFundInvestmentStrategies/RealEstateFundStrategy">
                <xsl:choose>
                    <xsl:when test="RealEstateFundStrategyType = 'OTHR_REST'">
                        <xsl:if test="not(StrategyTypeOtherDescription)">
    CAF-041
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:if test="StrategyTypeOtherDescription">
    ERROR 61.c.II
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>

            <xsl:for-each select="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/FundOfFundsInvestmentStrategies/FundOfFundsStrategy">
                <xsl:choose>
                    <xsl:when test="FundOfFundsStrategyType = 'OTHR_FOFS'">
                        <xsl:if test="not(StrategyTypeOtherDescription)">
    CAF-041
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:if test="StrategyTypeOtherDescription">
    ERROR 61.d.II
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>

            <xsl:for-each select="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/OtherFundInvestmentStrategies/OtherFundStrategy">
                <xsl:choose>
                    <xsl:when test="OtherFundStrategyType = 'OTHR_OTHF'">
                        <xsl:if test="not(StrategyTypeOtherDescription)">
    CAF-041
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:if test="StrategyTypeOtherDescription">
    ERROR 61.e.II
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>

            <xsl:variable 
            name="instrumentranks" 
            select="AIFCompleteDescription/AIFPrincipalInfo/MainInstrumentsTraded/MainInstrumentTraded/Ranking" />
            <xsl:if test="$instrumentranks and not($instrumentranks[.='1'] and $instrumentranks[.='2'] and $instrumentranks[.='3'] and $instrumentranks[.='4'] and $instrumentranks[.='5'])">
    ERROR 64
                <xsl:for-each select="$instrumentranks">
                    <xsl:value-of select="." />
                </xsl:for-each>
            </xsl:if>

            <xsl:for-each select="AIFCompleteDescription/AIFPrincipalInfo/MainInstrumentsTraded/MainInstrumentTraded">
                <xsl:choose>
                    <xsl:when test="not(SubAssetType = 'NTA_NTA_NOTA')">
                        <xsl:if test="not(InstrumentCodeType)">
    CAF-042
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:if test="InstrumentCodeType">
    CAF-042
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>

            <xsl:for-each select="AIFCompleteDescription/AIFPrincipalInfo/MainInstrumentsTraded/MainInstrumentTraded">
                <xsl:choose>
                    <xsl:when test="not(SubAssetType = 'NTA_NTA_NOTA')">
                        <xsl:if test="not(InstrumentName)">
    CAF-043
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:if test="InstrumentName">
    CAF-043
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>

            <xsl:for-each select="AIFCompleteDescription/AIFPrincipalInfo/MainInstrumentsTraded/MainInstrumentTraded">
                <xsl:choose>
                    <xsl:when test="InstrumentCodeType = 'ISIN'">
                        <xsl:if test="not(ISINInstrumentIdentification)">
    CAF-045
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:if test="ISINInstrumentIdentification">
    CAF-045
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>

            <xsl:for-each select="AIFCompleteDescription/AIFPrincipalInfo/MainInstrumentsTraded/MainInstrumentTraded">
                <xsl:choose>
                    <xsl:when test="InstrumentCodeType = 'AII'">
                        <xsl:if test="not(AIIInstrumentIdentification/AIIExchangeCode)">
    CAF-047
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:if test="AIIInstrumentIdentification/AIIExchangeCode">
    CAF-047
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>

            <xsl:for-each select="AIFCompleteDescription/AIFPrincipalInfo/MainInstrumentsTraded/MainInstrumentTraded">
                <xsl:choose>
                    <xsl:when test="InstrumentCodeType = 'AII'">
                        <xsl:if test="not(AIIInstrumentIdentification/AIIProductCode)">
    CAF-048
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:if test="AIIInstrumentIdentification/AIIProductCode">
    CAF-048
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>


            <xsl:for-each select="AIFCompleteDescription/AIFPrincipalInfo/MainInstrumentsTraded/MainInstrumentTraded">
                <xsl:choose>
                    <xsl:when test="InstrumentCodeType = 'AII'">
                        <xsl:if test="not(AIIInstrumentIdentification/AIIDerivativeType)">
    CAF-049
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:if test="AIIInstrumentIdentification/AIIDerivativeType">
    CAF-049
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>

            <xsl:for-each select="AIFCompleteDescription/AIFPrincipalInfo/MainInstrumentsTraded/MainInstrumentTraded">
                <xsl:choose>
                    <xsl:when test="InstrumentCodeType = 'AII'">
                        <xsl:if test="not(AIIInstrumentIdentification/AIIPutCallIdentifier)">
    CAF-050
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:if test="AIIInstrumentIdentification/AIIPutCallIdentifier">
    CAF-050
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>

            <xsl:for-each select="AIFCompleteDescription/AIFPrincipalInfo/MainInstrumentsTraded/MainInstrumentTraded">
                <xsl:choose>
                    <xsl:when test="InstrumentCodeType = 'AII'">
                        <xsl:if test="not(AIIInstrumentIdentification/AIIExpiryDate)">
    CAF-051
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:if test="AIIInstrumentIdentification/AIIExpiryDate">
    CAF-051
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>

            <xsl:for-each select="AIFCompleteDescription/AIFPrincipalInfo/MainInstrumentsTraded/MainInstrumentTraded">
                <xsl:choose>
                    <xsl:when test="InstrumentCodeType = 'AII'">
                        <xsl:if test="not(AIIInstrumentIdentification/AIIStrikePrice)">
    CAF-052
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:if test="AIIInstrumentIdentification/AIIStrikePrice">
    CAF-052
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>

            <xsl:for-each select="AIFCompleteDescription/AIFPrincipalInfo/MainInstrumentsTraded/MainInstrumentTraded">
                <xsl:choose>
                    <xsl:when test="not(SubAssetType = 'NTA_NTA_NOTA')">
                        <xsl:if test="not(PositionType)">
    CAF-053
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:if test="PositionType">
    CAF-053
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>

            <xsl:for-each select="AIFCompleteDescription/AIFPrincipalInfo/MainInstrumentsTraded/MainInstrumentTraded">
                <xsl:choose>
                    <xsl:when test="not(SubAssetType = 'NTA_NTA_NOTA')">
                        <xsl:if test="not(PositionValue)">
    CAF-054
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:if test="PositionValue">
    CAF-054
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>

            <xsl:for-each select="AIFCompleteDescription/AIFPrincipalInfo/MainInstrumentsTraded/MainInstrumentTraded">
                <xsl:if test="not(PositionType = 'S')">
                    <xsl:if test="ShortPositionHedgingRate">
    CAF-056
                    </xsl:if>
                </xsl:if>
            </xsl:for-each>

            <xsl:variable 
            name="navregions" 
            select="AIFCompleteDescription/AIFPrincipalInfo/NAVGeographicalFocus/*" />
            <xsl:if test="$navregions">
                <xsl:if test="not(sum($navregions) = 100)">
    CAF-057
                </xsl:if>
            </xsl:if>

            <xsl:variable 
            name="aumregions" 
            select="AIFCompleteDescription/AIFPrincipalInfo/AUMGeographicalFocus/*" />
            <xsl:if test="$aumregions">
                <xsl:if test="not(sum($aumregions) = 100)">
    CAF-058
                </xsl:if>
            </xsl:if>

            <xsl:variable 
            name="exposureranks" 
            select="AIFCompleteDescription/AIFPrincipalInfo/PrincipalExposures/PrincipalExposure/Ranking" />
            <xsl:if test="$exposureranks and not($exposureranks[.='1'] and $exposureranks[.='2'] and $exposureranks[.='3'] and $exposureranks[.='4'] and $exposureranks[.='5'] and $exposureranks[.='6'] and $exposureranks[.='7'] and $exposureranks[.='8'] and $exposureranks[.='9'] and $exposureranks[.='10'])">
    ERROR 94
            </xsl:if>

            <xsl:for-each select="AIFCompleteDescription/AIFPrincipalInfo/PrincipalExposures/PrincipalExposure">
                <xsl:choose>
                    <xsl:when test="not(AssetMacroType = 'NTA')">
                        <xsl:if test="not(SubAssetType)">
    CAF-059
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:if test="SubAssetType">
    CAF-059
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>

            <xsl:for-each select="AIFCompleteDescription/AIFPrincipalInfo/PrincipalExposures/PrincipalExposure">
                <xsl:choose>
                    <xsl:when test="not(AssetMacroType = 'NTA')">
                        <xsl:if test="not(PositionType)">
    CAF-060
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:if test="PositionType">
    CAF-060
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>

            <xsl:for-each select="AIFCompleteDescription/AIFPrincipalInfo/PrincipalExposures/PrincipalExposure">
                <xsl:choose>
                    <xsl:when test="not(AssetMacroType = 'NTA')">
                        <xsl:if test="not(AggregatedValueAmount)">
    CAF-061
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:if test="AggregatedValueAmount">
    CAF-061
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>

            <xsl:for-each select="AIFCompleteDescription/AIFPrincipalInfo/PrincipalExposures/PrincipalExposure">
                <xsl:choose>
                    <xsl:when test="not(AssetMacroType = 'NTA')">
                        <xsl:if test="not(AggregatedValueRate)">
    CAF-063
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:if test="AggregatedValueRate">
    CAF-063
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>

            <xsl:variable 
            name="ranks" 
            select="AIFCompleteDescription/AIFPrincipalInfo/MostImportantConcentration/PortfolioConcentrations/PortfolioConcentration/Ranking" />
            <xsl:if test="$ranks and not($ranks[.='1'] and $ranks[.='2'] and $ranks[.='3'] and $ranks[.='4'] and $ranks[.='5'])">
    ERROR 103
            </xsl:if>

            <xsl:for-each select="AIFCompleteDescription/AIFPrincipalInfo/MostImportantConcentration/PortfolioConcentrations/PortfolioConcentration">
                <xsl:choose>
                    <xsl:when test="not(AssetType = 'NTA_NTA')">
                        <xsl:if test="not(PositionType)">
    CAF-067
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:if test="PositionType">
    CAF-067
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>

            <xsl:for-each select="AIFCompleteDescription/AIFPrincipalInfo/MostImportantConcentration/PortfolioConcentrations/PortfolioConcentration">
                <xsl:choose>
                    <xsl:when test="not(AssetType = 'NTA_NTA')">
                        <xsl:if test="not(MarketIdentification/MarketCodeType)">
    CAF-068
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:if test="MarketIdentification/MarketCodeType">
    CAF-068
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>

            <xsl:for-each select="AIFCompleteDescription/AIFPrincipalInfo/MostImportantConcentration/PortfolioConcentrations/PortfolioConcentration/MarketIdentification">
                <xsl:choose>
                    <xsl:when test="MarketCodeType = 'MIC'">
                        <xsl:if test="not(MarketCode)">
    CAF-070
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:if test="MarketCode">
    CAF-070
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>

            <xsl:for-each select="AIFCompleteDescription/AIFPrincipalInfo/MostImportantConcentration/PortfolioConcentrations/PortfolioConcentration">
                <xsl:choose>
                    <xsl:when test="not(AssetType = 'NTA_NTA')">
                        <xsl:if test="not(AggregatedValueAmount)">
    CAF-071
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:if test="AggregatedValueAmount">
    CAF-071
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>

            <xsl:for-each select="AIFCompleteDescription/AIFPrincipalInfo/MostImportantConcentration/PortfolioConcentrations/PortfolioConcentration">
                <xsl:choose>
                    <xsl:when test="not(AssetType = 'NTA_NTA')">
                        <xsl:if test="not(AggregatedValueRate)">
    CAF-073
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:if test="AggregatedValueRate">
    CAF-073
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>

            <xsl:for-each select="AIFCompleteDescription/AIFPrincipalInfo/MostImportantConcentration/PortfolioConcentrations/PortfolioConcentration">
                <xsl:if test="not(MarketIdentification/MarketCodeType = 'OTC')">
                    <xsl:if test="CounterpartyIdentification/EntityName">
    ERROR 110_112
                    </xsl:if>
                </xsl:if>
            </xsl:for-each>

        </xsl:for-each>
        <xsl:text>&#xA;</xsl:text>

    </xsl:template>

</xsl:stylesheet>

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
        </xsl:for-each>

        <xsl:for-each select = "AIFRecordInfo">
            <xsl:choose> 
                <xsl:when test="AIFReportingObligationChangeFrequencyCode or AIFReportingObligationChangeContentsCode"> 
                    <xsl:if test="not(AIFReportingObligationChangeQuarter)">
CAF-006
                    </xsl:if>
                </xsl:when> 
                <xsl:otherwise>
                    <xsl:if test="AIFReportingObligationChangeQuarter">
CAF-006
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>

        <xsl:for-each select = "AIFRecordInfo">
            <xsl:choose> 
                <xsl:when test="AIFNoReportingFlag = 'true'"> 
                    <xsl:if test="AIFCompleteDescription">
CAF-012
                    </xsl:if>
                </xsl:when> 
                <xsl:otherwise>
                    <xsl:if test="not(AIFCompleteDescription)">
ERROR 23.b
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>

        <xsl:for-each select = "AIFRecordInfo">
            <xsl:if test="AIFCompleteDescription/AIFPrincipalInfo/ShareClassFlag = 'false'"> 
                <xsl:if test="AIFCompleteDescription/AIFPrincipalInfo/ShareClassIdentification/ShareClassIdentifier/ShareClassNationalCode">
CAF-016
                </xsl:if>
            </xsl:if> 
        </xsl:for-each>

        <xsl:for-each select = "AIFRecordInfo">
            <xsl:if test="AIFCompleteDescription/AIFPrincipalInfo/ShareClassFlag = 'false'"> 
                <xsl:if test="AIFCompleteDescription/AIFPrincipalInfo/ShareClassIdentification/ShareClassIdentifier/ShareClassIdentifierISIN">
CAF-018
                </xsl:if>
            </xsl:if>
        </xsl:for-each>

        <xsl:for-each select = "AIFRecordInfo">
            <xsl:if test="AIFCompleteDescription/AIFPrincipalInfo/ShareClassFlag = 'false'"> 
                <xsl:if test="AIFCompleteDescription/AIFPrincipalInfo/ShareClassIdentification/ShareClassIdentifier/ShareClassIdentifierCUSIP">
CAF-019
                </xsl:if>
            </xsl:if> 
        </xsl:for-each>

        <xsl:for-each select = "AIFRecordInfo">
            <xsl:if test="AIFCompleteDescription/AIFPrincipalInfo/ShareClassFlag = 'false'"> 
                <xsl:if test="AIFCompleteDescription/AIFPrincipalInfo/ShareClassIdentification/ShareClassIdentifier/ShareClassIdentifierSEDOL">
CAF-020
                </xsl:if>
            </xsl:if> 
        </xsl:for-each>

        <xsl:for-each select = "AIFRecordInfo">
            <xsl:if test="AIFCompleteDescription/AIFPrincipalInfo/ShareClassFlag = 'false'"> 
                <xsl:if test="AIFCompleteDescription/AIFPrincipalInfo/ShareClassIdentification/ShareClassIdentifier/ShareClassIdentifierTicker">
CAF-021
                </xsl:if>
            </xsl:if> 
        </xsl:for-each>

        <xsl:for-each select = "AIFRecordInfo">
            <xsl:if test="AIFCompleteDescription/AIFPrincipalInfo/ShareClassFlag = 'false'"> 
                <xsl:if test="AIFCompleteDescription/AIFPrincipalInfo/ShareClassIdentification/ShareClassIdentifier/ShareClassIdentifierRIC">
CAF-022
                </xsl:if>
            </xsl:if> 
        </xsl:for-each>

        <xsl:for-each select = "AIFRecordInfo">
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
        </xsl:for-each>

        <xsl:for-each select = "AIFRecordInfo">
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
        </xsl:for-each>

        <xsl:for-each select = "AIFRecordInfo">
            <xsl:if test="not(AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/AIFMasterFeederStatus = 'FEEDER')"> 
                <xsl:if test="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/MasterAIFsIdentification/MasterAIFIdentification/AIFIdentifierNCA/ReportingMemberState">
CAF-026
                </xsl:if>
            </xsl:if> 
        </xsl:for-each>

        <xsl:for-each select = "AIFRecordInfo">
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
        </xsl:for-each>

        <xsl:for-each select = "AIFRecordInfo">
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
        </xsl:for-each>

        <xsl:for-each select = "AIFRecordInfo">
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
        </xsl:for-each>

        <xsl:for-each select = "AIFRecordInfo">
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
        </xsl:for-each>

        <xsl:for-each select = "AIFRecordInfo">
            <xsl:if test="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/HedgeFundInvestmentStrategies/HedgeFundStrategy/HedgeFundStrategyType = 'MULT_HFND'"> 
                <xsl:variable name="count" select="count(AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/HedgeFundInvestmentStrategies/HedgeFundStrategy/HedgeFundStrategyType[.!='MULT_HFND'])"/>
                <xsl:if test="$count &lt; 2">
ERROR 58.b
                </xsl:if>
            </xsl:if> 
        </xsl:for-each>

        <xsl:for-each select = "AIFRecordInfo">
            <xsl:if test="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/PrivateEquityFundInvestmentStrategies/PrivateEquityFundInvestmentStrategy/PrivateEquityFundStrategyType = 'MULT_PEQF'"> 
                <xsl:variable name="count" select="count(AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/PrivateEquityFundInvestmentStrategies/PrivateEquityFundInvestmentStrategy/PrivateEquityFundStrategyType[.!='MULT_PEQF'])"/>
                <xsl:if test="$count &lt; 2">
ERROR 58.c
                </xsl:if>
            </xsl:if> 
        </xsl:for-each>

        <xsl:for-each select = "AIFRecordInfo">
            <xsl:if test="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/RealEstateFundInvestmentStrategies/RealEstateFundStrategy/RealEstateFundStrategyType = 'MULT_REST'"> 
                <xsl:variable name="count" select="count(AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/RealEstateFundInvestmentStrategies/RealEstateFundStrategy/RealEstateFundStrategyType[.!='MULT_REST'])"/>
                <xsl:if test="$count &lt; 2">
ERROR 58.d
                </xsl:if>
            </xsl:if> 
        </xsl:for-each>

        <xsl:for-each select = "AIFRecordInfo">
            <xsl:if test="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/PrivateEquityFundInvestmentStrategies/PrivateEquityFundInvestmentStrategy[PrivateEquityFundStrategyType = 'MULT_PEQF' and not(PrimaryStrategyFlag = 'true')]"> 
CAF-038
            </xsl:if>
        </xsl:for-each>

        <xsl:for-each select = "AIFRecordInfo">
            <xsl:if test="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/HedgeFundInvestmentStrategies/HedgeFundStrategy[HedgeFundStrategyType = 'MULT_HFND' and not(PrimaryStrategyFlag = 'true')]"> 
CAF-038
            </xsl:if>
        </xsl:for-each>

        <xsl:for-each select = "AIFRecordInfo">
            <xsl:if test="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/RealEstateFundInvestmentStrategies/RealEstateFundStrategy[RealEstateFundStrategyType = 'MULT_REST' and not(PrimaryStrategyFlag = 'true')]"> 
CAF-038
            </xsl:if>
        </xsl:for-each>

        <xsl:for-each select="AIFRecordInfo">
            <xsl:variable 
            name="strategies" 
            select="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/HedgeFundInvestmentStrategies/HedgeFundStrategy[not(HedgeFundStrategyType = 'MULT_HFND')] " />
            <xsl:if test="$strategies">
                <xsl:for-each select="$strategies">
                    <xsl:if test="not(StrategyNAVRate)">
ERROR 60.a.I
                    </xsl:if>
                </xsl:for-each>
                <xsl:if test="not(sum($strategies/StrategyNAVRate) = 100)">
ERROR 60.a.II
                </xsl:if>
            </xsl:if>
        </xsl:for-each>

        <xsl:for-each select="AIFRecordInfo">
            <xsl:variable 
            name="strategies" 
            select="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/PrivateEquityFundInvestmentStrategies/PrivateEquityFundInvestmentStrategy[not(PrivateEquityFundStrategyType = 'MULT_PEQF')] " />
            <xsl:if test="$strategies">
                <xsl:for-each select="$strategies">
                    <xsl:if test="not(StrategyNAVRate)">
ERROR 60.b.I
                    </xsl:if>
                </xsl:for-each>
                <xsl:if test="not(sum($strategies/StrategyNAVRate) = 100)">
CAF-039
                </xsl:if>
            </xsl:if>
        </xsl:for-each>

        <xsl:for-each select="AIFRecordInfo">
            <xsl:variable 
            name="strategies" 
            select="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/RealEstateFundInvestmentStrategies/RealEstateFundStrategy[not(RealEstateFundStrategyType = 'MULT_REST')] " />
            <xsl:if test="$strategies">
                <xsl:for-each select="$strategies">
                    <xsl:if test="not(StrategyNAVRate)">
ERROR 60.c.I
                    </xsl:if>
                </xsl:for-each>
                <xsl:if test="not(sum($strategies/StrategyNAVRate) = 100)">
CAF-039
                </xsl:if>
            </xsl:if>
        </xsl:for-each>

        <xsl:for-each select="AIFRecordInfo">
            <xsl:variable 
            name="strategies" 
            select="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/FundOfFundsInvestmentStrategies/FundOfFundsStrategy" />
            <xsl:if test="$strategies">
                <xsl:for-each select="$strategies">
                    <xsl:if test="not(StrategyNAVRate)">
ERROR 60.d.I
                    </xsl:if>
                </xsl:for-each>
                <xsl:if test="not(sum($strategies/StrategyNAVRate) = 100)">
CAF-039
                </xsl:if>
            </xsl:if>
        </xsl:for-each>

        <xsl:for-each select="AIFRecordInfo">
            <xsl:variable 
            name="strategies" 
            select="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/OtherFundInvestmentStrategies/OtherFundStrategy" />
            <xsl:if test="$strategies">
                <xsl:for-each select="$strategies">
                    <xsl:if test="not(StrategyNAVRate)">
ERROR 60.e.I
                    </xsl:if>
                </xsl:for-each>
                <xsl:if test="not(sum($strategies/StrategyNAVRate) = 100)">
CAF-039
                </xsl:if>
            </xsl:if>
        </xsl:for-each>

        <xsl:for-each select="AIFRecordInfo">
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
        </xsl:for-each>

        <xsl:for-each select="AIFRecordInfo">
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
        </xsl:for-each>

        <xsl:for-each select="AIFRecordInfo">
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
        </xsl:for-each>

        <xsl:for-each select="AIFRecordInfo">
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
        </xsl:for-each>

        <xsl:for-each select="AIFRecordInfo">
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
        </xsl:for-each>

        <xsl:for-each select="AIFRecordInfo">
            <xsl:variable 
            name="ranks" 
            select="AIFCompleteDescription/AIFPrincipalInfo/MainInstrumentsTraded/MainInstrumentTraded/Ranking" />
            <xsl:if test="$ranks and not($ranks[.='1'] and $ranks[.='2'] and $ranks[.='3'] and $ranks[.='4'] and $ranks[.='5'])">
ERROR 64
                <xsl:for-each select="$ranks">
                    <xsl:value-of select="." />
                </xsl:for-each>
            </xsl:if>
        </xsl:for-each>

        <xsl:for-each select="AIFRecordInfo">
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
        </xsl:for-each>

        <xsl:for-each select="AIFRecordInfo">
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
        </xsl:for-each>

        <xsl:for-each select="AIFRecordInfo">
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
        </xsl:for-each>

        <xsl:for-each select="AIFRecordInfo">
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
        </xsl:for-each>

        <xsl:for-each select="AIFRecordInfo">
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
        </xsl:for-each>

        <xsl:for-each select="AIFRecordInfo">
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
        </xsl:for-each>

        <xsl:for-each select="AIFRecordInfo">
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
        </xsl:for-each>

        <xsl:for-each select="AIFRecordInfo">
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
        </xsl:for-each>

        <xsl:for-each select="AIFRecordInfo">
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
        </xsl:for-each>

        <xsl:for-each select="AIFRecordInfo">
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
        </xsl:for-each>

        <xsl:for-each select="AIFRecordInfo">
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
        </xsl:for-each>

        <xsl:for-each select="AIFRecordInfo">
            <xsl:for-each select="AIFCompleteDescription/AIFPrincipalInfo/MainInstrumentsTraded/MainInstrumentTraded">
                <xsl:if test="not(PositionType = 'S')">
                    <xsl:if test="ShortPositionHedgingRate">
CAF-056
                    </xsl:if>
                </xsl:if>
            </xsl:for-each>
        </xsl:for-each>

        <xsl:for-each select="AIFRecordInfo">
            <xsl:variable 
            name="regions" 
            select="AIFCompleteDescription/AIFPrincipalInfo/NAVGeographicalFocus/*" />
            <xsl:if test="$regions">
                <xsl:if test="not(sum($regions) = 100)">
CAF-057
                </xsl:if>
            </xsl:if>
        </xsl:for-each>

        <xsl:for-each select="AIFRecordInfo">
            <xsl:variable 
            name="regions" 
            select="AIFCompleteDescription/AIFPrincipalInfo/AUMGeographicalFocus/*" />
            <xsl:if test="$regions">
                <xsl:if test="not(sum($regions) = 100)">
CAF-058
                </xsl:if>
            </xsl:if>
        </xsl:for-each>

        <xsl:for-each select="AIFRecordInfo">
            <xsl:variable 
            name="ranks" 
            select="AIFCompleteDescription/AIFPrincipalInfo/PrincipalExposures/PrincipalExposure/Ranking" />
            <xsl:if test="$ranks and not($ranks[.='1'] and $ranks[.='2'] and $ranks[.='3'] and $ranks[.='4'] and $ranks[.='5'] and $ranks[.='6'] and $ranks[.='7'] and $ranks[.='8'] and $ranks[.='9'] and $ranks[.='10'])">
ERROR 94
            </xsl:if>
        </xsl:for-each>

        <xsl:for-each select="AIFRecordInfo">
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
        </xsl:for-each>

        <xsl:for-each select="AIFRecordInfo">
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
        </xsl:for-each>

        <xsl:for-each select="AIFRecordInfo">
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
        </xsl:for-each>

        <xsl:for-each select="AIFRecordInfo">
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
        </xsl:for-each>

        <xsl:for-each select="AIFRecordInfo">
            <xsl:variable 
            name="ranks" 
            select="AIFCompleteDescription/AIFPrincipalInfo/MostImportantConcentration/PortfolioConcentrations/PortfolioConcentration/Ranking" />
            <xsl:if test="$ranks and not($ranks[.='1'] and $ranks[.='2'] and $ranks[.='3'] and $ranks[.='4'] and $ranks[.='5'])">
ERROR 103
            </xsl:if>
        </xsl:for-each>

        <xsl:for-each select="AIFRecordInfo">
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
        </xsl:for-each>

        <xsl:for-each select="AIFRecordInfo">
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
        </xsl:for-each>

        <xsl:for-each select="AIFRecordInfo">
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
        </xsl:for-each>

        <xsl:for-each select="AIFRecordInfo">
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
        </xsl:for-each>

        <xsl:for-each select="AIFRecordInfo">
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
        </xsl:for-each>

        <xsl:for-each select="AIFRecordInfo">
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

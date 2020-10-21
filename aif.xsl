<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

    <xsl:output method="text" />

    <xsl:template match="/">

        <xsl:for-each select = "AIFReportingInfo/AIFRecordInfo">
            <xsl:if test="AIFNoReportingFlag = 'false'"> 
                <xsl:if test="AIFContentType = '2' or AIFContentType = '4'">
                    <xsl:if test="not(AIFCompleteDescription/AIFIndividualInfo)">
ERROR 5.a
                    </xsl:if>
                </xsl:if>

                <xsl:if test="AIFContentType = '2' or AIFContentType = '4'">
                    <xsl:if test="not(AIFCompleteDescription/AIFLeverageInfo/AIFLeverageArticle24-2)">
ERROR 5.b
                    </xsl:if>
                </xsl:if>

                <xsl:if test="AIFContentType = '4' or AIFContentType = '5'">
                    <xsl:if test="not(AIFCompleteDescription/AIFLeverageInfo/AIFLeverageArticle24-4)">
ERROR 5.c
                    </xsl:if>
                </xsl:if>
            </xsl:if> 
        </xsl:for-each>

        <xsl:for-each select = "AIFReportingInfo/AIFRecordInfo">
            <xsl:choose> 
                <xsl:when test="AIFReportingObligationChangeFrequencyCode or AIFReportingObligationChangeContentsCode"> 
                    <xsl:if test="not(AIFReportingObligationChangeQuarter)">
ERROR 12.a
                    </xsl:if>
                </xsl:when> 
                <xsl:otherwise>
                    <xsl:if test="AIFReportingObligationChangeQuarter">
ERROR 12.b
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>

        <xsl:for-each select = "AIFReportingInfo/AIFRecordInfo">
            <xsl:choose> 
                <xsl:when test="AIFNoReportingFlag = 'true'"> 
                    <xsl:if test="AIFCompleteDescription">
ERROR 23.a
                    </xsl:if>
                </xsl:when> 
                <xsl:otherwise>
                    <xsl:if test="not(AIFCompleteDescription)">
ERROR 23.b
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>

        <xsl:for-each select = "AIFReportingInfo/AIFRecordInfo">
            <xsl:if test="AIFCompleteDescription/AIFPrincipalInfo/ShareClassFlag = 'false'"> 
                <xsl:if test="AIFCompleteDescription/AIFPrincipalInfo/ShareClassIdentification/ShareClassIdentifier/ShareClassNationalCode">
ERROR 34
                </xsl:if>
            </xsl:if> 
        </xsl:for-each>

        <xsl:for-each select = "AIFReportingInfo/AIFRecordInfo">
            <xsl:if test="AIFCompleteDescription/AIFPrincipalInfo/ShareClassFlag = 'false'"> 
                <xsl:if test="AIFCompleteDescription/AIFPrincipalInfo/ShareClassIdentification/ShareClassIdentifier/ShareClassIdentifierISIN">
ERROR 35
                </xsl:if>
            </xsl:if>
        </xsl:for-each>

        <xsl:for-each select = "AIFReportingInfo/AIFRecordInfo">
            <xsl:if test="AIFCompleteDescription/AIFPrincipalInfo/ShareClassFlag = 'false'"> 
                <xsl:if test="AIFCompleteDescription/AIFPrincipalInfo/ShareClassIdentification/ShareClassIdentifier/ShareClassIdentifierCUSIP">
ERROR 36
                </xsl:if>
            </xsl:if> 
        </xsl:for-each>

        <xsl:for-each select = "AIFReportingInfo/AIFRecordInfo">
            <xsl:if test="AIFCompleteDescription/AIFPrincipalInfo/ShareClassFlag = 'false'"> 
                <xsl:if test="AIFCompleteDescription/AIFPrincipalInfo/ShareClassIdentification/ShareClassIdentifier/ShareClassIdentifierSEDOL">
ERROR 37
                </xsl:if>
            </xsl:if> 
        </xsl:for-each>

        <xsl:for-each select = "AIFReportingInfo/AIFRecordInfo">
            <xsl:if test="AIFCompleteDescription/AIFPrincipalInfo/ShareClassFlag = 'false'"> 
                <xsl:if test="AIFCompleteDescription/AIFPrincipalInfo/ShareClassIdentification/ShareClassIdentifier/ShareClassIdentifierTicker">
ERROR 38
                </xsl:if>
            </xsl:if> 
        </xsl:for-each>

        <xsl:for-each select = "AIFReportingInfo/AIFRecordInfo">
            <xsl:if test="AIFCompleteDescription/AIFPrincipalInfo/ShareClassFlag = 'false'"> 
                <xsl:if test="AIFCompleteDescription/AIFPrincipalInfo/ShareClassIdentification/ShareClassIdentifier/ShareClassIdentifierRIC">
ERROR 39
                </xsl:if>
            </xsl:if> 
        </xsl:for-each>

        <xsl:for-each select = "AIFReportingInfo/AIFRecordInfo">
            <xsl:choose> 
                <xsl:when test="AIFCompleteDescription/AIFPrincipalInfo/ShareClassFlag = 'true'"> 
                    <xsl:if test="not(AIFCompleteDescription/AIFPrincipalInfo/ShareClassIdentification/ShareClassIdentifier/ShareClassName)">
ERROR 40.a
                    </xsl:if>
                </xsl:when> 
                <xsl:otherwise> 
                    <xsl:if test="AIFCompleteDescription/AIFPrincipalInfo/ShareClassIdentification/ShareClassIdentifier/ShareClassName">
ERROR 40.b
                    </xsl:if>
                </xsl:otherwise> 
            </xsl:choose>
        </xsl:for-each>

        <xsl:for-each select = "AIFReportingInfo/AIFRecordInfo">
            <xsl:choose> 
                <xsl:when test="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/AIFMasterFeederStatus = 'FEEDER'"> 
                    <xsl:if test="not(AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/MasterAIFsIdentification/MasterAIFIdentification/AIFName)">
ERROR 42.a
                    </xsl:if>
                </xsl:when> 
                <xsl:otherwise> 
                    <xsl:if test="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/MasterAIFsIdentification/MasterAIFIdentification/AIFName">
ERROR 42.b
                    </xsl:if>
                </xsl:otherwise> 
            </xsl:choose>
        </xsl:for-each>

        <xsl:for-each select = "AIFReportingInfo/AIFRecordInfo">
            <xsl:if test="not(AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/AIFMasterFeederStatus = 'FEEDER')"> 
                <xsl:if test="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/MasterAIFsIdentification/MasterAIFIdentification/AIFIdentifierNCA/ReportingMemberState">
ERROR 43
                </xsl:if>
            </xsl:if> 
        </xsl:for-each>

        <xsl:for-each select = "AIFReportingInfo/AIFRecordInfo">
            <xsl:choose> 
                <xsl:when test="AIFNoReportingFlag = 'false' and not(AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/AIFBaseCurrencyDescription/BaseCurrency = 'EUR')"> 
                    <xsl:if test="not(AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/AIFBaseCurrencyDescription/FXEURRate)">
ERROR 50.a
                    </xsl:if>
                </xsl:when> 
                <xsl:otherwise> 
                    <xsl:if test="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/AIFBaseCurrencyDescription/FXEURRate">
ERROR 50.b
                    </xsl:if>
                </xsl:otherwise> 
            </xsl:choose>
        </xsl:for-each>

        <xsl:for-each select = "AIFReportingInfo/AIFRecordInfo">
            <xsl:choose> 
                <xsl:when test="AIFNoReportingFlag = 'false' and not(AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/AIFBaseCurrencyDescription/BaseCurrency = 'EUR')"> 
                    <xsl:if test="not(AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/AIFBaseCurrencyDescription/FXEURReferenceRateType)">
ERROR 51.a
                    </xsl:if>
                </xsl:when> 
                <xsl:otherwise> 
                    <xsl:if test="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/AIFBaseCurrencyDescription/FXEURReferenceRateType">
ERROR 51.b
                    </xsl:if>
                </xsl:otherwise> 
            </xsl:choose>
        </xsl:for-each>

        <xsl:for-each select = "AIFReportingInfo/AIFRecordInfo">
            <xsl:choose> 
                <xsl:when test="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/AIFBaseCurrencyDescription/FXEURReferenceRateType = 'OTH'"> 
                    <xsl:if test="not(AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/AIFBaseCurrencyDescription/FXEUROtherReferenceRateDescription)">
ERROR 52.a
                    </xsl:if>
                </xsl:when> 
                <xsl:otherwise> 
                    <xsl:if test="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/AIFBaseCurrencyDescription/FXEUROtherReferenceRateDescription">
ERROR 52.b
                    </xsl:if>
                </xsl:otherwise> 
            </xsl:choose>
        </xsl:for-each>

        <xsl:for-each select = "AIFReportingInfo/AIFRecordInfo">
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

        <xsl:for-each select = "AIFReportingInfo/AIFRecordInfo">
            <xsl:if test="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/HedgeFundInvestmentStrategies/HedgeFundStrategy/HedgeFundStrategyType = 'MULT_HFND'"> 
                <xsl:variable name="count" select="count(AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/HedgeFundInvestmentStrategies/HedgeFundStrategy/HedgeFundStrategyType[.!='MULT_HFND'])"/>
                <xsl:if test="$count &lt; 2">
ERROR 58.b
                </xsl:if>
            </xsl:if> 
        </xsl:for-each>

        <xsl:for-each select = "AIFReportingInfo/AIFRecordInfo">
            <xsl:if test="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/PrivateEquityFundInvestmentStrategies/PrivateEquityFundInvestmentStrategy/PrivateEquityFundStrategyType = 'MULT_PEQF'"> 
                <xsl:variable name="count" select="count(AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/PrivateEquityFundInvestmentStrategies/PrivateEquityFundInvestmentStrategy/PrivateEquityFundStrategyType[.!='MULT_PEQF'])"/>
                <xsl:if test="$count &lt; 2">
ERROR 58.c
                </xsl:if>
            </xsl:if> 
        </xsl:for-each>

        <xsl:for-each select = "AIFReportingInfo/AIFRecordInfo">
            <xsl:if test="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/RealEstateFundInvestmentStrategies/RealEstateFundStrategy/RealEstateFundStrategyType = 'MULT_REST'"> 
                <xsl:variable name="count" select="count(AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/RealEstateFundInvestmentStrategies/RealEstateFundStrategy/RealEstateFundStrategyType[.!='MULT_REST'])"/>
                <xsl:if test="$count &lt; 2">
ERROR 58.d
                </xsl:if>
            </xsl:if> 
        </xsl:for-each>

        <xsl:for-each select = "AIFReportingInfo/AIFRecordInfo">
            <xsl:if test="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/PrivateEquityFundInvestmentStrategies/PrivateEquityFundInvestmentStrategy[PrivateEquityFundStrategyType = 'MULT_PEQF' and not(PrimaryStrategyFlag = 'true')]"> 
ERROR 59.a
            </xsl:if>
        </xsl:for-each>

        <xsl:for-each select = "AIFReportingInfo/AIFRecordInfo">
            <xsl:if test="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/HedgeFundInvestmentStrategies/HedgeFundStrategy[HedgeFundStrategyType = 'MULT_HFND' and not(PrimaryStrategyFlag = 'true')]"> 
ERROR 59.b
            </xsl:if>
        </xsl:for-each>

        <xsl:for-each select = "AIFReportingInfo/AIFRecordInfo">
            <xsl:if test="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/RealEstateFundInvestmentStrategies/RealEstateFundStrategy[RealEstateFundStrategyType = 'MULT_REST' and not(PrimaryStrategyFlag = 'true')]"> 
ERROR 59.c
            </xsl:if>
        </xsl:for-each>

        <xsl:for-each select="AIFReportingInfo/AIFRecordInfo">
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

        <xsl:for-each select="AIFReportingInfo/AIFRecordInfo">
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
ERROR 60.b.II
                </xsl:if>
            </xsl:if>
        </xsl:for-each>

        <xsl:for-each select="AIFReportingInfo/AIFRecordInfo">
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
ERROR 60.c.II
                </xsl:if>
            </xsl:if>
        </xsl:for-each>

        <xsl:for-each select="AIFReportingInfo/AIFRecordInfo">
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
ERROR 60.d.II
                </xsl:if>
            </xsl:if>
        </xsl:for-each>

        <xsl:for-each select="AIFReportingInfo/AIFRecordInfo">
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
ERROR 60.e.II
                </xsl:if>
            </xsl:if>
        </xsl:for-each>

        <xsl:for-each select="AIFReportingInfo/AIFRecordInfo">
            <xsl:for-each select="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/HedgeFundInvestmentStrategies/HedgeFundStrategy">
                <xsl:choose>
                    <xsl:when test="HedgeFundStrategyType = 'OTHR_HFND'">
                        <xsl:if test="not(StrategyTypeOtherDescription)">
ERROR 61.a.I
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

        <xsl:for-each select="AIFReportingInfo/AIFRecordInfo">
            <xsl:for-each select="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/PrivateEquityFundInvestmentStrategies/PrivateEquityFundInvestmentStrategy">
                <xsl:choose>
                    <xsl:when test="PrivateEquityFundStrategyType = 'OTHR_PEQF'">
                        <xsl:if test="not(StrategyTypeOtherDescription)">
ERROR 61.b.I
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

        <xsl:for-each select="AIFReportingInfo/AIFRecordInfo">
            <xsl:for-each select="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/RealEstateFundInvestmentStrategies/RealEstateFundStrategy">
                <xsl:choose>
                    <xsl:when test="RealEstateFundStrategyType = 'OTHR_REST'">
                        <xsl:if test="not(StrategyTypeOtherDescription)">
ERROR 61.c.I
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

        <xsl:for-each select="AIFReportingInfo/AIFRecordInfo">
            <xsl:for-each select="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/FundOfFundsInvestmentStrategies/FundOfFundsStrategy">
                <xsl:choose>
                    <xsl:when test="FundOfFundsStrategyType = 'OTHR_FOFS'">
                        <xsl:if test="not(StrategyTypeOtherDescription)">
ERROR 61.d.I
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

        <xsl:for-each select="AIFReportingInfo/AIFRecordInfo">
            <xsl:for-each select="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/OtherFundInvestmentStrategies/OtherFundStrategy">
                <xsl:choose>
                    <xsl:when test="OtherFundStrategyType = 'OTHR_OTHF'">
                        <xsl:if test="not(StrategyTypeOtherDescription)">
ERROR 61.e.I
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

        <xsl:for-each select="AIFReportingInfo/AIFRecordInfo">
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

        <xsl:for-each select="AIFReportingInfo/AIFRecordInfo">
            <xsl:for-each select="AIFCompleteDescription/AIFPrincipalInfo/MainInstrumentsTraded/MainInstrumentTraded">
                <xsl:choose>
                    <xsl:when test="not(SubAssetType = 'NTA_NTA_NOTA')">
                        <xsl:if test="not(InstrumentCodeType)">
ERROR 66.a
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:if test="InstrumentCodeType">
ERROR 66.b
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:for-each>

        <xsl:for-each select="AIFReportingInfo/AIFRecordInfo">
            <xsl:for-each select="AIFCompleteDescription/AIFPrincipalInfo/MainInstrumentsTraded/MainInstrumentTraded">
                <xsl:choose>
                    <xsl:when test="not(SubAssetType = 'NTA_NTA_NOTA')">
                        <xsl:if test="not(InstrumentName)">
ERROR 67.a
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:if test="InstrumentName">
ERROR 67.b
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:for-each>

        <xsl:for-each select="AIFReportingInfo/AIFRecordInfo">
            <xsl:for-each select="AIFCompleteDescription/AIFPrincipalInfo/MainInstrumentsTraded/MainInstrumentTraded">
                <xsl:choose>
                    <xsl:when test="InstrumentCodeType = 'ISIN'">
                        <xsl:if test="not(ISINInstrumentIdentification)">
ERROR 68.a
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:if test="ISINInstrumentIdentification">
ERROR 68.b
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:for-each>

        <xsl:for-each select="AIFReportingInfo/AIFRecordInfo">
            <xsl:for-each select="AIFCompleteDescription/AIFPrincipalInfo/MainInstrumentsTraded/MainInstrumentTraded">
                <xsl:choose>
                    <xsl:when test="InstrumentCodeType = 'AII'">
                        <xsl:if test="not(AIIInstrumentIdentification/AIIExchangeCode)">
ERROR 69.a
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:if test="AIIInstrumentIdentification/AIIExchangeCode">
ERROR 69.b
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:for-each>

        <xsl:for-each select="AIFReportingInfo/AIFRecordInfo">
            <xsl:for-each select="AIFCompleteDescription/AIFPrincipalInfo/MainInstrumentsTraded/MainInstrumentTraded">
                <xsl:choose>
                    <xsl:when test="InstrumentCodeType = 'AII'">
                        <xsl:if test="not(AIIInstrumentIdentification/AIIProductCode)">
ERROR 70.a
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:if test="AIIInstrumentIdentification/AIIProductCode">
ERROR 70.b
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:for-each>

        <xsl:for-each select="AIFReportingInfo/AIFRecordInfo">
            <xsl:for-each select="AIFCompleteDescription/AIFPrincipalInfo/MainInstrumentsTraded/MainInstrumentTraded">
                <xsl:choose>
                    <xsl:when test="InstrumentCodeType = 'AII'">
                        <xsl:if test="not(AIIInstrumentIdentification/AIIDerivativeType)">
ERROR 71.a
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:if test="AIIInstrumentIdentification/AIIDerivativeType">
ERROR 71.b
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:for-each>

        <xsl:for-each select="AIFReportingInfo/AIFRecordInfo">
            <xsl:for-each select="AIFCompleteDescription/AIFPrincipalInfo/MainInstrumentsTraded/MainInstrumentTraded">
                <xsl:choose>
                    <xsl:when test="InstrumentCodeType = 'AII'">
                        <xsl:if test="not(AIIInstrumentIdentification/AIIPutCallIdentifier)">
ERROR 72.a
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:if test="AIIInstrumentIdentification/AIIPutCallIdentifier">
ERROR 72.b
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:for-each>

        <xsl:for-each select="AIFReportingInfo/AIFRecordInfo">
            <xsl:for-each select="AIFCompleteDescription/AIFPrincipalInfo/MainInstrumentsTraded/MainInstrumentTraded">
                <xsl:choose>
                    <xsl:when test="InstrumentCodeType = 'AII'">
                        <xsl:if test="not(AIIInstrumentIdentification/AIIExpiryDate)">
ERROR 73.a
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:if test="AIIInstrumentIdentification/AIIExpiryDate">
ERROR 73.b
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:for-each>

        <xsl:for-each select="AIFReportingInfo/AIFRecordInfo">
            <xsl:for-each select="AIFCompleteDescription/AIFPrincipalInfo/MainInstrumentsTraded/MainInstrumentTraded">
                <xsl:choose>
                    <xsl:when test="InstrumentCodeType = 'AII'">
                        <xsl:if test="not(AIIInstrumentIdentification/AIIStrikePrice)">
ERROR 74.a
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:if test="AIIInstrumentIdentification/AIIStrikePrice">
ERROR 74.b
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:for-each>

        <xsl:for-each select="AIFReportingInfo/AIFRecordInfo">
            <xsl:for-each select="AIFCompleteDescription/AIFPrincipalInfo/MainInstrumentsTraded/MainInstrumentTraded">
                <xsl:choose>
                    <xsl:when test="not(SubAssetType = 'NTA_NTA_NOTA')">
                        <xsl:if test="not(PositionType)">
ERROR 75.a
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:if test="PositionType">
ERROR 75.b
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:for-each>

        <xsl:for-each select="AIFReportingInfo/AIFRecordInfo">
            <xsl:for-each select="AIFCompleteDescription/AIFPrincipalInfo/MainInstrumentsTraded/MainInstrumentTraded">
                <xsl:choose>
                    <xsl:when test="not(SubAssetType = 'NTA_NTA_NOTA')">
                        <xsl:if test="not(PositionValue)">
ERROR 76.a
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:if test="PositionValue">
ERROR 76.b
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:for-each>

        <xsl:for-each select="AIFReportingInfo/AIFRecordInfo">
            <xsl:for-each select="AIFCompleteDescription/AIFPrincipalInfo/MainInstrumentsTraded/MainInstrumentTraded">
                <xsl:if test="not(PositionType = 'S')">
                    <xsl:if test="ShortPositionHedgingRate">
ERROR 77
                    </xsl:if>
                </xsl:if>
            </xsl:for-each>
        </xsl:for-each>

        <xsl:for-each select="AIFReportingInfo/AIFRecordInfo">
            <xsl:variable 
            name="regions" 
            select="AIFCompleteDescription/AIFPrincipalInfo/NAVGeographicalFocus/*" />
            <xsl:if test="$regions">
                <xsl:if test="not(sum($regions) = 100)">
ERROR 78_85
                </xsl:if>
            </xsl:if>
        </xsl:for-each>

        <xsl:for-each select="AIFReportingInfo/AIFRecordInfo">
            <xsl:variable 
            name="regions" 
            select="AIFCompleteDescription/AIFPrincipalInfo/AUMGeographicalFocus/*" />
            <xsl:if test="$regions">
                <xsl:if test="not(sum($regions) = 100)">
ERROR 86_93
                </xsl:if>
            </xsl:if>
        </xsl:for-each>

        <xsl:for-each select="AIFReportingInfo/AIFRecordInfo">
            <xsl:variable 
            name="ranks" 
            select="AIFCompleteDescription/AIFPrincipalInfo/PrincipalExposures/PrincipalExposure/Ranking" />
            <xsl:if test="$ranks and not($ranks[.='1'] and $ranks[.='2'] and $ranks[.='3'] and $ranks[.='4'] and $ranks[.='5'] and $ranks[.='6'] and $ranks[.='7'] and $ranks[.='8'] and $ranks[.='9'] and $ranks[.='10'])">
ERROR 94
                <!-- <xsl:for-each select="$ranks">
                    <xsl:value-of select="." />
                </xsl:for-each> -->
            </xsl:if>
        </xsl:for-each>

        <xsl:for-each select="AIFReportingInfo/AIFRecordInfo">
            <xsl:for-each select="AIFCompleteDescription/AIFPrincipalInfo/PrincipalExposures/PrincipalExposure">
                <xsl:choose>
                    <xsl:when test="not(AssetMacroType = 'NTA')">
                        <xsl:if test="not(SubAssetType)">
ERROR 96.a
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:if test="SubAssetType">
ERROR 96.b
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:for-each>

    </xsl:template>

</xsl:stylesheet>

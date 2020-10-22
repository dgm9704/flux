<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" >
<xsl:output method="text" />

    <xsl:template match="/AIFMReportingInfo">

        <xsl:for-each select="AIFMRecordInfo">

            <xsl:variable name="manager" select="AIFMNationalCode" />     
            <xsl:variable name="year" select="substring(ReportingPeriodStartDate,1,4)" />
            <xsl:variable name="month" select="substring(ReportingPeriodStartDate,6,2)" />
            <xsl:variable name="day" select="substring(ReportingPeriodStartDate,9,2)" />
            <xsl:choose>
                <xsl:when test="not($day='01')">
CAM-002 <xsl:value-of select="$manager"/> The reporting period start date is not allowed.
                </xsl:when>
                <xsl:when test="ReportingPeriodType='Q1' or ReportingPeriodType='Q2' or ReportingPeriodType='Q3' or ReportingPeriodType='Q4'">
                    <xsl:if test="not($month='10' or $month='07' or $month='01')">
CAM-002 <xsl:value-of select="$manager"/> The reporting period start date is not allowed.
                    </xsl:if>
                </xsl:when>
                <xsl:when test="ReportingPeriodType='H1' or ReportingPeriodType='H2'">
                    <xsl:if test="not($month='07' or $month='01')">
CAM-002 <xsl:value-of select="$manager"/> The reporting period start date is not allowed.
                    </xsl:if>
                </xsl:when>
                <xsl:when test="ReportingPeriodType='Y1'">
                    <xsl:if test="not($month='01')">
CAM-002 <xsl:value-of select="$manager"/> The reporting period start date is not allowed.
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

            <xsl:choose> 
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
            </xsl:choose>

            <xsl:for-each select = "AIFMCompleteDescription/AIFMPrincipalMarkets/AIFMFivePrincipalMarket/MarketIdentification">
                <xsl:choose> 
                    <xsl:when test = "MarketCodeType = 'MIC'"> 
                        <xsl:if test="not(MarketCode)">
ERROR 28.a <xsl:value-of select="$manager"/>
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:if test="MarketCode">
ERROR 28.b <xsl:value-of select="$manager"/>
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

    </xsl:template>

</xsl:stylesheet>

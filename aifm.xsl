<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="text" />

    <xsl:template match="/">

        <xsl:for-each select = "AIFMReportingInfo/AIFMRecordInfo">
            <xsl:choose> 
                <xsl:when test="AIFMReportingObligationChangeFrequencyCode or AIFMReportingObligationChangeContentsCode"> 
                    <xsl:if test="not(AIFMReportingObligationChangeQuarter)">
            ERROR 12.a
                    </xsl:if>
                </xsl:when> 
                <xsl:otherwise> 
                    <xsl:if test="AIFMReportingObligationChangeQuarter">
            ERROR 12.b
                    </xsl:if>
                </xsl:otherwise> 
            </xsl:choose>
        </xsl:for-each>

        <xsl:for-each select = "AIFMReportingInfo/AIFMRecordInfo">
            <xsl:choose> 
                <xsl:when test = "AIFMNoReportingFlag = 'true' "> 
                    <xsl:if test="AIFMCompleteDescription">
            ERROR 21.a
                    </xsl:if>
                </xsl:when> 
                <xsl:otherwise> 
                    <xsl:if test="not(AIFMCompleteDescription)">
            ERROR 21.b
                    </xsl:if>
                </xsl:otherwise> 
            </xsl:choose>
        </xsl:for-each>

        <xsl:for-each select = "AIFMReportingInfo/AIFMRecordInfo/AIFMCompleteDescription/AIFMPrincipalMarkets/AIFMFivePrincipalMarket/MarketIdentification">
            <xsl:choose> 
                <xsl:when test = "MarketCodeType = 'MIC'"> 
                    <xsl:if test="not(MarketCode)">
            ERROR 28.a
                    </xsl:if>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:if test="MarketCode">
            ERROR 28.b
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>

        <xsl:for-each select = "AIFMReportingInfo/AIFMRecordInfo/AIFMCompleteDescription/AIFMPrincipalMarkets/AIFMFivePrincipalMarket">
            <xsl:choose> 
                <xsl:when test = "not(MarketIdentification/MarketCodeType = 'NOT')"> 
                    <xsl:if test="not(AggregatedValueAmount)">
            ERROR 29
                    </xsl:if>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>

        <xsl:for-each select = "AIFMReportingInfo/AIFMRecordInfo/AIFMCompleteDescription/AIFMPrincipalInstruments/AIFMPrincipalInstrument">
            <xsl:choose> 
                <xsl:when test = "not(SubAssetType = 'NTA_NTA_NOTA')"> 
                    <xsl:if test="not(AggregatedValueAmount)">
            ERROR 32
                    </xsl:if>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>

        <xsl:for-each select = "AIFMReportingInfo/AIFMRecordInfo/AIFMCompleteDescription/AIFMBaseCurrencyDescription">
            <xsl:choose> 
                <xsl:when test = "BaseCurrency = 'EUR'"> 
                    <xsl:if test="FXEURReferenceRateType">
            ERROR 36.a
                    </xsl:if>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:if test="not(FXEURReferenceRateType)">
            ERROR 36.b
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>

        <xsl:for-each select = "AIFMReportingInfo/AIFMRecordInfo/AIFMCompleteDescription/AIFMBaseCurrencyDescription">
            <xsl:choose> 
                <xsl:when test = "BaseCurrency = 'EUR'"> 
                    <xsl:if test="FXEURRate">
            ERROR 37.a
                    </xsl:if>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:if test="not(FXEURRate)">
            ERROR 37.b
                    </xsl:if>   
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>

        <xsl:for-each select = "AIFMReportingInfo/AIFMRecordInfo/AIFMCompleteDescription/AIFMBaseCurrencyDescription">
            <xsl:choose> 
                <xsl:when test = "BaseCurrency = 'EUR' and FXEURReferenceRateType = 'OTH'"> 
                    <xsl:if test="not(FXEUROtherReferenceRateDescription)">
            ERROR 38.a
                    </xsl:if>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:if test="FXEUROtherReferenceRateDescription">
            ERROR 38.b
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>

    </xsl:template>

</xsl:stylesheet>

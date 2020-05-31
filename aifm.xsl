<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="text" />
<!-- <xsl:template match="/">
    <xsl:for-each select = "AIFMReportingInfo/AIFMRecordInfo/AIFMCompleteDescription/AIFMPrincipalMarkets/AIFMFivePrincipalMarket">
        <xsl:value-of select = "Ranking" />
    </xsl:for-each>
</xsl:template> -->

<xsl:template match = "/AIFMReportingInfo/AIFMRecordInfo">
    <xsl:choose> 
        <xsl:when test = "AIFMNoReportingFlag = 'false' "> 
        <xsl:if test='not(/AIFMReportingInfo/AIFMRecordInfo/AIFMCompleteDescription/AIFMPrincipalMarkets)'>
ERROR1
        </xsl:if>
        </xsl:when> 
        <xsl:when test = "AIFMNoReportingFlag = 'true' "> 
        <xsl:if test='/AIFMReportingInfo/AIFMRecordInfo/AIFMCompleteDescription/AIFMPrincipalMarkets'>
ERROR2
        </xsl:if>
        </xsl:when> 
    </xsl:choose>

</xsl:template>

</xsl:stylesheet>

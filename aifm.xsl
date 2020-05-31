<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:template match="/">
    <xsl:for-each select = "AIFMReportingInfo/AIFMRecordInfo/AIFMCompleteDescription/AIFMPrincipalMarkets/AIFMFivePrincipalMarket">
        <xsl:value-of select = "Ranking" />

    </xsl:for-each>
</xsl:template>
</xsl:stylesheet>

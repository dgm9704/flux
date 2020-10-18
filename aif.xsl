<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="text" />

    <xsl:template match="/">

        <xsl:for-each select = "AIFReportingInfo/AIFRecordInfo">
            <xsl:choose> 
                <xsl:when test="AIFNoReportingFlag = 'false'"> 

                    <xsl:if test="AIFContentType = '2' or AIFContentType = '4'">
                        <xsl:if test="not(AIFCompleteDescription/AIFIndividualInfo)">
            ERROR 5.a
                        </xsl:if>
                    </xsl:if>

                </xsl:when> 
            </xsl:choose>
        </xsl:for-each>

    </xsl:template>

</xsl:stylesheet>

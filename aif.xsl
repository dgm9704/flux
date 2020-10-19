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

                </xsl:when> 
            </xsl:choose>
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
            <xsl:choose> 
                <xsl:when test="AIFCompleteDescription/AIFPrincipalInfo/ShareClassFlag = 'false'"> 
                    <xsl:if test="AIFCompleteDescription/AIFPrincipalInfo/ShareClassIdentification/ShareClassIdentifier/ShareClassNationalCode">
            ERROR 34
                    </xsl:if>
                </xsl:when> 
            </xsl:choose>
        </xsl:for-each>

        <xsl:for-each select = "AIFReportingInfo/AIFRecordInfo">
            <xsl:choose> 
                <xsl:when test="AIFCompleteDescription/AIFPrincipalInfo/ShareClassFlag = 'false'"> 
                    <xsl:if test="AIFCompleteDescription/AIFPrincipalInfo/ShareClassIdentification/ShareClassIdentifier/ShareClassIdentifierISIN">
            ERROR 35
                    </xsl:if>
                </xsl:when> 
            </xsl:choose>
        </xsl:for-each>

        <xsl:for-each select = "AIFReportingInfo/AIFRecordInfo">
            <xsl:choose> 
                <xsl:when test="AIFCompleteDescription/AIFPrincipalInfo/ShareClassFlag = 'false'"> 
                    <xsl:if test="AIFCompleteDescription/AIFPrincipalInfo/ShareClassIdentification/ShareClassIdentifier/ShareClassIdentifierCUSIP">
            ERROR 36
                    </xsl:if>
                </xsl:when> 
            </xsl:choose>
        </xsl:for-each>

        <xsl:for-each select = "AIFReportingInfo/AIFRecordInfo">
            <xsl:choose> 
                <xsl:when test="AIFCompleteDescription/AIFPrincipalInfo/ShareClassFlag = 'false'"> 
                    <xsl:if test="AIFCompleteDescription/AIFPrincipalInfo/ShareClassIdentification/ShareClassIdentifier/ShareClassIdentifierSEDOL">
            ERROR 37
                    </xsl:if>
                </xsl:when> 
            </xsl:choose>
        </xsl:for-each>

        <xsl:for-each select = "AIFReportingInfo/AIFRecordInfo">
            <xsl:choose> 
                <xsl:when test="AIFCompleteDescription/AIFPrincipalInfo/ShareClassFlag = 'false'"> 
                    <xsl:if test="AIFCompleteDescription/AIFPrincipalInfo/ShareClassIdentification/ShareClassIdentifier/ShareClassIdentifierTicker">
            ERROR 38
                    </xsl:if>
                </xsl:when> 
            </xsl:choose>
        </xsl:for-each>

        <xsl:for-each select = "AIFReportingInfo/AIFRecordInfo">
            <xsl:choose> 
                <xsl:when test="AIFCompleteDescription/AIFPrincipalInfo/ShareClassFlag = 'false'"> 
                    <xsl:if test="AIFCompleteDescription/AIFPrincipalInfo/ShareClassIdentification/ShareClassIdentifier/ShareClassIdentifierRIC">
            ERROR 39
                    </xsl:if>
                </xsl:when> 
            </xsl:choose>
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
            <xsl:choose> 
                <xsl:when test="not(AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/AIFMasterFeederStatus = 'FEEDER')"> 
                    <xsl:if test="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/MasterAIFsIdentification/MasterAIFIdentification/AIFIdentifierNCA/ReportingMemberState">
            ERROR 43
                    </xsl:if>
                </xsl:when> 
            </xsl:choose>
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

    </xsl:template>

</xsl:stylesheet>

<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"> 
    <xsl:output indent="yes" method="xml" />

    <xsl:template match="AIFReportingInfo">
<aif>
        <xsl:variable name="reportingmemberstate" select="@ReportingMemberState" />
        <xsl:if test="not($eeacountrycodes[. = $reportingmemberstate])" >
                <error>
                    <record></record>
                    <code>FIL-015</code>
                    <message>The authority key file attribute is invalid and should an EU or EEA country</message>
                    <field>ReportingMemberState</field>
                    <value><xsl:value-of select="$reportingmemberstate" /></value>
                </error>
        </xsl:if>
        <xsl:for-each select = "AIFRecordInfo">
            <xsl:variable name="fund" select="AIFNationalCode" />
            <xsl:if test="AIFNoReportingFlag = 'false'"> 
                <xsl:if test="AIFContentType = '2' or AIFContentType = '4'">
                    <xsl:if test="not(AIFCompleteDescription/AIFIndividualInfo)">
                <error>
                    <record><xsl:value-of select="$fund" /></record>
                    <code>CAF-002</code>
                    <message>The reported AIF information does not correspond to the AIF content type.</message>
                    <field>AIFContentType</field>
                    <value><xsl:value-of select="AIFContentType" /></value>
                </error>
                    </xsl:if>
                </xsl:if>

                <xsl:if test="AIFContentType = '2' or AIFContentType = '4'">
                    <xsl:if test="not(AIFCompleteDescription/AIFLeverageInfo/AIFLeverageArticle24-2)">
                <error>
                    <record><xsl:value-of select="$fund" /></record>
                    <code>CAF-002</code>
                    <message>The reported AIF information does not correspond to the AIF content type.</message>
                    <field>AIFContentType</field>
                    <value><xsl:value-of select="AIFContentType" /></value>
                </error>
                    </xsl:if>
                </xsl:if>

                <xsl:if test="AIFContentType = '4' or AIFContentType = '5'">
                    <xsl:if test="not(AIFCompleteDescription/AIFLeverageInfo/AIFLeverageArticle24-4)">
                <error>
                    <record><xsl:value-of select="$fund" /></record>
                    <code>CAF-002</code>
                    <message>The reported AIF information does not correspond to the AIF content type.</message>
                    <field>AIFContentType</field>
                    <value><xsl:value-of select="AIFContentType" /></value>
                </error>
                    </xsl:if>
                </xsl:if>
            </xsl:if> 

            <xsl:variable name="reportingperiodstartdate" select="ReportingPeriodStartDate" />
            <xsl:variable name="startdate" select="translate($reportingperiodstartdate,'-','')" />
            <xsl:variable name="year" select="substring($startdate,1,4)" />
            <xsl:variable name="month" select="substring($startdate,5,2)" />
            <xsl:variable name="day" select="substring($startdate,7,2)" />
            <xsl:variable name="periodtype" select="ReportingPeriodType" />
            <xsl:variable name="reportingyear" select="ReportingPeriodYear" />
            <xsl:choose>
                <xsl:when test="not($day='01') or not($year=$reportingyear)">
                <error>
                    <record><xsl:value-of select="$fund" /></record>
                    <code>CAF-003</code>
                    <message>The reporting period start date is not allowed. </message>
                    <field>ReportingPeriodStartDate</field>
                    <value><xsl:value-of select="$reportingperiodstartdate" /></value>
                </error>
                </xsl:when>
                <xsl:when test="$periodtype='Q1' or $periodtype='Q2' or $periodtype='Q3' or $periodtype='Q4'">
                    <xsl:if test="not($month='10' or $month='07' or $month='01')">
                <error>
                    <record><xsl:value-of select="$fund" /></record>FI

                    <code>CAF-003</code>
                    <message>The reporting period start date is not allowed. </message>
                    <field>ReportingPeriodStartDate</field>
                    <value><xsl:value-of select="$reportingperiodstartdate" /></value>
                </error>
                    </xsl:if>
                </xsl:when>
                <xsl:when test="$periodtype='H1' or $periodtype='H2'">
                    <xsl:if test="not($month='07' or $month='01')">
                <error>
                    <record><xsl:value-of select="$fund" /></record>
                    <code>CAF-003</code>
                    <message>The reporting period start date is not allowed. </message>
                    <field>ReportingPeriodStartDate</field>
                    <value><xsl:value-of select="$reportingperiodstartdate" /></value>
                </error>
                    </xsl:if>
                </xsl:when>
                <xsl:when test="$periodtype='Y1'">
                    <xsl:if test="not($month='01')">
                <error>
                    <record><xsl:value-of select="$fund" /></record>
                    <code>CAF-003</code>
                    <message>The reporting period start date is not allowed. </message>
                    <field>ReportingPeriodStartDate</field>
                    <value><xsl:value-of select="$reportingperiodstartdate" /></value>
                </error>
                    </xsl:if>
                </xsl:when>
            </xsl:choose>

            <xsl:variable name="reportingperiodenddate" select="ReportingPeriodEndDate" />
            <xsl:variable name="enddate" select="translate(reportingperiodenddate,'-','')" />
            <xsl:variable name="q1end" select="concat($year,'0331')" />
            <xsl:variable name="q2end" select="concat($year,'0630')" />
            <xsl:variable name="q3end" select="concat($year,'0930')" />
            <xsl:variable name="q4end" select="concat($year,'1231')" />
            <xsl:variable name="transition" select="LastReportingFlag='true'" />
            <xsl:choose>
                <xsl:when test="not($enddate&gt;$startdate)">    
                <error>
                    <record><xsl:value-of select="$fund" /></record>
                    <code>CAF-004</code>
                    <message>The reporting period end date is not allowed</message>
                    <field>ReportingPeriodEndDate</field>
                    <value><xsl:value-of select="$reportingperiodenddate" /></value>
                </error>
                </xsl:when>
                <xsl:when test="$periodtype='Q1'">
                    <xsl:if test="not($enddate=$q1end or ($transition and $enddate&lt;$q1end))">
                <error>
                    <record><xsl:value-of select="$fund" /></record>
                    <code>CAF-004</code>
                    <message>The reporting period end date is not allowed</message>
                    <field>ReportingPeriodEndDate</field>
                    <value><xsl:value-of select="$reportingperiodenddate" /></value>
                </error>
                    </xsl:if>
                </xsl:when>

                <xsl:when test="$periodtype='Q2' or $periodtype='H1'">
                    <xsl:if test="not($enddate=$q2end or ($transition and $enddate&lt;$q2end))">
                <error>
                    <record><xsl:value-of select="$fund" /></record>
                    <code>CAF-004</code>
                    <message>The reporting period end date is not allowed</message>
                    <field>ReportingPeriodEndDate</field>
                    <value><xsl:value-of select="$reportingperiodenddate" /></value>
                </error>
                    </xsl:if>
                </xsl:when>

                <xsl:when test="$periodtype='Q3'">
                    <xsl:if test="not($enddate=$q3end or ($transition and $enddate&lt;$q3end))">
                <error>
                    <record><xsl:value-of select="$fund" /></record>
                    <code>CAF-004</code>
                    <message>The reporting period end date is not allowed</message>
                    <field>ReportingPeriodEndDate</field>
                    <value><xsl:value-of select="$reportingperiodenddate" /></value>
                </error>
                    </xsl:if>
                </xsl:when>

                <xsl:when test="$periodtype='Q4' or $periodtype='H2' or $periodtype='Y1'">
                    <xsl:if test="not($enddate=$q4end or ($transition and $enddate&lt;$q4end))">
                <error>
                    <record><xsl:value-of select="$fund" /></record>
                    <code>CAF-004</code>
                    <message>The reporting period end date is not allowed</message>
                    <field>ReportingPeriodEndDate</field>
                    <value><xsl:value-of select="$reportingperiodenddate" /></value>
                </error>
                    </xsl:if>
                </xsl:when>
            </xsl:choose>

            <xsl:choose> 
                <xsl:when test="AIFReportingObligationChangeFrequencyCode or AIFReportingObligationChangeContentsCode"> 
                    <xsl:if test="not(AIFReportingObligationChangeQuarter)">
                <error>
                    <record><xsl:value-of select="$fund" /></record>
                    <code>CAF-006</code>
                    <message>The quarter for the AIF reporting obligation change should be reported</message>
                    <field>AIFReportingObligationChangeQuarter</field>
                    <value><xsl:value-of select="AIFReportingObligationChangeQuarter" /></value>
                </error>
                    </xsl:if>
                </xsl:when> 
                <xsl:otherwise>
                    <xsl:if test="AIFReportingObligationChangeQuarter">
                <error>
                    <record><xsl:value-of select="$fund" /></record>
                    <code>CAF-006</code>
                    <message>The quarter for the AIF reporting obligation change should not be reported</message>
                    <field>AIFReportingObligationChangeQuarter</field>
                    <value><xsl:value-of select="AIFReportingObligationChangeQuarter" /></value>
                </error>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>

            <xsl:variable name="manager" select="AIFMNationalCode" />
            <xsl:if test="not($aifmregister[. = $manager])" >
                <error>
                    <record><xsl:value-of select="$fund" /></record>
                    <code>CAF-007</code>
                    <message>The AIFM national code does not exist in the ESMA Register.</message>
                    <field>AIFMNationalCode</field>
                    <value><xsl:value-of select="$manager" /></value>
                </error>
            </xsl:if>

            <xsl:if test="not($aifregister[. = $fund])" >
                <error>
                    <record><xsl:value-of select="$fund" /></record>
                    <code>CAF-008</code>
                    <message>The AIF national code does not exist in the ESMA Register.</message>
                    <field>AIFMNationalCode</field>
                    <value><xsl:value-of select="$fund" /></value>
                </error>
            </xsl:if>

            <xsl:variable name="eeaflag" select="boolean(AIFEEAFlag='true')" />
            <xsl:variable name="domicile" select="AIFDomicile" />
            <xsl:variable name="iseea" select="boolean($eeacountrycodes[.=$domicile])" />
            <xsl:choose>
                <xsl:when test="$eeaflag">
                    <xsl:if test="not($iseea)">
                <error>
                    <record><xsl:value-of select="$fund" /></record>
                    <code>CAF-009</code>
                    <message>The EEA flag is not correct.</message>
                    <field>AIFEEAFlag</field>
                    <value><xsl:value-of select="AIFEEAFlag" /></value>
                </error>
                    </xsl:if>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:if test="$iseea">
                <error>
                    <record><xsl:value-of select="$fund" /></record>
                    <code>CAF-009</code>
                    <message>The EEA flag is not correct.</message>
                    <field>AIFEEAFlag</field>
                    <value><xsl:value-of select="AIFEEAFlag" /></value>
                </error>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>

            <xsl:if test="not($countrycodes[. = $domicile])" >
                <error>
                    <record><xsl:value-of select="$fund" /></record>
                    <code>CAF-010</code>
                    <message>The domicile of the AIF is not correct.</message>
                    <field>AIFDomicile</field>
                    <value><xsl:value-of select="$domicile" /></value>
                </error>
            </xsl:if>

            <xsl:variable name="inceptiondate" select="translate(InceptionDate,'-','')" />
            <xsl:if test="not($inceptiondate &lt; $startdate)">
                <error>
                    <record><xsl:value-of select="$fund" /></record>
                    <code>CAF-011</code>
                    <message>The inception date is not allowed as it should be before the reporting start date</message>
                    <field>InceptionDate</field>
                    <value><xsl:value-of select="InceptionDate" /></value>
                </error>
            </xsl:if>            

            <xsl:choose> 
                <xsl:when test="AIFNoReportingFlag = 'true'"> 
                    <xsl:if test="AIFCompleteDescription">
                <error>
                    <record><xsl:value-of select="$fund" /></record>
                    <code>CAF-012</code>
                    <message>The AIF no reporting flag is not consistent with the reported information.</message>
                    <field>AIFNoReportingFlag</field>
                    <value><xsl:value-of select="AIFNoReportingFlag" /></value>
                </error>
                    </xsl:if>
                </xsl:when> 
                <xsl:otherwise>
                    <xsl:if test="not(AIFCompleteDescription)">
                <error>
                    <record><xsl:value-of select="$fund" /></record>
                    <code>CAF-012</code>
                    <message>The AIF no reporting flag is not consistent with the reported information.</message>
                    <field>AIFNoReportingFlag</field>
                    <value><xsl:value-of select="AIFNoReportingFlag" /></value>
                </error>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>

            <xsl:variable name="lei" select="AIFCompleteDescription/AIFPrincipalInfo/AIFIdentification/AIFIdentifierLEI" />
            <xsl:if test="$lei and not($leiregister[. = $lei])" >
                <error>
                    <record><xsl:value-of select="$fund" /></record>
                    <code>CAF-013</code>
                    <message>The check digits of the LEI code are not correct.</message>
                    <field>AIFIdentifierLEI</field>
                    <value><xsl:value-of select="$lei" /></value>
                </error>
            </xsl:if>

            <xsl:for-each select="AIFCompleteDescription/AIFPrincipalInfo/AIFIdentification/AIFIdentifierISIN">
                <xsl:variable name="isin" select="." />
                <xsl:if test="$isin and not($isinregister[. = $isin])" >
                <error>
                    <record><xsl:value-of select="$fund" /></record>
                    <code>CAF-014</code>
                    <message>The check digit of the ISIN code is not correct.</message>
                    <field>AIFIdentifierISIN</field>
                    <value><xsl:value-of select="$isin" /></value>
                </error>
                </xsl:if>
            </xsl:for-each>

            <xsl:for-each select="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/MasterAIFsIdentification/MasterAIFIdentification/AIFIdentifierNCA/ReportingMemberState">
                <xsl:variable name="aifmemberstate" select="." />
                <xsl:if test="not($eeacountrycodes[. = $aifmemberstate])" >
                <error>
                    <record><xsl:value-of select="$fund" /></record>
                    <code>CAF-015</code>
                    <message>The country of the old AIF national code is not correct and should be an EEA or EU country.</message>
                    <field>ReportingMemberState</field>
                    <value><xsl:value-of select="$aifmemberstate" /></value>
                </error>
                </xsl:if>
            </xsl:for-each>

            <xsl:variable name="shareclassflag" select="AIFCompleteDescription/AIFPrincipalInfo/ShareClassFlag = 'true'" />
            <xsl:if test="not($shareclassflag)"> 
                <xsl:variable name="shareclassnationalcode" select="AIFCompleteDescription/AIFPrincipalInfo/ShareClassIdentification/ShareClassIdentifier/ShareClassNationalCode" />
                <xsl:if test="$shareclassnationalcode">
                <error>
                    <record><xsl:value-of select="$fund" /></record>
                    <code>CAF-016</code>
                    <message>The share class national code is not consistent with the share class flag.</message>
                    <field>ShareClassNationalCode</field>
                    <value><xsl:value-of select="$shareclassnationalcode" /></value>
                </error>
                </xsl:if>
            </xsl:if>

            <xsl:for-each select="AIFCompleteDescription/AIFPrincipalInfo/ShareClassIdentification/ShareClassIdentifier/ShareClassIdentifierISIN">
                <xsl:variable name="isin" select="." />
                <xsl:if test="$isin and not($isinregister[. = $isin])" >
                <error>
                    <record><xsl:value-of select="$fund" /></record>
                    <code>CAF-017</code>
                    <message>The check digit of the ISIN code is not correct.</message>
                    <field>ShareClassIdentifierISIN</field>
                    <value><xsl:value-of select="$isin" /></value>
                </error>
                </xsl:if>

            <xsl:if test="not($shareclassflag)"> 
                <xsl:if test="$isin">
                <error>
                    <record><xsl:value-of select="$fund" /></record>
                    <code>CAF-018</code>
                    <message>The share class ISIN code is not consistent with the share class flag.</message>
                    <field>ShareClassIdentifierISIN</field>
                    <value><xsl:value-of select="$isin" /></value>
                </error>
                </xsl:if>
            </xsl:if>

            <xsl:if test="not($shareclassflag)"> 
                <xsl:variable name="cusip" select="AIFCompleteDescription/AIFPrincipalInfo/ShareClassIdentification/ShareClassIdentifier/ShareClassIdentifierCUSIP" />
                <xsl:if test="$cusip">
                <error>
                    <record><xsl:value-of select="$fund" /></record>
                    <code>CAF-019</code>
                    <message>The share class CUSIP code is not consistent with the share class flag.</message>
                    <field>ShareClassIdentifierCUSIP</field>
                    <value><xsl:value-of select="$cusip" /></value>
                </error>
                </xsl:if>
            </xsl:if> 

            <xsl:if test="not($shareclassflag)"> 
                <xsl:variable name="sedol" select="AIFCompleteDescription/AIFPrincipalInfo/ShareClassIdentification/ShareClassIdentifier/ShareClassIdentifierSEDOL" />
                <xsl:if test="$sedol">
                <error>
                    <record><xsl:value-of select="$fund" /></record>
                    <code>CAF-020</code>
                    <message>The share class SEDOL code is not consistent with the share class flag.</message>
                    <field>ShareClassIdentifierSEDOL</field>
                    <value><xsl:value-of select="$sedol" /></value>
                </error>
                </xsl:if>
            </xsl:if> 

            <xsl:if test="not($shareclassflag)"> 
                <xsl:variable name="ticker" select="AIFCompleteDescription/AIFPrincipalInfo/ShareClassIdentification/ShareClassIdentifier/ShareClassIdentifierTicker" />
                <xsl:if test="$ticker">
                <error>
                    <record><xsl:value-of select="$fund" /></record>
                    <code>CAF-021</code>
                    <message>The share class Bloomberg code is not consistent with the share class flag.</message>
                    <field>ShareClassIdentifierTicker</field>
                    <value><xsl:value-of select="$ticker" /></value>
                </error>
                </xsl:if>
            </xsl:if> 

            <xsl:if test="not($shareclassflag)"> 
                <xsl:variable name="ric" select="AIFCompleteDescription/AIFPrincipalInfo/ShareClassIdentification/ShareClassIdentifier/ShareClassIdentifierRIC" />
                <xsl:if test="$ric">
                <error>
                    <record><xsl:value-of select="$fund" /></record>
                    <code>CAF-022</code>
                    <message>The share class Reuters code is not consistent with the share class flag.</message>
                    <field>ShareClassIdentifierRIC</field>
                    <value><xsl:value-of select="$ric" /></value>
                </error>
                </xsl:if>
            </xsl:if> 

            <xsl:variable name="shareclassname" select="AIFCompleteDescription/AIFPrincipalInfo/ShareClassIdentification/ShareClassIdentifier/ShareClassName" />
            <xsl:choose> 
                <xsl:when test="$shareclassflag"> 
                    <xsl:if test="not($shareclassname)">
                <error>
                    <record><xsl:value-of select="$fund" /></record>
                    <code>CAF-023</code>
                    <message>The share class name is not consistent with the share class flag.</message>
                    <field>ShareClassName</field>
                    <value><xsl:value-of select="$shareclassname" /></value>
                </error>
                    </xsl:if>
                </xsl:when> 
                <xsl:otherwise> 
                    <xsl:if test="$shareclassname">
                <error>
                    <record><xsl:value-of select="$fund" /></record>
                    <code>CAF-023</code>
                    <message>The share class name is not consistent with the share class flag.</message>
                    <field>ShareClassName</field>
                    <value><xsl:value-of select="$shareclassname" /></value>
                </error>
                    </xsl:if>
                </xsl:otherwise> 
            </xsl:choose>
            </xsl:for-each>

            <xsl:variable name="aifname" select="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/MasterAIFsIdentification/MasterAIFIdentification/AIFName" />
            <xsl:choose> 
                <xsl:when test="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/AIFMasterFeederStatus = 'FEEDER'"> 
                    <xsl:if test="not($aifname)">
                <error>
                    <record><xsl:value-of select="$fund" /></record>
                    <code>CAF-024</code>
                    <message>The master AIF name is not consistent with the master feeder status.</message>
                    <field>AIFName</field>
                    <value><xsl:value-of select="$aifname" /></value>
                </error>
                    </xsl:if>
                </xsl:when> 
                <xsl:otherwise> 
                    <xsl:if test="$aifname">
                <error>
                    <record><xsl:value-of select="$fund" /></record>
                    <code>CAF-024</code>
                    <message>The master AIF name is not consistent with the master feeder status.</message>
                    <field>AIFName</field>
                    <value><xsl:value-of select="$aifname" /></value>
                </error>
                    </xsl:if>
                </xsl:otherwise> 
            </xsl:choose>

            <xsl:variable name="aifmemberstate" select="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/MasterAIFsIdentification/MasterAIFIdentification/AIFIdentifierNCA/ReportingMemberState" />
            <xsl:if test="$aifmemberstate and not($eeacountrycodes[. = $aifmemberstate])" >
                <error>
                    <record><xsl:value-of select="$fund" /></record>
                    <code>CAF-025</code>
                    <message>The country of the master AIF national code is not correct and should be an EEA or EU country.</message>
                    <field>ReportingMemberState</field>
                    <value><xsl:value-of select="$aifmemberstate" /></value>
                </error>
            </xsl:if>

            <xsl:if test="not(AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/AIFMasterFeederStatus = 'FEEDER')"> 
                <xsl:if test="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/MasterAIFsIdentification/MasterAIFIdentification/AIFIdentifierNCA/ReportingMemberState">
                <error>
                    <record><xsl:value-of select="$fund" /></record>
                    <code>CAF-026</code>
                    <message>The master AIF reporting member state is not consistent with the master feeder status.</message>
                    <field>ReportingMemberState</field>
                    <value><xsl:value-of select="$aifmemberstate" /></value>
                </error>
                </xsl:if>
            </xsl:if> 

            <xsl:if test="not(AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/AIFMasterFeederStatus = 'FEEDER')"> 
            <xsl:variable name="aifnationalcode" select="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/MasterAIFsIdentification/MasterAIFIdentification/AIFIdentifierNCA/AIFNationalCode" />
                <xsl:if test="$aifnationalcode">
                <error>
                    <record><xsl:value-of select="$fund" /></record>
                    <code>CAF-027</code>
                    <message>The master AIF national code is not consistent with the master feeder status.</message>
                    <field>AIFNationalCode</field>
                    <value><xsl:value-of select="$aifnationalcode" /></value>
                </error>
                </xsl:if>
            </xsl:if> 

            <!-- CAF-028 The check digits of the LEI code are not correct. -->

            <xsl:variable name="basecurrency" select="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/AIFBaseCurrencyDescription/BaseCurrency" />
            <xsl:if test="not($currencycodes[. = $basecurrency])" >
                <error>
                    <record><xsl:value-of select="$fund" /></record>
                    <code>CAF-029</code>
                    <message>The currency code is not correct.</message>
                    <field>BaseCurrency</field>
                    <value><xsl:value-of select="$basecurrency" /></value>
                </error>
            </xsl:if>

            <xsl:choose> 
                <xsl:when test="AIFNoReportingFlag = 'false' and not(AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/AIFBaseCurrencyDescription/BaseCurrency = 'EUR')"> 
                    <xsl:if test="not(AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/AIFBaseCurrencyDescription/FXEURRate)">
                <error>
                    <record><xsl:value-of select="$fund" /></record>
                    <code>CAF-030</code>
                    <message></message>
                    <field>FXEURRate</field>
                    <value><xsl:value-of select="FXEURRate" /></value>
                </error>
                    </xsl:if>
                </xsl:when> 
                <xsl:otherwise> 
                    <xsl:if test="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/AIFBaseCurrencyDescription/FXEURRate">
                <error>
                    <record><xsl:value-of select="$fund" /></record>
                    <code>CAF-030</code>
                    <message></message>
                    <field>FXEURRate</field>
                    <value><xsl:value-of select="FXEURRate" /></value>
                </error>
                    </xsl:if>
                </xsl:otherwise> 
            </xsl:choose>

            <xsl:choose> 
                <xsl:when test="AIFNoReportingFlag = 'false' and not(AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/AIFBaseCurrencyDescription/BaseCurrency = 'EUR')"> 
                    <xsl:if test="not(AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/AIFBaseCurrencyDescription/FXEURReferenceRateType)">
                <error>
                    <record><xsl:value-of select="$fund" /></record>
                    <code>CAF-031</code>
                    <message></message>
                    <field>FXEURReferenceRateType</field>
                    <value><xsl:value-of select="FXEURReferenceRateType" /></value>
                </error>
                    </xsl:if>
                </xsl:when> 
                <xsl:otherwise> 
                    <xsl:if test="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/AIFBaseCurrencyDescription/FXEURReferenceRateType">
                <error>
                    <record><xsl:value-of select="$fund" /></record>
                    <code>CAF-031</code>
                    <message></message>
                    <field>FXEURReferenceRateType</field>
                    <value><xsl:value-of select="FXEURReferenceRateType" /></value>
                </error>
                    </xsl:if>
                </xsl:otherwise> 
            </xsl:choose>

            <xsl:choose> 
                <xsl:when test="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/AIFBaseCurrencyDescription/FXEURReferenceRateType = 'OTH'"> 
                    <xsl:if test="not(AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/AIFBaseCurrencyDescription/FXEUROtherReferenceRateDescription)">
                <error>
                    <record><xsl:value-of select="$fund" /></record>
                    <code>CAF-032</code>
                    <message></message>
                    <field>FXEUROtherReferenceRateDescription</field>
                    <value><xsl:value-of select="FXEUROtherReferenceRateDescription" /></value>
                </error>
                    </xsl:if>
                </xsl:when> 
                <xsl:otherwise> 
                    <xsl:if test="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/AIFBaseCurrencyDescription/FXEUROtherReferenceRateDescription">
                <error>
                    <record><xsl:value-of select="$fund" /></record>
                    <code>CAF-032</code>
                    <message></message>
                    <field>FXEUROtherReferenceRateDescription</field>
                    <value><xsl:value-of select="FXEUROtherReferenceRateDescription" /></value>
                </error>
                    </xsl:if>
                </xsl:otherwise> 
            </xsl:choose>

            <xsl:variable name="firstfundingsourcecountry" select="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/FirstFundingSourceCountry" />
            <xsl:if test="$firstfundingsourcecountry and not($countrycodes[. = $firstfundingsourcecountry])" >
                <error>
                    <record><xsl:value-of select="$fund" /></record>
                    <code>CAF-033</code>
                    <message>The first funding country is not correct.</message>
                    <field>FirstFundingSourceCountry</field>
                    <value><xsl:value-of select="$firstfundingsourcecountry" /></value>
                </error>
            </xsl:if>

            <xsl:variable name="secondfundingsourcecountry" select="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/SecondFundingSourceCountry" />
            <xsl:if test="$secondfundingsourcecountry and not($countrycodes[. = $secondfundingsourcecountry])" >
                <error>
                    <record><xsl:value-of select="$fund" /></record>
                    <code>CAF-034</code>
                    <message>The second funding country is not correct.</message>
                    <field>SecondFundingSourceCountry</field>
                    <value><xsl:value-of select="$secondfundingsourcecountry" /></value>
                </error>
            </xsl:if>

            <xsl:variable name="thirdfundingsourcecountry" select="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/ThirdFundingSourceCountry" />
            <xsl:if test="$thirdfundingsourcecountry and not($countrycodes[. = $thirdfundingsourcecountry])" >
                <error>
                    <record><xsl:value-of select="$fund" /></record>
                    <code>CAF-035</code>
                    <message>The third funding country is not correct.</message>
                    <field>ThirdFundingSourceCountry</field>
                    <value><xsl:value-of select="$thirdfundingsourcecountry" /></value>
                </error>
            </xsl:if>

            <xsl:variable name="predominantaiftype" select="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/PredominantAIFType" />
            <xsl:choose>
                <xsl:when test="$predominantaiftype = 'HFND'">
                    <xsl:if test="not(AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/HedgeFundInvestmentStrategies/HedgeFundStrategy)">
                <error>
                    <record><xsl:value-of select="$fund" /></record>
                    <code>CAF-036</code>
                    <message>The investment strategy code is not consistent with the predominant AIF type.</message>
                    <field>HedgeFundStrategy</field>
                    <value></value>
                </error>
                    </xsl:if>
                </xsl:when>
                <xsl:when test="$predominantaiftype = 'PEQF'">
                    <xsl:if test="not(AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/PrivateEquityFundInvestmentStrategies/PrivateEquityFundInvestmentStrategy)">
                <error>
                    <record><xsl:value-of select="$fund" /></record>
                    <code>CAF-036</code>
                    <message>The investment strategy code is not consistent with the predominant AIF type.</message>
                    <field>PrivateEquityFundInvestmentStrategy</field>
                    <value></value>
                </error>
                    </xsl:if>
                </xsl:when>
                <xsl:when test="$predominantaiftype = 'RESF'">
                    <xsl:if test="not(AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/RealEstateFundInvestmentStrategies/RealEstateFundStrategy)">
                <error>
                    <record><xsl:value-of select="$fund" /></record>
                    <code>CAF-036</code>
                    <message>The investment strategy code is not consistent with the predominant AIF type.</message>
                    <field>RealEstateFundStrategy</field>
                    <value></value>
                </error>
                    </xsl:if>
                </xsl:when>
                <xsl:when test="$predominantaiftype = 'FOFS'">
                    <xsl:if test="not(AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/FundOfFundsInvestmentStrategies/FundOfFundsStrategy)">
                <error>
                    <record><xsl:value-of select="$fund" /></record>
                    <code>CAF-036</code>
                    <message>The investment strategy code is not consistent with the predominant AIF type.</message>
                    <field>FundOfFundsStrategy</field>
                    <value></value>
                </error>
                    </xsl:if>
                </xsl:when>
                <xsl:when test="$predominantaiftype = 'OTHR'">
                    <xsl:if test="not(AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/OtherFundInvestmentStrategies/OtherFundStrategy)">
                <error>
                    <record><xsl:value-of select="$fund" /></record>
                    <code>CAF-036</code>
                    <message>The investment strategy code is not consistent with the predominant AIF type.</message>
                    <field>OtherFundStrategy</field>
                    <value></value>
                </error>
                    </xsl:if> 
                </xsl:when>
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
                <error>
                    <record><xsl:value-of select="$fund" /></record>
                    <code>CAF-037</code>
                    <message>The investment strategy code is not allowed.</message>
                    <field></field>
                    <value></value>
                </error>
                </xsl:if>
            </xsl:if>

            <xsl:variable name="hedgefundstrategytype" select="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/HedgeFundInvestmentStrategies/HedgeFundStrategy/HedgeFundStrategyType" />
            <xsl:if test="$hedgefundstrategytype = 'MULT_HFND'"> 
                <xsl:variable name="count" select="count(AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/HedgeFundInvestmentStrategies/HedgeFundStrategy/HedgeFundStrategyType[.!='MULT_HFND'])"/>
                <xsl:if test="$count &lt; 2">
                <error>
                    <record><xsl:value-of select="$fund" /></record>
                    <code>CAF-037</code>
                    <message>The investment strategy code is not allowed.</message>
                    <field>HedgeFundStrategyType</field>
                    <value><xsl:value-of select="$hedgefundstrategytype" /></value>
                </error>
                </xsl:if>
            </xsl:if> 

            <xsl:variable name="privateequityfundinvestmentstrategy" select="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/PrivateEquityFundInvestmentStrategies/PrivateEquityFundInvestmentStrategy/PrivateEquityFundStrategyType" />
            <xsl:if test="$privateequityfundinvestmentstrategy = 'MULT_HFND'"> 
                <xsl:variable name="count" select="count(AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/PrivateEquityFundInvestmentStrategies/PrivateEquityFundInvestmentStrategy/PrivateEquityFundStrategyType[.!='MULT_PEQF'])"/>
                <xsl:if test="$count &lt; 2">
                <error>
                    <record><xsl:value-of select="$fund" /></record>
                    <code>CAF-037</code>
                    <message>The investment strategy code is not allowed.</message>
                    <field>PrivateEquityFundStrategyType</field>
                    <value><xsl:value-of select="$privateequityfundinvestmentstrategy" /></value>
                </error>
                </xsl:if>
            </xsl:if> 

            <xsl:variable name="realestatefundStrategytype" select="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/RealEstateFundInvestmentStrategies/RealEstateFundStrategy/RealEstateFundStrategyType" />
            <xsl:if test="$realestatefundStrategytype = 'MULT_HFND'"> 
                <xsl:variable name="count" select="count(AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/RealEstateFundInvestmentStrategies/RealEstateFundStrategy/RealEstateFundStrategyType[.!='MULT_REST'])"/>
                <xsl:if test="$count &lt; 2">
                <error>
                    <record><xsl:value-of select="$fund" /></record>
                    <code>CAF-037</code>
                    <message>The investment strategy code is not allowed.</message>
                    <field>RealEstateFundStrategyType</field>
                    <value><xsl:value-of select="$realestatefundStrategytype" /></value>
                </error>
                </xsl:if>
            </xsl:if> 

            <xsl:if test="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/PrivateEquityFundInvestmentStrategies/PrivateEquityFundInvestmentStrategy[PrivateEquityFundStrategyType = 'MULT_PEQF' and not(PrimaryStrategyFlag = 'true')]"> 
                <error>
                    <record><xsl:value-of select="$fund" /></record>
                    <code>CAF-038</code>
                    <message>Multi strategies investment strategies should be primary strategies.</message>
                    <field>PrimaryStrategyFlag</field>
                    <value></value>
                </error>
            </xsl:if>

            <xsl:if test="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/HedgeFundInvestmentStrategies/HedgeFundStrategy[HedgeFundStrategyType = 'MULT_HFND' and not(PrimaryStrategyFlag = 'true')]"> 
                <error>
                    <record><xsl:value-of select="$fund" /></record>
                    <code>CAF-038</code>
                    <message>Multi strategies investment strategies should be primary strategies.</message>
                    <field>PrimaryStrategyFlag</field>
                    <value></value>
                </error>
            </xsl:if>

            <xsl:if test="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/RealEstateFundInvestmentStrategies/RealEstateFundStrategy[RealEstateFundStrategyType = 'MULT_REST' and not(PrimaryStrategyFlag = 'true')]"> 
                <error>
                    <record><xsl:value-of select="$fund" /></record>
                    <code>CAF-038</code>
                    <message>Multi strategies investment strategies should be primary strategies.</message>
                    <field>PrimaryStrategyFlag</field>
                    <value></value>
                </error>
            </xsl:if>

            <xsl:variable name="strategynavrates" select="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/*/*/StrategyNAVRate" />
            <xsl:if test="not(sum($strategynavrates) = 100)">
                <error>
                    <record><xsl:value-of select="$fund" /></record>
                    <code>CAF-039</code>
                    <message>For the reported AIF, the sum of all the reported investment strategy NAV percentages should be 100%</message>
                    <field>StrategyNAVRate</field>
                    <value><xsl:value-of select="sum($strategynavrates)" /></value>
                </error>
            </xsl:if>

            <xsl:variable name="hstrategies" select="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/HedgeFundInvestmentStrategies/HedgeFundStrategy[HedgeFundStrategyType = 'MULT_HFND'] " />
            <xsl:if test="$hstrategies">
                <xsl:for-each select="$hstrategies">
                    <xsl:variable name="strategynavrate" select="StrategyNAVRate"/>
                    <xsl:if test="$strategynavrate">
                <error>
                    <record><xsl:value-of select="$fund" /></record>
                    <code>CAF-040</code>
                    <message>There is no NAV percentage reported for multi strategies investment strategies.</message>
                    <field>StrategyNAVRate</field>
                    <value><xsl:value-of select="$strategynavrate" /></value>
                </error>
                    </xsl:if>
                </xsl:for-each>
            </xsl:if>

            <xsl:variable name="pstrategies" select="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/PrivateEquityFundInvestmentStrategies/PrivateEquityFundInvestmentStrategy[PrivateEquityFundStrategyType = 'MULT_HFND'] " />
            <xsl:if test="$pstrategies">
                <xsl:for-each select="$pstrategies">
                    <xsl:variable name="strategynavrate" select="StrategyNAVRate"/>
                    <xsl:if test="$ptrategynavrate">
                <error>
                    <record><xsl:value-of select="$fund" /></record>
                    <code>CAF-040</code>
                    <message>There is no NAV percentage reported for multi strategies investment strategies.</message>
                    <field>StrategyNAVRate</field>
                    <value><xsl:value-of select="$strategynavrate" /></value>
                </error>
                    </xsl:if>
                </xsl:for-each>
            </xsl:if>

            <xsl:variable name="rstrategies" select="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/RealEstateFundInvestmentStrategies/RealEstateFundStrategy[RealEstateFundStrategyType = 'MULT_REST'] " />
            <xsl:if test="$rstrategies">
                <xsl:for-each select="$rstrategies">
                    <xsl:variable name="strategynavrate" select="StrategyNAVRate"/>
                    <xsl:if test="$strategynavrate">
                <error>
                    <record><xsl:value-of select="$fund" /></record>
                    <code>CAF-040</code>
                    <message>There is no NAV percentage reported for multi strategies investment strategies.</message>
                    <field>StrategyNAVRate</field>
                    <value><xsl:value-of select="$strategynavrate" /></value>
                </error>
                    </xsl:if>
                </xsl:for-each>
            </xsl:if>

            <xsl:for-each select="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/HedgeFundInvestmentStrategies/HedgeFundStrategy">
                <xsl:variable name="strategytype" select="HedgeFundStrategyType" />
                <xsl:variable name="isother" select="$strategytype = 'OTHR_HFND'" />
                <xsl:variable name="description" select="StrategyTypeOtherDescription" />
                <xsl:if test="boolean($description) != $isother">
                <error>
                    <record><xsl:value-of select="$fund" /></record>
                    <code>CAF-041</code>
                    <message>The investement strategy code description is not consistent with the reported investment strategy code.</message>
                    <field>StrategyTypeOtherDescription</field>
                    <value><xsl:value-of select="$description" /></value>
                </error>
                </xsl:if>
            </xsl:for-each>

            <xsl:for-each select="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/PrivateEquityFundInvestmentStrategies/PrivateEquityFundInvestmentStrategy">
                <xsl:variable name="strategytype" select="PrivateEquityFundStrategyType" />
                <xsl:variable name="isother" select="$strategytype = 'OTHR_PEQF'" />
                <xsl:variable name="description" select="StrategyTypeOtherDescription" />
                <xsl:if test="boolean($description) != $isother">
                <error>
                    <record><xsl:value-of select="$fund" /></record>
                    <code>CAF-041</code>
                    <message>The investement strategy code description is not consistent with the reported investment strategy code.</message>
                    <field>StrategyTypeOtherDescription</field>
                    <value><xsl:value-of select="$description" /></value>
                </error>
                </xsl:if>
            </xsl:for-each>

            <xsl:for-each select="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/RealEstateFundInvestmentStrategies/RealEstateFundStrategy">
                <xsl:variable name="strategytype" select="RealEstateFundStrategyType" />
                <xsl:variable name="isother" select="$strategytype = 'OTHR_REST'" />
                <xsl:variable name="description" select="StrategyTypeOtherDescription" />
                <xsl:if test="boolean($description) != $isother">
                <error>
                    <record><xsl:value-of select="$fund" /></record>
                    <code>CAF-041</code>
                    <message>The investement strategy code description is not consistent with the reported investment strategy code.</message>
                    <field>StrategyTypeOtherDescription</field>
                    <value><xsl:value-of select="$description" /></value>
                </error>
                </xsl:if>
            </xsl:for-each>

            <xsl:for-each select="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/FundOfFundsInvestmentStrategies/FundOfFundsStrategy">
                <xsl:variable name="strategytype" select="FundOfFundsStrategyType" />
                <xsl:variable name="isother" select="$strategytype = 'OTHR_FOFS'" />
                <xsl:variable name="description" select="StrategyTypeOtherDescription" />
                <xsl:if test="boolean($description) != $isother">
                <error>
                    <record><xsl:value-of select="$fund" /></record>
                    <code>CAF-041</code>
                    <message>The investement strategy code description is not consistent with the reported investment strategy code.</message>
                    <field>StrategyTypeOtherDescription</field>
                    <value><xsl:value-of select="$description" /></value>
                </error>
                </xsl:if>
            </xsl:for-each>

            <xsl:for-each select="AIFCompleteDescription/AIFPrincipalInfo/AIFDescription/OtherFundInvestmentStrategies/OtherFundStrategy">
                <xsl:variable name="strategytype" select="OtherFundStrategyType" />
                <xsl:variable name="isother" select="$strategytype = 'OTHR_OTHF'" />
                <xsl:variable name="description" select="StrategyTypeOtherDescription" />
                <xsl:if test="boolean($description) != $isother">
                <error>
                    <record><xsl:value-of select="$fund" /></record>
                    <code>CAF-041</code>
                    <message>The investement strategy code description is not consistent with the reported investment strategy code.</message>
                    <field>StrategyTypeOtherDescription</field>
                    <value><xsl:value-of select="$description" /></value>
                </error>
                </xsl:if>
            </xsl:for-each>

            <xsl:for-each select="AIFCompleteDescription/AIFPrincipalInfo/MainInstrumentsTraded/MainInstrumentTraded">
                <xsl:variable name="subassettype" select="SubAssetType" />
                <xsl:variable name="isnota" select="$subassettype = 'NTA_NTA_NOTA'" />

                <xsl:variable name="instrumentcodetype" select="InstrumentCodeType" />
                <xsl:variable name="hascodetype" select="boolean($instrumentcodetype)" />

                <xsl:if test="$hascodetype = $isnota">

                <error>
                    <record><xsl:value-of select="$fund" /></record>
                    <code>CAF-042</code>
                    <message>The instrument code type is not consistent with the sub-asset type.</message>
                    <field>InstrumentCodeType</field>
                    <value><xsl:value-of select="$instrumentcodetype" /></value>
                </error>
                </xsl:if>
            </xsl:for-each>

            <xsl:for-each select="AIFCompleteDescription/AIFPrincipalInfo/MainInstrumentsTraded/MainInstrumentTraded">
                <xsl:variable name="subassettype" select="SubAssetType" />
                <xsl:variable name="isnota" select="$subassettype = 'NTA_NTA_NOTA'" />

                <xsl:variable name="instrumentname" select="InstrumentName" />
                <xsl:variable name="hasname" select="boolean($instrumentname)" />

                <xsl:if test="$hasname = $isnota">

                <error>
                    <record><xsl:value-of select="$fund" /></record>
                    <code>CAF-043</code>
                    <message>The instrument name is not consistent with the sub-asset type.</message>
                    <field>InstrumentName</field>
                    <value><xsl:value-of select="$instrumentname" /></value>
                </error>
                </xsl:if>
            </xsl:for-each>

            <xsl:for-each select="AIFCompleteDescription/AIFPrincipalInfo/MainInstrumentsTraded/MainInstrumentTraded/ISINInstrumentIdentification">
                <xsl:variable name="isin" select="." />
                <xsl:if test="$isin and not($isinregister[. = $isin])" >
                <error>
                    <record><xsl:value-of select="$fund" /></record>
                    <code>CAF-044</code>
                    <message>The check digit of the ISIN code is not correct.</message>
                    <field>ISINInstrumentIdentification</field>
                    <value><xsl:value-of select="$isin" /></value>
                </error>
                </xsl:if>
            </xsl:for-each>

            <xsl:for-each select="AIFCompleteDescription/AIFPrincipalInfo/MainInstrumentsTraded/MainInstrumentTraded">
                <xsl:if test="boolean(InstrumentCodeType = 'ISIN') != boolean(ISINInstrumentIdentification)">
                <error>
                    <record><xsl:value-of select="$fund" /></record>
                    <code>CAF-045</code>
                    <message>The instrument ISIN code is not consistent with the instrument code type.</message>
                    <field>ISINInstrumentIdentification</field>
                    <value><xsl:value-of select="ISINInstrumentIdentification" /></value>
                </error>
                </xsl:if>
            </xsl:for-each>

            <xsl:for-each select="AIFCompleteDescription/AIFPrincipalInfo/MainInstrumentsTraded/MainInstrumentTraded/AIIInstrumentIdentification/AIIExchangeCode">
                <xsl:variable name="mic" select="." />
                <xsl:if test="$mic and not($micregister[. = $mic])" >
                <error>
                    <record><xsl:value-of select="$fund" /></record>
                    <code>CAF-046</code>
                    <message>The MIC code is not correct</message>
                    <field>AIIExchangeCode</field>
                    <value><xsl:value-of select="$mic" /></value>
                </error>
                </xsl:if>
            </xsl:for-each>

            <xsl:for-each select="AIFCompleteDescription/AIFPrincipalInfo/MainInstrumentsTraded/MainInstrumentTraded">
                <xsl:if test="boolean(InstrumentCodeType = 'AII') != boolean(AIIInstrumentIdentification/AIIExchangeCode)">
                <error>
                    <record><xsl:value-of select="$fund" /></record>
                    <code>CAF-047</code>
                    <message>The instrument AII exchange code is not consistent with the instrument code type.</message>
                    <field>AIIExchangeCode</field>
                    <value><xsl:value-of select="AIIInstrumentIdentification/AIIExchangeCode" /></value>
                </error>
                </xsl:if>
            </xsl:for-each>

            <xsl:for-each select="AIFCompleteDescription/AIFPrincipalInfo/MainInstrumentsTraded/MainInstrumentTraded">
                <xsl:if test="boolean(InstrumentCodeType = 'AII') != boolean(AIIInstrumentIdentification/AIIProductCode)">
                <error>
                    <record><xsl:value-of select="$fund" /></record>
                    <code>CAF-048</code>
                    <message>The instrument AII exchange product code is not consistent with the instrument code type.</message>
                    <field>AIIProductCode</field>
                    <value><xsl:value-of select="AIIInstrumentIdentification/AIIProductCode" /></value>
                </error>
                </xsl:if>
            </xsl:for-each>

            <xsl:for-each select="AIFCompleteDescription/AIFPrincipalInfo/MainInstrumentsTraded/MainInstrumentTraded">
                <xsl:if test="boolean(InstrumentCodeType = 'AII') != boolean(AIIInstrumentIdentification/AIIDerivativeType)">
                <error>
                    <record><xsl:value-of select="$fund" /></record>
                    <code>CAF-049</code>
                    <message>The instrument AII derivative type is not consistent with the instrument code type.</message>
                    <field>AIIDerivativeType</field>
                    <value><xsl:value-of select="AIIInstrumentIdentification/AIIDerivativeType" /></value>
                </error>
                </xsl:if>
            </xsl:for-each>

            <xsl:for-each select="AIFCompleteDescription/AIFPrincipalInfo/MainInstrumentsTraded/MainInstrumentTraded">
                <xsl:if test="boolean(InstrumentCodeType = 'AII') != boolean(AIIInstrumentIdentification/AIIPutCallIdentifier)">
                <error>
                    <record><xsl:value-of select="$fund" /></record>
                    <code>CAF-050</code>
                    <message>The instrument put/call identifier is not consistent with the instrument code type.</message>
                    <field>AIIPutCallIdentifier</field>
                    <value><xsl:value-of select="AIIInstrumentIdentification/AIIPutCallIdentifier" /></value>
                </error>
                </xsl:if>
            </xsl:for-each>

            <xsl:for-each select="AIFCompleteDescription/AIFPrincipalInfo/MainInstrumentsTraded/MainInstrumentTraded">
                <xsl:if test="boolean(InstrumentCodeType = 'AII') != boolean(AIIInstrumentIdentification/AIIExpiryDate)">
                <error>
                    <record><xsl:value-of select="$fund" /></record>
                    <code>CAF-051</code>
                    <message>The instrument AII expiry date is not consistent with the instrument code type.</message>
                    <field>AIIExpiryDate</field>
                    <value><xsl:value-of select="AIIInstrumentIdentification/AIIExpiryDate" /></value>
                </error>
                </xsl:if>
            </xsl:for-each>

            <xsl:for-each select="AIFCompleteDescription/AIFPrincipalInfo/MainInstrumentsTraded/MainInstrumentTraded">
                <xsl:if test="boolean(InstrumentCodeType = 'AII') != boolean(AIIInstrumentIdentification/AIIStrikePrice)">
                <error>
                    <record><xsl:value-of select="$fund" /></record>
                    <code>CAF-052</code>
                    <message>The instrument AII strike price is not consistent with the instrument code type.</message>
                    <field>AIIStrikePrice</field>
                    <value><xsl:value-of select="AIIInstrumentIdentification/AIIStrikePrice" /></value>
                </error>
                </xsl:if>
            </xsl:for-each>

            <xsl:for-each select="AIFCompleteDescription/AIFPrincipalInfo/MainInstrumentsTraded/MainInstrumentTraded">
                <xsl:if test="boolean(SubAssetType = 'NTA_NTA_NOTA') = boolean(PositionType)">
                <error>
                    <record><xsl:value-of select="$fund" /></record>
                    <code>CAF-053</code>
                    <message>The position type is not consistent with the sub-asset type.</message>
                    <field>PositionType</field>
                    <value><xsl:value-of select="PositionType" /></value>
                </error>
                </xsl:if>
            </xsl:for-each>

            <xsl:for-each select="AIFCompleteDescription/AIFPrincipalInfo/MainInstrumentsTraded/MainInstrumentTraded">
                <xsl:if test="boolean(SubAssetType = 'NTA_NTA_NOTA') = boolean(PositionValue)">
                <error>
                    <record><xsl:value-of select="$fund" /></record>
                    <code>CAF-054</code>
                    <message>The position value is not consistent with the sub-asset type.</message>
                    <field>PositionValue</field>
                    <value><xsl:value-of select="PositionValue" /></value>
                </error>
                </xsl:if>
            </xsl:for-each>

<!-- skip CAF-055 for now -->

            <xsl:for-each select="AIFCompleteDescription/AIFPrincipalInfo/MainInstrumentsTraded/MainInstrumentTraded">
                <xsl:if test="not(PositionType = 'S') and boolean(ShortPositionHedgingRate)">
                <error>
                    <record><xsl:value-of select="$fund" /></record>
                    <code>CAF-056</code>
                    <message>The position value is not consistent with the position type.</message>
                    <field>ShortPositionHedgingRate</field>
                    <value><xsl:value-of select="ShortPositionHedgingRate" /></value>
                </error>
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
</aif>
    </xsl:template>

</xsl:transform>
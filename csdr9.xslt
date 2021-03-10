<xsl:transform
        version="1.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:func="http://exslt.org/functions"
        xmlns:str="http://exslt.org/strings"
        xmlns:my="http://example.org/my"
        exclude-result-prefixes="my"
        extension-element-prefixes="func str">

    <xsl:include href="common.xslt" />

    <xsl:output
            indent="yes"
            method="xml" />

    <xsl:variable
            name="eeacountrycodes"
            select="document('data/eea-countries.xml')/codes/code" />

    <!-- FIL-* not applicable -->

    <xsl:template match="/Document/SttlmIntlrRpt/RptHdr">
        <xsl:if test="Ccy != 'EUR'">
            INS-001 The Currency is not valid. Only the value "EUR" is expected.
        </xsl:if>

        <xsl:variable
                name="reportingperiod"
                select="RptgDt" />
        <xsl:variable
                name="date"
                select="substring($reportingperiod,6,5)" />
        <xsl:if test="not($date='03-31' or $date='06-30' or $date='09-30' or $date='12-31')">
            INS-002 The date [
            <xsl:value-of select="RptgDt" />
            ] is not valid. One of YYYY-03-31, YYYY-06-30, YYYY-09-30 or YYYY-12-31 is expected, where YYYY is the year of the report.
        </xsl:if>

    </xsl:template>

    <!-- INS-003 requires filename -->

    <xsl:template match="/Document/SttlmIntlrRpt/SttlmIntlr/Id">
        <xsl:if test="not(my:ISO17442(LEI))">
            INS-013 The LEI [
            <xsl:value-of select="LEI" />
            ] is not valid according to ISO 17442.
        </xsl:if>

        <!-- INS-014.1 requires filename -->

        <!-- INS-014.2 requires filename -->

        <xsl:variable
                name="branchid"
                select="BrnchId" />

        <xsl:if test="boolean($branchid) and not($eeacountrycodes[. = $branchid] or $branchid = 'TS')">
            INS-014.3 The branch country code [
            <xsl:value-of select="$branchid" />
            ] is not valid, since it must relate either to an EEA country code or to a Third Country State (i.e. 'TS').
        </xsl:if>
    </xsl:template>


    <xsl:template match="text()|@*">
        <!-- <xsl:value-of select="."/> -->
    </xsl:template>

</xsl:transform>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" >
    <xsl:variable name="countrycodes" select="document('iso-3166-1.xml')/codes/code" />
    <xsl:variable name="currencycodes" select="document('iso-4217.xml')/codes/code" />
    <xsl:variable name="eeacountrycodes" select="document('eea-countries.xml')/codes/code" />
    <xsl:variable name="aifmregister" select="document('aifm-register.xml')/codes/code" />
    <xsl:variable name="micregister" select="document('mic-register.xml')/codes/code" />    
    <xsl:include href="aifm.xsl" />
    <xsl:include href="aif.xsl" />
</xsl:stylesheet>
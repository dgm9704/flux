<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" >
    <xsl:variable name="countrycodes" select="document('register/iso-3166-1.xml')/codes/code" />
    <xsl:variable name="currencycodes" select="document('register/iso-4217.xml')/codes/code" />
    <xsl:variable name="eeacountrycodes" select="document('register/eea-countries.xml')/codes/code" />
    <xsl:variable name="aifmregister" select="document('register/aifm-register.xml')/codes/code" />
    <xsl:variable name="micregister" select="document('register/mic-register.xml')/codes/code" />    
    <xsl:variable name="leiregister" select="document('register/lei-register.xml')/codes/code" />    
    <xsl:include href="aifm.xsl" />
    <xsl:include href="aif.xsl" />
</xsl:stylesheet>
<xsl:transform
		version="1.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:exsl="http://exslt.org/common"
		xmlns:func="http://exslt.org/functions"
		xmlns:str="http://exslt.org/strings"
		xmlns:my="http://example.org/my"
		xmlns="http://www.w3.org/1999/xhtml" 
		xmlns:ix="http://www.xbrl.org/2013/inlineXBRL" 
		xmlns:xbrli="http://www.xbrl.org/2003/instance" 
		xmlns:gleif="http://www.gleif.org/20200422" 
		xmlns:link="http://www.xbrl.org/2003/linkbase" 
		xmlns:xbrldi="http://xbrl.org/2006/xbrldi" 
		xmlns:iso4217="http://www.xbrl.org/2003/iso4217" 
		xmlns:xlink="http://www.w3.org/1999/xlink" 
		xmlns:ixt="http://www.xbrl.org/inlineXBRL/transformation/2020-02-12" 
		xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
		xmlns:ifrs-full="http://xbrl.ifrs.org/taxonomy/2019-03-27/ifrs-full" 
		xmlns:esef_cor="http://www.esma.europa.eu/taxonomy/2019-03-27/esef_cor" 
		exclude-result-prefixes="my"
		extension-element-prefixes="func str exsl">

	<xsl:output
			indent="yes"
			method="xml" />
	
	<!-- report -->
	<xsl:template match="/">
		<xbrli:xbrl>
			<xsl:apply-templates />
		</xbrli:xbrl>
	</xsl:template>

	<!-- entrypoint -->
    <xsl:template match="ix:header/ix:references/link:schemaRef">
		<xsl:copy-of select="."/>
	</xsl:template>

	<!-- unit -->
	<xsl:template match="ix:header/ix:resources/xbrli:unit">
		<xsl:copy-of select="."/>
	</xsl:template>

	<!-- context -->
    <xsl:template match="ix:header/ix:resources/xbrli:context">
		<xsl:copy-of select="."/> 
    </xsl:template>

	<!-- fact -->
	<xsl:template match="ix:*[@contextRef!='']">
		<xsl:element name="{@name}">
			<xsl:attribute name="contextRef">
				<xsl:value-of select="@contextRef"/>
			</xsl:attribute>
			<xsl:if test="@unitRef">
				<xsl:attribute name="unitRef">
					<xsl:value-of select="@unitRef"/>
				</xsl:attribute>
			</xsl:if>
			<xsl:if test="@decimals">
				<xsl:attribute name="decimals">
					<xsl:value-of select="@decimals"/>
				</xsl:attribute>
			</xsl:if>
     		<xsl:value-of select="."/>
   		</xsl:element>		
	</xsl:template>

	<xsl:template match="text()">
		<!-- <xsl:value-of select="."/> -->
	</xsl:template>

</xsl:transform>
<xsl:transform
        version="1.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:func="http://exslt.org/functions"
        xmlns:str="http://exslt.org/strings"
        xmlns:my="http://example.org/my"
        exclude-result-prefixes="my"
        extension-element-prefixes="func str">

    <xsl:output
            indent="yes"
            method="xml" />

    <func:function name="my:ISO17442">
        <xsl:param name="lei" />
        <func:result select="my:modulo(my:convert($lei), 97) = 1" />
    </func:function>

    <func:function name="my:convert">
        <xsl:param name="value" />
        <func:result select="
        str:replace(
        str:replace(
        str:replace(
        str:replace(
        str:replace(
        str:replace(
        str:replace(
        str:replace(
        str:replace(
        str:replace(
        str:replace(
        str:replace(
        str:replace(
        str:replace(
        str:replace(
        str:replace(
        str:replace(
        str:replace(
        str:replace(
        str:replace(
        str:replace(
        str:replace(
        str:replace(
        str:replace(
        str:replace(
        str:replace($value,
            'A','10'),
            'B','11'),
            'C','12'),
            'D','13'),
            'E','14'),
            'F','15'),
            'G','16'),
            'H','17'),
            'I','18'),
            'J','19'),
            'K','20'),
            'L','21'),
            'M','22'),
            'N','23'),
            'O','24'),
            'P','25'),
            'Q','26'),
            'R','27'),
            'S','28'),
            'T','29'),
            'U','30'),
            'V','31'),
            'W','32'),
            'X','33'),
            'Y','34'),
            'Z','35')" />
    </func:function>

    <func:function name="my:modulo">
        <xsl:param name="dividend" />
        <xsl:param name="divisor" />

        <xsl:choose>
            <xsl:when test="not($dividend > 9999999999999999)">
                <func:result select="$dividend mod $divisor" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable
                        name="vLen"
                        select="string-length($dividend)" />

                <xsl:variable
                        name="vLen1"
                        select="$vLen -1" />

                <xsl:variable
                        name="vPart1"
                        select="substring($dividend, 1, $vLen1)" />

                <xsl:variable
                        name="vPart2"
                        select="substring($dividend, $vLen1 +1)" />

                <xsl:variable
                        name="vMod1"
                        select="my:modulo($vPart1, $divisor)" />

                <xsl:variable
                        name="vMod2"
                        select="$vPart2 mod $divisor" />

                <func:result select="(10*$vMod1 + $vMod2) mod $divisor" />
            </xsl:otherwise>
        </xsl:choose>
    </func:function>

</xsl:transform>
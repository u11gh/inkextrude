<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet
    version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:svg="http://www.w3.org/2000/svg"
    xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:i2s="http://www.feja.eu/ink2scad/2020/xsl-functions"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    >

    <xsl:output method="text"/>
    <xsl:output name="xml" method="xml" indent="yes"/>

    <xsl:function name="i2s:basename" as="xs:string" >
        <xsl:param name="root" as="item()" />
        <xsl:variable name="baseuri" select="fn:tokenize(base-uri($root), '/')" />
        <xsl:value-of select="substring-before($baseuri[count($baseuri)], '.')" />
    </xsl:function>

    <xsl:template name="block" >
        <xsl:param name="header" as="item()" />
        <xsl:param name="content" as="item()" />
        <xsl:value-of select="$header" /><xsl:text> {&#xa;</xsl:text>
        <xsl:for-each select="fn:tokenize($content, '\n')" >
            <xsl:text>  </xsl:text><xsl:value-of select="." /><xsl:text>&#xa;</xsl:text>
        </xsl:for-each>
        <xsl:text>}</xsl:text>
    </xsl:template> 

    <xsl:template match="/">
        <xsl:apply-templates select="node()"/>
    </xsl:template>

    <xsl:template match="svg:svg" >
        <xsl:call-template name="openscad_header" />

        <xsl:apply-templates select="svg:g" mode="openscad_functions" />

        <xsl:text>&#xa;&#xa;&#xa;</xsl:text>
        <xsl:apply-templates select="." mode="openscad_main" />

        <xsl:apply-templates select="svg:g" mode="start_extract" />
    </xsl:template>

    <xsl:template name="openscad_header" >
        <xsl:text>// This file is automatically generated.
// If you want to rearrange the content include the SCAD file in your custom script.&#xa;&#xa;</xsl:text>
        <xsl:text>$fn=100;&#xa;&#xa;</xsl:text>
    </xsl:template>

    <xsl:template match="svg:g" mode="openscad_functions">

        <xsl:text>&#xa;</xsl:text>
        <xsl:call-template name="block" >
            <xsl:with-param name="header" select="concat('module ',i2s:basename(.),'_',@id,'(x=0, y=0, z=0, height=0, center=false, linex_scale=1)')" />
            <xsl:with-param name="content">
                <xsl:call-template name="block" >
                    <xsl:with-param name="header" select="string('translate([x,y,z])')" />
                    <xsl:with-param name="content" >
                        <xsl:call-template name="block" >
                            <xsl:with-param name="header" select="string('linear_extrude(height = height)')" />
                            <xsl:with-param name="content">
                                <xsl:text>import("</xsl:text><xsl:value-of select="concat('svg_gen/',i2s:basename(.),'_', @id, '.svg')" /><xsl:text>", center=center);</xsl:text>
                            </xsl:with-param>
                        </xsl:call-template>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:with-param>
        </xsl:call-template>
        <xsl:text>&#xa;</xsl:text>
    </xsl:template >

    <xsl:template match="svg:svg" mode="openscad_main">
        <xsl:call-template name="block" >
            <xsl:with-param name="header" select="concat('module ',i2s:basename(.),'()')" />
            <xsl:with-param name="content">
                <xsl:call-template name="block" >
                    <xsl:with-param name="header" select="string('difference()')" />
                    <xsl:with-param name="content" >
                        <xsl:call-template name="block" >
                            <xsl:with-param name="header" select="string('union()')" />
                            <xsl:with-param name="content" >
                                <xsl:apply-templates select="svg:g[not(contains(@inkscape:label, '/*diff*/'))]" mode="openscad_main" />
                            </xsl:with-param>
                        </xsl:call-template>
                        <xsl:text>&#xa;</xsl:text>
                        <xsl:call-template name="block" >
                            <xsl:with-param name="header" select="string('union()')" />
                            <xsl:with-param name="content" >
                                <xsl:apply-templates select="svg:g[contains(@inkscape:label, '/*diff*/')]" mode="openscad_main" />
                            </xsl:with-param>
                        </xsl:call-template>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:with-param>
        </xsl:call-template>
        <xsl:text>&#xa;&#xa;&#xa;</xsl:text>
        <xsl:value-of select="concat(i2s:basename(.),'();')" />
    </xsl:template>

    <xsl:template match="svg:g" mode="openscad_main">
        <xsl:value-of select="concat(i2s:basename(.),'_',@id,'(', @inkscape:label,');')" />
        <xsl:text>&#xa;</xsl:text>
    </xsl:template >



    <!-- Layer extract templates -->

    <xsl:template match="svg:g" mode="start_extract" >
        <xsl:variable name="filename" select="concat('svg_gen/', i2s:basename(.), '_', @id,'.svg')" />
        <xsl:result-document href="{$filename}" format="xml">
            <xsl:apply-templates select="/" mode="extract">
                <xsl:with-param name="layerId"><xsl:value-of select="@id" /></xsl:with-param>
            </xsl:apply-templates>
        </xsl:result-document>
    </xsl:template>

    <xsl:template match="/" mode="extract" >
        <xsl:param name="layerId" />
        <xsl:apply-templates select="@*|node()" mode="extract">
            <xsl:with-param name="layerId"><xsl:value-of select="$layerId" /></xsl:with-param>
        </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="@*|node()" mode="extract">
        <xsl:param name="layerId" />
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="extract">
                <xsl:with-param name="layerId"><xsl:value-of select="$layerId" /></xsl:with-param>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="svg:g" mode="extract">
        <xsl:param name="layerId" />
        <xsl:if test="@id=$layerId">
            <xsl:copy-of select="." />
        </xsl:if>
    </xsl:template>




</xsl:stylesheet>

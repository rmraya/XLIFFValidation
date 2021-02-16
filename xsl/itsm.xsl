<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<xsl:stylesheet xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                xmlns:saxon="http://saxon.sf.net/"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:schold="http://www.ascc.net/xml/schematron"
                xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                xmlns:xhtml="http://www.w3.org/1999/xhtml"
                xmlns:itsm="urn:oasis:names:tc:xliff:itsm:2.1"
                xmlns:xlf="urn:oasis:names:tc:xliff:document:2.0"
                xmlns:ctr="urn:oasis:names:tc:xliff:changetracking:2.1"
                version="2.0"><!--Implementers: please note that overriding process-prolog or process-root is 
    the preferred method for meta-stylesheets to use where possible. -->
   <xsl:param name="archiveDirParameter"/>
   <xsl:param name="archiveNameParameter"/>
   <xsl:param name="fileNameParameter"/>
   <xsl:param name="fileDirParameter"/>
   <xsl:variable name="document-uri">
      <xsl:value-of select="document-uri(/)"/>
   </xsl:variable>

   <!--PHASES-->


   <!--PROLOG-->
   <xsl:output xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
               method="xml"
               omit-xml-declaration="no"
               standalone="yes"
               indent="yes"/>

   <!--XSD TYPES FOR XSLT2-->


   <!--KEYS AND FUNCTIONS-->


   <!--DEFAULT RULES-->


   <!--MODE: SCHEMATRON-SELECT-FULL-PATH-->
   <!--This mode can be used to generate an ugly though full XPath for locators-->
   <xsl:template match="*" mode="schematron-select-full-path">
      <xsl:apply-templates select="." mode="schematron-get-full-path"/>
   </xsl:template>

   <!--MODE: SCHEMATRON-FULL-PATH-->
   <!--This mode can be used to generate an ugly though full XPath for locators-->
   <xsl:template match="*" mode="schematron-get-full-path">
      <xsl:apply-templates select="parent::*" mode="schematron-get-full-path"/>
      <xsl:text>/</xsl:text>
      <xsl:choose>
         <xsl:when test="namespace-uri()=''">
            <xsl:value-of select="name()"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>*:</xsl:text>
            <xsl:value-of select="local-name()"/>
            <xsl:text>[namespace-uri()='</xsl:text>
            <xsl:value-of select="namespace-uri()"/>
            <xsl:text>']</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:variable name="preceding"
                    select="count(preceding-sibling::*[local-name()=local-name(current())                                   and namespace-uri() = namespace-uri(current())])"/>
      <xsl:text>[</xsl:text>
      <xsl:value-of select="1+ $preceding"/>
      <xsl:text>]</xsl:text>
   </xsl:template>
   <xsl:template match="@*" mode="schematron-get-full-path">
      <xsl:apply-templates select="parent::*" mode="schematron-get-full-path"/>
      <xsl:text>/</xsl:text>
      <xsl:choose>
         <xsl:when test="namespace-uri()=''">@<xsl:value-of select="name()"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>@*[local-name()='</xsl:text>
            <xsl:value-of select="local-name()"/>
            <xsl:text>' and namespace-uri()='</xsl:text>
            <xsl:value-of select="namespace-uri()"/>
            <xsl:text>']</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <!--MODE: SCHEMATRON-FULL-PATH-2-->
   <!--This mode can be used to generate prefixed XPath for humans-->
   <xsl:template match="node() | @*" mode="schematron-get-full-path-2">
      <xsl:for-each select="ancestor-or-self::*">
         <xsl:text>/</xsl:text>
         <xsl:value-of select="name(.)"/>
         <xsl:if test="preceding-sibling::*[name(.)=name(current())]">
            <xsl:text>[</xsl:text>
            <xsl:value-of select="count(preceding-sibling::*[name(.)=name(current())])+1"/>
            <xsl:text>]</xsl:text>
         </xsl:if>
      </xsl:for-each>
      <xsl:if test="not(self::*)">
         <xsl:text/>/@<xsl:value-of select="name(.)"/>
      </xsl:if>
   </xsl:template>
   <!--MODE: SCHEMATRON-FULL-PATH-3-->
   <!--This mode can be used to generate prefixed XPath for humans 
	(Top-level element has index)-->
   <xsl:template match="node() | @*" mode="schematron-get-full-path-3">
      <xsl:for-each select="ancestor-or-self::*">
         <xsl:text>/</xsl:text>
         <xsl:value-of select="name(.)"/>
         <xsl:if test="parent::*">
            <xsl:text>[</xsl:text>
            <xsl:value-of select="count(preceding-sibling::*[name(.)=name(current())])+1"/>
            <xsl:text>]</xsl:text>
         </xsl:if>
      </xsl:for-each>
      <xsl:if test="not(self::*)">
         <xsl:text/>/@<xsl:value-of select="name(.)"/>
      </xsl:if>
   </xsl:template>

   <!--MODE: GENERATE-ID-FROM-PATH -->
   <xsl:template match="/" mode="generate-id-from-path"/>
   <xsl:template match="text()" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.text-', 1+count(preceding-sibling::text()), '-')"/>
   </xsl:template>
   <xsl:template match="comment()" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.comment-', 1+count(preceding-sibling::comment()), '-')"/>
   </xsl:template>
   <xsl:template match="processing-instruction()" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.processing-instruction-', 1+count(preceding-sibling::processing-instruction()), '-')"/>
   </xsl:template>
   <xsl:template match="@*" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.@', name())"/>
   </xsl:template>
   <xsl:template match="*" mode="generate-id-from-path" priority="-0.5">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:text>.</xsl:text>
      <xsl:value-of select="concat('.',name(),'-',1+count(preceding-sibling::*[name()=name(current())]),'-')"/>
   </xsl:template>

   <!--MODE: GENERATE-ID-2 -->
   <xsl:template match="/" mode="generate-id-2">U</xsl:template>
   <xsl:template match="*" mode="generate-id-2" priority="2">
      <xsl:text>U</xsl:text>
      <xsl:number level="multiple" count="*"/>
   </xsl:template>
   <xsl:template match="node()" mode="generate-id-2">
      <xsl:text>U.</xsl:text>
      <xsl:number level="multiple" count="*"/>
      <xsl:text>n</xsl:text>
      <xsl:number count="node()"/>
   </xsl:template>
   <xsl:template match="@*" mode="generate-id-2">
      <xsl:text>U.</xsl:text>
      <xsl:number level="multiple" count="*"/>
      <xsl:text>_</xsl:text>
      <xsl:value-of select="string-length(local-name(.))"/>
      <xsl:text>_</xsl:text>
      <xsl:value-of select="translate(name(),':','.')"/>
   </xsl:template>
   <!--Strip characters-->
   <xsl:template match="text()" priority="-1"/>

   <!--SCHEMA SETUP-->
   <xsl:template match="/">
      <svrl:schematron-output xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                              title="Schematron rules for checking the constraints of the ITS module against XLIFF Version 2.1"
                              schemaVersion="ISO19757-3">
         <xsl:comment>
            <xsl:value-of select="$archiveDirParameter"/>   
		 <xsl:value-of select="$archiveNameParameter"/>  
		 <xsl:value-of select="$fileNameParameter"/>  
		 <xsl:value-of select="$fileDirParameter"/>
         </xsl:comment>
         <svrl:ns-prefix-in-attribute-values uri="urn:oasis:names:tc:xliff:itsm:2.1" prefix="itsm"/>
         <svrl:ns-prefix-in-attribute-values uri="urn:oasis:names:tc:xliff:document:2.0" prefix="xlf"/>
         <svrl:ns-prefix-in-attribute-values uri="urn:oasis:names:tc:xliff:changetracking:2.1" prefix="ctr"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M5"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M6"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M7"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M8"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M9"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M10"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M11"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M12"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M13"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M14"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M15"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M16"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M17"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M18"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M19"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M20"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M21"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M22"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M23"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M24"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M25"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M26"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M27"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M28"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M29"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M30"/>
      </svrl:schematron-output>
   </xsl:template>

   <!--SCHEMATRON PATTERNS-->
   <svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Schematron rules for checking the constraints of the ITS module against XLIFF Version 2.1</svrl:text>

   <!--PATTERN -->


	  <!--RULE -->
   <xsl:template match="ctr:revision" priority="1000" mode="M5">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="ctr:revision"/>

		    <!--REPORT -->
      <xsl:if test="@itsm:*[not(name()='itsm:toolRef')][not(name()='itsm:tool')][not(name()='itsm:revToolRef')][not(name()='itsm:revTool')]                 [not(name()='itsm:revPersonRef')][not(name()='itsm:revPerson')][not(name()='itsm:revOrgRef')][not(name()='itsm:revOrg')]                 [not(name()='itsm:org')][not(name()='itsm:provenanceRecordsRef')][not(name()='itsm:personRef')][not(name()='itsm:person')]                 [not(name()='itsm:orgRef')][not(name()='itsm:annotatorsRef')]">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="@itsm:*[not(name()='itsm:toolRef')][not(name()='itsm:tool')][not(name()='itsm:revToolRef')][not(name()='itsm:revTool')] [not(name()='itsm:revPersonRef')][not(name()='itsm:revPerson')][not(name()='itsm:revOrgRef')][not(name()='itsm:revOrg')] [not(name()='itsm:org')][not(name()='itsm:provenanceRecordsRef')][not(name()='itsm:personRef')][not(name()='itsm:person')] [not(name()='itsm:orgRef')][not(name()='itsm:annotatorsRef')]">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>
                Invalid 'itsm' attribute used in 'revision'.
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M5"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M5"/>
   <xsl:template match="@*|node()" priority="-2" mode="M5">
      <xsl:apply-templates select="*" mode="M5"/>
   </xsl:template>

   <!--PATTERN -->


	  <!--RULE -->
   <xsl:template match="xlf:mrk[@itsm:annotatorsRef] | xlf:sm[@itsm:annotatorsRef]"
                 priority="1000"
                 mode="M6">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="xlf:mrk[@itsm:annotatorsRef] | xlf:sm[@itsm:annotatorsRef]"/>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(@type) or @type='itsm:generic'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(@type) or @type='itsm:generic'">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                When the 'itsm:annotatorsRef' attribute is used, the optional 'type' attribute must be set to 'itsm:generic' if declared.
            </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M6"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M6"/>
   <xsl:template match="@*|node()" priority="-2" mode="M6">
      <xsl:apply-templates select="*" mode="M6"/>
   </xsl:template>

   <!--PATTERN -->


	  <!--RULE -->
   <xsl:template match="xlf:mrk[@itsm:locQualityIssuesRef] | xlf:sm[@itsm:locQualityIssuesRef]"
                 priority="1000"
                 mode="M7">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="xlf:mrk[@itsm:locQualityIssuesRef] | xlf:sm[@itsm:locQualityIssuesRef]"/>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(@type) or @type='itsm:generic'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(@type) or @type='itsm:generic'">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                When used in ITS Localization Quality Issue Annotation, the optional 'type' attribute must be set to 'itsm:generic' if declared.
            </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
      <xsl:if test="@itsm:locQualityIssueType or @itsm:locQualityIssueComment">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="@itsm:locQualityIssueType or @itsm:locQualityIssueComment">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>
                When the 'itsm:locQualityIssuesRef' attribute is used, the following attributes must be declared: 'itsm:locQualityIssueType' and 'itsm:locQualityIssueComment'.
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="@itsm:locQualityIssueSeverity or @itsm:locQualityIssueProfileRef or @itsm:locQualityIssueEnabled">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="@itsm:locQualityIssueSeverity or @itsm:locQualityIssueProfileRef or @itsm:locQualityIssueEnabled">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>
                When the 'itsm:locQualityIssuesRef' attribute is used, the following attributes must be declared: 'itsm:locQualityIssueSeverity', 'itsm:locQualityIssueProfileRef' and 'itsm:locQualityIssueEnabled'..
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M7"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M7"/>
   <xsl:template match="@*|node()" priority="-2" mode="M7">
      <xsl:apply-templates select="*" mode="M7"/>
   </xsl:template>

   <!--PATTERN -->


	  <!--RULE -->
   <xsl:template match="xlf:mrk[@itsm:locQualityIssueSeverity] | xlf:mrk[@itsm:locQualityIssueProfileRef] |              xlf:sm[@itsm:locQualityIssueSeverity] | xlf:sm[@itsm:locQualityIssueProfileRef]"
                 priority="1000"
                 mode="M8">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="xlf:mrk[@itsm:locQualityIssueSeverity] | xlf:mrk[@itsm:locQualityIssueProfileRef] |              xlf:sm[@itsm:locQualityIssueSeverity] | xlf:sm[@itsm:locQualityIssueProfileRef]"/>

		    <!--REPORT -->
      <xsl:if test="@itsm:locQualityIssuesRef">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="@itsm:locQualityIssuesRef">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>
                When the 'itsm:locQualityIssueSeverity' or 'itsm:locQualityIssueProfileRef' attributes are used, the 'itsm:locQualityIssuesRef' must not be declared.
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M8"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M8"/>
   <xsl:template match="@*|node()" priority="-2" mode="M8">
      <xsl:apply-templates select="*" mode="M8"/>
   </xsl:template>

   <!--PATTERN -->


	  <!--RULE -->
   <xsl:template match="xlf:mrk[@itsm:locQualityRatingScore] | xlf:sm[@itsm:locQualityRatingScore]"
                 priority="1000"
                 mode="M9">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="xlf:mrk[@itsm:locQualityRatingScore] | xlf:sm[@itsm:locQualityRatingScore]"/>

		    <!--REPORT -->
      <xsl:if test="@itsm:locQualityRatingVote">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="@itsm:locQualityRatingVote">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>
                When the 'itsm:locQualityRatingScore' attribute is used, the 'itms:locQualityRatingVote' attribute is not allowed.
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(@type) or @type='itsm:generic'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(@type) or @type='itsm:generic'">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                When the 'itsm:locQualityRatingScore' attribute is used, the optional 'type' attribute must be set to 'itsm:generic' if declared.
            </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M9"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M9"/>
   <xsl:template match="@*|node()" priority="-2" mode="M9">
      <xsl:apply-templates select="*" mode="M9"/>
   </xsl:template>

   <!--PATTERN -->


	  <!--RULE -->
   <xsl:template match="xlf:mrk[@itsm:locQualityRatingVote] | xlf:sm[@itsm:locQualityRatingVote]"
                 priority="1000"
                 mode="M10">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="xlf:mrk[@itsm:locQualityRatingVote] | xlf:sm[@itsm:locQualityRatingVote]"/>

		    <!--REPORT -->
      <xsl:if test="@itsm:locQualityRatingScore">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="@itsm:locQualityRatingScore">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>
                When the 'itsm:locQualityRatingVote' attribute is used, the 'itms:locQualityRatingScore' attribute is not allowed.
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(@type) or @type='itsm:generic'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(@type) or @type='itsm:generic'">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                When the 'itsm:locQualityRatingVote' attribute is used, the optional 'type' attribute must be set to 'itsm:generic' if declared.
            </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M10"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M10"/>
   <xsl:template match="@*|node()" priority="-2" mode="M10">
      <xsl:apply-templates select="*" mode="M10"/>
   </xsl:template>

   <!--PATTERN -->


	  <!--RULE -->
   <xsl:template match="xlf:*[@itsm:locQualityRatingScoreThreshold]"
                 priority="1000"
                 mode="M11">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="xlf:*[@itsm:locQualityRatingScoreThreshold]"/>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="@itsm:locQualityRatingScore or ancestor::xlf:*[@itsm:locQualityRatingScore]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="@itsm:locQualityRatingScore or ancestor::xlf:*[@itsm:locQualityRatingScore]">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                The 'itsm:locQualityRatingScoreThreshold' attribute may be set only if 'itsm:locQualityRatingScore' is declared or inherited from upper levels.
            </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M11"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M11"/>
   <xsl:template match="@*|node()" priority="-2" mode="M11">
      <xsl:apply-templates select="*" mode="M11"/>
   </xsl:template>

   <!--PATTERN -->


	  <!--RULE -->
   <xsl:template match="xlf:*[@itsm:locQualityRatingVoteThreshold]"
                 priority="1000"
                 mode="M12">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="xlf:*[@itsm:locQualityRatingVoteThreshold]"/>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="@itsm:locQualityRatingVote or ancestor::xlf:*[@itsm:locQualityRatingVote]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="@itsm:locQualityRatingVote or ancestor::xlf:*[@itsm:locQualityRatingVote]">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                The 'itsm:locQualityRatingVoteThreshold' attribute may be set only if 'itsm:locQualityRatingVote' is declared or inherited from upper levels.
            </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M12"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M12"/>
   <xsl:template match="@*|node()" priority="-2" mode="M12">
      <xsl:apply-templates select="*" mode="M12"/>
   </xsl:template>

   <!--PATTERN -->


	  <!--RULE -->
   <xsl:template match="xlf:mrk[@itsm:taIdentRef] | xlf:sm[@itsm:taIdentRef]"
                 priority="1000"
                 mode="M13">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="xlf:mrk[@itsm:taIdentRef] | xlf:sm[@itsm:taIdentRef]"/>

		    <!--REPORT -->
      <xsl:if test="@itsm:taSource or @itsm:taIdent">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="@itsm:taSource or @itsm:taIdent">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>
                When the 'itsm:taIdentRef' attribute is used, the following attributes are not allowed: 'itsm:taSource' and 'itsm:taIdent'.
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(@type) or @type='itsm:generic'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(@type) or @type='itsm:generic'">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                When the 'itsm:taIdentRef' attribute is used, the optional 'type' attribute must be set to 'itsm:generic' if declared.
            </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M13"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M13"/>
   <xsl:template match="@*|node()" priority="-2" mode="M13">
      <xsl:apply-templates select="*" mode="M13"/>
   </xsl:template>

   <!--PATTERN -->


	  <!--RULE -->
   <xsl:template match="xlf:mrk[@itsm:taSource] | xlf:sm[@itsm:taSource] |             xlf:mrk[@itsm:taIdent] | xlf:sm[@itsm:taIdent]"
                 priority="1000"
                 mode="M14">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="xlf:mrk[@itsm:taSource] | xlf:sm[@itsm:taSource] |             xlf:mrk[@itsm:taIdent] | xlf:sm[@itsm:taIdent]"/>

		    <!--REPORT -->
      <xsl:if test="@itsm:taIdentRef">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@itsm:taIdentRef">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>
                When the 'itsm:taSource' or 'itsm:taIdent' attributes are used, the 'itsm:taIdentRef' attribute is not allowed.
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="@itsm:taSource and @itsm:taIdent"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="@itsm:taSource and @itsm:taIdent">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                The pair of 'itsm:taSource' and 'itsm:taIdent'attributes must be present at the same time.
            </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(@type) or @type='itsm:generic'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(@type) or @type='itsm:generic'">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                When the 'itsm:taSource' and 'itsm:taIdent' attributes are used, the optional 'type' attribute must be set to 'itsm:generic' if declared.
            </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M14"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M14"/>
   <xsl:template match="@*|node()" priority="-2" mode="M14">
      <xsl:apply-templates select="*" mode="M14"/>
   </xsl:template>

   <!--PATTERN -->


	  <!--RULE -->
   <xsl:template match="xlf:mrk[@itsm:taClassRef] | xlf:sm[@itsm:taClassRef]"
                 priority="1000"
                 mode="M15">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="xlf:mrk[@itsm:taClassRef] | xlf:sm[@itsm:taClassRef]"/>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(@type) or @type='itsm:generic'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(@type) or @type='itsm:generic'">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                When the 'itsm:taClassRef' attribute is used, the optional 'type' attribute must be set to 'itsm:generic' if declared.
            </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M15"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M15"/>
   <xsl:template match="@*|node()" priority="-2" mode="M15">
      <xsl:apply-templates select="*" mode="M15"/>
   </xsl:template>

   <!--PATTERN -->


	  <!--RULE -->
   <xsl:template match="xlf:mrk[@itsm:lang] | xlf:sm[@itsm:lang]"
                 priority="1000"
                 mode="M16">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="xlf:mrk[@itsm:lang] | xlf:sm[@itsm:lang]"/>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(@type) or @type='itsm:generic'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(@type) or @type='itsm:generic'">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                When the 'itsm:lang' attribute is used, the optional 'type' attribute must be set to 'itsm:generic' if declared.
            </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M16"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M16"/>
   <xsl:template match="@*|node()" priority="-2" mode="M16">
      <xsl:apply-templates select="*" mode="M16"/>
   </xsl:template>

   <!--PATTERN -->


	  <!--RULE -->
   <xsl:template match="xlf:mrk[@itsm:mtConfidence] | xlf:sm[@itsm:mtConfidence]"
                 priority="1000"
                 mode="M17">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="xlf:mrk[@itsm:mtConfidence] | xlf:sm[@itsm:mtConfidence]"/>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(@type) or @type='itsm:generic'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(@type) or @type='itsm:generic'">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                When the 'itsm:mtConfidence' attribute is used, the optional 'type' attribute must be set to 'itsm:generic' if declared.
            </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M17"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M17"/>
   <xsl:template match="@*|node()" priority="-2" mode="M17">
      <xsl:apply-templates select="*" mode="M17"/>
   </xsl:template>

   <!--PATTERN -->


	  <!--RULE -->
   <xsl:template match="xlf:mrk[@itsm:provenanceRecordsRef] | xlf:sm[@itsm:provenanceRecordsRef]"
                 priority="1000"
                 mode="M18">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="xlf:mrk[@itsm:provenanceRecordsRef] | xlf:sm[@itsm:provenanceRecordsRef]"/>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(@type) or @type='itsm:generic'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(@type) or @type='itsm:generic'">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                When the 'itsm:provenanceRecordsRef' attribute is used, the optional 'type' attribute must be set to 'itsm:generic' if declared.
            </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
      <xsl:if test="@itsm:org or @itsm:orgRef or @itsm:person or                  @itsm:personRef or @itsm:revOrg or @itsm:revOrgRef or                  @itsm:revPerson or @itsm:revPersonRef or @itsm:revTool or                 @itsm:revToolRef or @itsm:tool or @itsm:toolRef">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="@itsm:org or @itsm:orgRef or @itsm:person or @itsm:personRef or @itsm:revOrg or @itsm:revOrgRef or @itsm:revPerson or @itsm:revPersonRef or @itsm:revTool or @itsm:revToolRef or @itsm:tool or @itsm:toolRef">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>
                When the 'itsm:provenanceRecordsRef' attribute is used, the following attributes are not allowed: itsm:org, itsm:orgRef, itsm:person, itsm:personRef, itsm:revOrg,
                itsm:revOrgRef, itsm:revPerson, itsm:revPersonRef, itsm:revTool, itsm:revToolRef, itsm:tool and itsm:toolRef.
                
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M18"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M18"/>
   <xsl:template match="@*|node()" priority="-2" mode="M18">
      <xsl:apply-templates select="*" mode="M18"/>
   </xsl:template>

   <!--PATTERN -->


	  <!--RULE -->
   <xsl:template match="xlf:mrk[@itsm:allowedCharacters] | xlf:mrk[@itsm:domains] | xlf:mrk[@itsm:localeFilterList] |             xlf:sm[@itsm:allowedCharacters] | xlf:sm[@itsm:domains] | xlf:sm[@itsm:localeFilterList]"
                 priority="1000"
                 mode="M19">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="xlf:mrk[@itsm:allowedCharacters] | xlf:mrk[@itsm:domains] | xlf:mrk[@itsm:localeFilterList] |             xlf:sm[@itsm:allowedCharacters] | xlf:sm[@itsm:domains] | xlf:sm[@itsm:localeFilterList]"/>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(@type) or @type='itsm:generic'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(@type) or @type='itsm:generic'">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                When the 'itsm:allowedCharacters', 'itsm:domains' or 'itsm:localeFilterList attributes are used, the value of optional 'type' attribute must be set to 'itsm:generic'.
            </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M19"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M19"/>
   <xsl:template match="@*|node()" priority="-2" mode="M19">
      <xsl:apply-templates select="*" mode="M19"/>
   </xsl:template>

   <!--PATTERN -->


	  <!--RULE -->
   <xsl:template match="xlf:mrk[@itsm:locQualityIssuesRef] | xlf:sm[@itsm:locQualityIssuesRef]"
                 priority="1000"
                 mode="M20">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="xlf:mrk[@itsm:locQualityIssuesRef] | xlf:sm[@itsm:locQualityIssuesRef]"/>

		    <!--REPORT -->
      <xsl:if test="@itsm:locQualityIssueSeverity or @itsm:locQualityIssueProfileRef or @itsm:locQualityIssueEnabled">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="@itsm:locQualityIssueSeverity or @itsm:locQualityIssueProfileRef or @itsm:locQualityIssueEnabled">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>
                If the 'itsm:locQualityIssuesRef' attribute is declared, the following attributes are not allowd: itsm:locQualityIssueSeverity, itsm:locQualityIssueProfileRef, and itsm:locQualityIssueEnabled".
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="count(ancestor::xlf:unit//itsm:locQualityIssues[@id=current()/@itsm:locQualityIssuesRef])=1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count(ancestor::xlf:unit//itsm:locQualityIssues[@id=current()/@itsm:locQualityIssuesRef])=1">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                The value of the locQualityIssuesRef attribute must be an NMTOKEN value of one of the id attributes declared on a &lt;locQualityIssues&gt; elements within the same 'unit'.
            </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M20"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M20"/>
   <xsl:template match="@*|node()" priority="-2" mode="M20">
      <xsl:apply-templates select="*" mode="M20"/>
   </xsl:template>

   <!--PATTERN -->


	  <!--RULE -->
   <xsl:template match="xlf:mrk[@itsm:locQualityIssuesRef] | xlf:sm[@itsm:locQualityIssuesRef]"
                 priority="1000"
                 mode="M21">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="xlf:mrk[@itsm:locQualityIssuesRef] | xlf:sm[@itsm:locQualityIssuesRef]"/>

		    <!--REPORT -->
      <xsl:if test="@itsm:locQualityIssueType or @itsm:locQualityIssueComment">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="@itsm:locQualityIssueType or @itsm:locQualityIssueComment">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>
                When 'itsm:locQualityIssuesRef' is declared, 'itsm:locQualityIssueType' and itsm:locQualityIssueComment are not allowed.
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M21"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M21"/>
   <xsl:template match="@*|node()" priority="-2" mode="M21">
      <xsl:apply-templates select="*" mode="M21"/>
   </xsl:template>

   <!--PATTERN -->


	  <!--RULE -->
   <xsl:template match="xlf:mrk[@itsm:locQualityIssueType] | xlf:mrk[@itsm:locQualityIssueComment] |                            xlf:sm[@itsm:locQualityIssueType] | xlf:sm[@itsm:locQualityIssueComment] "
                 priority="1000"
                 mode="M22">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="xlf:mrk[@itsm:locQualityIssueType] | xlf:mrk[@itsm:locQualityIssueComment] |                            xlf:sm[@itsm:locQualityIssueType] | xlf:sm[@itsm:locQualityIssueComment] "/>

		    <!--REPORT -->
      <xsl:if test="@itsm:locQualityIssuesRef">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="@itsm:locQualityIssuesRef">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>
                When 'itsm:locQualityIssueType' or 'itsm:locQualityIssueComment' are declared, 'itsm:locQualityIssuesRef' is not allowed.
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M22"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M22"/>
   <xsl:template match="@*|node()" priority="-2" mode="M22">
      <xsl:apply-templates select="*" mode="M22"/>
   </xsl:template>

   <!--PATTERN -->


	  <!--RULE -->
   <xsl:template match="xlf:*[@itsm:annotatorsRef][not(contains(@itsm:annotatorsRef, ' '))]"
                 priority="1000"
                 mode="M23">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="xlf:*[@itsm:annotatorsRef][not(contains(@itsm:annotatorsRef, ' '))]"/>
      <xsl:variable name="ref" select="@itsm:annotatorsRef"/>
      <xsl:variable name="its-dc-id" select="substring-before($ref,'|')"/>

		    <!--REPORT -->
      <xsl:if test="$its-dc-id!='allowed-characters' and $its-dc-id!='directionality' and $its-dc-id!='domain' and $its-dc-id!='elements-within-text' and                 $its-dc-id!='external-resource' and $its-dc-id!='id-value' and $its-dc-id!='language-information' and                 $its-dc-id!='locale-filter' and $its-dc-id!='localization-note' and $its-dc-id!='localization-quality-issue' and                 $its-dc-id!='localization-quality-rating' and $its-dc-id!='mt-confidence' and $its-dc-id!='preserve-space' and                 $its-dc-id!='provenance' and $its-dc-id!='storage-size' and $its-dc-id!='target-pointer' and                 $its-dc-id!='terminology' and $its-dc-id!='text-analysis' and $its-dc-id!='translate'">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="$its-dc-id!='allowed-characters' and $its-dc-id!='directionality' and $its-dc-id!='domain' and $its-dc-id!='elements-within-text' and $its-dc-id!='external-resource' and $its-dc-id!='id-value' and $its-dc-id!='language-information' and $its-dc-id!='locale-filter' and $its-dc-id!='localization-note' and $its-dc-id!='localization-quality-issue' and $its-dc-id!='localization-quality-rating' and $its-dc-id!='mt-confidence' and $its-dc-id!='preserve-space' and $its-dc-id!='provenance' and $its-dc-id!='storage-size' and $its-dc-id!='target-pointer' and $its-dc-id!='terminology' and $its-dc-id!='text-analysis' and $its-dc-id!='translate'">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>
                Invalid id used for the ITS datacategory <xsl:text/>
               <xsl:value-of select="$its-dc-id"/>
               <xsl:text/>. Please see the Specification for guidelines on the value of this attribute.
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M23"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M23"/>
   <xsl:template match="@*|node()" priority="-2" mode="M23">
      <xsl:apply-templates select="*" mode="M23"/>
   </xsl:template>

   <!--PATTERN -->


	  <!--RULE -->
   <xsl:template match="xlf:*[@itsm:annotatorsRef][(contains(@itsm:annotatorsRef, ' '))]"
                 priority="1000"
                 mode="M24">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="xlf:*[@itsm:annotatorsRef][(contains(@itsm:annotatorsRef, ' '))]"/>
      <xsl:variable name="ids-string" select=" replace(@itsm:annotatorsRef, '\|\w+','')"/>
      <xsl:variable name="ids-tokens" select="tokenize($ids-string, ' ')"/>

		    <!--REPORT -->
      <xsl:if test="count($ids-tokens)!=count(distinct-values($ids-tokens))">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count($ids-tokens)!=count(distinct-values($ids-tokens))">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>
                Each ITS data category identifier must not be used more than once.
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="matches($ids-string, '^(allowed-characters)?\s*(directionality)?\s*(domain)?\s*(elements-within-text)?\s*(external-resource)?\s*(id-value)?\s*(language-information)?\s*(locale-filter)?\s*(localization-note)?\s*(localization-quality-issue)?\s*(localization-quality-rating)?\s*(mt-confidence)?\s*(preserve-space)?\s*(provenance)?\s*(storage-size)?\s*(target-pointer)?\s*(terminology)?\s*(text-analysis)?\s*(translate)?$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="matches($ids-string, '^(allowed-characters)?\s*(directionality)?\s*(domain)?\s*(elements-within-text)?\s*(external-resource)?\s*(id-value)?\s*(language-information)?\s*(locale-filter)?\s*(localization-note)?\s*(localization-quality-issue)?\s*(localization-quality-rating)?\s*(mt-confidence)?\s*(preserve-space)?\s*(provenance)?\s*(storage-size)?\s*(target-pointer)?\s*(terminology)?\s*(text-analysis)?\s*(translate)?$')">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                The space separated triples are not ordered alphabetically as per the ITS Data category identifier or contain iligal value. Please see the Specification for guidelines on the value of this attribute.
            </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M24"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M24"/>
   <xsl:template match="@*|node()" priority="-2" mode="M24">
      <xsl:apply-templates select="*" mode="M24"/>
   </xsl:template>

   <!--PATTERN -->


	  <!--RULE -->
   <xsl:template match="itsm:locQualityIssue" priority="1000" mode="M25">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="itsm:locQualityIssue"/>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="@locQualityIssueType or @locQualityIssueComment"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="@locQualityIssueType or @locQualityIssueComment">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                At least one of the attributes locQualityIssueType or locQualityIssueComment must be set.
            </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M25"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M25"/>
   <xsl:template match="@*|node()" priority="-2" mode="M25">
      <xsl:apply-templates select="*" mode="M25"/>
   </xsl:template>

   <!--PATTERN -->


	  <!--RULE -->
   <xsl:template match="itsm:provenanceRecord" priority="1000" mode="M26">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="itsm:provenanceRecord"/>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="@itsm:org or @itsm:orgRef or @itsm:person or                  @itsm:personRef or @itsm:revOrg or @itsm:revOrgRef or                  @itsm:revPerson or @itsm:revPersonRef or @itsm:revTool or                 @itsm:revToolRef or @itsm:tool or @itsm:toolRef"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="@itsm:org or @itsm:orgRef or @itsm:person or @itsm:personRef or @itsm:revOrg or @itsm:revOrgRef or @itsm:revPerson or @itsm:revPersonRef or @itsm:revTool or @itsm:revToolRef or @itsm:tool or @itsm:toolRef">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                At least one of the followings must be set: itsm:org, itsm:orgRef, itsm:person, itsm:personRef, itsm:revOrg,
                itsm:revOrgRef, itsm:revPerson, itsm:revPersonRef, itsm:revTool, itsm:revToolRef, itsm:tool and itsm:toolRef.
            </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M26"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M26"/>
   <xsl:template match="@*|node()" priority="-2" mode="M26">
      <xsl:apply-templates select="*" mode="M26"/>
   </xsl:template>

   <!--PATTERN -->


	  <!--RULE -->
   <xsl:template match="itsm:locQualityIssues | itsm:provenanceRecords[ancestor::xlf:unit]"
                 priority="1000"
                 mode="M27">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="itsm:locQualityIssues | itsm:provenanceRecords[ancestor::xlf:unit]"/>
      <xsl:variable name="id" select="@id"/>
      <xsl:variable name="counter"
                    select="count(ancestor::xlf:unit//itsm:locQualityIssues[@id=$id] | ancestor::xlf:unit//itsm:provenanceRecords[@id=$id])"/>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="$counter=1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$counter=1">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                Value of 'id' must be unique among all of  &lt;locQualityIssues&gt; and &lt;provenanceRecords&gt; elements within the enclosing 'unit'.
            </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M27"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M27"/>
   <xsl:template match="@*|node()" priority="-2" mode="M27">
      <xsl:apply-templates select="*" mode="M27"/>
   </xsl:template>

   <!--PATTERN -->


	  <!--RULE -->
   <xsl:template match="itsm:provenanceRecords[ancestor::xlf:group][not(ancestor::xlf:unit)]"
                 priority="1000"
                 mode="M28">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="itsm:provenanceRecords[ancestor::xlf:group][not(ancestor::xlf:unit)]"/>
      <xsl:variable name="id" select="@id"/>
      <xsl:variable name="counter"
                    select="count(ancestor::xlf:group[1]//itsm:provenanceRecords[@id=$id][not(ancestor::xlf:unit)])"/>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="$counter=1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$counter=1">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                Value of 'id' must be unique among all of  &lt;provenanceRecords&gt; elements within the enclosing 'group'.
            </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M28"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M28"/>
   <xsl:template match="@*|node()" priority="-2" mode="M28">
      <xsl:apply-templates select="*" mode="M28"/>
   </xsl:template>

   <!--PATTERN -->


	  <!--RULE -->
   <xsl:template match="itsm:provenanceRecords[ancestor::xlf:file][not(ancestor::xlf:unit)][not(ancestor::xlf:group)]"
                 priority="1000"
                 mode="M29">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="itsm:provenanceRecords[ancestor::xlf:file][not(ancestor::xlf:unit)][not(ancestor::xlf:group)]"/>
      <xsl:variable name="id" select="@id"/>
      <xsl:variable name="counter"
                    select="count(ancestor::xlf:file//itsm:provenanceRecords[@id=$id][not(ancestor::xlf:group)][not(ancestor::xlf:unit)])"/>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="$counter=1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$counter=1">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                Value of 'id' must be unique among all of  &lt;provenanceRecords&gt; elements within the enclosing 'file'.
            </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M29"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M29"/>
   <xsl:template match="@*|node()" priority="-2" mode="M29">
      <xsl:apply-templates select="*" mode="M29"/>
   </xsl:template>

   <!--PATTERN -->


	  <!--RULE -->
   <xsl:template match="xlf:*[@itsm:locQualityIssuesRef]" priority="1000" mode="M30">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="xlf:*[@itsm:locQualityIssuesRef]"/>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(@itsm:locQualityIssueSeverity)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(@itsm:locQualityIssueSeverity)">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                If 'itsm:locQualityIssuesRef' attribute is declared, the 'itsm:locQualityIssueSeverity' must not be used. 
            </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not (@itsm:locQualityIssueProfileRef) "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not (@itsm:locQualityIssueProfileRef)">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                If 'itsm:locQualityIssuesRef' attribute is declared, the 'itsm:locQualityIssueProfileRef' must not be used. 
            </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(@itsm:locQualityIssueEnabled)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(@itsm:locQualityIssueEnabled)">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                If 'itsm:locQualityIssuesRef' attribute is declared, the 'itsm:locQualityIssueEnabled' must not be used. 
            </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M30"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M30"/>
   <xsl:template match="@*|node()" priority="-2" mode="M30">
      <xsl:apply-templates select="*" mode="M30"/>
   </xsl:template>
</xsl:stylesheet>

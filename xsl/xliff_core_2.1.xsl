<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<xsl:stylesheet xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                xmlns:saxon="http://saxon.sf.net/"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:schold="http://www.ascc.net/xml/schematron"
                xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                xmlns:xhtml="http://www.w3.org/1999/xhtml"
                xmlns:xlf="urn:oasis:names:tc:xliff:document:2.0"
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
                              title="Schematron Rules for validation of XLIFF Version 2.1 Core constraints"
                              schemaVersion="ISO19757-3">
         <xsl:comment>
            <xsl:value-of select="$archiveDirParameter"/>   
		 <xsl:value-of select="$archiveNameParameter"/>  
		 <xsl:value-of select="$fileNameParameter"/>  
		 <xsl:value-of select="$fileDirParameter"/>
         </xsl:comment>
         <svrl:ns-prefix-in-attribute-values uri="urn:oasis:names:tc:xliff:document:2.0" prefix="xlf"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">K1</xsl:attribute>
            <xsl:attribute name="name">The value [of id] must be unique among all 'file' id attribute values within the enclosing 'xliff' element</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M2"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">K2</xsl:attribute>
            <xsl:attribute name="name">The value [of id] must be unique among all 'group' id attribute values within the enclosing 'file' element</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M3"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">K3</xsl:attribute>
            <xsl:attribute name="name">The value [of id] must be unique among all 'unit' id attribute values within the enclosing 'file' element</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M4"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">K4F</xsl:attribute>
            <xsl:attribute name="name">The value [of id] must be unique among all 'note' id attribute values within the enclosing 'notes' element</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M5"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">K4GU</xsl:attribute>
            <xsl:attribute name="name">The value [of id] must be unique among all 'note' id attribute values within the enclosing 'notes' element</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M6"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">K5</xsl:attribute>
            <xsl:attribute name="name">The value [of id] must be unique among all 'data' id attribute values within the enclosing 'originalData' element</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M7"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">K6</xsl:attribute>
            <xsl:attribute name="name">Except for the above exception [target duplication], the value [of id attribute] must be unique among all of the above 
            [segment, ignorable, mkr, sm,pc, sc, ec, ph] within the enclosing 'unit' element</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M8"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">K7</xsl:attribute>
            <xsl:attribute name="name">The value of the order attribute must be unique within the enclosing 'unit' element</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M9"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">K8</xsl:attribute>
            <xsl:attribute name="name">The inline elements enclosed by a &lt;target&gt; element must use the duplicate id values of their corresponding inline elements enclosed within the sibling &lt;source&gt; element if and only if those corresponding elements exist</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M10"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F1</xsl:attribute>
            <xsl:attribute name="name">The 'trgLang' attribute is required if and only if the XLIFF Document contains 'target' elements 
            that are children of 'segment' or 'ignorable'</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M11"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F2</xsl:attribute>
            <xsl:attribute name="name">The attribute 'href' is required if and only if the 'skeleton' element is empty</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M12"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F3</xsl:attribute>
            <xsl:attribute name="name">A 'unit' must contain at least one 'segment' element</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M13"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F4</xsl:attribute>
            <xsl:attribute name="name">When a 'target' element is a child of 'segment' or 'ignorable', the explicit or inherited value
            of the optional xml:lang must be equal to the value of the trgLang attribute of the enclosing 'xliff' 
            element</xsl:attribute>
            <svrl:text>This rule does not rais an error if 'xml:lang' is a subcategory of 'trgLang', but not vice versa.
            i.e. 'trgLang="en"/xml:lang="en-ie"' is a valid pair.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M14"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F5S</xsl:attribute>
            <xsl:attribute name="name">The attribute isolated must be set to yes if and only if the 'ec' element corresponding to this
            start marker is not in the same 'unit', and set to no otherwise</xsl:attribute>
            <svrl:text>This rule selects those 'sc' with 'isolated' attribute set to 'yes' and appear in 'source'. 
            An error will be raised if
            a) there exists any 'ec' in the same 'unit' and in a 'source', corresponding to this 'sc' by 'startRef';
            b) there is not any 'ec' in the document which appears after the start code and is not in the same 'unit' 
            and is within a 'source';
            c) the values of 'canCopy', 'canDelete', 'canOverlap' or 'canReorder' attributes are not matching with the 
            corresponding 'ec';
            d) the value of 'canReorder' is set to 'firstNo', but is not 'no' in the corresponding 'ec'</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M15"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F5T</xsl:attribute>
            <xsl:attribute name="name">The attribute isolated must be set to yes if and only if the 'ec' element corresponding to this
            start marker is not in the same 'unit', and set to no otherwise</xsl:attribute>
            <svrl:text>This rule selects those 'sc' files with 'isolated' attribute set to 'yes' and appear in 'target'. 
            An error will be raised if
            a) there exists any 'ec' in the same 'unit' and in a 'target', corresponding to this 'sc' by 'startRef';
            b) there is not any 'ec' in the document which appears after the start code and is not in the same 'unit' 
            and is within a 'target';
            c) the value of 'canCopy', 'canDelete', 'canOverlap' or 'canReorder' attributes are not matching with the 
            corresponding 'ec';
            d) the value of 'canReorder' is set to 'firstNo', but is not 'no' in the corresponding 'ec'</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M16"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F5.1S</xsl:attribute>
            <xsl:attribute name="name">The attribute isolated must be set to yes if and only if the 'ec' element corresponding to this
            start marker is not in the same 'unit', and set to no otherwise</xsl:attribute>
            <svrl:text>This rule selects those 'sc' with 'isolated' attribute set to 'no' (or missing) and appear in 'source'. 
            An error will be raised if
            a) there is not one and only one 'ec' element in the same 'unit', in a 'source', which appears after the 'sc' 
            and corresponds to this 'sc' by 'startRef';
            b) the values of 'canCopy', 'canDelete', 'canReorder' or 'canOverlap' attributes are not matching with the 
            corresponding ec;
            c) the value of 'canReorder' is set to 'firstNo', but is not 'no' in the corresponding 'ec'</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M17"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F5.1T</xsl:attribute>
            <xsl:attribute name="name">The attribute isolated must be set to yes if and only if the 'ec' element corresponding to this
            start marker is not in the same 'unit', and set to no otherwise</xsl:attribute>
            <svrl:text>This rule selects those 'sc' with 'isolated' attribute set to 'no' (or missing) and appear in 'target'. 
            An error will be raised if
            a) there is not one and only one 'ec' element in the same 'unit', in a 'target', which appears after the 'sc' 
            and corresponds to this 'sc' by 'startRef';
            b) the values of 'canCopy', 'canDelete', 'canReorder' or 'canOverlap' attributes are not matching with the 
            corresponding ec;
            c) the value of 'canReorder' is set to 'firstNo', but is not 'no' in the corresponding 'ec'</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M18"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F6S</xsl:attribute>
            <xsl:attribute name="name">The attribute isolated must be set to yes if and only if the 'sc' element corresponding to this
            end code [ec] is not in the same 'unit' and set to no otherwise</xsl:attribute>
            <svrl:text>This rule selects those 'ec' which are in 'source' and raises an error if
            a) 'id' and 'startRef' attributes are used illegally, based on the value of 'isolated': if 'yes',
            only 'id' must be used and if 'no' (or missing), only 'startRef' must be specified;
            b) 'isolated' is set to 'yes', but there is no 'sc' in the same 'file', in a different 'unit', in
            'source' and which appears before this end code;
            c)'isolated' is set to 'no', but there is no 'sc' in the same 'unit', in a 'source' and which
            appears before this end code.
        </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M19"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F6T</xsl:attribute>
            <xsl:attribute name="name">The attribute isolated must be set to yes if and only if the 'sc' element corresponding to this
            end code [ec] is not in the same 'unit' and set to no otherwise</xsl:attribute>
            <svrl:text>This rule selects those 'ec' which are in 'target' and raises an error if
            a) 'id' and 'startRef' attributes are used illegally, based on the value of 'isolated': if 'yes',
            only 'id' must be used and if 'no' (or missing), only 'startRef' must be specified;
            b) 'isolated' is set to 'yes', but there is no 'sc' in the same 'file', in a different 'unit', in
            'target' and which appears before this end code;
            c)'isolated' is set to 'no' (or missing), but there is no 'sc' in the same 'unit', in a 'target' and which
            appears before this end code.
            d) 'isolate' is set to 'no' (or missing) and 'dir' attribute is used. 
        </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M20"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F7</xsl:attribute>
            <xsl:attribute name="name">If the attribute subState is used, the attribute state must be explicitly set</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M21"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F8</xsl:attribute>
            <xsl:attribute name="name">If the attribute 'subType' is used, the attribute 'type' must be specified as well</xsl:attribute>
            <svrl:text>This rule select inline elements, which specify 'subType'. It also checks the value of 'subType'.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M22"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F9</xsl:attribute>
            <xsl:attribute name="name">The copyOf attribute must be used when, and only when, the base code has no associated original data</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M23"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F10</xsl:attribute>
            <xsl:attribute name="name">When the attribute canReorder is set to no or firstNo, the attributes canCopy and canDelete must also be set to no</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M24"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F11S</xsl:attribute>
            <xsl:attribute name="name">Translate Annotation</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M25"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F11T</xsl:attribute>
            <xsl:attribute name="name">Translate Annotation</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M26"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F12S</xsl:attribute>
            <xsl:attribute name="name">Comment Annotation</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M27"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F12T</xsl:attribute>
            <xsl:attribute name="name">Comment Annotation</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M28"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F13S</xsl:attribute>
            <xsl:attribute name="name">ref attribute in Comment Annotation</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M29"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">FD13T</xsl:attribute>
            <xsl:attribute name="name">ref attribute in Comment Annotation</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M30"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F14</xsl:attribute>
            <xsl:attribute name="name">The 'copyOf' attribute must point to a code within the same 'unit'</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M31"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F15</xsl:attribute>
            <xsl:attribute name="name">dataRef attribute must point to a data element within the same unit</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M32"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F16S</xsl:attribute>
            <xsl:attribute name="name">dataRefEnd attribute must point to a data element within the same unit</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M33"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F16T</xsl:attribute>
            <xsl:attribute name="name">dataRefEnd attribute must point to a data element within the same unit</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M34"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F17S</xsl:attribute>
            <xsl:attribute name="name">dataRefStart attribute must point to a data element within the same unit</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M35"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F17T</xsl:attribute>
            <xsl:attribute name="name">dataRefStart attribute must point to a data element within the same unit</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M36"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F18</xsl:attribute>
            <xsl:attribute name="name">Its value [order attribute] is an integer from 1 to N, where N is the sum of the numbers of the &lt;segment&gt; 
            and &lt;ignorable&gt; elements within the given enclosing &lt;unit&gt; element</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M37"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F19</xsl:attribute>
            <xsl:attribute name="name">To be able to map order differences, the &lt;target&gt; element has an optional order attribute that indicates its position in the sequence of segments (and inter-segments). Its value is an
            integer from 1 to N, where N is the sum of the numbers of the &lt;segment&gt; and &lt;ignorable&gt; elements within the given enclosing &lt;unit&gt; element.
            When Writers set explicit order on&lt;target&gt; elements, they have to check for conflicts with implicit order, as &lt;target&gt; elements without explicit
            order correspond to their sibling &lt;source&gt; elements</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M38"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">F20</xsl:attribute>
            <xsl:attribute name="name">Modifiers must not delete inline codes that have their attribute canDelete set to no</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M39"/>
      </svrl:schematron-output>
   </xsl:template>

   <!--SCHEMATRON PATTERNS-->
   <svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Schematron Rules for validation of XLIFF Version 2.1 Core constraints</svrl:text>

   <!--PATTERN K1The value [of id] must be unique among all 'file' id attribute values within the enclosing 'xliff' element-->
   <svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">The value [of id] must be unique among all 'file' id attribute values within the enclosing 'xliff' element</svrl:text>

	  <!--RULE -->
   <xsl:template match="xlf:file" priority="1000" mode="M2">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="xlf:file"/>
      <xsl:variable name="id" select="current()/@id"/>
      <xsl:variable name="fragid" select="concat('f=',$id)"/>

		    <!--REPORT -->
      <xsl:if test="following-sibling::xlf:file[@id=$id]">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="following-sibling::xlf:file[@id=$id]">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>
                id duplication found. The value '<xsl:text/>
               <xsl:value-of select="$id"/>
               <xsl:text/>' is used more than once for 'file' elements 
                within the enclosing 'xliff'.
            </svrl:text> 
            <svrl:diagnostic-reference diagnostic="fragid-report">
#<xsl:text/>
               <xsl:value-of select="$fragid"/>
               <xsl:text/>
            </svrl:diagnostic-reference>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M2"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M2"/>
   <xsl:template match="@*|node()" priority="-2" mode="M2">
      <xsl:apply-templates select="*" mode="M2"/>
   </xsl:template>

   <!--PATTERN K2The value [of id] must be unique among all 'group' id attribute values within the enclosing 'file' element-->
   <svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">The value [of id] must be unique among all 'group' id attribute values within the enclosing 'file' element</svrl:text>

	  <!--RULE -->
   <xsl:template match="xlf:group" priority="1000" mode="M3">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="xlf:group"/>
      <xsl:variable name="id" select="current()/@id"/>
      <xsl:variable name="fragid" select="concat('f=',ancestor::xlf:file/@id,'/g=',$id)"/>

		    <!--REPORT -->
      <xsl:if test="count(ancestor::xlf:file//xlf:group[@id=$id])&gt;1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(ancestor::xlf:file//xlf:group[@id=$id])&gt;1">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>
                id duplication found. The value '<xsl:text/>
               <xsl:value-of select="$id"/>
               <xsl:text/>' is used more than once for 'group' elements 
                within the enclosing 'file'.
            </svrl:text> 
            <svrl:diagnostic-reference diagnostic="fragid-report">
#<xsl:text/>
               <xsl:value-of select="$fragid"/>
               <xsl:text/>
            </svrl:diagnostic-reference>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M3"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M3"/>
   <xsl:template match="@*|node()" priority="-2" mode="M3">
      <xsl:apply-templates select="*" mode="M3"/>
   </xsl:template>

   <!--PATTERN K3The value [of id] must be unique among all 'unit' id attribute values within the enclosing 'file' element-->
   <svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">The value [of id] must be unique among all 'unit' id attribute values within the enclosing 'file' element</svrl:text>

	  <!--RULE -->
   <xsl:template match="xlf:unit" priority="1000" mode="M4">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="xlf:unit"/>
      <xsl:variable name="id" select="@id"/>
      <xsl:variable name="fragid" select="concat('f=', ancestor::xlf:file/@id,'/u=',$id)"/>

		    <!--REPORT -->
      <xsl:if test="count(ancestor::xlf:file//xlf:unit[@id=$id])&gt;1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(ancestor::xlf:file//xlf:unit[@id=$id])&gt;1">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>
                id duplication found. The value '<xsl:text/>
               <xsl:value-of select="$id"/>
               <xsl:text/>' is used more than once for 'unit' elements 
                within the enclosing 'file'.
            </svrl:text> 
            <svrl:diagnostic-reference diagnostic="fragid-report">
#<xsl:text/>
               <xsl:value-of select="$fragid"/>
               <xsl:text/>
            </svrl:diagnostic-reference>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M4"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M4"/>
   <xsl:template match="@*|node()" priority="-2" mode="M4">
      <xsl:apply-templates select="*" mode="M4"/>
   </xsl:template>

   <!--PATTERN K4FThe value [of id] must be unique among all 'note' id attribute values within the enclosing 'notes' element-->
   <svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">The value [of id] must be unique among all 'note' id attribute values within the enclosing 'notes' element</svrl:text>

	  <!--RULE -->
   <xsl:template match="xlf:note[@id][not(ancestor::xlf:unit)][not(ancestor::xlf:group)]"
                 priority="1000"
                 mode="M5">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="xlf:note[@id][not(ancestor::xlf:unit)][not(ancestor::xlf:group)]"/>
      <xsl:variable name="id" select="@id"/>
      <xsl:variable name="fragid" select="concat('f=',ancestor::xlf:file/@id,'/n=',$id) "/>

		    <!--REPORT -->
      <xsl:if test="following-sibling::xlf:note[@id=$id]">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="following-sibling::xlf:note[@id=$id]">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>
                id duplication found. The value '<xsl:text/>
               <xsl:value-of select="$id"/>
               <xsl:text/>' is used more than once for 'note' elements 
                within the enclosing 'notes'.
            </svrl:text> 
            <svrl:diagnostic-reference diagnostic="fragid-report">
#<xsl:text/>
               <xsl:value-of select="$fragid"/>
               <xsl:text/>
            </svrl:diagnostic-reference>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M5"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M5"/>
   <xsl:template match="@*|node()" priority="-2" mode="M5">
      <xsl:apply-templates select="*" mode="M5"/>
   </xsl:template>

   <!--PATTERN K4GUThe value [of id] must be unique among all 'note' id attribute values within the enclosing 'notes' element-->
   <svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">The value [of id] must be unique among all 'note' id attribute values within the enclosing 'notes' element</svrl:text>

	  <!--RULE -->
   <xsl:template match="xlf:note[@id][ancestor::xlf:unit| ancestor::xlf:group]"
                 priority="1000"
                 mode="M6">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="xlf:note[@id][ancestor::xlf:unit| ancestor::xlf:group]"/>
      <xsl:variable name="id" select="current()/@id"/>
      <xsl:variable name="fragid"
                    select="concat('f=',ancestor::xlf:file/@id,concat('/',substring(name(../..),1,1),'=',../../@id),'/n=',$id)"/>

		    <!--REPORT -->
      <xsl:if test="following-sibling::xlf:note[@id=$id]">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="following-sibling::xlf:note[@id=$id]">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>
                id duplication found. The value '<xsl:text/>
               <xsl:value-of select="$id"/>
               <xsl:text/>' is used more than once for 'note' elements 
                within the enclosing 'notes'.
            </svrl:text> 
            <svrl:diagnostic-reference diagnostic="fragid-report">
#<xsl:text/>
               <xsl:value-of select="$fragid"/>
               <xsl:text/>
            </svrl:diagnostic-reference>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M6"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M6"/>
   <xsl:template match="@*|node()" priority="-2" mode="M6">
      <xsl:apply-templates select="*" mode="M6"/>
   </xsl:template>

   <!--PATTERN K5The value [of id] must be unique among all 'data' id attribute values within the enclosing 'originalData' element-->
   <svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">The value [of id] must be unique among all 'data' id attribute values within the enclosing 'originalData' element</svrl:text>

	  <!--RULE -->
   <xsl:template match="xlf:data" priority="1000" mode="M7">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="xlf:data"/>
      <xsl:variable name="id" select="current()/@id"/>
      <xsl:variable name="fragid"
                    select="concat('f=',ancestor::xlf:file/@id,'/u=', ancestor::xlf:unit/@id,'/d=',$id)"/>

		    <!--REPORT -->
      <xsl:if test="following-sibling::xlf:data[@id=$id]">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="following-sibling::xlf:data[@id=$id]">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>
                id duplication found. The value '<xsl:text/>
               <xsl:value-of select="$id"/>
               <xsl:text/>' is used more than once for 'data' elements 
                within the enclosing 'unit'.
            </svrl:text> 
            <svrl:diagnostic-reference diagnostic="fragid-report">
#<xsl:text/>
               <xsl:value-of select="$fragid"/>
               <xsl:text/>
            </svrl:diagnostic-reference>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M7"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M7"/>
   <xsl:template match="@*|node()" priority="-2" mode="M7">
      <xsl:apply-templates select="*" mode="M7"/>
   </xsl:template>

   <!--PATTERN K6Except for the above exception [target duplication], the value [of id attribute] must be unique among all of the above 
            [segment, ignorable, mkr, sm,pc, sc, ec, ph] within the enclosing 'unit' element-->
   <svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Except for the above exception [target duplication], the value [of id attribute] must be unique among all of the above 
            [segment, ignorable, mkr, sm,pc, sc, ec, ph] within the enclosing 'unit' element</svrl:text>

	  <!--RULE -->
   <xsl:template match="xlf:source[ancestor::xlf:segment| ancestor::xlf:ignorable]//xlf:*[@id]|             xlf:segment[@id]| xlf:ignorable[@id]"
                 priority="1000"
                 mode="M8">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="xlf:source[ancestor::xlf:segment| ancestor::xlf:ignorable]//xlf:*[@id]|             xlf:segment[@id]| xlf:ignorable[@id]"/>
      <xsl:variable name="id" select="current()/@id"/>
      <xsl:variable name="fragid"
                    select="concat('f=',ancestor::xlf:file/@id,'/u=',ancestor::xlf:unit/@id,'/',$id)"/>

		    <!--REPORT -->
      <xsl:if test="count(ancestor::xlf:unit//xlf:*[@id=$id][ancestor-or-self::xlf:segment| ancestor-or-self::xlf:ignorable][not(ancestor::xlf:target)])&gt;1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(ancestor::xlf:unit//xlf:*[@id=$id][ancestor-or-self::xlf:segment| ancestor-or-self::xlf:ignorable][not(ancestor::xlf:target)])&gt;1">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>
                id duplication found. The value '<xsl:text/>
               <xsl:value-of select="$id"/>
               <xsl:text/>' is used more then once among inline and/or 'segmen'/'ignorable' 
                elements within the enclosing 'unit'.
            </svrl:text> 
            <svrl:diagnostic-reference diagnostic="fragid-report">
#<xsl:text/>
               <xsl:value-of select="$fragid"/>
               <xsl:text/>
            </svrl:diagnostic-reference>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M8"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M8"/>
   <xsl:template match="@*|node()" priority="-2" mode="M8">
      <xsl:apply-templates select="*" mode="M8"/>
   </xsl:template>

   <!--PATTERN K7The value of the order attribute must be unique within the enclosing 'unit' element-->
   <svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">The value of the order attribute must be unique within the enclosing 'unit' element</svrl:text>

	  <!--RULE -->
   <xsl:template match="xlf:target[@order][ancestor::xlf:segment|ancestor::xlf:ignorable]"
                 priority="1000"
                 mode="M9">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="xlf:target[@order][ancestor::xlf:segment|ancestor::xlf:ignorable]"/>
      <xsl:variable name="order" select="@order"/>
      <xsl:variable name="fragid"
                    select="concat('f=', ancestor::xlf:file/@id, '/u=', ancestor::xlf:unit/@id)"/>

		    <!--REPORT -->
      <xsl:if test="count(ancestor::xlf:unit//xlf:target[ancestor::xlf:segment|ancestor::xlf:ignorable][@order=$order])&gt;1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count(ancestor::xlf:unit//xlf:target[ancestor::xlf:segment|ancestor::xlf:ignorable][@order=$order])&gt;1">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>
                The value '<xsl:text/>
               <xsl:value-of select="$order"/>
               <xsl:text/>' is used more than once for 'order' attributes of 'target' elements 
                within the enclosing 'unit'.
            </svrl:text> 
            <svrl:diagnostic-reference diagnostic="fragid-report">
#<xsl:text/>
               <xsl:value-of select="$fragid"/>
               <xsl:text/>
            </svrl:diagnostic-reference>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M9"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M9"/>
   <xsl:template match="@*|node()" priority="-2" mode="M9">
      <xsl:apply-templates select="*" mode="M9"/>
   </xsl:template>

   <!--PATTERN K8The inline elements enclosed by a <target> element must use the duplicate id values of their corresponding inline elements enclosed within the sibling <source> element if and only if those corresponding elements exist-->
   <svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">The inline elements enclosed by a &lt;target&gt; element must use the duplicate id values of their corresponding inline elements enclosed within the sibling &lt;source&gt; element if and only if those corresponding elements exist</svrl:text>

	  <!--RULE -->
   <xsl:template match="xlf:target[ancestor::xlf:segment | ancestor::xlf:ignorable]//xlf:*[@id]"
                 priority="1000"
                 mode="M10">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="xlf:target[ancestor::xlf:segment | ancestor::xlf:ignorable]//xlf:*[@id]"/>
      <xsl:variable name="id" select="@id"/>
      <xsl:variable name="file-id" select="ancestor::xlf:file/@id"/>
      <xsl:variable name="unit-id" select="ancestor::xlf:unit/@id"/>
      <xsl:variable name="fragid" select="concat('f=', $file-id,'/u=',$unit-id,'/t=',$id)"/>
      <xsl:variable name="counter"
                    select="count(ancestor::xlf:unit//xlf:*[@id=$id]                 [ancestor-or-self::xlf:segment| ancestor-or-self::xlf:ignorable])"/>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="($counter=1) or ($counter=2 and                 count(ancestor::xlf:segment/xlf:source//xlf:*[@id=$id]                 [name()= name(current())] |                  ancestor::xlf:ignorable/xlf:source//xlf:*[@id=$id][name()=                  name(current())][@*=current()/@*])=1)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="($counter=1) or ($counter=2 and count(ancestor::xlf:segment/xlf:source//xlf:*[@id=$id] [name()= name(current())] | ancestor::xlf:ignorable/xlf:source//xlf:*[@id=$id][name()= name(current())][@*=current()/@*])=1)">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> 
                Invalid id used for element '<xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/>'. It must duplicate the 
                id of its corresponding element, enclosed within the 'source' 
                element or be unique in the scope of 'unit'.
            </svrl:text> 
               <svrl:diagnostic-reference diagnostic="fragid-report">
#<xsl:text/>
                  <xsl:value-of select="$fragid"/>
                  <xsl:text/>
               </svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M10"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M10"/>
   <xsl:template match="@*|node()" priority="-2" mode="M10">
      <xsl:apply-templates select="*" mode="M10"/>
   </xsl:template>

   <!--PATTERN F1The 'trgLang' attribute is required if and only if the XLIFF Document contains 'target' elements 
            that are children of 'segment' or 'ignorable'-->
   <svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">The 'trgLang' attribute is required if and only if the XLIFF Document contains 'target' elements 
            that are children of 'segment' or 'ignorable'</svrl:text>

	  <!--RULE -->
   <xsl:template match="xlf:target[parent::xlf:segment | parent::xlf:ignorable]"
                 priority="1000"
                 mode="M11">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="xlf:target[parent::xlf:segment | parent::xlf:ignorable]"/>
      <xsl:variable name="fragid"
                    select="concat('f=', ancestor::xlf:file/@id, '/u=', ancestor::xlf:unit/@id)"/>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="/xlf:xliff/@trgLang"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="/xlf:xliff/@trgLang">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                XLIFF document contains 'target' element(s), but the 'trgLang' attribute of 'xliff' is missing.
            </svrl:text> 
               <svrl:diagnostic-reference diagnostic="fragid-report">
#<xsl:text/>
                  <xsl:value-of select="$fragid"/>
                  <xsl:text/>
               </svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M11"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M11"/>
   <xsl:template match="@*|node()" priority="-2" mode="M11">
      <xsl:apply-templates select="*" mode="M11"/>
   </xsl:template>

   <!--PATTERN F2The attribute 'href' is required if and only if the 'skeleton' element is empty-->
   <svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">The attribute 'href' is required if and only if the 'skeleton' element is empty</svrl:text>

	  <!--RULE -->
   <xsl:template match="xlf:skeleton" priority="1000" mode="M12">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="xlf:skeleton"/>
      <xsl:variable name="fragid" select="concat('f=',ancestor::xlf:file/@id)"/>

		    <!--REPORT -->
      <xsl:if test="not(@href) and not(child::node())">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="not(@href) and not(child::node())">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>
                'skeleton' element must not be empty when the 'href' attribute is missing.
            </svrl:text> 
            <svrl:diagnostic-reference diagnostic="fragid-report">
#<xsl:text/>
               <xsl:value-of select="$fragid"/>
               <xsl:text/>
            </svrl:diagnostic-reference>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="@href and  child::node()">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@href and child::node()">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>
                'skeleton' element must be empty when containing 'href' attribute.
            </svrl:text> 
            <svrl:diagnostic-reference diagnostic="fragid-report">
#<xsl:text/>
               <xsl:value-of select="$fragid"/>
               <xsl:text/>
            </svrl:diagnostic-reference>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M12"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M12"/>
   <xsl:template match="@*|node()" priority="-2" mode="M12">
      <xsl:apply-templates select="*" mode="M12"/>
   </xsl:template>

   <!--PATTERN F3A 'unit' must contain at least one 'segment' element-->
   <svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">A 'unit' must contain at least one 'segment' element</svrl:text>

	  <!--RULE -->
   <xsl:template match="xlf:unit" priority="1000" mode="M13">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="xlf:unit"/>
      <xsl:variable name="fragid"
                    select="concat('f=',ancestor::xlf:file/@id,'/u=', current()/@id)"/>

		    <!--REPORT -->
      <xsl:if test="not(child::xlf:segment)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(child::xlf:segment)">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>
                Incomplete 'unit'; it must have at least one 'segment' child.
            </svrl:text> 
            <svrl:diagnostic-reference diagnostic="fragid-report">
#<xsl:text/>
               <xsl:value-of select="$fragid"/>
               <xsl:text/>
            </svrl:diagnostic-reference>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M13"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M13"/>
   <xsl:template match="@*|node()" priority="-2" mode="M13">
      <xsl:apply-templates select="*" mode="M13"/>
   </xsl:template>

   <!--PATTERN F4When a 'target' element is a child of 'segment' or 'ignorable', the explicit or inherited value
            of the optional xml:lang must be equal to the value of the trgLang attribute of the enclosing 'xliff' 
            element-->
   <svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">When a 'target' element is a child of 'segment' or 'ignorable', the explicit or inherited value
            of the optional xml:lang must be equal to the value of the trgLang attribute of the enclosing 'xliff' 
            element</svrl:text>

	  <!--RULE -->
   <xsl:template match="xlf:target[@xml:lang][parent::xlf:segment | parent::xlf:ignorable]"
                 priority="1000"
                 mode="M14">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="xlf:target[@xml:lang][parent::xlf:segment | parent::xlf:ignorable]"/>
      <xsl:variable name="trgLang" select="/xlf:xliff/@trgLang"/>
      <xsl:variable name="fragid"
                    select="concat('f=',ancestor::xlf:file/@id,'/u=', ancestor::xlf:unit/@id)"/>

		    <!--REPORT -->
      <xsl:if test="not(lang($trgLang))">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(lang($trgLang))">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>
                'xml:lang' attribute of the 'target' element and 'trgLang' attribute of the 'xliff' are not matching.
            </svrl:text> 
            <svrl:diagnostic-reference diagnostic="fragid-report">
#<xsl:text/>
               <xsl:value-of select="$fragid"/>
               <xsl:text/>
            </svrl:diagnostic-reference>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M14"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M14"/>
   <xsl:template match="@*|node()" priority="-2" mode="M14">
      <xsl:apply-templates select="*" mode="M14"/>
   </xsl:template>

   <!--PATTERN F5SThe attribute isolated must be set to yes if and only if the 'ec' element corresponding to this
            start marker is not in the same 'unit', and set to no otherwise-->
   <svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">The attribute isolated must be set to yes if and only if the 'ec' element corresponding to this
            start marker is not in the same 'unit', and set to no otherwise</svrl:text>

	  <!--RULE -->
   <xsl:template match="xlf:sc[ancestor::xlf:source][@isolated='yes'][ancestor::xlf:segment | ancestor::xlf:ignorable]"
                 priority="1000"
                 mode="M15">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="xlf:sc[ancestor::xlf:source][@isolated='yes'][ancestor::xlf:segment | ancestor::xlf:ignorable]"/>
      <xsl:variable name="id" select="current()/@id"/>
      <xsl:variable name="file-id" select="ancestor::xlf:file/@id"/>
      <xsl:variable name="unit-id" select="ancestor::xlf:unit/@id"/>
      <xsl:variable name="fragid"
                    select="concat('f=', $file-id, '/u=', $unit-id, '/', $id)"/>

		    <!--REPORT -->
      <xsl:if test="ancestor::xlf:unit//xlf:ec[@startRef=$id][ancestor::xlf:source]">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="ancestor::xlf:unit//xlf:ec[@startRef=$id][ancestor::xlf:source]">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>
                'isolated' attribute is set to 'yes', but 'ec' element(s) referencing this start code found within the same unit.
            </svrl:text> 
            <svrl:diagnostic-reference diagnostic="fragid-report">
#<xsl:text/>
               <xsl:value-of select="$fragid"/>
               <xsl:text/>
            </svrl:diagnostic-reference>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="following::xlf:ec[@id=$id][ancestor::xlf:source][ancestor::xlf:file/@id=$file-id]                 [not(ancestor::xlf:unit[@id=$unit-id])]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="following::xlf:ec[@id=$id][ancestor::xlf:source][ancestor::xlf:file/@id=$file-id] [not(ancestor::xlf:unit[@id=$unit-id])]">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                'isolated' attribute is set to 'yes', but the corresponding 'ec' element, out of the 'unit' with 
                'id=<xsl:text/>
                  <xsl:value-of select="$unit-id"/>
                  <xsl:text/>', was not found. The end code must appear after the start code, but in the
                same 'file'.
            </svrl:text> 
               <svrl:diagnostic-reference diagnostic="fragid-report">
#<xsl:text/>
                  <xsl:value-of select="$fragid"/>
                  <xsl:text/>
               </svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
      <xsl:if test="@canCopy='no' and not(following::xlf:ec[@id=$id][ancestor::xlf:source][ancestor::xlf:file/@id=$file-id][not(ancestor::xlf:unit[@id=$unit-id])]                 [ancestor::xlf:segment | ancestor::xlf:ignorable][@canCopy='no'])">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="@canCopy='no' and not(following::xlf:ec[@id=$id][ancestor::xlf:source][ancestor::xlf:file/@id=$file-id][not(ancestor::xlf:unit[@id=$unit-id])] [ancestor::xlf:segment | ancestor::xlf:ignorable][@canCopy='no'])">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>
                'canCopy' attribute is not matching with the 'canCopy' attribute of the corresponding 'ec' element 
                (out of 'unit' with 'id=<xsl:text/>
               <xsl:value-of select="$unit-id"/>
               <xsl:text/>').
            </svrl:text> 
            <svrl:diagnostic-reference diagnostic="fragid-report">
#<xsl:text/>
               <xsl:value-of select="$fragid"/>
               <xsl:text/>
            </svrl:diagnostic-reference>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="(@canCopy='yes' or not(@canCopy)) and                  not(following::xlf:ec[@id=$id][ancestor::xlf:source][ancestor::xlf:file/@id=$file-id][not(ancestor::xlf:unit[@id=$unit-id])]                 [ancestor::xlf:segment | ancestor::xlf:ignorable][@canCopy='yes']) and                 not(following::xlf:ec[@id=$id][ancestor::xlf:source][ancestor::xlf:file/@id=$file-id][not(ancestor::xlf:unit[@id=$unit-id])]                 [ancestor::xlf:segment | ancestor::xlf:ignorable][not(@canCopy)])">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="(@canCopy='yes' or not(@canCopy)) and not(following::xlf:ec[@id=$id][ancestor::xlf:source][ancestor::xlf:file/@id=$file-id][not(ancestor::xlf:unit[@id=$unit-id])] [ancestor::xlf:segment | ancestor::xlf:ignorable][@canCopy='yes']) and not(following::xlf:ec[@id=$id][ancestor::xlf:source][ancestor::xlf:file/@id=$file-id][not(ancestor::xlf:unit[@id=$unit-id])] [ancestor::xlf:segment | ancestor::xlf:ignorable][not(@canCopy)])">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>
                'canCopy' attribute is not matching with the 'canCopy' attribute of the corresponding 'ec' element 
                (out of 'unit' with 'id=<xsl:text/>
               <xsl:value-of select="$unit-id"/>
               <xsl:text/>').
            </svrl:text> 
            <svrl:diagnostic-reference diagnostic="fragid-report">
#<xsl:text/>
               <xsl:value-of select="$fragid"/>
               <xsl:text/>
            </svrl:diagnostic-reference>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="@canDelete='no' and not(following::xlf:ec[@id=$id][ancestor::xlf:source][ancestor::xlf:file/@id=$file-id][not(ancestor::xlf:unit[@id=$unit-id])]                 [ancestor::xlf:segment | ancestor::xlf:ignorable][@canDelete='no'])">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="@canDelete='no' and not(following::xlf:ec[@id=$id][ancestor::xlf:source][ancestor::xlf:file/@id=$file-id][not(ancestor::xlf:unit[@id=$unit-id])] [ancestor::xlf:segment | ancestor::xlf:ignorable][@canDelete='no'])">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>
                'canDelete' attribute is not matching with the 'canDelete' attribute of the corresponding 'ec' element 
                (out of 'unit' with 'id=<xsl:text/>
               <xsl:value-of select="$unit-id"/>
               <xsl:text/>').
            </svrl:text> 
            <svrl:diagnostic-reference diagnostic="fragid-report">
#<xsl:text/>
               <xsl:value-of select="$fragid"/>
               <xsl:text/>
            </svrl:diagnostic-reference>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="(@canDelete='yes' or not(@canDelete)) and                  not(following::xlf:ec[@id=$id][ancestor::xlf:source][ancestor::xlf:file/@id=$file-id][not(ancestor::xlf:unit[@id=$unit-id])]                 [ancestor::xlf:segment | ancestor::xlf:ignorable][@canDelete='yes']) and                 not(following::xlf:ec[@id=$id][ancestor::xlf:source][ancestor::xlf:file/@id=$file-id][not(ancestor::xlf:unit[@id=$unit-id])]                 [ancestor::xlf:segment | ancestor::xlf:ignorable][not(@canDelete)])">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="(@canDelete='yes' or not(@canDelete)) and not(following::xlf:ec[@id=$id][ancestor::xlf:source][ancestor::xlf:file/@id=$file-id][not(ancestor::xlf:unit[@id=$unit-id])] [ancestor::xlf:segment | ancestor::xlf:ignorable][@canDelete='yes']) and not(following::xlf:ec[@id=$id][ancestor::xlf:source][ancestor::xlf:file/@id=$file-id][not(ancestor::xlf:unit[@id=$unit-id])] [ancestor::xlf:segment | ancestor::xlf:ignorable][not(@canDelete)])">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>
                'canDelete' attribute is not matching with the 'canDelete' attribute of the corresponding 'ec' element 
                (out of 'unit' with 'id=<xsl:text/>
               <xsl:value-of select="$unit-id"/>
               <xsl:text/>').
            </svrl:text> 
            <svrl:diagnostic-reference diagnostic="fragid-report">
#<xsl:text/>
               <xsl:value-of select="$fragid"/>
               <xsl:text/>
            </svrl:diagnostic-reference>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="@canReorder='no' and not(following::xlf:ec[@id=$id][ancestor::xlf:source][ancestor::xlf:file/@id=$file-id][not(ancestor::xlf:unit[@id=$unit-id])]                 [ancestor::xlf:segment | ancestor::xlf:ignorable][@canReorder='no'])">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="@canReorder='no' and not(following::xlf:ec[@id=$id][ancestor::xlf:source][ancestor::xlf:file/@id=$file-id][not(ancestor::xlf:unit[@id=$unit-id])] [ancestor::xlf:segment | ancestor::xlf:ignorable][@canReorder='no'])">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>
                'canReorder' attribute is not matching with the 'canReorder' attribute of the corresponding 'ec' element 
                (out of 'unit' with 'id=<xsl:text/>
               <xsl:value-of select="$unit-id"/>
               <xsl:text/>').
            </svrl:text> 
            <svrl:diagnostic-reference diagnostic="fragid-report">
#<xsl:text/>
               <xsl:value-of select="$fragid"/>
               <xsl:text/>
            </svrl:diagnostic-reference>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="(@canReorder='yes' or not(@canReorder)) and                  not(following::xlf:ec[@id=$id][ancestor::xlf:source][ancestor::xlf:file/@id=$file-id][not(ancestor::xlf:unit[@id=$unit-id])]                 [ancestor::xlf:segment | ancestor::xlf:ignorable][@canReorder='yes']) and                 not(following::xlf:ec[@id=$id][ancestor::xlf:source][ancestor::xlf:file/@id=$file-id][not(ancestor::xlf:unit[@id=$unit-id])]                 [ancestor::xlf:segment | ancestor::xlf:ignorable][not(@canReorder)])">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="(@canReorder='yes' or not(@canReorder)) and not(following::xlf:ec[@id=$id][ancestor::xlf:source][ancestor::xlf:file/@id=$file-id][not(ancestor::xlf:unit[@id=$unit-id])] [ancestor::xlf:segment | ancestor::xlf:ignorable][@canReorder='yes']) and not(following::xlf:ec[@id=$id][ancestor::xlf:source][ancestor::xlf:file/@id=$file-id][not(ancestor::xlf:unit[@id=$unit-id])] [ancestor::xlf:segment | ancestor::xlf:ignorable][not(@canReorder)])">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>
                'canReorder' attribute is not matching with the 'canReorder' attribute of the corresponding 'ec' element 
                (out of 'unit' with 'id=<xsl:text/>
               <xsl:value-of select="$unit-id"/>
               <xsl:text/>').
            </svrl:text> 
            <svrl:diagnostic-reference diagnostic="fragid-report">
#<xsl:text/>
               <xsl:value-of select="$fragid"/>
               <xsl:text/>
            </svrl:diagnostic-reference>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="@canOverlap='no' and not(following::xlf:ec[@id=$id][ancestor::xlf:source][ancestor::xlf:file/@id=$file-id][not(ancestor::xlf:unit[@id=$unit-id])]                 [ancestor::xlf:segment | ancestor::xlf:ignorable][@canOverlap='no'])">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="@canOverlap='no' and not(following::xlf:ec[@id=$id][ancestor::xlf:source][ancestor::xlf:file/@id=$file-id][not(ancestor::xlf:unit[@id=$unit-id])] [ancestor::xlf:segment | ancestor::xlf:ignorable][@canOverlap='no'])">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>
                'canOverlap' attribute is not matching with the 'canOverlap' attribute of the corresponding 'ec' element 
                (out of 'unit' with 'id=<xsl:text/>
               <xsl:value-of select="$unit-id"/>
               <xsl:text/>').
            </svrl:text> 
            <svrl:diagnostic-reference diagnostic="fragid-report">
#<xsl:text/>
               <xsl:value-of select="$fragid"/>
               <xsl:text/>
            </svrl:diagnostic-reference>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="(@canOverlap='yes' or not(@canOverlap)) and                  not(following::xlf:ec[@id=$id][ancestor::xlf:source][ancestor::xlf:file/@id=$file-id][not(ancestor::xlf:unit[@id=$unit-id])]                 [ancestor::xlf:segment | ancestor::xlf:ignorable][@canOverlap='yes']) and                 not(following::xlf:ec[@id=$id][ancestor::xlf:source][ancestor::xlf:file/@id=$file-id][not(ancestor::xlf:unit[@id=$unit-id])]                 [ancestor::xlf:segment | ancestor::xlf:ignorable][not(@canOverlap)])">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="(@canOverlap='yes' or not(@canOverlap)) and not(following::xlf:ec[@id=$id][ancestor::xlf:source][ancestor::xlf:file/@id=$file-id][not(ancestor::xlf:unit[@id=$unit-id])] [ancestor::xlf:segment | ancestor::xlf:ignorable][@canOverlap='yes']) and not(following::xlf:ec[@id=$id][ancestor::xlf:source][ancestor::xlf:file/@id=$file-id][not(ancestor::xlf:unit[@id=$unit-id])] [ancestor::xlf:segment | ancestor::xlf:ignorable][not(@canOverlap)])">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>
                'canOverlap' attribute is not matching with the 'canOverlap' attribute of the corresponding 'ec' element 
                (out of 'unit' with 'id=<xsl:text/>
               <xsl:value-of select="$unit-id"/>
               <xsl:text/>').
            </svrl:text> 
            <svrl:diagnostic-reference diagnostic="fragid-report">
#<xsl:text/>
               <xsl:value-of select="$fragid"/>
               <xsl:text/>
            </svrl:diagnostic-reference>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="@canReorder='firstNo' and not(following::xlf:ec[@id=$id][ancestor::xlf:source][ancestor::xlf:file/@id=$file-id]                 [not(ancestor::xlf:unit[@id=$unit-id])][ancestor::xlf:segment | ancestor::xlf:ignorable][@canReorder='no'])">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="@canReorder='firstNo' and not(following::xlf:ec[@id=$id][ancestor::xlf:source][ancestor::xlf:file/@id=$file-id] [not(ancestor::xlf:unit[@id=$unit-id])][ancestor::xlf:segment | ancestor::xlf:ignorable][@canReorder='no'])">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>
                'canReorder' is set to 'firstNo', but the corresponding 'ec' (out of 'unit' with 'id=<xsl:text/>
               <xsl:value-of select="$unit-id"/>
               <xsl:text/>')
                has not set its 'canReorder' attribute to 'no'.
            </svrl:text> 
            <svrl:diagnostic-reference diagnostic="fragid-report">
#<xsl:text/>
               <xsl:value-of select="$fragid"/>
               <xsl:text/>
            </svrl:diagnostic-reference>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M15"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M15"/>
   <xsl:template match="@*|node()" priority="-2" mode="M15">
      <xsl:apply-templates select="*" mode="M15"/>
   </xsl:template>

   <!--PATTERN F5TThe attribute isolated must be set to yes if and only if the 'ec' element corresponding to this
            start marker is not in the same 'unit', and set to no otherwise-->
   <svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">The attribute isolated must be set to yes if and only if the 'ec' element corresponding to this
            start marker is not in the same 'unit', and set to no otherwise</svrl:text>

	  <!--RULE -->
   <xsl:template match="xlf:sc[ancestor::xlf:target][@isolated='yes'][ancestor::xlf:segment | ancestor::xlf:ignorable]"
                 priority="1000"
                 mode="M16">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="xlf:sc[ancestor::xlf:target][@isolated='yes'][ancestor::xlf:segment | ancestor::xlf:ignorable]"/>
      <xsl:variable name="id" select="current()/@id"/>
      <xsl:variable name="file-id" select="ancestor::xlf:file/@id"/>
      <xsl:variable name="unit-id" select="ancestor::xlf:unit/@id"/>
      <xsl:variable name="fragid"
                    select="concat('f=', $file-id, '/u=', $unit-id, '/t=', $id)"/>

		    <!--REPORT -->
      <xsl:if test="ancestor::xlf:unit//xlf:ec[@startRef=$id][ancestor::xlf:target]">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="ancestor::xlf:unit//xlf:ec[@startRef=$id][ancestor::xlf:target]">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>
                'isolated' attribute is set to 'yes', but 'ec' element(s) referencing this start code found within the same unit.
            </svrl:text> 
            <svrl:diagnostic-reference diagnostic="fragid-report">
#<xsl:text/>
               <xsl:value-of select="$fragid"/>
               <xsl:text/>
            </svrl:diagnostic-reference>
         </svrl:successful-report>
      </xsl:if>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="following::xlf:ec[@id=$id][ancestor::xlf:target][ancestor::xlf:file/@id=$file-id]                 [not(ancestor::xlf:unit[@id=$unit-id])]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="following::xlf:ec[@id=$id][ancestor::xlf:target][ancestor::xlf:file/@id=$file-id] [not(ancestor::xlf:unit[@id=$unit-id])]">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                'isolated' attribute is set to 'yes', but the corresponding 'ec' element, out of the 'unit' with
                'id=<xsl:text/>
                  <xsl:value-of select="$unit-id"/>
                  <xsl:text/>', was not found. The end code must appear after the start code, but in the
                same 'file'.
            </svrl:text> 
               <svrl:diagnostic-reference diagnostic="fragid-report">
#<xsl:text/>
                  <xsl:value-of select="$fragid"/>
                  <xsl:text/>
               </svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
      <xsl:if test="@canCopy='no' and not(following::xlf:ec[@id=$id][ancestor::xlf:target][ancestor::xlf:file/@id=$file-id][not(ancestor::xlf:unit[@id=$unit-id])]                 [ancestor::xlf:segment | ancestor::xlf:ignorable][@canCopy='no'])">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="@canCopy='no' and not(following::xlf:ec[@id=$id][ancestor::xlf:target][ancestor::xlf:file/@id=$file-id][not(ancestor::xlf:unit[@id=$unit-id])] [ancestor::xlf:segment | ancestor::xlf:ignorable][@canCopy='no'])">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>
                'canCopy' attribute is not matching with the 'canCopy' attribute of the corresponding 'ec' element 
                (out of 'unit' with 'id=<xsl:text/>
               <xsl:value-of select="$unit-id"/>
               <xsl:text/>').
            </svrl:text> 
            <svrl:diagnostic-reference diagnostic="fragid-report">
#<xsl:text/>
               <xsl:value-of select="$fragid"/>
               <xsl:text/>
            </svrl:diagnostic-reference>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="(@canCopy='yes' or not(@canCopy)) and                  not(following::xlf:ec[@id=$id][ancestor::xlf:target][ancestor::xlf:file/@id=$file-id][not(ancestor::xlf:unit[@id=$unit-id])]                 [ancestor::xlf:segment | ancestor::xlf:ignorable][@canCopy='yes']) and                 not(following::xlf:ec[@id=$id][ancestor::xlf:target][ancestor::xlf:file/@id=$file-id][not(ancestor::xlf:unit[@id=$unit-id])]                 [ancestor::xlf:segment | ancestor::xlf:ignorable][not(@canCopy)])">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="(@canCopy='yes' or not(@canCopy)) and not(following::xlf:ec[@id=$id][ancestor::xlf:target][ancestor::xlf:file/@id=$file-id][not(ancestor::xlf:unit[@id=$unit-id])] [ancestor::xlf:segment | ancestor::xlf:ignorable][@canCopy='yes']) and not(following::xlf:ec[@id=$id][ancestor::xlf:target][ancestor::xlf:file/@id=$file-id][not(ancestor::xlf:unit[@id=$unit-id])] [ancestor::xlf:segment | ancestor::xlf:ignorable][not(@canCopy)])">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>
                'canCopy' attribute is not matching with the 'canCopy' attribute of the corresponding 'ec' element 
                (out of 'unit' with 'id=<xsl:text/>
               <xsl:value-of select="$unit-id"/>
               <xsl:text/>').
            </svrl:text> 
            <svrl:diagnostic-reference diagnostic="fragid-report">
#<xsl:text/>
               <xsl:value-of select="$fragid"/>
               <xsl:text/>
            </svrl:diagnostic-reference>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="@canDelete='no' and not(following::xlf:ec[@id=$id][ancestor::xlf:target][ancestor::xlf:file/@id=$file-id][not(ancestor::xlf:unit[@id=$unit-id])]                 [ancestor::xlf:segment | ancestor::xlf:ignorable][@canDelete='no'])">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="@canDelete='no' and not(following::xlf:ec[@id=$id][ancestor::xlf:target][ancestor::xlf:file/@id=$file-id][not(ancestor::xlf:unit[@id=$unit-id])] [ancestor::xlf:segment | ancestor::xlf:ignorable][@canDelete='no'])">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>
                'canDelete' attribute is not matching with the 'canDelete' attribute of the corresponding 'ec' element 
                (out of 'unit' with 'id=<xsl:text/>
               <xsl:value-of select="$unit-id"/>
               <xsl:text/>').
            </svrl:text> 
            <svrl:diagnostic-reference diagnostic="fragid-report">
#<xsl:text/>
               <xsl:value-of select="$fragid"/>
               <xsl:text/>
            </svrl:diagnostic-reference>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="(@canDelete='yes' or not(@canDelete)) and                  not(following::xlf:ec[@id=$id][ancestor::xlf:target][ancestor::xlf:file/@id=$file-id][not(ancestor::xlf:unit[@id=$unit-id])]                 [ancestor::xlf:segment | ancestor::xlf:ignorable][@canDelete='yes']) and                 not(following::xlf:ec[@id=$id][ancestor::xlf:target][ancestor::xlf:file/@id=$file-id][not(ancestor::xlf:unit[@id=$unit-id])]                 [ancestor::xlf:segment | ancestor::xlf:ignorable][not(@canDelete)])">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="(@canDelete='yes' or not(@canDelete)) and not(following::xlf:ec[@id=$id][ancestor::xlf:target][ancestor::xlf:file/@id=$file-id][not(ancestor::xlf:unit[@id=$unit-id])] [ancestor::xlf:segment | ancestor::xlf:ignorable][@canDelete='yes']) and not(following::xlf:ec[@id=$id][ancestor::xlf:target][ancestor::xlf:file/@id=$file-id][not(ancestor::xlf:unit[@id=$unit-id])] [ancestor::xlf:segment | ancestor::xlf:ignorable][not(@canDelete)])">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>
                'canDelete' attribute is not matching with the 'canDelete' attribute of the corresponding 'ec' element 
                (out of 'unit' with 'id=<xsl:text/>
               <xsl:value-of select="$unit-id"/>
               <xsl:text/>').
            </svrl:text> 
            <svrl:diagnostic-reference diagnostic="fragid-report">
#<xsl:text/>
               <xsl:value-of select="$fragid"/>
               <xsl:text/>
            </svrl:diagnostic-reference>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="@canReorder='no' and not(following::xlf:ec[@id=$id][ancestor::xlf:target][ancestor::xlf:file/@id=$file-id][not(ancestor::xlf:unit[@id=$unit-id])]                 [ancestor::xlf:segment | ancestor::xlf:ignorable][@canReorder='no'])">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="@canReorder='no' and not(following::xlf:ec[@id=$id][ancestor::xlf:target][ancestor::xlf:file/@id=$file-id][not(ancestor::xlf:unit[@id=$unit-id])] [ancestor::xlf:segment | ancestor::xlf:ignorable][@canReorder='no'])">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>
                'canReorder' attribute is not matching with the 'canReorder' attribute of the corresponding 'ec' element 
                (out of 'unit' with 'id=<xsl:text/>
               <xsl:value-of select="$unit-id"/>
               <xsl:text/>').
            </svrl:text> 
            <svrl:diagnostic-reference diagnostic="fragid-report">
#<xsl:text/>
               <xsl:value-of select="$fragid"/>
               <xsl:text/>
            </svrl:diagnostic-reference>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="(@canReorder='yes' or not(@canReorder)) and                  not(following::xlf:ec[@id=$id][ancestor::xlf:target][ancestor::xlf:file/@id=$file-id][not(ancestor::xlf:unit[@id=$unit-id])]                 [ancestor::xlf:segment | ancestor::xlf:ignorable][@canReorder='yes']) and                 not(following::xlf:ec[@id=$id][ancestor::xlf:target][ancestor::xlf:file/@id=$file-id][not(ancestor::xlf:unit[@id=$unit-id])]                 [ancestor::xlf:segment | ancestor::xlf:ignorable][not(@canReorder)])">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="(@canReorder='yes' or not(@canReorder)) and not(following::xlf:ec[@id=$id][ancestor::xlf:target][ancestor::xlf:file/@id=$file-id][not(ancestor::xlf:unit[@id=$unit-id])] [ancestor::xlf:segment | ancestor::xlf:ignorable][@canReorder='yes']) and not(following::xlf:ec[@id=$id][ancestor::xlf:target][ancestor::xlf:file/@id=$file-id][not(ancestor::xlf:unit[@id=$unit-id])] [ancestor::xlf:segment | ancestor::xlf:ignorable][not(@canReorder)])">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>
                'canReorder' attribute is not matching with the 'canReorder' attribute of the corresponding 'ec' element 
                (out of 'unit' with 'id=<xsl:text/>
               <xsl:value-of select="$unit-id"/>
               <xsl:text/>').
            </svrl:text> 
            <svrl:diagnostic-reference diagnostic="fragid-report">
#<xsl:text/>
               <xsl:value-of select="$fragid"/>
               <xsl:text/>
            </svrl:diagnostic-reference>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="@canOverlap='no' and not(following::xlf:ec[@id=$id][ancestor::xlf:target][ancestor::xlf:file/@id=$file-id][not(ancestor::xlf:unit[@id=$unit-id])]                 [ancestor::xlf:segment | ancestor::xlf:ignorable][@canOverlap='no'])">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="@canOverlap='no' and not(following::xlf:ec[@id=$id][ancestor::xlf:target][ancestor::xlf:file/@id=$file-id][not(ancestor::xlf:unit[@id=$unit-id])] [ancestor::xlf:segment | ancestor::xlf:ignorable][@canOverlap='no'])">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>
                'canOverlap' attribute is not matching with the 'canOverlap' attribute of the corresponding 'ec' element 
                (out of 'unit' with 'id=<xsl:text/>
               <xsl:value-of select="$unit-id"/>
               <xsl:text/>').
            </svrl:text> 
            <svrl:diagnostic-reference diagnostic="fragid-report">
#<xsl:text/>
               <xsl:value-of select="$fragid"/>
               <xsl:text/>
            </svrl:diagnostic-reference>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="(@canOverlap='yes' or not(@canOverlap)) and                  not(following::xlf:ec[@id=$id][ancestor::xlf:source][ancestor::xlf:file/@id=$file-id][not(ancestor::xlf:unit[@id=$unit-id])]                 [ancestor::xlf:segment | ancestor::xlf:ignorable][@canOverlap='yes']) and                 not(following::xlf:ec[@id=$id][ancestor::xlf:source][ancestor::xlf:file/@id=$file-id][not(ancestor::xlf:unit[@id=$unit-id])]                 [ancestor::xlf:segment | ancestor::xlf:ignorable][not(@canOverlap)])">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="(@canOverlap='yes' or not(@canOverlap)) and not(following::xlf:ec[@id=$id][ancestor::xlf:source][ancestor::xlf:file/@id=$file-id][not(ancestor::xlf:unit[@id=$unit-id])] [ancestor::xlf:segment | ancestor::xlf:ignorable][@canOverlap='yes']) and not(following::xlf:ec[@id=$id][ancestor::xlf:source][ancestor::xlf:file/@id=$file-id][not(ancestor::xlf:unit[@id=$unit-id])] [ancestor::xlf:segment | ancestor::xlf:ignorable][not(@canOverlap)])">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>
                'canOverlap' attribute is not matching with the 'canOverlap' attribute of the corresponding 'ec' element 
                (out of 'unit' with 'id=<xsl:text/>
               <xsl:value-of select="$unit-id"/>
               <xsl:text/>').
            </svrl:text> 
            <svrl:diagnostic-reference diagnostic="fragid-report">
#<xsl:text/>
               <xsl:value-of select="$fragid"/>
               <xsl:text/>
            </svrl:diagnostic-reference>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="@canReorder='firstNo' and not(following::xlf:ec[@id=$id][ancestor::xlf:target][ancestor::xlf:file/@id=$file-id]                 [not(ancestor::xlf:unit[@id=$unit-id])][ancestor::xlf:segment | ancestor::xlf:ignorable][@canReorder='no'])">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="@canReorder='firstNo' and not(following::xlf:ec[@id=$id][ancestor::xlf:target][ancestor::xlf:file/@id=$file-id] [not(ancestor::xlf:unit[@id=$unit-id])][ancestor::xlf:segment | ancestor::xlf:ignorable][@canReorder='no'])">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>
                'canReorder' is set to 'firstNo', but the corresponding 'ec' (out of 'unit' with 'id=<xsl:text/>
               <xsl:value-of select="$unit-id"/>
               <xsl:text/>')
                has not set its 'canReorder' attribute to 'no'.
            </svrl:text> 
            <svrl:diagnostic-reference diagnostic="fragid-report">
#<xsl:text/>
               <xsl:value-of select="$fragid"/>
               <xsl:text/>
            </svrl:diagnostic-reference>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M16"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M16"/>
   <xsl:template match="@*|node()" priority="-2" mode="M16">
      <xsl:apply-templates select="*" mode="M16"/>
   </xsl:template>

   <!--PATTERN F5.1SThe attribute isolated must be set to yes if and only if the 'ec' element corresponding to this
            start marker is not in the same 'unit', and set to no otherwise-->
   <svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">The attribute isolated must be set to yes if and only if the 'ec' element corresponding to this
            start marker is not in the same 'unit', and set to no otherwise</svrl:text>

	  <!--RULE -->
   <xsl:template match="xlf:sc[ancestor::xlf:source][ancestor::xlf:segment | ancestor::xlf:ignorable][@isolated='no'] |              xlf:sc[ancestor::xlf:source][ancestor::xlf:segment | ancestor::xlf:ignorable][not(@isolated)]"
                 priority="1000"
                 mode="M17">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="xlf:sc[ancestor::xlf:source][ancestor::xlf:segment | ancestor::xlf:ignorable][@isolated='no'] |              xlf:sc[ancestor::xlf:source][ancestor::xlf:segment | ancestor::xlf:ignorable][not(@isolated)]"/>
      <xsl:variable name="id" select="current()/@id"/>
      <xsl:variable name="file-id" select="ancestor::xlf:file/@id"/>
      <xsl:variable name="unit-id" select="ancestor::xlf:unit/@id"/>
      <xsl:variable name="fragid"
                    select="concat('f=', $file-id, '/u=', $unit-id, '/', $id)"/>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="count(following::xlf:ec[@startRef=$id][ancestor::xlf:source]                 [ancestor::xlf:unit[@id=$unit-id]][ancestor::xlf:file[@id=$file-id]])=1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count(following::xlf:ec[@startRef=$id][ancestor::xlf:source] [ancestor::xlf:unit[@id=$unit-id]][ancestor::xlf:file[@id=$file-id]])=1">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                'isolated' attribute is set to 'not', but the corresponding 'ec' element within the same 'unit' was not found. 
                The end code must appear after the start code.
            </svrl:text> 
               <svrl:diagnostic-reference diagnostic="fragid-report">
#<xsl:text/>
                  <xsl:value-of select="$fragid"/>
                  <xsl:text/>
               </svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
      <xsl:if test="@canCopy='no' and not(following::xlf:ec[@startRef=$id][ancestor::xlf:source]                 [ancestor::xlf:unit/@id=$unit-id][ancestor::xlf:file/@id=$file-id][@canCopy='no'])">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="@canCopy='no' and not(following::xlf:ec[@startRef=$id][ancestor::xlf:source] [ancestor::xlf:unit/@id=$unit-id][ancestor::xlf:file/@id=$file-id][@canCopy='no'])">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>
                'canCopy' attribute is not matching with the 'canCopy' attribute of the corresponding 'ec' element within the same 'unit'.
            </svrl:text> 
            <svrl:diagnostic-reference diagnostic="fragid-report">
#<xsl:text/>
               <xsl:value-of select="$fragid"/>
               <xsl:text/>
            </svrl:diagnostic-reference>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="(@canCopy='yes' or not(@canCopy)) and not(following::xlf:ec[@startRef=$id][ancestor::xlf:source]                 [ancestor::xlf:unit/@id=$unit-id][ancestor::xlf:file/@id=$file-id][@canCopy='yes']) and                  not(following::xlf:ec[@startRef=$id][ancestor::xlf:source][ancestor::xlf:unit/@id=$unit-id]                 [ancestor::xlf:file/@id=$file-id][not(@canCopy)])">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="(@canCopy='yes' or not(@canCopy)) and not(following::xlf:ec[@startRef=$id][ancestor::xlf:source] [ancestor::xlf:unit/@id=$unit-id][ancestor::xlf:file/@id=$file-id][@canCopy='yes']) and not(following::xlf:ec[@startRef=$id][ancestor::xlf:source][ancestor::xlf:unit/@id=$unit-id] [ancestor::xlf:file/@id=$file-id][not(@canCopy)])">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>
                'canCopy' attribute is not matching with the 'canCopy' attribute of the corresponding 'ec' element within the same 'unit'.
            </svrl:text> 
            <svrl:diagnostic-reference diagnostic="fragid-report">
#<xsl:text/>
               <xsl:value-of select="$fragid"/>
               <xsl:text/>
            </svrl:diagnostic-reference>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="@canDelete='no' and not(following::xlf:ec[@startRef=$id][ancestor::xlf:source]                 [ancestor::xlf:unit/@id=$unit-id][ancestor::xlf:file/@id=$file-id][@canDelete='no'])">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="@canDelete='no' and not(following::xlf:ec[@startRef=$id][ancestor::xlf:source] [ancestor::xlf:unit/@id=$unit-id][ancestor::xlf:file/@id=$file-id][@canDelete='no'])">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>
                'canDelete' attribute is not matching with the 'canDelete' attribute of the corresponding 'ec' element within the same 'unit'.
            </svrl:text> 
            <svrl:diagnostic-reference diagnostic="fragid-report">
#<xsl:text/>
               <xsl:value-of select="$fragid"/>
               <xsl:text/>
            </svrl:diagnostic-reference>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="(@canDelete='yes' or not(@canDelete)) and not(following::xlf:ec[@startRef=$id]                 [ancestor::xlf:source][ancestor::xlf:unit/@id=$unit-id][ancestor::xlf:file/@id=$file-id][@canDelete='yes']) and                  not(following::xlf:ec[@startRef=$id][ancestor::xlf:source][ancestor::xlf:unit/@id=$unit-id]                 [ancestor::xlf:file/@id=$file-id][not(@canDelete)])">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="(@canDelete='yes' or not(@canDelete)) and not(following::xlf:ec[@startRef=$id] [ancestor::xlf:source][ancestor::xlf:unit/@id=$unit-id][ancestor::xlf:file/@id=$file-id][@canDelete='yes']) and not(following::xlf:ec[@startRef=$id][ancestor::xlf:source][ancestor::xlf:unit/@id=$unit-id] [ancestor::xlf:file/@id=$file-id][not(@canDelete)])">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>
                'canDelete' attribute is not matching with the 'canDelete' attribute of the corresponding 'ec' element within the same 'unit'.
            </svrl:text> 
            <svrl:diagnostic-reference diagnostic="fragid-report">
#<xsl:text/>
               <xsl:value-of select="$fragid"/>
               <xsl:text/>
            </svrl:diagnostic-reference>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="@canReorder='no' and not(following::xlf:ec[@startRef=$id][ancestor::xlf:source]                 [ancestor::xlf:unit/@id=$unit-id][ancestor::xlf:file/@id=$file-id][@canReorder='no'])">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="@canReorder='no' and not(following::xlf:ec[@startRef=$id][ancestor::xlf:source] [ancestor::xlf:unit/@id=$unit-id][ancestor::xlf:file/@id=$file-id][@canReorder='no'])">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>
                'canReorder' attribute is not matching with the 'canReorder' attribute of the corresponding 'ec' element within the same 'unit'.
            </svrl:text> 
            <svrl:diagnostic-reference diagnostic="fragid-report">
#<xsl:text/>
               <xsl:value-of select="$fragid"/>
               <xsl:text/>
            </svrl:diagnostic-reference>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="(@canReorder='yes' or not(@canReorder)) and not(following::xlf:ec[@startRef=$id]                 [ancestor::xlf:source][ancestor::xlf:unit/@id=$unit-id][ancestor::xlf:file/@id=$file-id][@canReorder='yes']) and                  not(following::xlf:ec[@startRef=$id][ancestor::xlf:source][ancestor::xlf:unit/@id=$unit-id]                 [ancestor::xlf:file/@id=$file-id][not(@canReorder)])">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="(@canReorder='yes' or not(@canReorder)) and not(following::xlf:ec[@startRef=$id] [ancestor::xlf:source][ancestor::xlf:unit/@id=$unit-id][ancestor::xlf:file/@id=$file-id][@canReorder='yes']) and not(following::xlf:ec[@startRef=$id][ancestor::xlf:source][ancestor::xlf:unit/@id=$unit-id] [ancestor::xlf:file/@id=$file-id][not(@canReorder)])">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>
                'canReorder' attribute is not matching with the 'canReorder' attribute of the corresponding 'ec' element within the same 'unit'.
            </svrl:text> 
            <svrl:diagnostic-reference diagnostic="fragid-report">
#<xsl:text/>
               <xsl:value-of select="$fragid"/>
               <xsl:text/>
            </svrl:diagnostic-reference>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="@canOverlap='no' and not(following::xlf:ec[@startRef=$id][ancestor::xlf:source]                 [ancestor::xlf:unit/@id=$unit-id][ancestor::xlf:file/@id=$file-id][@canOverlap='no'])">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="@canOverlap='no' and not(following::xlf:ec[@startRef=$id][ancestor::xlf:source] [ancestor::xlf:unit/@id=$unit-id][ancestor::xlf:file/@id=$file-id][@canOverlap='no'])">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>
                'canOverlap' attribute is not matching with the 'canOverlap' attribute of the corresponding 'ec' element within the same 'unit'.
            </svrl:text> 
            <svrl:diagnostic-reference diagnostic="fragid-report">
#<xsl:text/>
               <xsl:value-of select="$fragid"/>
               <xsl:text/>
            </svrl:diagnostic-reference>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="(@canOverlap='yes' or not(@canOverlap)) and not(following::xlf:ec[@startRef=$id]                 [ancestor::xlf:source][ancestor::xlf:unit/@id=$unit-id][ancestor::xlf:file/@id=$file-id][@canOverlap='yes']) and                  not(following::xlf:ec[@startRef=$id][ancestor::xlf:source][ancestor::xlf:unit/@id=$unit-id]                 [ancestor::xlf:file/@id=$file-id][not(@canOverlap)])">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="(@canOverlap='yes' or not(@canOverlap)) and not(following::xlf:ec[@startRef=$id] [ancestor::xlf:source][ancestor::xlf:unit/@id=$unit-id][ancestor::xlf:file/@id=$file-id][@canOverlap='yes']) and not(following::xlf:ec[@startRef=$id][ancestor::xlf:source][ancestor::xlf:unit/@id=$unit-id] [ancestor::xlf:file/@id=$file-id][not(@canOverlap)])">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>
                'canOverlap' attribute is not matching with the 'canOverlap' attribute of the corresponding 'ec' element within the same 'unit'.
            </svrl:text> 
            <svrl:diagnostic-reference diagnostic="fragid-report">
#<xsl:text/>
               <xsl:value-of select="$fragid"/>
               <xsl:text/>
            </svrl:diagnostic-reference>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="@canReorder='firstNo' and not(following::xlf:ec[@startRef=$id][ancestor::xlf:source][ancestor::xlf:unit/@id=$unit-id]                 [ancestor::xlf:file/@id=$file-id][@canReorder='no'])">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="@canReorder='firstNo' and not(following::xlf:ec[@startRef=$id][ancestor::xlf:source][ancestor::xlf:unit/@id=$unit-id] [ancestor::xlf:file/@id=$file-id][@canReorder='no'])">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>
                'canReorder' is set to 'firstNo', but the corresponding 'ec', within the same 'unit'
                has not set its 'canReorder' attribute to 'no'.
            </svrl:text> 
            <svrl:diagnostic-reference diagnostic="fragid-report">
#<xsl:text/>
               <xsl:value-of select="$fragid"/>
               <xsl:text/>
            </svrl:diagnostic-reference>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M17"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M17"/>
   <xsl:template match="@*|node()" priority="-2" mode="M17">
      <xsl:apply-templates select="*" mode="M17"/>
   </xsl:template>

   <!--PATTERN F5.1TThe attribute isolated must be set to yes if and only if the 'ec' element corresponding to this
            start marker is not in the same 'unit', and set to no otherwise-->
   <svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">The attribute isolated must be set to yes if and only if the 'ec' element corresponding to this
            start marker is not in the same 'unit', and set to no otherwise</svrl:text>

	  <!--RULE -->
   <xsl:template match="xlf:sc[ancestor::xlf:target][ancestor::xlf:segment | ancestor::xlf:ignorable][@isolated='no'] |              xlf:sc[ancestor::xlf:target][ancestor::xlf:segment | ancestor::xlf:ignorable][not(@isolated)]"
                 priority="1000"
                 mode="M18">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="xlf:sc[ancestor::xlf:target][ancestor::xlf:segment | ancestor::xlf:ignorable][@isolated='no'] |              xlf:sc[ancestor::xlf:target][ancestor::xlf:segment | ancestor::xlf:ignorable][not(@isolated)]"/>
      <xsl:variable name="id" select="current()/@id"/>
      <xsl:variable name="file-id" select="ancestor::xlf:file/@id"/>
      <xsl:variable name="unit-id" select="ancestor::xlf:unit/@id"/>
      <xsl:variable name="fragid"
                    select="concat('f=', $file-id, '/u=', $unit-id, '/t=', $id)"/>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="count(following::xlf:ec[@startRef=$id][ancestor::xlf:target]                 [ancestor::xlf:unit[@id=$unit-id]][ancestor::xlf:file[@id=$file-id]])=1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count(following::xlf:ec[@startRef=$id][ancestor::xlf:target] [ancestor::xlf:unit[@id=$unit-id]][ancestor::xlf:file[@id=$file-id]])=1">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                'isolated' attribute is set to 'not', but the corresponding 'ec' element within the same 'unit' was not found.
                The end code must appear after the start code.
            </svrl:text> 
               <svrl:diagnostic-reference diagnostic="fragid-report">
#<xsl:text/>
                  <xsl:value-of select="$fragid"/>
                  <xsl:text/>
               </svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
      <xsl:if test="@canCopy='no' and not(following::xlf:ec[@startRef=$id][ancestor::xlf:target]                 [ancestor::xlf:unit/@id=$unit-id][ancestor::xlf:file/@id=$file-id][@canCopy='no'])">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="@canCopy='no' and not(following::xlf:ec[@startRef=$id][ancestor::xlf:target] [ancestor::xlf:unit/@id=$unit-id][ancestor::xlf:file/@id=$file-id][@canCopy='no'])">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>
                'canCopy' attribute is not matching with the 'canCopy' attribute of the corresponding 'ec' element within the same 'unit'.
            </svrl:text> 
            <svrl:diagnostic-reference diagnostic="fragid-report">
#<xsl:text/>
               <xsl:value-of select="$fragid"/>
               <xsl:text/>
            </svrl:diagnostic-reference>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="(@canCopy='yes' or not(@canCopy)) and not(following::xlf:ec[@startRef=$id]                 [ancestor::xlf:target][ancestor::xlf:unit/@id=$unit-id][ancestor::xlf:file/@id=$file-id][@canCopy='yes']) and                  not(following::xlf:ec[@startRef=$id][ancestor::xlf:target][ancestor::xlf:unit/@id=$unit-id]                 [ancestor::xlf:file/@id=$file-id][not(@canCopy)])">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="(@canCopy='yes' or not(@canCopy)) and not(following::xlf:ec[@startRef=$id] [ancestor::xlf:target][ancestor::xlf:unit/@id=$unit-id][ancestor::xlf:file/@id=$file-id][@canCopy='yes']) and not(following::xlf:ec[@startRef=$id][ancestor::xlf:target][ancestor::xlf:unit/@id=$unit-id] [ancestor::xlf:file/@id=$file-id][not(@canCopy)])">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>
                'canCopy' attribute is not matching with the 'canCopy' attribute of the corresponding 'ec' element within the same 'unit'.
            </svrl:text> 
            <svrl:diagnostic-reference diagnostic="fragid-report">
#<xsl:text/>
               <xsl:value-of select="$fragid"/>
               <xsl:text/>
            </svrl:diagnostic-reference>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="@canDelete='no' and not(following::xlf:ec[@startRef=$id][ancestor::xlf:target]                 [ancestor::xlf:unit/@id=$unit-id][ancestor::xlf:file/@id=$file-id][@canDelete='no'])">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="@canDelete='no' and not(following::xlf:ec[@startRef=$id][ancestor::xlf:target] [ancestor::xlf:unit/@id=$unit-id][ancestor::xlf:file/@id=$file-id][@canDelete='no'])">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>
                'canDelete' attribute is not matching with the 'canDelete' attribute of the corresponding 'ec' element within the same 'unit'.
            </svrl:text> 
            <svrl:diagnostic-reference diagnostic="fragid-report">
#<xsl:text/>
               <xsl:value-of select="$fragid"/>
               <xsl:text/>
            </svrl:diagnostic-reference>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="(@canDelete='yes' or not(@canDelete)) and not(following::xlf:ec[@startRef=$id]                 [ancestor::xlf:target][ancestor::xlf:unit/@id=$unit-id][ancestor::xlf:file/@id=$file-id][@canDelete='yes']) and                  not(following::xlf:ec[@startRef=$id][ancestor::xlf:target][ancestor::xlf:unit/@id=$unit-id]                 [ancestor::xlf:file/@id=$file-id][not(@canDelete)])">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="(@canDelete='yes' or not(@canDelete)) and not(following::xlf:ec[@startRef=$id] [ancestor::xlf:target][ancestor::xlf:unit/@id=$unit-id][ancestor::xlf:file/@id=$file-id][@canDelete='yes']) and not(following::xlf:ec[@startRef=$id][ancestor::xlf:target][ancestor::xlf:unit/@id=$unit-id] [ancestor::xlf:file/@id=$file-id][not(@canDelete)])">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>
                The 'canDelete' attribute is not matching with the 'canDelete' attribute of the corresponding 'ec' element within the same 'unit'.
            </svrl:text> 
            <svrl:diagnostic-reference diagnostic="fragid-report">
#<xsl:text/>
               <xsl:value-of select="$fragid"/>
               <xsl:text/>
            </svrl:diagnostic-reference>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="@canReorder='no' and not(following::xlf:ec[@startRef=$id][ancestor::xlf:target]                 [ancestor::xlf:unit/@id=$unit-id][ancestor::xlf:file/@id=$file-id][@canReorder='no'])">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="@canReorder='no' and not(following::xlf:ec[@startRef=$id][ancestor::xlf:target] [ancestor::xlf:unit/@id=$unit-id][ancestor::xlf:file/@id=$file-id][@canReorder='no'])">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>
                'canReorder' attribute is not matching with the 'canReorder' attribute of the corresponding 'ec' element within the same 'unit'.
            </svrl:text> 
            <svrl:diagnostic-reference diagnostic="fragid-report">
#<xsl:text/>
               <xsl:value-of select="$fragid"/>
               <xsl:text/>
            </svrl:diagnostic-reference>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="(@canReorder='yes' or not(@canReorder)) and not(following::xlf:ec[@startRef=$id]                 [ancestor::xlf:target][ancestor::xlf:unit/@id=$unit-id][ancestor::xlf:file/@id=$file-id][@canReorder='yes']) and                  not(following::xlf:ec[@startRef=$id][ancestor::xlf:target][ancestor::xlf:unit/@id=$unit-id]                 [ancestor::xlf:file/@id=$file-id][not(@canReorder)])">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="(@canReorder='yes' or not(@canReorder)) and not(following::xlf:ec[@startRef=$id] [ancestor::xlf:target][ancestor::xlf:unit/@id=$unit-id][ancestor::xlf:file/@id=$file-id][@canReorder='yes']) and not(following::xlf:ec[@startRef=$id][ancestor::xlf:target][ancestor::xlf:unit/@id=$unit-id] [ancestor::xlf:file/@id=$file-id][not(@canReorder)])">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>
                'canReorder' attribute is not matching with the 'canReorder' attribute of the corresponding 'ec' element within the same 'unit'.
            </svrl:text> 
            <svrl:diagnostic-reference diagnostic="fragid-report">
#<xsl:text/>
               <xsl:value-of select="$fragid"/>
               <xsl:text/>
            </svrl:diagnostic-reference>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="@canOverlap='no' and not(following::xlf:ec[@startRef=$id][ancestor::xlf:target]                 [ancestor::xlf:unit/@id=$unit-id][ancestor::xlf:file/@id=$file-id][@canOverlap='no'])">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="@canOverlap='no' and not(following::xlf:ec[@startRef=$id][ancestor::xlf:target] [ancestor::xlf:unit/@id=$unit-id][ancestor::xlf:file/@id=$file-id][@canOverlap='no'])">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>
                'canOverlap' attribute is not matching with the 'canOverlap' attribute of the corresponding 'ec' element within the same 'unit'.
            </svrl:text> 
            <svrl:diagnostic-reference diagnostic="fragid-report">
#<xsl:text/>
               <xsl:value-of select="$fragid"/>
               <xsl:text/>
            </svrl:diagnostic-reference>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="(@canOverlap='yes' or not(@canOverlap)) and not(following::xlf:ec[@startRef=$id]                 [ancestor::xlf:target][ancestor::xlf:unit/@id=$unit-id][ancestor::xlf:file/@id=$file-id][@canOverlap='yes']) and                  not(following::xlf:ec[@startRef=$id][ancestor::xlf:target][ancestor::xlf:unit/@id=$unit-id]                 [ancestor::xlf:file/@id=$file-id][not(@canOverlap)])">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="(@canOverlap='yes' or not(@canOverlap)) and not(following::xlf:ec[@startRef=$id] [ancestor::xlf:target][ancestor::xlf:unit/@id=$unit-id][ancestor::xlf:file/@id=$file-id][@canOverlap='yes']) and not(following::xlf:ec[@startRef=$id][ancestor::xlf:target][ancestor::xlf:unit/@id=$unit-id] [ancestor::xlf:file/@id=$file-id][not(@canOverlap)])">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>
                The 'canOverlap' attribute is not matching with the 'canOverlap' attribute of the corresponding 'ec' element within the same 'unit'.
            </svrl:text> 
            <svrl:diagnostic-reference diagnostic="fragid-report">
#<xsl:text/>
               <xsl:value-of select="$fragid"/>
               <xsl:text/>
            </svrl:diagnostic-reference>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="@canReorder='firstNo' and not(following::xlf:ec[@startRef=$id][ancestor::xlf:target][ancestor::xlf:unit/@id=$unit-id]                 [ancestor::xlf:file/@id=$file-id][@canReorder='no'])">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="@canReorder='firstNo' and not(following::xlf:ec[@startRef=$id][ancestor::xlf:target][ancestor::xlf:unit/@id=$unit-id] [ancestor::xlf:file/@id=$file-id][@canReorder='no'])">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>
                'canReorder' is set to 'firstNo', but the corresponding 'ec', within the same 'unit'
                has not set its 'canReorder' attribute to 'no'.
            </svrl:text> 
            <svrl:diagnostic-reference diagnostic="fragid-report">
#<xsl:text/>
               <xsl:value-of select="$fragid"/>
               <xsl:text/>
            </svrl:diagnostic-reference>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M18"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M18"/>
   <xsl:template match="@*|node()" priority="-2" mode="M18">
      <xsl:apply-templates select="*" mode="M18"/>
   </xsl:template>

   <!--PATTERN F6SThe attribute isolated must be set to yes if and only if the 'sc' element corresponding to this
            end code [ec] is not in the same 'unit' and set to no otherwise-->
   <svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">The attribute isolated must be set to yes if and only if the 'sc' element corresponding to this
            end code [ec] is not in the same 'unit' and set to no otherwise</svrl:text>

	  <!--RULE -->
   <xsl:template match="xlf:ec[ancestor::xlf:source][ancestor::xlf:segment | ancestor::xlf:ignorable]"
                 priority="1000"
                 mode="M19">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="xlf:ec[ancestor::xlf:source][ancestor::xlf:segment | ancestor::xlf:ignorable]"/>
      <xsl:variable name="file-id" select="ancestor::xlf:file/@id"/>
      <xsl:variable name="unit-id" select="ancestor::xlf:unit/@id"/>
      <xsl:variable name="fragid" select="concat('f=', $file-id, '/u=', $unit-id)"/>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="(@isolated='yes' and @id and not(@startRef)) or                  ((@isolated='no' or not(@isolated)) and @startRef and not(@id))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="(@isolated='yes' and @id and not(@startRef)) or ((@isolated='no' or not(@isolated)) and @startRef and not(@id))">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                Illegal use of 'id' and 'startRef' atribute. If 'isolated' is set to 'yes', only 'id' must be 
                used and if set to 'no' (or missing), only 'startRef' must be specified
            </svrl:text> 
               <svrl:diagnostic-reference diagnostic="fragid-report">
#<xsl:text/>
                  <xsl:value-of select="$fragid"/>
                  <xsl:text/>
               </svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
      <xsl:if test="(@isolated='yes' and not(preceding::xlf:sc[@id=current()/@id][@isolated='yes'][ancestor::xlf:source]                 [ancestor::xlf:segment | ancestor::xlf:ignorable][ancestor::xlf:file/@id=$file-id]                 [not(ancestor::xlf:unit/@id=$unit-id)]))">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="(@isolated='yes' and not(preceding::xlf:sc[@id=current()/@id][@isolated='yes'][ancestor::xlf:source] [ancestor::xlf:segment | ancestor::xlf:ignorable][ancestor::xlf:file/@id=$file-id] [not(ancestor::xlf:unit/@id=$unit-id)]))">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>
                'isolated' attribute is set to 'yes', but the corresponding 'sc' element, out of the 'unit' with 
                'id=<xsl:text/>
               <xsl:value-of select="$unit-id"/>
               <xsl:text/>', was not found. The start code must appear before the end code, but in the
                same 'file'.
            </svrl:text> 
            <svrl:diagnostic-reference diagnostic="fragid-report">
#<xsl:text/>
               <xsl:value-of select="$fragid"/>
               <xsl:text/>
            </svrl:diagnostic-reference>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="(@isolated='no' or not(@isolated)) and count(preceding::xlf:sc[@id=current()/@startRef][ancestor::xlf:source]                 [ancestor::xlf:file/@id=$file-id][ancestor::xlf:unit/@id=$unit-id][not(@isolated='yes')])!=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="(@isolated='no' or not(@isolated)) and count(preceding::xlf:sc[@id=current()/@startRef][ancestor::xlf:source] [ancestor::xlf:file/@id=$file-id][ancestor::xlf:unit/@id=$unit-id][not(@isolated='yes')])!=1">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>
                'isolated' attribute is set to 'not', but the corresponding 'sc' element within the same 'unit' was not found. 
                The start code must appear befor the end code.
            </svrl:text> 
            <svrl:diagnostic-reference diagnostic="fragid-report">
#<xsl:text/>
               <xsl:value-of select="$fragid"/>
               <xsl:text/>
            </svrl:diagnostic-reference>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M19"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M19"/>
   <xsl:template match="@*|node()" priority="-2" mode="M19">
      <xsl:apply-templates select="*" mode="M19"/>
   </xsl:template>

   <!--PATTERN F6TThe attribute isolated must be set to yes if and only if the 'sc' element corresponding to this
            end code [ec] is not in the same 'unit' and set to no otherwise-->
   <svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">The attribute isolated must be set to yes if and only if the 'sc' element corresponding to this
            end code [ec] is not in the same 'unit' and set to no otherwise</svrl:text>

	  <!--RULE -->
   <xsl:template match="xlf:ec[ancestor::xlf:target][ancestor::xlf:segment | ancestor::xlf:ignorable]"
                 priority="1000"
                 mode="M20">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="xlf:ec[ancestor::xlf:target][ancestor::xlf:segment | ancestor::xlf:ignorable]"/>
      <xsl:variable name="file-id" select="ancestor::xlf:file/@id"/>
      <xsl:variable name="unit-id" select="ancestor::xlf:unit/@id"/>
      <xsl:variable name="fragid" select="concat('f=', $file-id, '/u=', $unit-id)"/>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="(@isolated='yes' and @id and not(@startRef)) or                  ((@isolated='no' or not(@isolated)) and @startRef and not(@id))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="(@isolated='yes' and @id and not(@startRef)) or ((@isolated='no' or not(@isolated)) and @startRef and not(@id))">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                Illegal use of 'id' and 'startRef' atribute. If 'isolated' is set to 'yes', only 'id' must be 
                used and if set to 'no' (or missing), only 'startRef' must be specified
            </svrl:text> 
               <svrl:diagnostic-reference diagnostic="fragid-report">
#<xsl:text/>
                  <xsl:value-of select="$fragid"/>
                  <xsl:text/>
               </svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--REPORT -->
      <xsl:if test="(@isolated='yes' and not(preceding::xlf:sc[@id=current()/@id][@isolated='yes'][ancestor::xlf:target]                 [ancestor::xlf:segment | ancestor::xlf:ignorable][ancestor::xlf:file/@id=$file-id]                 [not(ancestor::xlf:unit/@id=$unit-id)]))">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="(@isolated='yes' and not(preceding::xlf:sc[@id=current()/@id][@isolated='yes'][ancestor::xlf:target] [ancestor::xlf:segment | ancestor::xlf:ignorable][ancestor::xlf:file/@id=$file-id] [not(ancestor::xlf:unit/@id=$unit-id)]))">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>
                'isolated' attribute is set to 'yes', but the corresponding 'sc' element, out of the 'unit' with 
                'id=<xsl:text/>
               <xsl:value-of select="$unit-id"/>
               <xsl:text/>', was not found. The start code must appear before the end code, but in the
                same 'file'.
            </svrl:text> 
            <svrl:diagnostic-reference diagnostic="fragid-report">
#<xsl:text/>
               <xsl:value-of select="$fragid"/>
               <xsl:text/>
            </svrl:diagnostic-reference>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="(@isolated='no' or not(@isolated)) and count(preceding::xlf:sc[@id=current()/@startRef][ancestor::xlf:target]                 [ancestor::xlf:file/@id=$file-id][ancestor::xlf:unit/@id=$unit-id][not(@isolated='yes')])!=1">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="(@isolated='no' or not(@isolated)) and count(preceding::xlf:sc[@id=current()/@startRef][ancestor::xlf:target] [ancestor::xlf:file/@id=$file-id][ancestor::xlf:unit/@id=$unit-id][not(@isolated='yes')])!=1">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>
                'isolated' attribute is set to 'not', but the corresponding 'sc' element within the same 'unit' was not found. 
                The start code must appear befor the end code.
            </svrl:text> 
            <svrl:diagnostic-reference diagnostic="fragid-report">
#<xsl:text/>
               <xsl:value-of select="$fragid"/>
               <xsl:text/>
            </svrl:diagnostic-reference>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="(@isolated='no' or not(@isolated)) and @dir">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="(@isolated='no' or not(@isolated)) and @dir">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>
                'dir' attribute is not allowed when 'ec' is not isolated ('isolated' is set to 'no' or missing).
            </svrl:text> 
            <svrl:diagnostic-reference diagnostic="fragid-report">
#<xsl:text/>
               <xsl:value-of select="$fragid"/>
               <xsl:text/>
            </svrl:diagnostic-reference>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M20"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M20"/>
   <xsl:template match="@*|node()" priority="-2" mode="M20">
      <xsl:apply-templates select="*" mode="M20"/>
   </xsl:template>

   <!--PATTERN F7If the attribute subState is used, the attribute state must be explicitly set-->
   <svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">If the attribute subState is used, the attribute state must be explicitly set</svrl:text>

	  <!--RULE -->
   <xsl:template match="xlf:segment[@subState]" priority="1000" mode="M21">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="xlf:segment[@subState]"/>
      <xsl:variable name="fragid"
                    select="concat('f=',ancestor::xlf:file/@id, '/u=',ancestor::xlf:unit/@id)"/>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="@state"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@state">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                'segment' element specifies 'subState' attribute, but missing the 'state' attribute.
            </svrl:text> 
               <svrl:diagnostic-reference diagnostic="fragid-report">
#<xsl:text/>
                  <xsl:value-of select="$fragid"/>
                  <xsl:text/>
               </svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M21"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M21"/>
   <xsl:template match="@*|node()" priority="-2" mode="M21">
      <xsl:apply-templates select="*" mode="M21"/>
   </xsl:template>

   <!--PATTERN F8If the attribute 'subType' is used, the attribute 'type' must be specified as well-->
   <svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">If the attribute 'subType' is used, the attribute 'type' must be specified as well</svrl:text>

	  <!--RULE -->
   <xsl:template match="xlf:*[@subType]" priority="1000" mode="M22">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="xlf:*[@subType]"/>
      <xsl:variable name="fragid"
                    select="concat('f=',ancestor::xlf:file/@id,'/u=',ancestor::xlf:unit/@id)"/>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="@type"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@type">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                '<xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/>' element specifies 'subType' attribute, but missing the 'type' attribute.
            </svrl:text> 
               <svrl:diagnostic-reference diagnostic="fragid-report">
#<xsl:text/>
                  <xsl:value-of select="$fragid"/>
                  <xsl:text/>
               </svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="((@subType='xlf:i' or @subType='xlf:u' or @subType='xlf:lb' or @subType='xlf:pb' or @subType='xlf:b')and( @type='fmt')) or                 (@subType='xlf:var' and @type='ui') or not(starts-with(@subType,'xlf:'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="((@subType='xlf:i' or @subType='xlf:u' or @subType='xlf:lb' or @subType='xlf:pb' or @subType='xlf:b')and( @type='fmt')) or (@subType='xlf:var' and @type='ui') or not(starts-with(@subType,'xlf:'))">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                'type' and 'subType' attributes don't match. Value of 'type' must either be set to a user-defined value, 
                or to 'ui' when 'subType=xlf:var', or to 'fmt' for following values of 'subType':'xlf:i','xlf:u','xlf:lb' and 'xlf:pb'.
            </svrl:text> 
               <svrl:diagnostic-reference diagnostic="fragid-report">
#<xsl:text/>
                  <xsl:value-of select="$fragid"/>
                  <xsl:text/>
               </svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M22"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M22"/>
   <xsl:template match="@*|node()" priority="-2" mode="M22">
      <xsl:apply-templates select="*" mode="M22"/>
   </xsl:template>

   <!--PATTERN F9The copyOf attribute must be used when, and only when, the base code has no associated original data-->
   <svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">The copyOf attribute must be used when, and only when, the base code has no associated original data</svrl:text>

	  <!--RULE -->
   <xsl:template match="xlf:*[@copyOf]" priority="1000" mode="M23">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="xlf:*[@copyOf]"/>
      <xsl:variable name="fragid"
                    select="concat('f=',ancestor::xlf:file/@id,'/u=',ancestor::xlf:unit/@id)"/>

		    <!--REPORT -->
      <xsl:if test="name()='pc' and (@dataRefStart or @dataRefEnd)">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="name()='pc' and (@dataRefStart or @dataRefEnd)">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>
                'pc' cannot use 'copyOf' attribute while referring to the original data through 'dataRefStart/dataRefEnd' attributes.
            </svrl:text> 
            <svrl:diagnostic-reference diagnostic="fragid-report">
#<xsl:text/>
               <xsl:value-of select="$fragid"/>
               <xsl:text/>
            </svrl:diagnostic-reference>
         </svrl:successful-report>
      </xsl:if>

		    <!--REPORT -->
      <xsl:if test="name()!='pc' and @dataRef">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="name()!='pc' and @dataRef">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>
                '<xsl:text/>
               <xsl:value-of select="name(.)"/>
               <xsl:text/>' cannot use 'copyOf' attribute while referring to the original data through 'dataRef' attribute.
            </svrl:text> 
            <svrl:diagnostic-reference diagnostic="fragid-report">
#<xsl:text/>
               <xsl:value-of select="$fragid"/>
               <xsl:text/>
            </svrl:diagnostic-reference>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M23"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M23"/>
   <xsl:template match="@*|node()" priority="-2" mode="M23">
      <xsl:apply-templates select="*" mode="M23"/>
   </xsl:template>

   <!--PATTERN F10When the attribute canReorder is set to no or firstNo, the attributes canCopy and canDelete must also be set to no-->
   <svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">When the attribute canReorder is set to no or firstNo, the attributes canCopy and canDelete must also be set to no</svrl:text>

	  <!--RULE -->
   <xsl:template match="xlf:*[@canReorder='no'] | xlf:*[@canReorder='firstNo']"
                 priority="1000"
                 mode="M24">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="xlf:*[@canReorder='no'] | xlf:*[@canReorder='firstNo']"/>
      <xsl:variable name="fragid"
                    select="concat('f=',ancestor::xlf:file/@id,'/u=',ancestor::xlf:unit/@id)"/>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="@canDelete='no' and @canCopy='no'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="@canDelete='no' and @canCopy='no'">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                '<xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/>' element has set its 'canReorder' attribute is set to '<xsl:text/>
                  <xsl:value-of select="@canReorder"/>
                  <xsl:text/>', but 'canDelete' and 
                'canCopy' attributes are not set to 'no'.
            </svrl:text> 
               <svrl:diagnostic-reference diagnostic="fragid-report">
#<xsl:text/>
                  <xsl:value-of select="$fragid"/>
                  <xsl:text/>
               </svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M24"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M24"/>
   <xsl:template match="@*|node()" priority="-2" mode="M24">
      <xsl:apply-templates select="*" mode="M24"/>
   </xsl:template>

   <!--PATTERN F11STranslate Annotation-->
   <svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Translate Annotation</svrl:text>

	  <!--RULE -->
   <xsl:template match="xlf:sm[@type='generic'][ancestor::xlf:source] | xlf:sm[not(@type)][ancestor::xlf:source] |             xlf:mrk[@type='generic'][ancestor::xlf:source] | xlf:mrk[not(@type)][ancestor::xlf:source]"
                 priority="1000"
                 mode="M25">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="xlf:sm[@type='generic'][ancestor::xlf:source] | xlf:sm[not(@type)][ancestor::xlf:source] |             xlf:mrk[@type='generic'][ancestor::xlf:source] | xlf:mrk[not(@type)][ancestor::xlf:source]"/>
      <xsl:variable name="fragid"
                    select="concat('f=',ancestor::xlf:file/@id,'/u=',ancestor::xlf:unit/@id,'/',current()/@id)"/>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="@translate"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@translate">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                '<xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/>' element is being used for translate annotaition, but missing the 'translate' attribute.
            </svrl:text> 
               <svrl:diagnostic-reference diagnostic="fragid-report">
#<xsl:text/>
                  <xsl:value-of select="$fragid"/>
                  <xsl:text/>
               </svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M25"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M25"/>
   <xsl:template match="@*|node()" priority="-2" mode="M25">
      <xsl:apply-templates select="*" mode="M25"/>
   </xsl:template>

   <!--PATTERN F11TTranslate Annotation-->
   <svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Translate Annotation</svrl:text>

	  <!--RULE -->
   <xsl:template match="xlf:sm[@type='generic'][ancestor::xlf:target]|xlf:sm[not(@type)][ancestor::xlf:target]|             xlf:mrk[@type='generic'][ancestor::xlf:target] | xlf:mrk[not(@type)][ancestor::xlf:target]"
                 priority="1000"
                 mode="M26">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="xlf:sm[@type='generic'][ancestor::xlf:target]|xlf:sm[not(@type)][ancestor::xlf:target]|             xlf:mrk[@type='generic'][ancestor::xlf:target] | xlf:mrk[not(@type)][ancestor::xlf:target]"/>
      <xsl:variable name="fragid"
                    select="concat('f=',ancestor::xlf:file/@id,'/u=',ancestor::xlf:unit/@id,'/t=',current()/@id)"/>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="@translate"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@translate">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                '<xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/>' element is being used for translate annotaition, but missing the 'translate' attribute.
            </svrl:text> 
               <svrl:diagnostic-reference diagnostic="fragid-report">
#<xsl:text/>
                  <xsl:value-of select="$fragid"/>
                  <xsl:text/>
               </svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M26"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M26"/>
   <xsl:template match="@*|node()" priority="-2" mode="M26">
      <xsl:apply-templates select="*" mode="M26"/>
   </xsl:template>

   <!--PATTERN F12SComment Annotation-->
   <svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Comment Annotation</svrl:text>

	  <!--RULE -->
   <xsl:template match="xlf:sm[@type='comment'][ancestor::xlf:source]|xlf:mrk[@type='comment'][ancestor::xlf:source]"
                 priority="1000"
                 mode="M27">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="xlf:sm[@type='comment'][ancestor::xlf:source]|xlf:mrk[@type='comment'][ancestor::xlf:source]"/>
      <xsl:variable name="fragid"
                    select="concat('f', ancestor::xlf:file/@id,'/u=',ancestor::xlf:unit/@id,'/',current()/@id)"/>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="(@value and not(@ref))or(@ref and not(@value))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="(@value and not(@ref))or(@ref and not(@value))">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                '<xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/>' element cannot contain both 'value' and 'ref' attributes simultaneously when used for comment annotation.
            </svrl:text> 
               <svrl:diagnostic-reference diagnostic="fragid-report">
#<xsl:text/>
                  <xsl:value-of select="$fragid"/>
                  <xsl:text/>
               </svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M27"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M27"/>
   <xsl:template match="@*|node()" priority="-2" mode="M27">
      <xsl:apply-templates select="*" mode="M27"/>
   </xsl:template>

   <!--PATTERN F12TComment Annotation-->
   <svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Comment Annotation</svrl:text>

	  <!--RULE -->
   <xsl:template match="xlf:sm[@type='comment'][ancestor::xlf:target]|xlf:mrk[@type='comment'][ancestor::xlf:target]"
                 priority="1000"
                 mode="M28">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="xlf:sm[@type='comment'][ancestor::xlf:target]|xlf:mrk[@type='comment'][ancestor::xlf:target]"/>
      <xsl:variable name="fragid"
                    select="concat('f=',ancestor::xlf:file/@id,'/u=',ancestor::xlf:unit/@id,'/t=',current()/@id)"/>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="(@value and not(@ref))or(@ref and not(@value))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="(@value and not(@ref))or(@ref and not(@value))">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                '<xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/>' element cannot contain both 'value' and 'ref' attributes simultaneously when used for comment annotation.
            </svrl:text> 
               <svrl:diagnostic-reference diagnostic="fragid-report">
#<xsl:text/>
                  <xsl:value-of select="$fragid"/>
                  <xsl:text/>
               </svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M28"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M28"/>
   <xsl:template match="@*|node()" priority="-2" mode="M28">
      <xsl:apply-templates select="*" mode="M28"/>
   </xsl:template>

   <!--PATTERN F13Sref attribute in Comment Annotation-->
   <svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">ref attribute in Comment Annotation</svrl:text>

	  <!--RULE -->
   <xsl:template match="xlf:sm[@type='comment'][@ref][ancestor::xlf:source]|xlf:mrk[@type='comment'][@ref][ancestor::xlf:source]"
                 priority="1000"
                 mode="M29">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="xlf:sm[@type='comment'][@ref][ancestor::xlf:source]|xlf:mrk[@type='comment'][@ref][ancestor::xlf:source]"/>
      <xsl:variable name="ref" select="@ref"/>
      <xsl:variable name="fragid"
                    select="concat('f=',ancestor::xlf:file/@id,'/u=',ancestor::xlf:unit/@id,'/',current()/@id)"/>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="(not(contains($ref,'#')) and count(ancestor::xlf:unit//xlf:note[@id=$ref])=1) or                 (contains($ref,'#') and not(contains($ref,'=')) and count(ancestor::xlf:unit//xlf:note[@id=substring-after($ref,'#')]))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="(not(contains($ref,'#')) and count(ancestor::xlf:unit//xlf:note[@id=$ref])=1) or (contains($ref,'#') and not(contains($ref,'=')) and count(ancestor::xlf:unit//xlf:note[@id=substring-after($ref,'#')]))">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                'ref' attribute of '<xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/>' must point to a 'note' element within the same unit.
            </svrl:text> 
               <svrl:diagnostic-reference diagnostic="fragid-report">
#<xsl:text/>
                  <xsl:value-of select="$fragid"/>
                  <xsl:text/>
               </svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M29"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M29"/>
   <xsl:template match="@*|node()" priority="-2" mode="M29">
      <xsl:apply-templates select="*" mode="M29"/>
   </xsl:template>

   <!--PATTERN FD13Tref attribute in Comment Annotation-->
   <svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">ref attribute in Comment Annotation</svrl:text>

	  <!--RULE -->
   <xsl:template match="xlf:sm[@type='comment'][@ref][ancestor::xlf:target]|xlf:mrk[@type='comment'][@ref][ancestor::xlf:target]"
                 priority="1000"
                 mode="M30">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="xlf:sm[@type='comment'][@ref][ancestor::xlf:target]|xlf:mrk[@type='comment'][@ref][ancestor::xlf:target]"/>
      <xsl:variable name="ref" select="@ref"/>
      <xsl:variable name="fragid"
                    select="concat('f=',ancestor::xlf:file/@id,'/u=',ancestor::xlf:unit/@id,'/t=',current()/@id)"/>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="(not(contains($ref,'#')) and count(ancestor::xlf:unit//xlf:note[@id=$ref])=1) or                 (contains($ref,'#') and not(contains($ref,'=')) and count(ancestor::xlf:unit//xlf:note[@id=substring-after($ref,'#')]))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="(not(contains($ref,'#')) and count(ancestor::xlf:unit//xlf:note[@id=$ref])=1) or (contains($ref,'#') and not(contains($ref,'=')) and count(ancestor::xlf:unit//xlf:note[@id=substring-after($ref,'#')]))">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                'ref' attribute of '<xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/>' must point to a 'note' element within the same unit.
            </svrl:text> 
               <svrl:diagnostic-reference diagnostic="fragid-report">
#<xsl:text/>
                  <xsl:value-of select="$fragid"/>
                  <xsl:text/>
               </svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M30"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M30"/>
   <xsl:template match="@*|node()" priority="-2" mode="M30">
      <xsl:apply-templates select="*" mode="M30"/>
   </xsl:template>

   <!--PATTERN F14The 'copyOf' attribute must point to a code within the same 'unit'-->
   <svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">The 'copyOf' attribute must point to a code within the same 'unit'</svrl:text>

	  <!--RULE -->
   <xsl:template match="xlf:*[@copyOf]" priority="1000" mode="M31">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="xlf:*[@copyOf]"/>
      <xsl:variable name="fragid"
                    select="concat(ancestor::xlf:file/@id,'/u=',ancestor::xlf:unit/@id)"/>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="ancestor::xlf:unit//xlf:*[ancestor::xlf:source|ancestor::xlf:target][@id=current()/@copyOf]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="ancestor::xlf:unit//xlf:*[ancestor::xlf:source|ancestor::xlf:target][@id=current()/@copyOf]">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                No inline element with 'id=<xsl:text/>
                  <xsl:value-of select="current()/@copyOf"/>
                  <xsl:text/>' found within the same 'unit'.
            </svrl:text> 
               <svrl:diagnostic-reference diagnostic="fragid-report">
#<xsl:text/>
                  <xsl:value-of select="$fragid"/>
                  <xsl:text/>
               </svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M31"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M31"/>
   <xsl:template match="@*|node()" priority="-2" mode="M31">
      <xsl:apply-templates select="*" mode="M31"/>
   </xsl:template>

   <!--PATTERN F15dataRef attribute must point to a data element within the same unit-->
   <svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">dataRef attribute must point to a data element within the same unit</svrl:text>

	  <!--RULE -->
   <xsl:template match="xlf:*[@dataRef][ancestor::xlf:source]"
                 priority="1000"
                 mode="M32">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="xlf:*[@dataRef][ancestor::xlf:source]"/>
      <xsl:variable name="fragid"
                    select="concat('f=', ancestor::xlf:file/@id,'/u=',ancestor::xlf:unit/@id)"/>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="ancestor::xlf:unit//xlf:data[@id=current()/@dataRef]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="ancestor::xlf:unit//xlf:data[@id=current()/@dataRef]">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                'dataRef' attribute must point to a 'data' element within the same 'unit'.
            </svrl:text> 
               <svrl:diagnostic-reference diagnostic="fragid-report">
#<xsl:text/>
                  <xsl:value-of select="$fragid"/>
                  <xsl:text/>
               </svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M32"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M32"/>
   <xsl:template match="@*|node()" priority="-2" mode="M32">
      <xsl:apply-templates select="*" mode="M32"/>
   </xsl:template>

   <!--PATTERN F16SdataRefEnd attribute must point to a data element within the same unit-->
   <svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">dataRefEnd attribute must point to a data element within the same unit</svrl:text>

	  <!--RULE -->
   <xsl:template match="xlf:pc[@dataRefEnd][ancestor::xlf:source]"
                 priority="1000"
                 mode="M33">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="xlf:pc[@dataRefEnd][ancestor::xlf:source]"/>
      <xsl:variable name="fragid"
                    select="concat('f=', ancestor::xlf:file/@id,'/u=',ancestor::xlf:unit/@id,'/',current()/@id)"/>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="ancestor::xlf:unit//xlf:data[@id=current()/@dataRefEnd]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="ancestor::xlf:unit//xlf:data[@id=current()/@dataRefEnd]">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                'dataRefEnd' attribute must point to a 'data' element within the same 'unit'.
            </svrl:text> 
               <svrl:diagnostic-reference diagnostic="fragid-report">
#<xsl:text/>
                  <xsl:value-of select="$fragid"/>
                  <xsl:text/>
               </svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M33"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M33"/>
   <xsl:template match="@*|node()" priority="-2" mode="M33">
      <xsl:apply-templates select="*" mode="M33"/>
   </xsl:template>

   <!--PATTERN F16TdataRefEnd attribute must point to a data element within the same unit-->
   <svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">dataRefEnd attribute must point to a data element within the same unit</svrl:text>

	  <!--RULE -->
   <xsl:template match="xlf:pc[@dataRefEnd][ancestor::xlf:target]"
                 priority="1000"
                 mode="M34">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="xlf:pc[@dataRefEnd][ancestor::xlf:target]"/>
      <xsl:variable name="fragid"
                    select="concat('f=',ancestor::xlf:file/@id,'/u=',ancestor::xlf:unit/@id,'/t=',current()/@id)"/>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="ancestor::xlf:unit//xlf:data[@id=current()/@dataRefEnd]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="ancestor::xlf:unit//xlf:data[@id=current()/@dataRefEnd]">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                'dataRefEnd' attribute must point to a 'data' element within the same 'unit'.
            </svrl:text> 
               <svrl:diagnostic-reference diagnostic="fragid-report">
#<xsl:text/>
                  <xsl:value-of select="$fragid"/>
                  <xsl:text/>
               </svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M34"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M34"/>
   <xsl:template match="@*|node()" priority="-2" mode="M34">
      <xsl:apply-templates select="*" mode="M34"/>
   </xsl:template>

   <!--PATTERN F17SdataRefStart attribute must point to a data element within the same unit-->
   <svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">dataRefStart attribute must point to a data element within the same unit</svrl:text>

	  <!--RULE -->
   <xsl:template match="xlf:pc[@dataRefStart][ancestor::xlf:source]"
                 priority="1000"
                 mode="M35">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="xlf:pc[@dataRefStart][ancestor::xlf:source]"/>
      <xsl:variable name="fragid"
                    select="concat('f=',ancestor::xlf:file/@id,'/u=',ancestor::xlf:unit/@id,'/',current()/@id)"/>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="ancestor::xlf:unit//xlf:data[@id=current()/@dataRefStart]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="ancestor::xlf:unit//xlf:data[@id=current()/@dataRefStart]">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                'dataRefStart' attribute must point to a 'data' element within the same 'unit'.
            </svrl:text> 
               <svrl:diagnostic-reference diagnostic="fragid-report">
#<xsl:text/>
                  <xsl:value-of select="$fragid"/>
                  <xsl:text/>
               </svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M35"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M35"/>
   <xsl:template match="@*|node()" priority="-2" mode="M35">
      <xsl:apply-templates select="*" mode="M35"/>
   </xsl:template>

   <!--PATTERN F17TdataRefStart attribute must point to a data element within the same unit-->
   <svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">dataRefStart attribute must point to a data element within the same unit</svrl:text>

	  <!--RULE -->
   <xsl:template match="xlf:*[@dataRefStart][ancestor::xlf:target]"
                 priority="1000"
                 mode="M36">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="xlf:*[@dataRefStart][ancestor::xlf:target]"/>
      <xsl:variable name="fragid"
                    select="concat('f=',ancestor::xlf:file/@id,'/u=',ancestor::xlf:unit/@id,'/t=',current()/@id)"/>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="ancestor::xlf:unit//xlf:data[@id=current()/@dataRefStart]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="ancestor::xlf:unit//xlf:data[@id=current()/@dataRefStart]">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                'dataRefStart' attribute must point to a 'data' element within the same 'unit'.
            </svrl:text> 
               <svrl:diagnostic-reference diagnostic="fragid-report">
#<xsl:text/>
                  <xsl:value-of select="$fragid"/>
                  <xsl:text/>
               </svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M36"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M36"/>
   <xsl:template match="@*|node()" priority="-2" mode="M36">
      <xsl:apply-templates select="*" mode="M36"/>
   </xsl:template>

   <!--PATTERN F18Its value [order attribute] is an integer from 1 to N, where N is the sum of the numbers of the <segment> 
            and <ignorable> elements within the given enclosing <unit> element-->
   <svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Its value [order attribute] is an integer from 1 to N, where N is the sum of the numbers of the &lt;segment&gt; 
            and &lt;ignorable&gt; elements within the given enclosing &lt;unit&gt; element</svrl:text>

	  <!--RULE -->
   <xsl:template match="xlf:unit" priority="1000" mode="M37">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="xlf:unit"/>
      <xsl:variable name="maxOrder" select="count(xlf:segment|xlf:ignorable)"/>
      <xsl:variable name="fragid"
                    select="concat('f=',ancestor::xlf:file/@id,'/u=',current()/@id)"/>

		    <!--REPORT -->
      <xsl:if test=".//xlf:target[@order&gt;$maxOrder][ancestor::xlf:segment|ancestor::xlf:ignorable]">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test=".//xlf:target[@order&gt;$maxOrder][ancestor::xlf:segment|ancestor::xlf:ignorable]">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>
                Invalid value used for order attribute of &lt;target&gt; element(s). It must be an integer from 1 to <xsl:text/>
               <xsl:value-of select="$maxOrder"/>
               <xsl:text/>.
            </svrl:text> 
            <svrl:diagnostic-reference diagnostic="fragid-report">
#<xsl:text/>
               <xsl:value-of select="$fragid"/>
               <xsl:text/>
            </svrl:diagnostic-reference>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M37"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M37"/>
   <xsl:template match="@*|node()" priority="-2" mode="M37">
      <xsl:apply-templates select="*" mode="M37"/>
   </xsl:template>

   <!--PATTERN F19To be able to map order differences, the <target> element has an optional order attribute that indicates its position in the sequence of segments (and inter-segments). Its value is an
            integer from 1 to N, where N is the sum of the numbers of the <segment> and <ignorable> elements within the given enclosing <unit> element.
            When Writers set explicit order on<target> elements, they have to check for conflicts with implicit order, as <target> elements without explicit
            order correspond to their sibling <source> elements-->
   <svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">To be able to map order differences, the &lt;target&gt; element has an optional order attribute that indicates its position in the sequence of segments (and inter-segments). Its value is an
            integer from 1 to N, where N is the sum of the numbers of the &lt;segment&gt; and &lt;ignorable&gt; elements within the given enclosing &lt;unit&gt; element.
            When Writers set explicit order on&lt;target&gt; elements, they have to check for conflicts with implicit order, as &lt;target&gt; elements without explicit
            order correspond to their sibling &lt;source&gt; elements</svrl:text>

	  <!--RULE -->
   <xsl:template match="xlf:target[@order]" priority="1000" mode="M38">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="xlf:target[@order]"/>
      <xsl:variable name="order" select="@order"/>
      <xsl:variable name="actual-pos"
                    select="count(../preceding-sibling::xlf:segment| ../preceding-sibling::xlf:ignorable)+1"/>
      <xsl:variable name="fragid"
                    select="concat('f=',ancestor::xlf:file/@id,'/u=',current()/@id)"/>

		    <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="ancestor::xlf:unit//xlf:target[@order=$actual-pos][ancestor::xlf:segment | ancestor::xlf:ignorable]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="ancestor::xlf:unit//xlf:target[@order=$actual-pos][ancestor::xlf:segment | ancestor::xlf:ignorable]">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> 
                The corresponding 'target' element, 'order' attribute of which must be '<xsl:text/>
                  <xsl:value-of select="$actual-pos"/>
                  <xsl:text/>', is missing within the enclosing 'unit'.
            </svrl:text> 
               <svrl:diagnostic-reference diagnostic="fragid-report">
#<xsl:text/>
                  <xsl:value-of select="$fragid"/>
                  <xsl:text/>
               </svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M38"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M38"/>
   <xsl:template match="@*|node()" priority="-2" mode="M38">
      <xsl:apply-templates select="*" mode="M38"/>
   </xsl:template>

   <!--PATTERN F20Modifiers must not delete inline codes that have their attribute canDelete set to no-->
   <svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Modifiers must not delete inline codes that have their attribute canDelete set to no</svrl:text>

	  <!--RULE -->
   <xsl:template match="xlf:source//xlf:*[@canDelete='no']"
                 priority="1000"
                 mode="M39">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="xlf:source//xlf:*[@canDelete='no']"/>
      <xsl:variable name="id" select="current()/@id"/>
      <xsl:variable name="fragid"
                    select="concat('f=', ancestor::xlf:file/@id,'/u=', ancestor::xlf:unit/@id,'/', $id)"/>

		    <!--REPORT -->
      <xsl:if test="not(ancestor::xlf:segment/xlf:target//xlf:*[@id=$id])">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="not(ancestor::xlf:segment/xlf:target//xlf:*[@id=$id])">
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>
                'canDelete' attribute is set to 'no', but the corresponding element is missing in the sibling target.
            </svrl:text> 
            <svrl:diagnostic-reference diagnostic="fragid-report">
#<xsl:text/>
               <xsl:value-of select="$fragid"/>
               <xsl:text/>
            </svrl:diagnostic-reference>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M39"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M39"/>
   <xsl:template match="@*|node()" priority="-2" mode="M39">
      <xsl:apply-templates select="*" mode="M39"/>
   </xsl:template>
</xsl:stylesheet>

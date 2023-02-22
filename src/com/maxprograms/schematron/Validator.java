/*******************************************************************************
 * Copyright (c) 2021-2023 Maxprograms.
 *
 * This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License 1.0
 * which accompanies this distribution, and is available at
 * https://www.eclipse.org/org/documents/epl-v10.html
 *
 * Contributors:
 *     Maxprograms - initial API and implementation
 *******************************************************************************/

 package com.maxprograms.schematron;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.util.Iterator;
import java.util.List;

import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.Source;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;

import org.xml.sax.SAXException;

import com.maxprograms.xml.Document;
import com.maxprograms.xml.Element;
import com.maxprograms.xml.SAXBuilder;

public class Validator {

	private String reason;

	public String getReason() {
		return reason;
	}

	public boolean validate(String file, String stylesheet) {
		reason = "";
		try {
			File result = File.createTempFile("result", ".xml");
			transform(stylesheet, file, result.getAbsolutePath());
			SAXBuilder builder = new SAXBuilder();
			Document doc = builder.build(result);
			boolean valid = recurse(doc.getRootElement());
			Files.delete(result.toPath());
			return valid;
		} catch (IOException | TransformerException | SAXException | ParserConfigurationException e) {
			reason = e.getMessage();
			return false;
		}
	}

	private boolean recurse(Element e) {
		if ("svrl:successful-report".equals(e.getName())) {
			reason = e.getChild("svrl:text").getTextNormalize();
			return false;
		}
		List<Element> children = e.getChildren();
		Iterator<Element> it = children.iterator();
		while (it.hasNext()) {
			if (!recurse(it.next())) {
				return false;
			}
		}
		return true;
	}

	public static void transform(String stylesheet, String input, String output) throws TransformerException {
		TransformerFactory factory = TransformerFactory.newInstance();
		Source xslt = new StreamSource(new File(stylesheet));
		Transformer transformer = factory.newTransformer(xslt);
		Source text = new StreamSource(new File(input));
		transformer.transform(text, new StreamResult(new File(output)));
	}

	public static void createStylesheet(String schematron, String stylesheet) throws TransformerException, IOException {
		File stage1 = File.createTempFile("stage", ".xsl");
		transform("iso/iso_dsdl_include.xsl", schematron, stage1.getAbsolutePath());
		File stage2 = File.createTempFile("stage", ".xsl");
		transform("iso/iso_abstract_expand.xsl", stage1.getAbsolutePath(), stage2.getAbsolutePath());
		Files.delete(stage1.toPath());
		transform("iso/iso_svrl_for_xslt2.xsl", stage2.getAbsolutePath(), stylesheet);
		Files.delete(stage2.toPath());
	}
}

/*******************************************************************************
 * Copyright (c) 2021-2024 Maxprograms.
 *
 * This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License 1.0
 * which accompanies this distribution, and is available at
 * https://www.eclipse.org/org/documents/epl-v10.html
 *
 * Contributors:
 *     Maxprograms - initial API and implementation
 *******************************************************************************/

package com.maxprograms.xliffvalidation.rest;

import java.io.File;
import java.io.IOException;
import java.lang.System.Logger;
import java.lang.System.Logger.Level;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.util.Iterator;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.FileItemFactory;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.ServletFileUpload;
import org.json.JSONObject;

import com.maxprograms.validation.XliffChecker;
import com.maxprograms.xliffvalidation.Constants;

public class UploadServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static Logger logger = System.getLogger(UploadServlet.class.getName());

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json");
        JSONObject result = new JSONObject();
        StringBuffer from = request.getRequestURL();
        if (!from.toString().toLowerCase().startsWith("https://")) {
            result.put(Constants.STATUS, Constants.ERROR);
            result.put(Constants.REASON, "https protocol required");
            writeOutput(result, response, 401);
            return;
        }
        try {
            JSONObject uploadItem = getFileItem(request);
            File homeDir = new File(System.getenv("XLIFF_HOME"));
            File catalogFolder = new File(homeDir, "catalog");
            File catalog = new File(catalogFolder, "catalog.xml");
            XliffChecker instance = new XliffChecker();
            String file = uploadItem.getString("location");
            File uploaded = new File(file);
            result.put("xliff", uploaded.getName());
            if (instance.validate(file, catalog.getAbsolutePath())) {
                result.put(Constants.STATUS, Constants.OK);
                result.put("version", instance.getVersion());
            } else {
                result.put(Constants.STATUS, Constants.ERROR);
                result.put(Constants.REASON, instance.getReason());
            }
            writeOutput(result, response, 200);

            File sessionDir = new File(file).getParentFile();
            removeDir(sessionDir);

        } catch (Exception e) {
            logger.log(Level.ERROR, "Validation error", e);
            result.put(Constants.STATUS, Constants.ERROR);
            result.put(Constants.REASON, e.getMessage());
            writeOutput(result, response, 500);
        }
    }

    private static void writeOutput(JSONObject json, HttpServletResponse response, int status) throws IOException {
        byte[] bytes = json.toString().getBytes(StandardCharsets.UTF_8);
        response.setContentLength(bytes.length);
        response.setStatus(status);
        try (ServletOutputStream output = response.getOutputStream()) {
            output.write(bytes);
        }
    }

    private static JSONObject getFileItem(HttpServletRequest request) throws Exception {
        JSONObject result = new JSONObject();
        FileItemFactory factory = new DiskFileItemFactory();
        ServletFileUpload upload = new ServletFileUpload(factory);

        String session = request.getHeader("session");

        List<FileItem> items = upload.parseRequest(request);
        Iterator<FileItem> it = items.iterator();
        File homeDir = new File(System.getenv("XLIFF_HOME"));
        if (!homeDir.exists()) {
            Files.createDirectories(homeDir.toPath());
        }
        File sessionDir = new File(homeDir, session);
        if (!sessionDir.exists()) {
            Files.createDirectories(sessionDir.toPath());
        }
        while (it.hasNext()) {
            FileItem item = it.next();
            if (!item.isFormField()) {
                String fileName = item.getName();
                if (fileName.indexOf('\\') != -1) {
                    fileName = fileName.substring(1 + fileName.lastIndexOf('\\'));
                }
                File tmp = new File(sessionDir, fileName);
                if (tmp.exists()) {
                    Files.delete(tmp.toPath());
                }
                item.write(tmp);
                result.put("session", session);
                result.put("name", fileName);
                result.put("location", tmp.getAbsolutePath());
            }
        }
        return result;
    }

    private static void removeDir(File dir) {
        if (dir.isFile()) {
            dir.delete();
            return;
        }
        File[] files = dir.listFiles();
        for (int i = 0; i < files.length; i++) {
            removeDir(files[i]);
        }
        dir.delete();
    }
}

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

package com.maxprograms.xliffvalidation.rest;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.UUID;

import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.maxprograms.xliffvalidation.Constants;

import org.json.JSONObject;

public class VersionServlet extends HttpServlet {

    private static final long serialVersionUID = 6179989578325854817L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json");

        StringBuffer from = request.getRequestURL();
        if (!from.toString().toLowerCase().startsWith("https://")) {
            response.setStatus(401);
            JSONObject result = new JSONObject();
            result.put(Constants.STATUS, Constants.ERROR);
            result.put(Constants.REASON, "https protocol required");
            byte[] bytes = result.toString().getBytes(StandardCharsets.UTF_8);
            response.setContentLength(bytes.length);
            try (ServletOutputStream output = response.getOutputStream()) {
                output.write(bytes);
            }
            return;
        }

        response.setStatus(200);
        JSONObject result = new JSONObject();
        result.put(Constants.STATUS, Constants.OK);
        result.put("version", Constants.VERSION + "_" + Constants.BUILD);
        result.put("session", UUID.randomUUID().toString());
        byte[] bytes = result.toString().getBytes(StandardCharsets.UTF_8);
        response.setContentLength(bytes.length);
        try (ServletOutputStream output = response.getOutputStream()) {
            output.write(bytes);
        }
    }
}
/*******************************************************************************
 * Copyright (c) 2021 Maxprograms.
 *
 * This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License 1.0
 * which accompanies this distribution, and is available at
 * https://www.eclipse.org/org/documents/epl-v10.html
 *
 * Contributors:
 *     Maxprograms - initial API and implementation
 *******************************************************************************/

package com.maxprograms.xliffvalidation.utils;

import java.io.IOException;
import java.lang.System.Logger;
import java.lang.System.Logger.Level;
import java.nio.charset.StandardCharsets;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletResponse;

import com.maxprograms.xliffvalidation.Constants;

public class SecurityFilter implements Filter {

	private static Logger logger = System.getLogger(SecurityFilter.class.getName());
	
	@Override
	public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
		HttpServletResponse res = (HttpServletResponse) response;
		
		res.addHeader("X-FRAME-OPTIONS", "sameorigin");
		res.addHeader("X-XSS-Protection", "1; mode=block");
		res.addHeader("X-Content-Type-Options", "nosniff");
		res.addHeader("Cache-Control", "no-cache, no-store, must-revalidate");
		res.addHeader("Pragma", "no-cache");
		res.addHeader("Expires", "-1");
		res.addHeader("Strict-Transport-Security", "max-age=31536000; includeSubDomains");
		res.addHeader("X-Permitted-Cross-Domain-Policies", "master-only");
		res.addHeader("Content-Security-Policy", "report-uri https://dev.maxprograms.com");
		res.addHeader("Referrer-Policy", "no-referrer-when-downgrade");
		res.addHeader("Feature-Policy", "microphone 'none'; camera 'none'");

		res.setCharacterEncoding(StandardCharsets.UTF_8.name());
		res.setContentType("text/html;charset=utf-8");
		try {
			chain.doFilter(request, response);
		} catch (IOException e) {
			logger.log(Level.ERROR, Constants.ERROR, e);
		}
	}

	@Override
	public void destroy() {
		// do nothing
	}

	@Override
	public void init(FilterConfig filterConfig) {		
		// do nothing
	}
}
/*
 * Java Payloads.
 * 
 * Copyright (c) 2010, Michael 'mihi' Schierl
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 
 * - Redistributions of source code must retain the above copyright notice,
 *   this list of conditions and the following disclaimer.
 *   
 * - Redistributions in binary form must reproduce the above copyright
 *   notice, this list of conditions and the following disclaimer in the
 *   documentation and/or other materials provided with the distribution.
 *   
 * - Neither name of the copyright holders nor the names of its
 *   contributors may be used to endorse or promote products derived from
 *   this software without specific prior written permission.
 *   
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND THE CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * HOLDERS OR THE CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS
 * OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
 * TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
 * USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

package javapayload.builder;

import java.io.FileOutputStream;
import java.io.InputStream;
import java.util.jar.JarOutputStream;
import java.util.jar.Manifest;
import java.util.zip.ZipEntry;

public class JarBuilder {
	protected static void buildJar(String filename, Class[] classes, Manifest manifest, byte[] extraResource) throws Exception {
		manifest.getMainAttributes().putValue("Manifest-Version", "1.0");
		final JarOutputStream jos = new JarOutputStream(new FileOutputStream(filename), manifest);
		final byte[] buf = new byte[4096];
		int len;
		for (int i = 0; i < classes.length; i++) {
			final String classname = classes[i].getName().replace('.', '/') + ".class";
			jos.putNextEntry(new ZipEntry(classname));
			final InputStream in = JarBuilder.class.getResourceAsStream("/" + classname);
			while ((len = in.read(buf)) != -1) {
				jos.write(buf, 0, len);
			}
			in.close();
		}
		if (extraResource != null) {
			jos.putNextEntry(new ZipEntry("x"));
			jos.write(extraResource, 0, extraResource.length);
		}
		jos.close();
	}

	public static void main(String[] args) throws Exception {
		if (args.length == 0) {
			System.out.println("Usage: java javapayload.builder.JarBuilder <stager> [<moreStagers...>]");
			return;
		}
		StringBuffer jarName = new StringBuffer(); 
		final Class[] classes = new Class[args.length+2];
		classes[0] = javapayload.loader.StandaloneLoader.class;
		classes[1] = javapayload.stager.Stager.class;
		for (int i = 0; i < args.length; i++) {
			if (i > 0)
				jarName.append('_');
			jarName.append(args[i]);
			classes[i+2] = Class.forName("javapayload.stager." + args[i]);
		}
		final Manifest manifest = new Manifest();
		manifest.getMainAttributes().putValue("Main-Class", "javapayload.loader.StandaloneLoader");
		buildJar(jarName.append(".jar").toString(), classes, manifest, null);
	}
}

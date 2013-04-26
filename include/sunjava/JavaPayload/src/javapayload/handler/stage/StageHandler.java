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

package javapayload.handler.stage;

import java.io.ByteArrayOutputStream;
import java.io.DataOutputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.PrintStream;

import javapayload.stage.StreamForwarder;

public abstract class StageHandler {
	
	// overwrite them if you want to redirect the stream elsewhere
	public InputStream consoleIn = System.in;
	public PrintStream consoleOut = System.out;
	public PrintStream consoleErr = System.err;

	protected void customUpload(DataOutputStream out, String[] parameters) throws Exception {
	}

	public abstract Class[] getNeededClasses();

	public final void handle(OutputStream rawOut, InputStream in, String[] parameters) throws Exception {
		final Class[] classes = getNeededClasses();
		final DataOutputStream out = new DataOutputStream(rawOut);
		for (int i = 0; i < classes.length; i++) {
			final InputStream classStream = StageHandler.class.getResourceAsStream("/" + classes[i].getName().replace('.', '/') + ".class");
			final ByteArrayOutputStream baos = new ByteArrayOutputStream();
			StreamForwarder.forward(classStream, baos);
			final byte[] clazz = baos.toByteArray();
			out.writeInt(clazz.length);
			out.write(clazz);
		}
		out.writeInt(0);
		out.flush();
		handleStreams(out, in, parameters);
	}
	
	protected void handleStreams(DataOutputStream out, InputStream in, String[] parameters) throws Exception {
		customUpload(out, parameters);
		final StreamForwarder sf = new StreamForwarder(consoleIn, out, consoleErr);
		sf.setDaemon(true);
		sf.start();
		StreamForwarder.forward(in, consoleOut);
	}


	public final StageHandler createClone(PrintStream newConsole) {
		StageHandler result = createClone();
		result.consoleIn = consoleIn;
		result.consoleOut = newConsole;
		result.consoleErr = newConsole;
		return result;
	}
	
	// require explicit implementation to make sure they can really be cloned,
	// no implicit Cloneable!
	protected abstract StageHandler createClone();
}
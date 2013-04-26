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
package javapayload.handler.stager;

import java.io.InputStream;
import java.io.PrintStream;

import javapayload.handler.stage.StageHandler;

public class MultiListen extends StagerHandler {

	ListeningStagerHandler realHandler = null;
	
	protected boolean prepare(String[] parametersToPrepare) throws Exception {
		String[] realParameters = new String[parametersToPrepare.length-1];
		System.arraycopy(parametersToPrepare, 1, realParameters, 0, realParameters.length);
		realHandler = (ListeningStagerHandler) Class.forName("javapayload.handler.stager." + realParameters[0]).newInstance();
		boolean result = realHandler.prepare(realParameters);
		if (result) {
			System.arraycopy(realParameters, 0, parametersToPrepare, 1, realParameters.length);
		}
		return result;
	}
	
	protected void handle(StageHandler stageHandler, String[] parameters, final PrintStream errorStream, Object extraArg) throws Exception {
		String[] realParameters = new String[parameters.length-1];
		System.arraycopy(parameters, 1, realParameters, 0, realParameters.length);
		if (realHandler == null) {
			realHandler = (ListeningStagerHandler) Class.forName("javapayload.handler.stager." + realParameters[0]).newInstance();
		}
		final InputStream waitIn = stageHandler.consoleIn;
		new Thread(new Runnable() {
			public void run() {
				try {
					while(waitIn.read() != -1)
						;
					realHandler.stopMulti();
				} catch (Exception ex) {
					ex.printStackTrace(errorStream);
				}
			}
		}).start();
		realHandler.handleMulti(stageHandler, realParameters, errorStream);
	}

	protected boolean needHandleBeforeStart() {
		return true;
	}
}

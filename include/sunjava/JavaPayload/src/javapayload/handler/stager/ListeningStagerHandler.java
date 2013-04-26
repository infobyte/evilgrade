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

import java.io.ByteArrayOutputStream;
import java.io.PrintStream;

import javapayload.handler.stage.StageHandler;

public abstract class ListeningStagerHandler extends StagerHandler {

	protected final void handle(StageHandler stageHandler, String[] parameters, PrintStream errorStream, Object extraArg) throws Exception {
		startListen(parameters);
		final Object socket = acceptSocket();
		stopListen();
		handleSocket(socket, stageHandler, parameters, errorStream);
	}

	protected final boolean needHandleBeforeStart() {
		return true;
	}
	
	private boolean multiRunning = true;
	private boolean multiListening = false;
	
	public void handleMulti(StageHandler stageHandler, final String[] parameters, final PrintStream errorStream) throws Exception {
		final PrintStream consoleOut = stageHandler.consoleOut;
		synchronized(this) {
			if (multiRunning) {
				startListen(parameters);
				multiListening = true;
				consoleOut.println("Listening started");
			}
		}
		while (multiRunning) {
			final Object socket = acceptSocket();
			final ByteArrayOutputStream baos = new ByteArrayOutputStream();
			final StageHandler realStageHandler = stageHandler.createClone(new PrintStream(baos, true));
			new Thread(new Runnable() {
				public void run() {
					try {
						handleSocket(socket, realStageHandler, parameters, errorStream);
						synchronized(ListeningStagerHandler.this) {
							consoleOut.println("=== BEGIN INSTANCE ===");
							consoleOut.write(baos.toByteArray());
							consoleOut.println();
							consoleOut.println("=== END INSTANCE ===");
						}
					} catch (Exception ex) {
						synchronized(ListeningStagerHandler.this) {
							ex.printStackTrace(consoleOut);
						}
					}
				}
			}).start();
		}
		synchronized(this) {
			if (multiListening) {
				stopListen();
				multiListening = false;
			}
			consoleOut.println("Listening stopped");
		}
	}

	public synchronized void stopMulti() throws Exception {
		multiRunning = false;
		if (multiListening) {
			stopListen();
			multiListening = false;
		}
	}
	
	protected abstract void startListen(String[] parameters) throws Exception;
	protected abstract void stopListen() throws Exception;
	protected abstract Object acceptSocket() throws Exception;
	protected abstract void handleSocket(Object socket, StageHandler stageHandler, String[] parameters, PrintStream errorStream) throws Exception;
}

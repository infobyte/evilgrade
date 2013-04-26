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

import java.io.PrintStream;

import javapayload.handler.stage.StageHandler;

public abstract class StagerHandler {
	
	public static void main(String[] args) throws Exception {
		boolean stageFound = false;
		for (int i = 0; i < args.length - 1; i++) {
			if (args[i].equals("--")) {
				stageFound = true;
			}
		}
		if (!stageFound) {
			System.out.println("Usage: java javapayload.handler.stager.StagerHandler <stager> [stageroptions] -- <stage> [stageoptions]");
			return;
		}
		new Loader(args).handle(System.err, null);
	}

	// may have side effects on the parameters!
	protected boolean prepare(String[] parametersToPrepare) throws Exception {
		return false;
	}

	protected abstract void handle(StageHandler stageHandler, String[] parameters, PrintStream errorStream, Object extraArg) throws Exception;
	protected abstract boolean needHandleBeforeStart();

	public static class Loader {
		private final String[] args;
		public final StageHandler stageHandler;
		private final StagerHandler stagerHandler;
		
		public Loader(String[] args) throws Exception {
			this.args = args;
			String stager = args[0];
			String stage = null;
			for (int i = 0; i < args.length - 1; i++) {
				if (args[i].equals("--")) {
					stage = args[i + 1];
				}
			}
			if (stage == null) {
				throw new IllegalArgumentException("No stage given");
			}
			stageHandler = (StageHandler) Class.forName("javapayload.handler.stage." + stage).newInstance();
			stagerHandler = (StagerHandler) Class.forName("javapayload.handler.stager." + stager).newInstance();
		}
		
		public void handle(PrintStream errorStream, Object extraArg) throws Exception {
			if (stagerHandler.prepare(args)) {
				errorStream.print("Stager changed parameters:");
				for (int i = 0; i < args.length; i++) {
					errorStream.print(" "+args[i]);
				}
				errorStream.println();
			}
			handleInternal(errorStream, extraArg);
		}
		
		public String[] getArgs() {
			return args;
		}
		
		private void handleInternal(PrintStream errorStream, Object extraArg) throws Exception {
			stagerHandler.handle(stageHandler, args, errorStream, extraArg);
		}
		
		public void handleBefore(final PrintStream errorStream, final Object extraArg) throws Exception {
			if (stagerHandler.needHandleBeforeStart()) {
				stagerHandler.prepare(args);
				new Thread(new Runnable() {
					public void run() {
						try {
							handleInternal(errorStream, extraArg);
						} catch (final Exception ex) {
							ex.printStackTrace();
						}
					}
				}).start();
			}
		}
		
		public void handleAfter(PrintStream errorStream, Object extraArg) throws Exception {
			if (!stagerHandler.needHandleBeforeStart())
				handleInternal(errorStream, extraArg);
		}
	}
}

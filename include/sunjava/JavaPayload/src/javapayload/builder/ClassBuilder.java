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

import java.io.FileOutputStream;
import java.io.InputStream;

import javapayload.stager.Stager;

import org.objectweb.asm.ClassAdapter;
import org.objectweb.asm.ClassReader;
import org.objectweb.asm.ClassVisitor;
import org.objectweb.asm.ClassWriter;
import org.objectweb.asm.FieldVisitor;
import org.objectweb.asm.MethodAdapter;
import org.objectweb.asm.MethodVisitor;
import org.objectweb.asm.Opcodes;

public class ClassBuilder extends Stager {

	protected static void buildClass(final String classname, final String stager, Class loaderClass, final String embeddedArgs) throws Exception {

		final ClassWriter cw = new ClassWriter(0);

		class MyMethodVisitor extends MethodAdapter {
			private final String newClassName;

			public MyMethodVisitor(MethodVisitor mv, String newClassName) {
				super(mv);
				this.newClassName = newClassName;
			}

			private String cleanType(String type) {
				if (type.startsWith("javapayload/")) {
					type = newClassName;
				}
				return type;
			}

			public void visitFieldInsn(int opcode, String owner, String name, String desc) {
				super.visitFieldInsn(opcode, cleanType(owner), name, desc);
			}

			public void visitMethodInsn(int opcode, String owner, String name, String desc) {
				super.visitMethodInsn(opcode, cleanType(owner), name, desc);
			}

			public void visitTypeInsn(int opcode, String type) {
				super.visitTypeInsn(opcode, cleanType(type));
			}
		}
		final ClassVisitor stagerVisitor = new ClassAdapter(cw) {

			public void visit(int version, int access, String name, String signature, String superName, String[] interfaces) {
				super.visit(version, access, classname, signature, "java/lang/ClassLoader", interfaces);
			}

			public void visitEnd() {
				// not the end!
			}

			public MethodVisitor visitMethod(int access, String name, String desc, String signature, String[] exceptions) {
				// strip constructors
				if (name.equals("<init>")) {
					return null;
				}
				return new MyMethodVisitor(super.visitMethod(access, name, desc, signature, exceptions), classname);
			}
		};
		visitClass(Class.forName("javapayload.stager." + stager), stagerVisitor, cw);
		final ClassVisitor stagerBaseVisitor = new ClassAdapter(cw) {

			public void visit(int version, int access, String name, String signature, String superName, String[] interfaces) {
				// not the beginning!
			}

			public void visitEnd() {
				// not the end!
			}

			public MethodVisitor visitMethod(int access, String name, String desc, String signature, String[] exceptions) {
				// strip abstract bootstrap method
				if (name.equals("bootstrap") && (access & Opcodes.ACC_ABSTRACT) != 0) {
					return null;
				}
				return new MyMethodVisitor(super.visitMethod(access, name, desc, signature, exceptions), classname);
			}
		};
		visitClass(Stager.class, stagerBaseVisitor, cw);
		final ClassVisitor loaderVisitor = new ClassAdapter(cw) {
			public void visit(int version, int access, String name, String signature, String superName, String[] interfaces) {
				// not the beginning!
			}

			public FieldVisitor visitField(int access, String name, String desc, String signature, Object value) {
				if (embeddedArgs != null && name.equals("EMBEDDED_ARGS")) {
					// create EMBEDDED_ARGS field
					return super.visitField(access, name, desc, signature, embeddedArgs);
				}
				// do not copy other fields
				return null;
			}

			public void visitInnerClass(String name, String outerName, String innerName, int access) {
				// do not copy inner classes
			}

			public MethodVisitor visitMethod(int access, String name, String desc, String signature, String[] exceptions) {
				if (name.equals("mainToEmbed")) {
					return new MyMethodVisitor(super.visitMethod(access, "main", desc, signature, exceptions), classname);
				} else {
					return null;
				}
			}

			public void visitOuterClass(String owner, String name, String desc) {
				// do not copy outer classes
			}
		};
		visitClass(loaderClass, loaderVisitor, cw);
		final byte[] newBytecode = cw.toByteArray();
		final FileOutputStream fos = new FileOutputStream(classname + ".class");
		fos.write(newBytecode);
		fos.close();
	}

	public static void main(String[] args) throws Exception {
		if (args.length != 1 && args.length != 2) {
			System.out.println("Usage: java javapayload.builder.ClassBuilder <stager> [classname]");
			return;
		}
		final String stager = args[0];
		String classname = stager + "Class";
		if (args.length == 2) {
			classname = args[1];
		}

		buildClass(classname, stager, ClassBuilder.class, null);
	}

	public static void mainToEmbed(String[] args) throws Exception {
		new ClassBuilder().bootstrap(args);
	}

	private static void visitClass(Class clazz, ClassVisitor stagerVisitor, ClassWriter cw) throws Exception {
		final InputStream is = ClassBuilder.class.getResourceAsStream("/" + clazz.getName().replace('.', '/') + ".class");
		final ClassReader cr = new ClassReader(is);
		cr.accept(stagerVisitor, ClassReader.SKIP_DEBUG);
		is.close();
	}

	public void bootstrap(String[] parameters) throws Exception {
		throw new Exception("Never used!");
	}
}

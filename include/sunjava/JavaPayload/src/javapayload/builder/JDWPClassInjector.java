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

import java.util.Arrays;

import com.sun.jdi.ArrayReference;
import com.sun.jdi.ByteValue;
import com.sun.jdi.ClassObjectReference;
import com.sun.jdi.ClassType;
import com.sun.jdi.Method;
import com.sun.jdi.ObjectReference;
import com.sun.jdi.ThreadReference;
import com.sun.jdi.Value;
import com.sun.jdi.VirtualMachine;

/**
 * Injects classes into a debugged process via JDI and optionally creates an instance of them using the default constructor.
 */
public class JDWPClassInjector {

	private final ThreadReference thread;
	private final VirtualMachine virtualMachine;
	private final ObjectReference myClassLoader;

	private final ClassType _Class; // java.lang.Class
	private final ClassType _Array; // java.lang.reflect.Array
	private final ClassType _URLClassLoader; // java.net.URLClassLoader
	private final ClassType _byte; // byte

	/**
	 * Create a new class injector.
	 * 
	 * @param tr
	 *            A suspended thread in the target thread that allows code execution and has <b>no step requests pending</b>.
	 */
	public JDWPClassInjector(ThreadReference thread) throws Exception {
		this.thread = thread;
		this.virtualMachine = thread.virtualMachine();
		// java.lang.Class is guaranteed to be loaded in any JVM,
		// so pick it from the classes cache
		this._Class = (ClassType) virtualMachine.classesByName("java.lang.Class").get(0);

		// load more types via reflection
		this._Array = loadClass("java.lang.reflect.Array");
		this._URLClassLoader = loadClass("java.net.URLClassLoader");
		final ClassType _Byte = loadClass("java.lang.Byte");
		this._byte = (ClassType) ((ClassObjectReference) _Byte.getValue(_Byte.fieldByName("TYPE"))).reflectedType();

		// get an empty URL[] and use it to create an URLClassLoader
		final ArrayReference urls = buildArray(loadClass("java.net.URL"), 0);
		myClassLoader = newInstance(_URLClassLoader, "([Ljava/net/URL;)V", new Value[] { urls });
	}

	/**
	 * Create a new array via reflection
	 * 
	 * @param baseType
	 *            base type of the array
	 * @param length
	 *            length of the array
	 */
	private ArrayReference buildArray(ClassType baseType, int length) throws Exception {
		return (ArrayReference) invokeStaticMethod(_Array, "newInstance", "(Ljava/lang/Class;I)Ljava/lang/Object;", new Value[] { baseType.classObject(), virtualMachine.mirrorOf(length) });
	}

	/**
	 * Inject a class
	 * 
	 * @param clazz
	 *            the "class file".
	 * @param argsForInstantiate
	 *            arguments to instantiate the class with, or <code>null</code> to not instantiate it
	 * @return the {@link ClassType} instance
	 */
	public ClassType inject(byte[] clazz, String argsForInstantiate) throws Exception {

		// build a byte array and fill it
		final ArrayReference array = buildArray(_byte, clazz.length);
		ByteValue[] byteValues = new ByteValue[clazz.length];
		for (int i = 0; i < clazz.length; i++) {
			byteValues[i] = virtualMachine.mirrorOf(clazz[i]);
		}
		array.setValues(Arrays.asList(byteValues));

		// load the class with the class loader
		final ObjectReference loadedClazz = (ObjectReference) invokeMethod(myClassLoader, _URLClassLoader, "defineClass", "([BII)Ljava/lang/Class;", new Value[] { array, virtualMachine.mirrorOf(0), virtualMachine.mirrorOf(clazz.length) });
		final ClassType _clazz = (ClassType) ((ClassObjectReference) loadedClazz).reflectedType();

		if (argsForInstantiate != null) {
			// prepare the class
			invokeMethod(myClassLoader, _URLClassLoader, "resolveClass", "(Ljava/lang/Class;)V", new Value[] { loadedClazz });
			invokeMethod(loadedClazz, _Class, "getMethods", "()[Ljava/lang/reflect/Method;", new Value[0]);

			// invoke its constructor
			final ObjectReference loadedInstance = newInstance(_clazz, "()V", new Value[0]);

			// invoke its go method
			invokeMethod(loadedInstance, _clazz, "go", "(Ljava/lang/String;)V", new Value[] { virtualMachine.mirrorOf(argsForInstantiate) });
		}
		
		return _clazz;
	}

	/**
	 * Invoke a method via JDI.
	 * 
	 * @param object
	 *            The object/class to invoke the method on
	 * @param _class
	 *            The class the method belongs to
	 * @param name
	 *            The name of the method
	 * @param signature
	 *            The signature of the method
	 * @param parameters
	 *            Parameters to use
	 * @return The return value
	 */
	private Value invokeMethod(ObjectReference object, ClassType _class, String name, String signature, Value[] parameters) throws Exception {
		final Method method = _class.concreteMethodByName(name, signature);
		if (method == null) {
			throw new IllegalArgumentException("Method not found: " + name + " " + signature);
		}
		return object.invokeMethod(thread, method, Arrays.asList(parameters), 0);
	}

	/**
	 * Invoke a static method via JDI.
	 * 
	 * @param _class
	 *            The class the method belongs to
	 * @param name
	 *            The name of the method
	 * @param signature
	 *            The signature of the method
	 * @param parameters
	 *            Parameters to use
	 * @return The return value
	 */
	private Value invokeStaticMethod(ClassType _class, String name, String signature, Value[] parameters) throws Exception {
		return _class.invokeMethod(thread, _class.concreteMethodByName(name, signature), Arrays.asList(parameters), 0);
	}

	/**
	 * Load a class via JDI
	 * 
	 * @param className
	 *            The class to load
	 * @return The loaded class
	 */
	private ClassType loadClass(String className) throws Exception {
		return (ClassType) ((ClassObjectReference) _Class.invokeMethod(thread, _Class.concreteMethodByName("forName", "(Ljava/lang/String;)Ljava/lang/Class;"), Arrays.asList(new Value[] { virtualMachine.mirrorOf(className) }), 0)).reflectedType();
	}

	/**
	 * Create a remote instance of a class via JDI.
	 * 
	 * @param _class
	 *            Class
	 * @param signature
	 *            Signature of the constructor
	 * @param parameters
	 *            Constructor parameters
	 * @return
	 * @return the new instance
	 */
	private ObjectReference newInstance(ClassType _class, String signature, Value[] parameters) throws Exception {
		return _class.newInstance(thread, _class.concreteMethodByName("<init>", signature), Arrays.asList(parameters), 0);
	}
}
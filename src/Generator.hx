// Copyright (c) 2013 Christopher Kaster
//
// This file is part of java-haxe-extern-generator <https://github.com/kasoki/java-haxe-extern-generator>.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
package;

import java.lang.reflect.Method;
import java.lang.Class;
import java.lang.ClassLoader;
import java.lang.System;
import java.io.FileWriter;
import java.io.File;
import java.net.URL;
import java.net.URLClassLoader;

class Generator {

	public static function main() {
		var args = Sys.args();

		if(args.length == 0) {
			trace("Please enter a valid Java class name (like: 'java.lang.String')");
			return;
		}

		var file:File = new File(args[0]);

		var url:URL = null;

		try {
			url = file.toURI().toURL();
		} catch(ex:Dynamic) {
			trace(ex);
		}

		var classIdent:String = args[1];

		var urls:java.NativeArray<URL> = new java.NativeArray<URL>(1);

		urls[0] = url;

		var classLoader:ClassLoader = new URLClassLoader(urls);

		var _class:Class<Dynamic> = null;

		try {
			_class = classLoader.loadClass(classIdent);
		} catch(ex:Dynamic) {
			trace(ex);
		}

		Generator.generate(_class);
	}

	private static function generate(_class:Class<Dynamic>) {
		var gclass = new GeneratorClass(_class);

		var path = StringTools.replace(gclass.jpackage, ".", "/");

		var file = new File("gen-externs/" + path);

		file.mkdirs();

		file = new File("gen-externs/" + path + "/" + gclass.getNameWithoutPackage() + ".hx");

		try {
			var writer = new FileWriter(file.getAbsoluteFile());

			writer.write(gclass.toString());

			writer.close();

			trace("Done. Check out your new fancy extern class: " + file.toString());
		} catch(ex:java.lang.Exception) {
			ex.printStackTrace();
		}
	}
}
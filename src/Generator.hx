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

		Generator.parse(_class);
	}

	private static function parse(_class:Class<Dynamic>) {
		var gclass = new GeneratorClass(_class);

		var file = new File(gclass.name + ".extern.hx");

		try {
			var writer = new FileWriter(file.getAbsoluteFile());

			writer.write(gclass.toString());

			writer.close();

			trace("Done. Check out your new fancy extern class: " + gclass.name + ".extern.hx");
		} catch(ex:Dynamic) {
			trace(ex);
		}
	}
}
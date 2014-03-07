package;

import java.lang.reflect.Method;
import java.lang.Class;
import java.lang.ClassLoader;

class Generator {

	public static function main() {
		var args = Sys.args();

		if(args.length == 0) {
			trace("Please enter a valid Java class name (like: 'java.lang.String')");
			return;
		}

		var classIdent:String = args[0];

		var classLoader:ClassLoader = ClassLoader.getSystemClassLoader();

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

		trace(gclass.name);
	}
}
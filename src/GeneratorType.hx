package;

import java.lang.reflect.Modifier;
import java.lang.Class;

class GeneratorType {
	public var name(default, null):String;
	public var nameWithoutPackage(get, null):String;

	private static var types:Map<String, GeneratorType>;

	public static var imports:Array<String>;

	private function new(classType:Class<Dynamic>) {
		this.name = classType.getCanonicalName();
	}

	private function get_nameWithoutPackage():String {
		var new_name = this.name.split('.');

		return new_name[new_name.length - 1];
	}

	public function asHaxeType():String {
		var isArray:Bool = false;

		var name = this.nameWithoutPackage;

		if(name.indexOf("[") > -1) {
			isArray = true;

			name = name.split('[]')[0];
		}

		switch(name) {
			case "String":
				name = "String";
			case "CharSequence":
				name = "String";
			case "char":
				name = "String";

			case "int":
				name = "Int";
			case "short":
				name = "Int";
			case "long":
				name = "Int";

			case "float":
				name = "Float";
			case "double":
				name = "Float";

			case "boolean":
				name = "Bool";

			case "Object":
				name = "Dynamic";
		}

		var result = name;

		if(isArray) {
			result = "Array<" + result + ">";
		}

		return result;
	}

	public static function get(_class:Class<Dynamic>):GeneratorType {
		if(types == null) {
			types = new Map<String, GeneratorType>();
			imports = new Array<String>();
		}

		var name = _class.getCanonicalName();

		if(types.exists(name)) {
			return types.get(name);
		} else {
			if(name.indexOf('.') > -1) {
				var copy = new String(name);

				copy = copy.split('[]')[0];

				imports.push(copy);
			}

			types.set(name, new GeneratorType(_class));

			return types.get(name);
		}
	}
}
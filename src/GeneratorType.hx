package;

import java.lang.reflect.Field;
import java.lang.Class;

class GeneratorType {
	public var name(default, null):String;
	public var nameWithoutPackage(get, null):String;

	public function new(classType:Class<Dynamic>) {
		this.name = classType.getCanonicalName();
	}

	private function get_nameWithoutPackage():String {
		return this.name;
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
}
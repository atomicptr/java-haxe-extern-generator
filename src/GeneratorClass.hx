package;

import java.lang.Class;
import java.lang.reflect.Method;
import java.lang.reflect.Modifier;

class GeneratorClass {

	public var name(get_name, null):String;
	public var jpackage(get_jpackage, null):String;

	public var isInterface(default, null):Bool;

	public var fields(default, null):Array<GeneratorField>;
	public var methods(default, null):Map<String, Array<GeneratorMethod>>;

	private var methodNames:Array<String>;

	private var _class:Class<Dynamic>;

	public function new(_class:Class<Dynamic>) {
		this._class = _class;

		this.methodNames = new Array<String>();
		this.methods = new Map<String, Array<GeneratorMethod>>();
		this.fields = new Array<GeneratorField>();

		var mod:Int = this._class.getModifiers();

		this.isInterface = Modifier.isInterface(mod);

		var fields = this._class.getDeclaredFields();
		var methods = this._class.getDeclaredMethods();

		for(field in fields) {
			var mod:Int = field.getModifiers();

			if(Modifier.isPrivate(mod)) {
				continue;
			}

			this.fields.push(new GeneratorField(field));
		}

		for(method in methods) {
			var mod:Int = method.getModifiers();

			if(Modifier.isPrivate(mod)) {
				continue;
			}

			var methodName = method.getName();

			if(!this.methods.exists(methodName)) {
				this.methods.set(methodName, new Array<GeneratorMethod>());

				methodNames.push(methodName);
			}

			var genMethodArr = this.methods.get(methodName);

			genMethodArr.push(new GeneratorMethod(method));
		}
	}

	private function getNameWithoutPackage():String {
		var split = this.name.split('.');

		return split[split.length - 1];
	}

	private function get_name():String {
		return this._class.getCanonicalName();
	}

	private function get_jpackage():String {
		return this._class.getPackage().getName();
	}

	public function toString():String {
		var str = "";

		str += "package " + this.jpackage + ";";

		str += "\n\n";

		for(imp in GeneratorType.imports) {
			str += "import " + imp + ";\n";
		}

		str += "\n";

		str += "@:native(\"" + this.name + "\")\n";
		str += "extern class " + this.getNameWithoutPackage() + " {\n";

		str += "\n";

		for(field in this.fields) {
			str += "\t" + field.toString() + "\n";
		}

		str += "\n";

		for(methodGroup in this.methods) {
			var arr = GeneratorMethod.overloadToString(methodGroup);

			if(arr.length > 1) {
				str += "\n";
			}

			for(overload in arr) {
				str += "\t" + overload + "\n";
			}

			if(arr.length > 1) {
				str += "\n";
			}
		}

		str += "}\n";

		return str;
	}
}
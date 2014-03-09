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

import java.NativeArray;
import java.lang.Class;
import java.lang.reflect.Method;
import java.lang.reflect.Modifier;

class GeneratorClass {

	public var name(get_name, null):String;
	public var jpackage(get_jpackage, null):String;

	public var isInterface(default, null):Bool;

	public var fields(default, null):Array<GeneratorField>;
	public var methods(default, null):Map<String, Array<GeneratorMethod>>;

	private var _class:Class<Dynamic>;

	private var inner_classes:Array<GeneratorClass>;

	public function new(_class:Class<Dynamic>) {
		this._class = _class;

		this.methods = new Map<String, Array<GeneratorMethod>>();
		this.fields = new Array<GeneratorField>();
		this.inner_classes = new Array<GeneratorClass>();

		var _inner_classes = this._class.getDeclaredClasses();

		for(classObj in _inner_classes) {
			var name = classObj.getCanonicalName();

			if(name == null) {
				continue;
			}

			var _class = new GeneratorClass(classObj);

			this.inner_classes.push(_class);
		}

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
			}

			var genMethodArr = this.methods.get(methodName);

			genMethodArr.push(new GeneratorMethod(method));
		}
	}

	public function getNameWithoutPackage(?replaceDotWithUnderscore:Bool = false):String {
		return getClassName(_class, replaceDotWithUnderscore);
	}

	public static function getClassName(_class:Class<Dynamic>, ?replaceDotWithUnderscore:Bool = false):String {
		if(_class.getName().indexOf('.') > -1) {
			var packageNameLength:Int = _class.getPackage().getName().length;

			var name:String = _class.getCanonicalName();

			name = name.substring(packageNameLength + 1, name.length);

			if(replaceDotWithUnderscore) {
				name = StringTools.replace(name, ".", "_");
			}

			return name;
		} else {
			return _class.getName();
		}
	}

	private function get_name():String {
		return this._class.getCanonicalName();
	}

	private function get_jpackage():String {
		return this._class.getPackage().getName();
	}

	public function toString(?useImports:Bool = true):String {
		var str = "";

		var extendsClass = null;

		if(!this.isInterface) {
			extendsClass = GeneratorType.get(this._class.getSuperclass());
		}

		var _interfaces = this._class.getInterfaces();

		var interfaces = new Array<GeneratorType>();

		for(inface in _interfaces) {
			interfaces.push(GeneratorType.get(inface));
		}

		if(useImports) {
			str += "package " + this.jpackage + ";";

			str += "\n\n";

			for(imp in GeneratorType.imports) {

				if(imp.name != this.name) {
					str += "import " + imp.name + ";\n";
				}
			}

			str += "\n";
		}

		str += "@:native(\"" + this.name + "\")\n";

		if(!this.isInterface) {
			str += "extern class " + this.getNameWithoutPackage(true);
		} else {
			str += "extern interface " + this.getNameWithoutPackage(true);
		}

		if(!this.isInterface) {
			if(extendsClass.name != "java.lang.Object") {
				str += " extends " + extendsClass.nameWithoutPackage;
			}
		}

		if(interfaces.length > 0) {

			for(inface in interfaces) {
				if(!this.isInterface) {
					str += " implements ";
				} else {
					str += " extends ";
				}

				var interfaceName:String = inface.nameWithoutPackage;

				interfaceName = StringTools.replace(interfaceName, "$", ".");

				interfaceName = StringTools.replace(interfaceName, ".", "_");

				str += interfaceName;
			}
		}

		str += " {\n";

		if(!this.isInterface) {

			if(this.fields.length > 0) {
				str += "\n";

				for(field in this.fields) {

					// replace "$" sign with "_"
					var fieldText:String = StringTools.replace(field.toString(), "$", "_");

					str += "\t" + fieldText + "\n";
				}

				str += "\n";
			}
		}

		if(Lambda.count(this.methods) > 0) {
			for(methodGroup in this.methods) {
				var arr = GeneratorMethod.overloadToString(methodGroup);

				if(arr.length > 1) {
					str += "\n";
				}

				for(overload in arr) {
					str += "\t" + overload + "\n";
				}
			}
		}

		str += "}\n";

		for(_class in this.inner_classes) {
			str += "\n";
			str += _class.toString(false);
		}

		return str;
	}
}
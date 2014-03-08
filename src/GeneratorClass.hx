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

	private var methodNames:Array<String>;

	private var _class:Class<Dynamic>;

	private var _inner_classes:NativeArray<Class<Dynamic>>;

	public function new(_class:Class<Dynamic>) {
		this._class = _class;

		this.methodNames = new Array<String>();
		this.methods = new Map<String, Array<GeneratorMethod>>();
		this.fields = new Array<GeneratorField>();
		this._inner_classes = this._class.getDeclaredClasses();

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

	public function getNameWithoutPackage():String {
		return this.getClassName(this.name);
	}

	private function getClassName(pkg:String):String {
		var split = pkg.split('.');

		return split[split.length - 1];
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

				if(imp != this.name) {
					str += "import " + imp + ";\n";
				}
			}

			str += "\n";
		}

		str += "@:native(\"" + this.name + "\")\n";

		if(!this.isInterface) {
			str += "extern class " + this.getNameWithoutPackage();
		} else {
			str += "extern interface " + this.getNameWithoutPackage();
		}

		if(!this.isInterface) {
			if(extendsClass.name != "java.lang.Object") {
				str += " extends " + extendsClass.nameWithoutPackage;
			}
		}

		if(interfaces.length > 0) {

			for(inface in interfaces) {
				if(this.isInterface) {
					str += " implements ";
				} else {
					str += " extends ";
				}

				str += StringTools.replace(inface.nameWithoutPackage, "$", ".");
			}
		}

		str += " {\n";

		if(!this.isInterface) {

			if(this.fields.length > 0) {
				str += "\n";

				for(field in this.fields) {

					// ignore fields which contain a $ sign
					if(field.toString().indexOf('$') == -1) {
						str += "\t" + field.toString() + "\n";
					}
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

		for(classObj in _inner_classes) {
			var name = classObj.getCanonicalName();

			if(name == null) {
				continue;
			}

			var _class = new GeneratorClass(classObj);

			str += "\n";
			str += _class.toString(false);
		}

		return str;
	}
}
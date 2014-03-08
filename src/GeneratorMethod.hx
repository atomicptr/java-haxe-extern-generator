package;

import java.lang.reflect.Method;
import java.lang.reflect.Modifier;

class GeneratorMethod {

	public var name(default, null):String;
	public var isPublic(default, null):Bool;
	public var isFinal(default, null):Bool;
	public var isStatic(default, null):Bool;

	public var returnType(default, null):GeneratorType;
	public var parameters(default, null):Array<GeneratorType>;

	public function new(method:Method) {
		this.name = method.getName();

		this.parameters = new Array<GeneratorType>();

		var mod:Int = method.getModifiers();

		this.isPublic = Modifier.isPublic(mod);
		this.isFinal = Modifier.isFinal(mod);
		this.isStatic = Modifier.isStatic(mod);

		this.returnType = GeneratorType.get(method.getReturnType());

		var params = method.getParameterTypes();

		for(param in params) {
			this.parameters.push(GeneratorType.get(param));
		}
	}

	public function toString(?isOverload:Bool = false, ?dynamicParams = false):String {
		var str = "";

		if(!isOverload) {
			if(isFinal) {
				str += "@:final ";
			}

			if(isPublic) {
				str += "public ";
			} else {
				str += "private ";
			}

			if(isStatic) {
				str += "static ";
			}

			str += "function ";

			str += this.name;

			str += "(";

			if(!dynamicParams) {
				var index:Int = 0;
				var length:Int = this.parameters.length;

				for(param in this.parameters) {
					str += "arg" + index + ":" + param.asHaxeType();

					if(index < length - 1) {
						str += ", ";
					}

					index++;
				}
			} else {
				str += "params:Dynamic";
			}

			str += "):";

			str += returnType.asHaxeType();

			str += ";";
		} else {
			//@:overload(function(a:Int):Void{})

			str += "@:overload(function(";

			var index:Int = 0;
			var length:Int = this.parameters.length;

			for(param in this.parameters) {
				str += "arg" + index + ":" + param.asHaxeType();

				if(index < length - 1) {
					str += ", ";
				}

				index++;
			}

			str += "):";

			str += returnType.asHaxeType();

			str += "{})";
		}

		return str;
	}

	public static function overloadToString(methods:Array<GeneratorMethod>):Array<String> {
		var arr = new Array<String>();

		if(methods.length == 1) {
			arr.push(methods[0].toString());

			return arr;
		}

		for(method in methods) {
			arr.push(method.toString(true, false));
		}

		arr.push(methods[0].toString(false, true));

		return arr;
	}

}
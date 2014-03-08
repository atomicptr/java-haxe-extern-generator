package;

import java.lang.reflect.Field;
import java.lang.reflect.Modifier;

class GeneratorField {

	public var name(default, null):String;
	public var isPublic(default, null):Bool;
	public var isFinal(default, null):Bool;
	public var isStatic(default, null):Bool;

	public var type(default, null):GeneratorType;

	public function new(field:Field) {
		this.name = field.getName();

		var mod:Int = field.getModifiers();

		this.isPublic = Modifier.isPublic(mod);
		this.isFinal = Modifier.isFinal(mod);
		this.isStatic = Modifier.isStatic(mod);

		this.type = new GeneratorType(field.getType());
	}

	public function toString():String {
		var str:String = "";

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

		str += "var ";

		str += name;

		str += ":" + type.asHaxeType() + ";";

		return str;
	}

}
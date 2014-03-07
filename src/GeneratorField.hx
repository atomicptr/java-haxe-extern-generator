package;

import java.lang.reflect.Field;

class GeneratorField {

	public var name(default, null):String;
	public var isPublic(default, null):Bool;
	public var isFinal(default, null):Bool;
	public var isStatic(default, null):Bool;

	public var type(default, null):GeneratorType;

	public function new(field:Field) {

	}

}
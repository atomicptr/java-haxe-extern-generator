package;

import java.lang.reflect.Method;
import java.lang.reflect.Modifier;

class GeneratorMethod {

	public var name(default, null):String;
	public var isPublic(default, null):Bool;
	public var isFinal(default, null):Bool;
	public var isStatic(default, null):Bool;

	public var returnType(default, null):GeneratorType;
	public var arguments(default, null):Array<GeneratorType>;

	public function new(method:Method) {
		this.name = method.getName();

		this.arguments = new Array<GeneratorType>();

		var mod:Int = method.getModifiers();

		this.isPublic = Modifier.isPublic(mod);
		this.isFinal = Modifier.isFinal(mod);
		this.isStatic = Modifier.isStatic(mod);

	}

}
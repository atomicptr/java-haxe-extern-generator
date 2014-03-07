package;

import java.lang.Class;
import java.lang.reflect.Method;
import java.lang.reflect.Modifier;

class GeneratorClass {

	public var name(get_name, null):String;

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
			this.fields.push(new GeneratorField(field));
		}

		for(method in methods) {
			var methodName = method.getName();

			if(!this.methods.exists(methodName)) {
				this.methods.set(methodName, new Array<GeneratorMethod>());

				methodNames.push(methodName);
			}

			var genMethodArr = this.methods.get(methodName);

			genMethodArr.push(new GeneratorMethod(method));
		}
	}

	private function get_name():String {
		return this._class.getCanonicalName();
	}
}
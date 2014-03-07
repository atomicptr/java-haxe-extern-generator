package;

import java.lang.Class;

class GeneratorClass {

	public var name(get, null):String;

	private var _class:Class<Dynamic>;

	public function new(_class:Class<Dynamic>) {
		this._class = _class;
	}

	public function get_name():String {
		return this._class.getName();
	}
}
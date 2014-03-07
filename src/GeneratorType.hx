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
}
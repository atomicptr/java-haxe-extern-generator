java-haxe-extern-generator
===========================

Generate Haxe externs for Java libraries

## Example Usage

	java -jar Generator.jar /path/to/dir android.view.View
	
## Limitations

The following limitations can be resolved if you edit the generated externs by hand ;).

* You can't use inner classes with the same name (e.g. some.package.**Class.InnerClass** and some.package.**OtherClass.InnerClass** will cause a problem)
	
## Licence

java-haxe-extern-generator is licenced under the terms of the MIT licence.
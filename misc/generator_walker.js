var glob = require('glob')
var exec = require('exec-sync');

var files = glob.sync("android/**/*.class");

var new_files = [];

files.forEach(function(e) {
	if(e.indexOf('$') == -1) {
		var str = e.replace(/\//g, ".");

		var str = str.split('.class')[0];

		new_files.push(str);
	}
});

var generate = function(e) {
	exec("java -jar Generator.jar . " + e);
}

new_files.forEach(function(e) {
	generate(e);
});

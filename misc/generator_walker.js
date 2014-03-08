#!/usr/bin/env node
var glob = require('glob')
var exec = require('exec-sync');

var dir = process.argv[2];

if(!dir) {
	dir = ".";
}

if(dir.lastIndexOf('/') == -1) {
	dir += "/";
}

var files = glob.sync(dir + "**/*.class");

var new_files = [];

files.forEach(function(e) {
	if(e.indexOf('$') == -1) {
		var str = e.replace(/\//g, ".");

		var str = str.split('.class')[0];

		new_files.push(str);
	}
});

var generate = function(e) {
	var result = exec("java -jar Generator.jar . " + e);

	console.log(result);
}

new_files.forEach(function(e) {
	generate(e);
});

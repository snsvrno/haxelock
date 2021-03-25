private var tabSpaced = "  ";
private var tooLongString = "..";

function log(text : String) {
	if (!Main.switches.contains("debug")) return;

	Sys.println("LOG: " + text);
}

function error(text : String) {
	Sys.println("ERROR: " + text);
}

function trace(text : String) {
	if (!Main.switches.contains("debug")) return;
	trace("TRACE: " + text);
}

function warn(text : String) {
	Sys.println("WARN: " + text);
}

function passthrough(text : String) {
	if (Main.switches.contains("passthroughoutput")) {
		var lines = Utils.makeLines(text);
		for (l in lines) {
			tab(); println(l);
		}
	}
}

function print(text : String, ?length : Int) {
	var fulltext = text;

	if (length != null) {
		if (fulltext.length <= length) {
			while(fulltext.length < length) fulltext += " ";
		} else {
			fulltext = fulltext.substr(0,length - tooLongString.length);
			fulltext += tooLongString;
		}
	}

	Sys.print(fulltext);
}

function println(text : String) {
	Sys.println(text);
}

function newline() Sys.print("\n");

function tab(?count = 1) {
	var tab = tabSpaced;

	for (_ in 0 ... count) {
		tab += tabSpaced;
	}

	Sys.print(tab);
}
enum Result {
	Success;
	Failure(message : String);
}

class Haxe {


	static public function build(file : String) : Result {
		var haxeprocess = new sys.io.Process("haxe", [file]);
		var errormsg = haxeprocess.stderr.readAll();
		
		if (errormsg.length > 0) return Failure(errormsg.toString());
		else return Success;
	}

	static public function getVersion() : String {

		var haxeprocess = new sys.io.Process("haxe", ["--version"]);

		var string = haxeprocess.stdout.readAll().toString();
		while (string.charAt(string.length-1) == "\n" || string.charAt(string.length-1) == "\r") string = string.substr(0, string.length-1);
		
		return string;
	}
	
	static public function getLibraries(filepath : String) : Array<String> {
		var libraryNames : Array<String> = new Array<String>();

		var contents = sys.io.File.read(filepath).readAll().toString();

		var i = 0;
		while(true) {
			var char = contents.charAt(i);
			if (char == "-" && contents.substr(i+1,3) == "lib") {
				i += 5;
	
				char = contents.charAt(i);
				var word = "";
				while(char != "\r" && char != "\n" && i < contents.length) {
					word += char;

					i += 1;
					char = contents.charAt(i);
				}
				libraryNames.push(word);
			}

			i += 1;
			if (i >= contents.length) break;
		}

		return libraryNames;
	}
}
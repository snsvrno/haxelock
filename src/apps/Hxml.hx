package apps;

class Hxml {

	public var libraries : Array<String> = [];

	static public function load(hxmlfilepath : String) : Null<Hxml> {
		var hxml = new Hxml();

		if (sys.FileSystem.exists(hxmlfilepath) == false) {
			Io.log('haxefile $hxmlfilepath doesn\'t exists');
			return null;
		}

		var contents = sys.io.File.read(hxmlfilepath).readAll().toString();
		var lines = Utils.makeLines(contents);

		for (line in lines) {
			if (line.substr(0,4) == "-lib") {

				var name = line.substr(4);
				while (name.charAt(0) == " ") name = name.substr(1);
				hxml.addLibrary(name);

			} else if (line.substr(0,5) == "--lib") {

				var name = line.substr(5);
				while (name.charAt(0) == " ") name = name.substr(1);
				hxml.addLibrary(name);

			} else if (line.substr(line.length-5,5) == ".hxml") {

				// we have another hxml reference, so we should search that file for 
				// more libraries.

				var embeddedHxml = load(line);
				if (embeddedHxml != null) {
					for (l in embeddedHxml.libraries) hxml.addLibrary(l);
				}

			}
		}

		/*
		var i = 0;
		while(true) {
			
			var char = contents.charAt(i);

			// checks if we have a '-lib' or '--lib'
			if (char == "-" && 
			(contents.substr(i+1,3) == "lib") || (contents.substr(i+1,4) == "-lib")) {

				// we move the counter to the space.
				while(contents.charAt(i) != " ") i += 1;
	
				// we add one more so we are at the first character
				i += 1;

				// we start building the library name.
				char = contents.charAt(i);
				var word = "";

				// grabs all the characters until we get to a new line characer or a space.
				while(char != "\r" && char != "\n" && char != " " && i < contents.length) {
					word += char;

					i += 1;
					char = contents.charAt(i);
				}

				hxml.libraries.push(new Library(word));
			} 

			i += 1;
			if (i >= contents.length) break;
		}
		*/

		return hxml;
	}

	public function new() {

	}

	/**
	 * Only adds the library if its unique.
	 * @param library 
	 */
	public function addLibrary(library : String) {
		for (l in libraries) if (l == library) return;
		libraries.push(library);
	}
}
package apps;

class Hxml {

	public var libraries : Array<String> = [];

	/**
	 * parses the hxml file, loading the list of libraries required.
	 * will recursively look through all the hxml files if they are
	 * referenced inside this hxml file.
	 * @param hxmlfilepath 
	 * @return Null<Hxml>
	 */
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
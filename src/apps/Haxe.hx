package apps;

enum Result {
	Ok;
	Error(msg : String);
}

class Haxe {

	/**
	 * Reads the hxml file provided and returns any libraries that are used.
	 * @param buildfile 
	 * @return Array<Library>
	 */
	static public function getLibraries(buildfile : String) : Array<String> {
		var hxml = Hxml.load(buildfile);
		return hxml.libraries;
	}

	static public function build(buildfile : String) : Result {
		Io.trace('building $buildfile');

		var haxeprocess = new sys.io.Process("haxe", [buildfile]);
		var errormsg = haxeprocess.stderr.readAll();
		
		if (errormsg.length > 0) return Error(errormsg.toString());
		else return Ok;
	}
}
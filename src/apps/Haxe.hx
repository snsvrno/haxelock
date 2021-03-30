package apps;

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

	static public function runCommand(args : Array<String>) : Result {
		
		var haxeprocess = new sys.io.Process("haxe", args);
		var errormsg = haxeprocess.stderr.readAll().toString();
		var msg = haxeprocess.stdout.readAll().toString();

		if (errormsg.length > 0) return Error(errormsg);
		else return Ok(msg);
		
	}

	static public function build(buildfile : String) : Result {
		var result = runCommand([buildfile]);
		return result;
	}
}
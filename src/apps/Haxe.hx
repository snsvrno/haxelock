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
}
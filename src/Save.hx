class Save {
	inline static public var FILENAME = 'haxelib.lock';

	static public function libraries(buildfile : String) {
	
		var libs = Haxe.getLibraries(buildfile);

		var versions = Haxelib.getLibraryVersions(libs);

		// creates the lock file and saves the structure to it.
		var lockfile = sys.io.File.write(FILENAME);
		var json = haxe.Json.stringify({ haxe : Haxe.getVersion(), libraries: versions }, replacer, "  ");
		lockfile.writeString(json);
		lockfile.close();
	}

	static private function replacer(key : Dynamic, value : Dynamic) : Dynamic {
		if (Std.isOfType(value, Haxelib.Version)) { 
			switch (cast(value, Haxelib.Version)) {
				case Haxelib(ver): return ver;
				case Git(path, branch, commit): return { url: path, branch : branch, commit: commit };
				case Dev(url, branch, commit): return { url: url, branch : branch, commit: commit };
				// an error shouldnt' get this far.
				case Error(message): return null; 
			}
		} else return value;
	}
}
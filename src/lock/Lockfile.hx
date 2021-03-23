package lock;

class Lockfile {
	
	static public var filename : String = "haxelib.lock";
	
	public var libraries : Array<libraries.Library> = [];

	////////////////////////////////////////////////////////////////
	// alternate constructors
	static public function open() : Null<Lockfile> {

		if (sys.FileSystem.exists(filename) == false) return null;

		var lock = new Lockfile();

		var contents = sys.io.File.read(filename).readAll().toString();
		var parsed = haxe.Json.parse(contents);
		var libs = Reflect.getProperty(parsed, "libraries");
		
		for (libname in Reflect.fields(libs)) {
			var lib = Reflect.getProperty(libs, libname);

			if (Reflect.hasField(lib, "version")) {

				var library = new libraries.Haxelib(libname, Reflect.getProperty(lib, "version"));
				lock.libraries.push(library);

			} else {

				Io.error('git libraries are unimplemented.');
				/*
				newLibrary.setGitRaw(
					Reflect.getProperty(lib, "url"),
					Reflect.getProperty(lib, "commit"),
					Reflect.getProperty(lib, "branch")
				);*/

			}
		}

		return lock;
	}

	
	/**
	 * Creates a lockfile for the current project
	 * @return Lockfile
	 */
	 /*
	static public function create(buildfile : String) : Lockfile {
		var lock = new Lockfile();
		var hxml = apps.Hxml.load(buildfile);

		for (l in hxml.libraries) {
			// goes through the libraries named in the hxml file, and looks them
			// up using haxelib to see what the current verison is.
			var library = apps.Haxelib.getLibrary(l);
			if (library == null) Io.error('Library $l is defined in the hxml but not available locally?');
			else lock.libraries.push(library);
		}

		lock.save();

		return lock;
	}*/

	public function new() { }

	/**
	 * Saves the file to the disk.
	 */
	public function save() {

		/*
		var libs = new Map<String, Any>();
		for (l in libraries) {
			var data = l.serialize();
			if (data != null) libs.set(l.name,data);
		}
		*/
		
		//var stringified = haxe.Json.stringify({ libraries : libs }, "  ");

		var stringified = haxe.Json.stringify(this, "  ");
		sys.io.File.write(filename).writeString(stringified);
	} 
}
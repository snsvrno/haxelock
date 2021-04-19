package lock;
import libraries.Library.LibraryTools;

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
		
		// checks that it is formatted correctly. throws an error if we don't
		// get the expected type, which is an array.
		var libs = try { cast(Reflect.getProperty(parsed, "libraries"), Array<Dynamic>);
		} catch (_) throw('malformed lockfile at $filename, please recreate.');
		
		for (i in 0 ... libs.length) {
			var lib = libs[i];
			var libname = Reflect.getProperty(lib, "name");
			
			if (libname == null) throw("error in lockfile, library doesn't have a name?");

			if (Reflect.hasField(lib, "version")) {

				var library = new libraries.Haxelib(libname, Reflect.getProperty(lib, "version"));
				lock.libraries.push(library);

			} else {

				Io.trace('git libraries are unimplemented.');
				/*
				newLibrary.setGitRaw(
					Reflect.getProperty(lib, "url"),
					Reflect.getProperty(lib, "commit"),
					Reflect.getProperty(lib, "branch")
				);*/

			}
		}

		// sorts the libraries so they are alphabetical.
		lock.libraries.sort(function(a : libraries.Library, b : libraries.Library)  {
			if (a.name == b.name) return 0;
			if (a.name > b.name) return 1;
			else return -1;
		});

		return lock;
	}

	static public function set(library : libraries.Library) {

		var lock = open();

		for (l in lock.libraries) { 
			if (LibraryTools.isEqual(l,library)) {
				Io.println('locked version of ${library.name} is already set to ${library.getVersion()}');
				return;
			}
		}

		Io.print('locking version of ${library.name} to ${library.getVersion()}');

		// checks if we already have a library with this name defined, and
		// if we do then we remove it.
		for (l in lock.libraries) {
			if (l.name == library.name) {
				Io.print(' replacing ${l.getVersion()}');

				lock.libraries.remove(l);
				break;
			}
		}

		Io.newline();
		lock.libraries.push(library);
		lock.save();
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
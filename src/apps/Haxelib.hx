package apps;

class Haxelib {

	// the command used to run haxelib
	static private var command : String = "haxelib";

	/**
	 * Gets the path of the currently used haxelib local library.
	 * @return String
	 */
	static public function getPath() : String {
		 // creates the process
		var process = new sys.io.Process(command, ["config"]);
		
		// reads the output from the process, which should be the library path.
		var string = process.stdout.readAll().toString();
		// cleans up the path, removes newline characters.
		string = Utils.cleanString(string);
		
		process.close();		
		return string;

	}

	/**
	 * get the currently used library.
	 * @param library 
	 * @return String
	 */
	static public function getLibrary(library : String) : Null<Library> {
		var haxelibpath = getPath();
		var libroot = haxelibpath + library;

		var lib = new Library(library);

		// checks that the folder exists, it should exists. if it isn't then it will
		// let us know.
		if (!sys.FileSystem.exists(libroot)) { 
			Io.error('can\'t find the library $library. expected to find it here: $libroot');
			return null;
		}
		
		// first we check if we are using a DEV library, defined by the presence of a dev file.
		if (sys.FileSystem.exists(libroot + "\\.dev")) {
			Io.trace('Library $library has a .dev file.');

			var devpath = sys.io.File.read(libroot + "\\.dev").readAll().toString();
			devpath = Utils.cleanString(devpath);

			// we need to check if this library is a git repository, that is the only way we know
			// how to keep track of it.
			if (sys.FileSystem.exists(devpath + "\\.git")) {
				Io.trace('Dev library $library is a git repository.');

				lib.setGit(devpath);
				return lib;

			} else {
				Io.error('Dev library $library is local and isn\'t version controlled. There is no way to track this.');
			}
		}

		// next we'll check what is defined as the current version in the current file.
		var current = Utils.cleanString(sys.io.File.read(libroot + "\\.current").readAll().toString());
		if (current == "git") {
			// we are using the git version as the most recent version.

			lib.setGit(libroot + "\\git");
			return lib;

		} else {
			// we are using a haxelib version.
			
			lib.setVersion(current);
			return lib;
		}

		return null;
	}

	static public function setVersion(name : String, version : String) : Bool {
		Sys.print('Setting $name to $version ... ');

		var haxelibprocess = new sys.io.Process(command, ["set", name, version, "--always"]);

		// hack to check if we failed. going to split by how the error is formatted so that
		// we can see if we suceeded or failed on the switch.
		var msg = haxelibprocess.stdout.readAll();
		haxelibprocess.close();

		var splitMessage = msg.toString().split("Error: [");
		if (splitMessage.length == 1) { 
			
			Sys.println("Success!");
			return true;

		} else {

			Sys.println("Failed!");
			return false;
		}
	}

	static public function setGit(name : String, url : String) {
		Sys.print('Setting $name to git: $url ... ');

		var haxelibprocess = new sys.io.Process(command, ["git", name, url, "--always"]);

		// hack to check if we failed. going to split by how the error is formatted so that
		// we can see if we suceeded or failed on the switch.
		var msg = haxelibprocess.stdout.readAll();
		haxelibprocess.close();

		var splitMessage = msg.toString().split("Error: [");
		if (splitMessage.length == 1) { 
			
			Sys.println("Success!");
			return true;

		} else {

			Sys.println("Failed!");
			return false;
		}
	}

}
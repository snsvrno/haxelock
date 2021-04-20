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
	 * Sets the haxelib managed library to this one.
	 * @param library 
	 */
	static public function setLibrary(library : libraries.Library) : Result {
		return library.set();
	}

	/**
	 * get the currently used library.
	 * @param library 
	 * @return String
	 */
	static public function getLibrary(library : String) : Null<libraries.Library> {
		var haxelibpath = getPath();
		var libroot = haxelibpath + library;

		// checks that the folder exists, it should exists. if it isn't then it will
		// let us know.
		if (!sys.FileSystem.exists(libroot)) { 
			Io.trace('can\'t find the library $library. expected to find it here: $libroot');
			return null;
		}

		return libraries.Tools.parseFromPath(library, libroot);
	}

	/**
	 * gets all the locally setup libraries for the given library ...
	 * with return multiple versions of the same library and possibly
	 * a git repository if set and locally tracked.
	 * @param library 
	 * @return Array<libraries.Library>
	 */
	static public function getAllLibraries(library : String) : Array<libraries.Library> {
		var haxelibpath = getPath();
		var libroot = haxelibpath + library;

		var libs : Array<libraries.Library> = [];

		// checks that the folder exists, it should exists. if it isn't then it will
		// let us know.
		if (!sys.FileSystem.exists(libroot)) { 
			Io.trace('can\'t find the library $library. expected to find it here: $libroot');
			return libs;
		}

		for (f in sys.FileSystem.readDirectory(libroot)) {
			var fullPath = haxe.io.Path.join([libroot, f]);
			if (sys.FileSystem.isDirectory(fullPath)) {
				if (f == 'git') {

					libs.push(new libraries.Git(library,
						apps.Git.getUpstreamUrl(fullPath),
						apps.Git.getBranch(fullPath),
						apps.Git.getCommit(fullPath)
					));

				} else {
				
					var version = f.split(',').join('.');
					libs.push(new libraries.Haxelib(library, version));

				}
			}
		}

		return libs;
	}

	static public function runCommand(args : Array<String>) : Result {
		var haxelibprocess = new sys.io.Process(command, args);

		var msg = haxelibprocess.stdout.readAll().toString();
		var error = haxelibprocess.stderr.readAll().toString();

		haxelibprocess.close();

		if (msg.length > 0) {

			// if we don't have an error stream we should still check the 
			// main stream for an error. because haxelib isn't good at 
			// using the error stream.

			var isAnError : Bool = true;
			var split = msg.split("Error");

			if (split.length == 1) {
				split = msg.split("error");
				if (split.length == 1) isAnError = false;
			}

			if (isAnError) error = msg;
			else return Ok("haxelib\n" + msg);
		}

		if (error.length > 0) return Error("haxelib\n" + error);

		return Ok("");
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
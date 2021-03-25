package commands;

class Build implements Command{

	public var name : String = "build";
	public var displayName : String = "<hxml file> (build)";
	public var doc : String = "calls haxe to build the given hxml file.";
	
	public function new() {}

	public function run(?buildfile : String, args : Array<String>) {
		// check if all the libraries are installed. will
		// load the library if not exists, but will only give a
		// warning if you are using a different version so you can
		// correct it or 'force' this to be the new correct version.
		//
		// checks for OK status, if for any reason something goes wrong
		// it will return false and we should not build.
	
		// we attempt to load the lockfile, if it exists then
		// we can check against it.
		
		var validEnvironment = true;
		var lockfile = lock.Lockfile.open();
		if (lockfile != null) {
			Io.trace("lockfile found");
			for (l in lockfile.libraries) {
				switch(l.check()) {

					case Ok: Io.log('${l.name} is ${l.getVersion()}');
						
					case NotInstalled | WrongVersion:
						
						Io.print('setting ${l.name} to ${l.getVersion()} ... ');
						
						switch(apps.Haxelib.setLibrary(l)) {

							case Ok(msg):
								Io.println("success!");
								Io.passthrough(msg);
							case Error(error):
								validEnvironment = false;
								Io.println("failed!");
								Io.passthrough(error);

						}
						
					case Other(message): 

						Io.error(message);
						validEnvironment = false;
				}
			}
		} else Io.trace("lockfile not found, skipping checks.");

		if (!validEnvironment) { 
			Io.error("Failed to align locked version, aborting build.");
			return;
		} else if (lockfile != null) Io.trace('all libraries are at locked versions');

		switch(apps.Haxe.build(buildfile)) {
			case Ok(msg):
				Io.trace("built successfully.");
			
			case Error(msg):
				Io.error(msg);
		}

	}

	/**
	 * checks that the passed parameter is a hxml file (at least in name only)
	 * @param parameter 
	 * @return Bool
	 */
	public function isCommand(parameter : String) : Bool {

		// checks for anything that ends in .hxml and then decides that the
		// user wants to build that file.
		if (parameter.length > 5 && parameter.substr(parameter.length-5,5) == ".hxml") return true;
		return false;
	}

	public function help() {
		Io.println('Usage: haxelock <hxml file>');
		
		Io.newline();

		Io.tab();
		Io.println("builds the given hxml file using haxe.");
	}

}
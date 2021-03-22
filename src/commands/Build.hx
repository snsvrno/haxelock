package commands;

class Build implements Command{

	public var name : String = "Build";
	public var doc : String = "n";
	
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
			for (l in lockfile.libraries) {
				switch(l.check()) {
					case Ok:
						
					case NotInstalled:
						

						if (l.version != null) { 

							if (!apps.Haxelib.setVersion(l.name, l.version)) validEnvironment = false;

						} else {

							trace('${l.name} trying to install via GIT');

							// a git repo, we need to set the git version.
							apps.Haxelib.setGit(l.name, l.url);

							// make sure its running the same commit.
							var local = apps.Haxelib.getLibrary(l.name);
							if(!apps.Git.setCommit(local.path, l.url, l.branch, l.commit)) validEnvironment = false; 
						}
						
					case WrongVersion: 
						
						if (!apps.Haxelib.setVersion(l.name, l.version)) validEnvironment = false;

					case WrongCommit: 

						var local = apps.Haxelib.getLibrary(l.name);
						if(!apps.Git.setCommit(local.path, l.url, l.branch, l.commit)) validEnvironment = false; 
					
					case Other(message): 

						Io.error(message);
						validEnvironment = false;
				}
			}
		}

		if (!validEnvironment) { 
			Sys.println("Failed to align locked version, aborting build.");
			return;
		}
		
		

		// if (lockfile == null) lock.Lockfile.create(buildfile);

		/*
		if (!Check.versions(buildfile)) {
			Sys.println("Failed to align locked version, aborting build.");
			return;
		}

		// build
		switch (Haxe.build(buildfile)) {
			case Success:

				// save the libraries
				Save.libraries(buildfile);

			case Failure(msg):

				// stop and tell the user the build error
				Sys.println(msg);
		}*/

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

	}

}
class Main {
	static public function main() {
		
		// checks the args if we passed a parameter.
		// and then sets the file
		var args = Sys.args();
		if (args.length != 2) Sys.println("please supply a valid .hxml to build.");
		else {
			var buildfile = args[0];

			// check if all the libraries are installed. will
			// load the library if not exists, but will only give a
			// warning if you are using a different version so you can
			// correct it or 'force' this to be the new correct version.
			//
			// checks for OK status, if for any reason something goes wrong
			// it will return false and we should not build.
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
			}

		}
	}

}
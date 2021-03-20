class Check {
	static public function versions(buildfile : String) : Bool {
		
		// this is what we have locally.
		var libs = Haxe.getLibraries(buildfile);
		var versions = Haxelib.getLibraryVersions(libs, true);

		// this is what the lock file says.
		if (!sys.FileSystem.exists(Save.FILENAME)) {

			// if the lock file doesnt' exist we don't know what to check, so we just 
			// continue.
			Sys.println("WARNING: no lockfile found.");

		} else {

			var rawContents = sys.io.File.read(Save.FILENAME).readAll().toString();
			var parsedContents = haxe.Json.parse(rawContents);

			// check the haxe version here, we will just warn if they are not the same.
			var localHaxeVersion = Haxe.getVersion();
			var lockHaxeVersion = Reflect.getProperty(parsedContents, "haxe");
			if (lockHaxeVersion != localHaxeVersion) {
				Sys.println('WARNING: lock file was made with Haxe $lockHaxeVersion. currently using $localHaxeVersion');
			}

			// check the librarues here.
			var libraries = Reflect.getProperty(parsedContents, "libraries");
			for (l in Reflect.fields(libraries)) {
				var data = Reflect.getProperty(libraries, l);
				var v = parseVersion(data);

				var localv = versions.get(l);

				switch([v, localv]) {
					// for each of these we check if there is a difference, and if there
					// is we will attempt to set it to the lock file version. if we can't
					// then we are going to error out and not build.

					case [Haxelib(v1), Haxelib(v2)]:
						if (v1 != v2) if (!Haxelib.setVersion(l, v1)) return false;

					case [Git(url, branch, commit), Git(_,_)]:
						if (!Haxelib.setGitCommit(l, url, branch, commit)) return false;

					case [Git(url, branch, commit), Dev(_,_)]:
						if (!Haxelib.setGitCommit(l, url, branch, commit)) return false;

					case [_,_]:
						Sys.println('ERROR: don\'t know what to do with $v and $localv');
						return false;
				}

			}
		}

		return true;
	}

	static private function parseVersion(jsontext : Dynamic) : Haxelib.Version {
		if (Std.isOfType(jsontext, String)) return Haxelib(cast(jsontext, String));
		else return Git(
			cast(Reflect.getProperty(jsontext, "url"), String),
			cast(Reflect.getProperty(jsontext, "branch"), String),
			cast(Reflect.getProperty(jsontext, "commit"), String)
		);
	}
}
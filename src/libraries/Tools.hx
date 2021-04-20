package libraries;


class Tools {
	static public function isEqual(a : Library, b : Library) : Bool {
		return a.source == b.source && a.getVersion() == b.getVersion();
	}

	/**
	 * creates a library from a name and a defining string, the string (otherValue)
	 * can be a version, a local path, or a git url with commit (optional)
	 * * 0.2.3
	 * * ../../libraries/path
	 * * https://www.gitpath.repo@13fa233
	 * * https://gitpath.repo.nocommit
	 * @param name 
	 * @param otherValue 
	 * @return Library
	 */
	static public function parse(name : String, otherValue : String) : Library {

        // for matching a version number, can match any number
        // that has at least 2 points `(x.y)`.
        var versionRegex = ~/([0-9]+)\.[0-9]+(\.([0-9]+))*/i;

        if (versionRegex.match(otherValue)) {
            // it matches the version regex so that means it must be a version
            // and we'll create a standard haxelib library.

            return new libraries.Haxelib(name, otherValue);

        } else if (otherValue.substr(0,6) == "https:" 
		|| otherValue.substr(0,4) == "git:") {
            // this is a url, so it must be a git repository.

			// urls can end with an '@' which will then give the commit hash.
			// we we try and split it here and give it to the initalizer later.
			var urlBlob = otherValue.split("@");

			return new libraries.Git(name, urlBlob[0], null, urlBlob[1]);

		} else {
            // the only other valid input now is a commit to change an existing git
            // repository.

            var libs = apps.Haxelib.getAllLibraries(name);
            for (l in libs) {// if (l.source == "git") {
                trace(l);
                //var l = cast(l, libraries.Git);
                //eturn new libraries.Git(l.name, l.url, otherValue);

            }

            throw('don\'t know what to do with "$name" and "$otherValue"');

        }
		
	}

	static public function parseBySource(blob : Dynamic) : Null<Library> {

		var source = Reflect.getProperty(blob, "source");
		if (source == null) return null;
		else if (source == "haxelib") { 
			
			return new libraries.Haxelib(
				Reflect.getProperty(blob, "name"),
				Reflect.getProperty(blob, "version")
			);

		} else if (source == "git") {

			return new libraries.Git(
				Reflect.getProperty(blob, "name"),
				Reflect.getProperty(blob, "url"),
				Reflect.getProperty(blob, "branch"),
				Reflect.getProperty(blob, "commit")
			);
		}
		
		return null;
	}

	/**
	 * creates a library from the library path inside the haxelib folder.
     * this is the root folder, so it will contain a `.current` which
     * tells what version to use (or could have a `.dev` file)
	 * @param path 
	 * @return Null<Library>
	 */
	static public function parseFromPath(library : String, path : String) : Null<Library> {
		
        // checking if a dev file exists.
        if (sys.FileSystem.exists(haxe.io.Path.join([path, ".dev"]))) {
			Io.trace('Library $library has a .dev file.');

			var devpath = sys.io.File.read(haxe.io.Path.join([path, ".dev"])).readAll().toString();
			devpath = Utils.cleanString(devpath);

			// we need to check if this library is a git repository, that is the only way we know
			// how to keep track of it (checking if there is a `.git` folder)
			if (sys.FileSystem.exists(haxe.io.Path.join([devpath,".git"]))) {
				Io.trace('Dev library $library is a git repository.');

                return new Git(library,
                    apps.Git.getUpstreamUrl(devpath),
                    apps.Git.getBranch(devpath),
                    apps.Git.getCommit(devpath)
                );

			} else {
				Io.error('Dev library $library is local and isn\'t version controlled. There is no way to track this.');
                return null;
			}
        }

		// next we'll check what is defined as the current version in the current file.
		var current = Utils.cleanString(sys.io.File.read(haxe.io.Path.join([path, ".current"])).readAll().toString());
		if (current == "git") {
			// we are using the git version as the most recent version.

            Io.trace('Library $library is a git repository.');

			var gitpath = haxe.io.Path.join([path, "git"]);

            return new Git(library,
                apps.Git.getUpstreamUrl(gitpath),
				apps.Git.getBranch(gitpath),
                apps.Git.getCommit(gitpath)
            );

		} else {
			// we are using a haxelib version.
			
            Io.trace('Library $library is a haxelib library.');
			return new libraries.Haxelib(library, current);
		}


        return null;
	}
}
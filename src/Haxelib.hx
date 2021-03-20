import sys.io.Process;

enum Version {
	// a version that was taken from haxelib.
	Haxelib(ver : String);
	// a version that was a directly from a git.
	Git(path : String, branch : String, commit : String);
	// a version that was 'dev' and is commited and has an upstream url. 
	Dev(url: String, branch : String, commit : String);
	// an error
	Error(message : String);
}

class Haxelib {

	static public function getLibraryVersions(libs : Array<String>, ?supressErrors : Bool = false) : Map<String, Version> {
		
		var versions : Map<String, Version> = new Map();

		for (l in libs) {
			var version = getVersionOfLib(l);
			switch(version) {

				case Error(message): if (!supressErrors) Sys.println("ERROR: " + message);
				case other: versions.set(l, other);

			}
		}

		return versions;
	}
	
	static public function getVersionOfLib(name : String)  : Version {
		var haxelibpath =getHaxelibPath() ;
		var libpath = '$haxelibpath$name';

		if (!sys.FileSystem.exists(libpath)) {
			trace('can\'t find the library $name');
		}

		// first we check if this is a dev library
		var devpath = libpath + "\\.dev";
		if (sys.FileSystem.exists(devpath)) {
			// is a dev path, so we need to get the dev path string.
			var path = sys.io.File.read(devpath).readAll().toString();
			while (path.charAt(path.length-1) == "\n" || path.charAt(path.length-1) == "\r") path = path.substr(0, path.length-1);

			if (!sys.FileSystem.exists(path + "\\.git")) return Error('library $name is a local only library, HAXELOCK will not track it');
			else {
				// we have a git folder, so we are a git repository.
				return Error('dev is unimplemented');
			}
	
		}

		// next we check what the content of the current folder is.
		var string = sys.io.File.read(libpath + "\\.current").readAll().toString();
		while (string.charAt(string.length-1) == "\n" || string.charAt(string.length-1) == "\r") string = string.substr(0, string.length-1);
		
		if (string == "git") {
			// we are using a git repo, lets look at the repo
			// to see what the commit hash is.
			var gitpath = libpath + "\\git";
			return Git(
				getGitUrl(gitpath),
				getGitBranch(gitpath), 
				getGitCommit(gitpath)
			);

		} else {
			// is a local version, lets save that string
			// as the version number
			return (Haxelib(string));
		}
	}

	static private function getHaxelibPath() : String {
		var process = new sys.io.Process("haxelib", ["config"]);
		var string = process.stdout.readAll().toString();
		while (string.charAt(string.length-1) == "\n" || string.charAt(string.length-1) == "\r") string = string.substr(0, string.length-1);
		process.close();
		return string;
	}

	static private function getGitCommit(path : String, ?length : Int = 6) : String {

		var gitprocess = new sys.io.Process("git", ["--git-dir", path + "\\.git", "rev-parse", "HEAD"]);

		var string = gitprocess.stdout.readAll().toString();
		while (string.charAt(string.length-1) == "\n" || string.charAt(string.length-1) == "\r") string = string.substr(0, string.length-1);
		
		gitprocess.close();
		return string.substr(0, length);
	}

	static private function getGitUrl(path : String) : String {

		var gitprocess = new sys.io.Process("git", ["--git-dir", path + "\\.git", "config", "--get", "remote.origin.url"]);

		var string = gitprocess.stdout.readAll().toString();
		while (string.charAt(string.length-1) == "\n" || string.charAt(string.length-1) == "\r") string = string.substr(0, string.length-1);
		
		gitprocess.close();
		return string;
	}

	static private function getGitBranch(path : String) : String {

		var gitprocess = new sys.io.Process("git", ["--git-dir", path + "\\.git", "rev-parse", "--abbrev-ref", "HEAD"]);

		var string = gitprocess.stdout.readAll().toString();
		while (string.charAt(string.length-1) == "\n" || string.charAt(string.length-1) == "\r") string = string.substr(0, string.length-1);
		
		gitprocess.close();
		return string;
	}

	static public function setVersion(lib : String, version : String) : Bool {

		Sys.print('Setting $lib to $version ... ');
		var haxelibprocess = new sys.io.Process("haxelib", ["set", lib, version, "--always"]);

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

	static public function setGitCommit(lib : String, url : String, branch : String, commit : String) : Bool {
		
		var haxelibpath = getHaxelibPath();
		// checks if we are running a local dev library
		var repositoryPath : String = if (sys.FileSystem.exists(haxelibpath + "\\.dev")) {
			var string = sys.io.File.read(haxelibpath + "\\.dev").readAll().toString();
			while (string.charAt(string.length-1) == "\n" || string.charAt(string.length-1) == "\r") string = string.substr(0, string.length-1);
			string;
		} else {
			'$haxelibpath$lib\\git';
		}

		// first we check if we have the same upstream path.
		var upstream = getGitUrl(repositoryPath);
		if (upstream != url) {
			Sys.println('ERROR: local version of $lib does not have the same upstream as lock file: "$upstream" vs "$url"');
			return false;
		}

		// next we check if the commit is the same.
		var localCommit = getGitCommit(repositoryPath);
		if (localCommit != commit) {
			// not the same so we need to change it.

			{
				var checkoutprocess = new sys.io.Process("git", ["--git-dir", repositoryPath + "\\.git", "--work-tree", repositoryPath, "checkout", branch]);
				var checkoutError = checkoutprocess.stdout.readAll().toString();
				if (checkoutError.substr(0, 11) != "Your branch" ) {
					Sys.println('ERROR: Failed to move repository $lib ($repositoryPath) to branch $branch:');
					Sys.println('=GIT=ERROR======================');
					Sys.println(checkoutError.toString());
					checkoutprocess.close();
					return false;
				}
				checkoutprocess.close();

				var pullprocess = new sys.io.Process("git", ["--git-dir", repositoryPath + "\\.git", "--work-tree", repositoryPath, "pull"]);
				pullprocess.close();

			}

			var gitprocess = new sys.io.Process("git", ["--git-dir", repositoryPath + "\\.git", "--work-tree", repositoryPath, "checkout", commit]);

			// hack to check if the first character is an "e" so we know its an error, because
			// git gives a warning when checking out a commit.
			var error = gitprocess.stderr.readAll().toString();
			if (error.charAt(0) == "e") {
				Sys.println('ERROR: git can\'t change $lib ($repositoryPath) to commit $commit');
				Sys.println('=GIT=ERROR======================');
				Sys.println(error);
				gitprocess.close();
				return false;
			}
			gitprocess.close();

			Sys.println('git: $lib set to commit $commit');
		}


		return true;
	}

}
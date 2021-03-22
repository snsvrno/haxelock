enum Result {
	Ok;
	WrongVersion;
	NotInstalled;
	WrongCommit;
	Other(message : String);
}

class Library {

	public final name : String;

	// used for haxelib libraries
	public var version : Null<String>;

	// used for the rest of libraries
	public var url : Null<String>;
	public var commit : Null<String>;
	public var branch : Null<String>;

	public var path : Null<String>;
	
	public function new(name : String) {
		this.name = name;
	}

	public function setGitRaw(url : String, commit : String, branch : String) {

		this.url = url;
		this.commit = commit;
		this.branch = branch;

		version = null;

	}

	public function setGit(gitpath : String) {

		url = apps.Git.getUpstreamUrl(gitpath);
		commit = apps.Git.getCommit(gitpath);
		branch = apps.Git.getBranch(gitpath);

		version = null;

		path = gitpath;

		// going to check if the library is "dirty" (meaning we have
		// un commited changes) and then if we do we'll warn the
		// user, because at this point it isn't an issue ... maybe...
		var status = apps.Git.status(gitpath);
		if (status.untracked > 0 || status.modified > 0)
			Io.warn('Git repository for library $name has uncommit changes: (${status.untracked} untracked, ${status.modified} modified).');
	}

	public function setVersion(version : String) {
		url = null;
		commit = null;
		branch = null;

		this.version = version;
	}

	public function check() : Result {

		// gets whatever the local version of this library is.
		var local = apps.Haxelib.getLibrary(name);

		if (local == null) return NotInstalled;

		if (version != null && local.version == version) return Ok;
		else if (version != null) return WrongVersion;

		if (url != null && local.url == url && local.commit == commit) return Ok;
		else if (url != null && local.url == url) return WrongCommit;
		else if (url != null && local.url == null) return NotInstalled;
		else if (url != null) return Other('Library $name upstream is ${local.url} but expecting $url');

		trace(local.version, version);

		return Other('shouldn\'t have been here');
	}

	public function serialize() : Dynamic {
		var data = { };

		if (version != null) {

			Reflect.setProperty(data, "version", version);
			return data;

		} else {

			Reflect.setProperty(data, "commit", commit);
			Reflect.setProperty(data, "branch", branch);
			Reflect.setProperty(data, "url", url);
			return data;
		}

		return null;
	}
}
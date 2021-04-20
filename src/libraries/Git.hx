package libraries;

/**
 * A library that is managed and on lib.haxe.org.
 */
class Git implements Library {
	public final source : String = "git";
	public final name : String;

	public var url(default, null) : String;
    private var commit : Null<String>;
	private var branch : Null<String>;

	public function new(name : String, url : String, ?branch : String, ?commit : String) {
		this.name = name;
		this.url = url;
        this.commit = commit;
		this.branch = branch;
	}

	public function check() : libraries.Library.Result {
		var local = apps.Haxelib.getLibrary(name);

		if (local == null) return NotInstalled;
		else if (local.source != source) return WrongVersion;
		else {
			var gitlib = cast(local, Git);
            // error message if the urls are different. may not be an issue but you should
            // probably be using the same upstream.
            // TODO : maybe allow this?
            if (gitlib.url != url) return Other('library has different upstream: ${gitlib.url} found, $url defined');
			// checking if the commit is the same, which means this is the same version.
            if (gitlib.commit == commit) return Ok;
			else return WrongVersion;
		}

		return Other('general error.');
	}

	public function set() : apps.Result {

        //if (commit != null) Io.print('setting library $name to git:$commit ... ');
        //else Io.print('setting library $name to git ...');

        // first we make sure that the haxelib version is a git version
		var result = apps.Haxelib.runCommand(["git", name, url, "--always"]);

        // next we check if we have a commit set, 
        if (commit != null) {
            // if we do then we need to set the current version to that commit.

			var path = haxe.io.Path.join([ apps.Haxelib.getPath(), name, "git" ]);
			apps.Git.setCommit(path, commit, branch);

        } else {
            // if we don't then we save that commit so we know what it is in the
            // future.

            commit = apps.Git.getCommit(haxe.io.Path.join([apps.Haxelib.getPath(), name, "git"]));
        }

		return result;
	}

	public function getVersion() : String {
		return 'git(#$commit)';
	}
}
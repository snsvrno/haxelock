package apps;

typedef Status = {
	untracked : Int,
	modified : Int,
};

class Git {

	static private var command : String = "git";

	static public function getUpstreamUrl(path : String) {
		
		var gitprocess = new sys.io.Process(command, [
			"--git-dir", 
			haxe.io.Path.join([path, ".git"]), 
			"--work-tree", 
			haxe.io.Path.join([path, ".git"]),
			 "config", 
			 "--get", 
			 "remote.origin.url"
		]);

		var string = gitprocess.stdout.readAll().toString();
		string = Utils.cleanString(string);
		
		gitprocess.close();
		return string;
	}

	static public function getBranch(path : String) { 

		var gitprocess = new sys.io.Process(command, [
			"--git-dir", 
			haxe.io.Path.join([path, ".git"]), 
			"--work-tree", 
			haxe.io.Path.join([path, ".git"]), 
			"rev-parse", 
			"--abbrev-ref", 
			"HEAD"
		]);

		var string = gitprocess.stdout.readAll().toString();
		string = Utils.cleanString(string);
		
		gitprocess.close();
		return string;
	}

	static public function getCommit(path : String, ?length : Int = 6) {

		var gitprocess = new sys.io.Process(command, [
			"--git-dir", 
			haxe.io.Path.join([path, ".git"]), 
			"--work-tree", 
			haxe.io.Path.join([path, ".git"]), 
			"rev-parse", 
			"HEAD"
		]);

		var string = gitprocess.stdout.readAll().toString();
		string = Utils.cleanString(string);
		
		gitprocess.close();
		return string.substr(0, length);
	}

	static public function status(path : String) : Status {
		
		var gitprocess = new sys.io.Process(command, [
			"--git-dir", 
			haxe.io.Path.join([path, ".git"]), 
			"--work-tree", 
			haxe.io.Path.join([path, ".git"]), 
			"status", 
			"--porcelain"
		]);
		var output = gitprocess.stdout.readAll().toString();

		var files = Utils.makeLines(output);
		var status : Status = { modified : 0, untracked : 0};
		
		for (f in files) {
			if (f.substr(0,2) == " m") status.modified++;
			else if (f.substr(0,2) == "??") status.untracked++;
		}

		gitprocess.close();

		return status;
	}

	static public function setCommit(name : String, url : String, commit : String, branch : String) : Bool {
		trace(name, url, commit, branch);
		return true;
	}
}
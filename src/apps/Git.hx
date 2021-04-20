package apps;

typedef Status = {
	untracked : Int,
	modified : Int,
};

class Git {

	static private var command : String = "git";

	static public function runCommand(path : String, ... commands:String) : Result {

		var commandArray = [
			"--git-dir", haxe.io.Path.join([path, ".git"]), 
			"--work-tree", haxe.io.Path.join([path]),
		];
		
		for (c in commands) commandArray.push(c);

		var gitprocess = new sys.io.Process(command, commandArray);

		var msg = gitprocess.stdout.readAll().toString();
		var error = gitprocess.stderr.readAll().toString();

		gitprocess.close();

		if (msg.length > 0) return Ok(msg);
		if (error.length > 0) return Error(error);

		return Ok("");
	}

	static public function getUpstreamUrl(path : String) : String {

		var result = runCommand(path, "config", "--get", "remote.origin.url");
		switch (result) {
			case Ok(string): return Utils.cleanString(string);
			case Error(message): throw('no upstream url for repository $path; is this really a git repositry?:\n\n    $message');
		}
	
	}

	static public function getBranch(path : String) : String {

		var result = runCommand(path, "rev-parse", "--abbrev-ref", "HEAD");
		switch (result) {
			case Ok(string): 
				var branch = Utils.cleanString(string);
				if (branch == "HEAD") {
					// this means we've checkout a commit already and we're using this
					// we need to toggle back to whatever the actual branch was so we can
					// get that information

					// should toggle us back to the real branch ... hopefully.
					var checkoutResult = runCommand(path, "checkout", "-");
					switch (checkoutResult) {
						case Error(message): throw(message);
						case Ok(_):
					}

					// we try again.
					var secondResult = runCommand(path, "rev-parse", "--abbrev-ref", "HEAD");
					// return it back to whatever it was.
					runCommand(path, "checkout", "-");
					// check what we have.
					switch (secondResult) {
						case Error(message): throw(message);
						case Ok(string): 
							var realBranch = Utils.cleanString(string);
							if (realBranch != "HEAD") return realBranch;
							throw("error");
					}

				} else {

					return branch;

				}

			case Error(message): throw('no branch for repository $path; is this really a git repositry?:\n\n    $message');
		}

	}

	static public function getCommit(path : String, ?length : Int = 6) {

		var result = runCommand(path, "rev-parse", "HEAD");
		switch (result) {
			case Ok(string): return Utils.cleanString(string).substr(0, length);
			case Error(message): throw('no commit for repository $path; is this really a git repositry?:\n\n    $message');
		}

	}

	/**
	 * checks if a repository has a specific commit currently available.
	 * @param path 
	 * @param commitHash 
	 * @return Bool
	 */
	static public function commitExists(path : String, commitHash : String) : Bool {

		var result = runCommand(path, "cat-file", "-t", commitHash);
		switch (result) {
			case Ok(_): return true;
			case Error(_): return false;
		}

	}

	static public function status(path : String) : Status {

		var result = runCommand(path, "status", "--porcelain");
		switch (result) {
			case Ok(string): 

				var status : Status = { modified : 0, untracked : 0};
				var files = Utils.makeLines(string);
				
				for (f in files) {
					if (f.substr(0,2) == " m") status.modified++;
					else if (f.substr(0,2) == "??") status.untracked++;
				}

				return status;
				
			case Error(message): throw('is $path really a git repositry?:\n\n    $message');
		}

	}

	static public function setCommit(path : String, commit : String, ?branch : String) : Bool {

		// if we don't provide a branch then we will assume that it 
		// can be found from the repository, probably main/master.
		if (branch == null) branch = getBranch(path);

		var result = runCommand(path, "checkout", branch);
		switch (result) {
			case Error(message): 
				Io.error('failed to change "$path" to "$branch"');
				Io.passthrough("git:\n" + message);
				return false;

			case Ok(message):
				Io.passthrough("git:\n" + message);
		}


		// now we need to check if the commit actually exists. if it doesn't
		// then we assume we have to pull the repo to update it it.
		if (!commitExists(path, commit)) {
			var updateResult = runCommand(path, "pull");
			switch(updateResult) {
				case Error(message): 
					Io.error('failed pull $path');
					Io.passthrough("git:\n" + message);
					return false;
	
				case Ok(message):
					Io.passthrough("git:\n" + message);
			}

			// we check again if the commit exists, if it doesn't exist a 2nd time
			// then there is something wrong and that commit is not available on this
			// repo or branch.
			if (!commitExists(path, commit)) {
				Io.error('can\'t find commit "$commit" on branch "$branch" on "$path"');
				return false;
			}
		}

		// now we checkout the commit
		var checkoutStatus = runCommand(path, 'checkout', commit);
		switch(checkoutStatus) {
			case Error(message): 
				// this uses the 'error' chanel when detaching a head ... so this
				// feedback isn't valid, we get the 'error' but the actually command
				// executed as expected.
				//Io.error('failed to change "$path" to "$commit" (2)');
				Io.passthrough("git:\n" + message);
				return true;

			case Ok(message):
				Io.passthrough("git:\n" + message);
				return true;
		}

		Io.error("failed to do anything.");
		return false;
	}
}
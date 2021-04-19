package commands;

private enum UpgradeStatus {
	Failed;
	Suceeded;
	NoUpgrade;
}

class Upgrade implements Command {
	private var switches : Array<Switch> = [
		{ name : "test hxml", description : "the build file to test if the upgrade is successful", long : "--hxml" }
	];
	
	public var name : String = "upgrade";
	public var doc : String = "upgrades a single locked library or all locked libraries";
	public var displayName : Null<String> = "upgrade";

	public function new() { }

	public function run(?command : String, args : Array<String>) {
		// if the upgrade was successful, so we can check if we should try to do the 
		// verification build or cancel.
		var status : UpgradeStatus = NoUpgrade;

		// the existing lock file, so we can revert back to it if the test build
		// fails.
		var lock = lock.Lockfile.open();

		if (lock == null) {
			Io.println('no haxe.lock file found, this project is not currently being tracked.');
			return;
		}

		var buildfiles : Array<String> = [];
		var libraries : Array<String> = [];
		var i = 0;
		while(i < args.length) {
			if (args[i].charAt(0) == "-") {
				if (args[i] == "--hxml") {
					buildfiles.push(args[i+1]);
					i += 1;
				} else {
					Io.log('unknown switch ${args[i]}');
				}
			} else {
				libraries.push(args[i]);
			}

			i += 1;
		}
		
		// checking if we are going to upgrade all libraries or a list of libraries
		if (libraries.length == 0) {

			// we are going to do all the libraries
			Io.log('upgrading all tracked libraries');

			for (l in lock.libraries) {
				var individualStatus = upgradeLibrary(l.name);
				if (individualStatus == Suceeded && status != Failed) status = Suceeded;
				else if (individualStatus == Failed) status = Failed;
			}

		} else {
			// we are going to only do the local tracked libraries.
			for (l in libraries) {
				var individualStatus = upgradeLibrary(l);
				if (individualStatus == Suceeded && status != Failed) status = Suceeded;
				else if (individualStatus == Failed) status = Failed;
			}
		}

		if (status == Suceeded) {
			if (buildfiles.length == 0) {
				buildfiles = Utils.getAllHxmlFiles([".haxelib","test","tests"]);
			}

			var buildOk = true;
			for (b in buildfiles) {
				Io.print('testing build of $b .. ');
				switch(apps.Haxe.build(b)) {
					case Ok(msg): Io.println("ok!");					
					case Error(msg): 
						Io.println('failed!');
						buildOk = false;
				}
			}

			if (!buildOk) {
				Io.println("build failed, reverting back to old version(s)");
			} else {

				for (l in lock.libraries) {
					var local = apps.Haxelib.getLibrary(l.name);
					if (l.getVersion() != local.getVersion()) {
						lock.libraries.remove(l);
						lock.libraries.push(local);
					}
				}

				lock.save();
				Io.println("new lockfile saved");
			}
		} else if (status == NoUpgrade) {
			Io.println('upgrade cancelled, no libraries have changed.');
			return;
		} else {
			Io.println('upgrade cancelled, error upgrading one or more libraries.');
			return;
		}

	}

	public function help() {
		Io.println('Usage: haxelock upgrade (<library name> | <switch>)');
		
		Io.newline();

		Io.tab(); Io.println("upgrades all the tracked libraries, or the given library(s) and runs a build to confirm the");
		Io.tab(); Io.println("new library still works with the the given code base.");
		Io.newline();
		Io.tab(); Io.println("if no build file is given then all buildfiles in the project folder will be run and any");
		Io.tab(); Io.println("failed build will prevent the lockfile from being updated.");

		Io.newline();

		Io.println('Switches:');
		for (s in switches) {
			Io.tab();

			if (s.short != null && s.long != null) Io.print(s.short + ", " + s.long,14);
			else if (s.short != null) Io.print(s.short, 14);
			else if (s.long != null) Io.print(s.long, 14);
			else Io.print("ERROR NO SWITCH", 14); 

			Io.print(s.description);
			Io.newline();
		}

	}

	public function isCommand(parameter : String) : Bool return parameter == name;

	/**
	 * runs a haxelib upgrade command on the library, will
	 * return a true if there isn't any error. returns a false
	 * if there is an error with the upgrade.
	 * @param library 
	 * @return UpgradeStatus [Suceeded|NoUpgrade|Failed]
	 */
	private function upgradeLibrary(library : String) : UpgradeStatus {

		// checks if we are tracking this library, if we are not tracking this
		// library then we don't do anything ..
		var lock = lock.Lockfile.open();
		for (l in lock.libraries) if (l.name == library) {
			
			switch(apps.Haxelib.runCommand(["upgrade", library, "--always"])) {
				case Ok(output):
					if (Main.switches.contains("passthroughoutput")) Io.passthrough(output);

					var version = apps.Haxelib.getLibrary(l.name);
					if (version.getVersion() != l.getVersion()) {
						Io.println('$library upgraded from ${l.getVersion()} to ${version.getVersion()}');
						return Suceeded;
					}

					// we finished the update.
					Io.log('upgrading library $library ... no change');
					return NoUpgrade;

				case Error(output):
					if (Main.switches.contains("passthroughoutput")) Io.passthrough(output);
					Io.error('failed to upgrade library $library');

					return Failed;
			}

		}

		Io.error('the library $library is not tracked by haxelock. used `set` to start tracking it.');
		return Failed;

	}
}
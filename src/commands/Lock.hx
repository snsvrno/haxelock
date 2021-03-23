package commands;

import Io.println;

class Lock implements Command {
	private var switches : Array<Switch> = [
		{ name : "all", description : "scans the current folder recusively and manages versions for all hxml files found.", long : "--all" }
	];

	public var name : String = "lock";
	public var doc : String = "creates a lockfile";
	public var displayName : Null<String> = null;

	public function new() { }

	public function run(?command : String, args : Array<String>) {
		var buildfile = args.shift();
		var wasrun = false;

		// checks if the first arguement is a switch.
		if (buildfile == "--all") {
			// replaces the args with all the hxml files we found.
			args = Utils.getAllHxmlFiles([".haxelib","test","tests"]);
			buildfile = args.shift();
		}

		var lockfile = new lock.Lockfile();
		while(buildfile != null) {
			Io.println('reading file $buildfile');

			var usedlibraries = apps.Haxe.getLibraries(buildfile);

			for (usedlib in usedlibraries) {
				var lib = apps.Haxelib.getLibrary(usedlib);

				println('found library ${lib.name} ${lib.getVersion()}');
				
				// checks if a different version is in here.
				// currently don't have a method of tracking different
				// versions ..
				// TODO: figure this out, should we do this? could a project
				//       have different versions for different builds?
				var exists : Bool = false;
				for (l in lockfile.libraries) {
					if (l.name == lib.name) {
						exists = true;
						Io.warn('already tracking library ${l.name} ${l.getVersion()}, won\'t track ${lib.getVersion()}');

						// there should only be one duplicate.
						break;
					}
				}

				if (!exists) lockfile.libraries.push(lib);
			}

			// prep for next iteration.
			if (!wasrun) wasrun = true;
			buildfile = args.shift();
		}

		// we tracked everything and we're ready to save the file.
		lockfile.save();
		
		Io.println("lock file successfully created");

		if (!wasrun) help();
	}

	public function help() {
		Io.println('Usage: haxelock lock <hxml file> <hxml file> ...');
		
		Io.newline();

		Io.tab(); Io.println("scans the build file recusively and creates a lockfile in the root of the project to manage versions.");
		Io.tab(); Io.println("can be given one or multiple hxml files.");
		
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
}
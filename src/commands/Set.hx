package commands;

class Set implements Command{

	public var name : String = "set";
	public var displayName : String = "set";
	public var doc : String = "sets the locked version of a particular library";
	
	public function new() {}

	public function run(?buildfile : String, args : Array<String>) {

		if (args[0] == null || args[1] == null) {
			Io.error('expecting <library name> <version>');
			return;
		}

		// we only support haxelib right now, so we don't need to check anything.
		var library = new libraries.Haxelib(args[0], args[1]);
		// make the change locally.
		var result = library.set();
		switch(result) {

			case Error(output):
				Io.trace("set error");
				if (Main.switches.contains("passthroughoutput")) Io.passthrough(output);
				else Io.error(output);
				return;

			case Ok(output):
				Io.trace("set ok");
				if (Main.switches.contains("passthroughoutput")) Io.passthrough(output);
		}

		// then we need to make the change to the haxelock file, so we know this is the
		// locked version.

		lock.Lockfile.set(library);
		
	}

	/**
	 * checks that the passed parameter is a hxml file (at least in name only)
	 * @param parameter 
	 * @return Bool
	 */
	public function isCommand(parameter : String) : Bool return parameter == name;

	public function help() {
		Io.println('Usage: haxelock set <library name> (<version> | other');
		
		Io.newline();

		Io.tab();
		Io.println("sets the version of the locked library.");
	}

}
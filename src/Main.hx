class Main {

	// all the registered commands that haxelock can execute.
	static private var commands : Array<commands.Command> = [
		new commands.Build(),
		new commands.Help(),
	];

	static public function main() {
		
		// checks the args if we passed a parameter.
		// and then sets the file
		var args = Sys.args();

		// gets ride of that last bit, which is the haxelock executable
		// file.
		args.pop();

		if (args.length >= 1) {
			// finds out what the command is and removes
			// it from the list of arguements.
			var command = args.shift();
			var commandRan  = false;

			// runs through each registered command and sees if we have a 
			// valid command.
			for (c in commands) { 
				if (c.isCommand(command)) {
					// we want to check that we found a match so we don't display
					// the help information at the end.
					commandRan = true; 
					c.run(command, args);
				}
			}

			if (!commandRan) {
				// ran if we didn't actually run a command
				// so we can tell the user that their command
				// wasn't valid and can give them the help so they
				// can see what they should be doing instead.

				Sys.println('Command $command is not a valid command.');
				for (c in commands) if (c.isCommand("help")) c.run([]);
			}

			/*

			// checks for anything that ends in .hxml and then decides that the
			// user wants to build that file.
			if (param.length > 5 && param.substr(param.length-5,5) == ".hxml") build(args[0]);

			// if we do install then we pass that and the rest of the args to haxelib
			// and record what we did so we can make changes to the lock file.
			if (param == "install" || param == "set") installLibrary(args);*/
		}
	}

	/*

	static private function installLibrary(args : Array<String>) {

		if (Haxelib.setVersion(args[1], args[2])){
			trace("save it");
			i need to generic the load and save function so i cna reusei it better.
		}
	}

	static private function help() {
		Sys.print('help me');
	}*/

}
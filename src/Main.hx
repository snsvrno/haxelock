class Main {

	static public var version : String = "0.0.0";

	/*** all the registered commands that haxelock can execute. */
	static public var commands : Array<commands.Command> = [
		new commands.Build(),
		new commands.Upgrade(),
		new commands.List(),
		new commands.Lock(),
		new commands.Set(),
		new commands.Help(),
	];

	/*** The list of switches that are active when running */
	static public var switches : Array<String> = [];
	/*** All valid switches are defined here. */
	static public var validSwitches : Array<Switch> = [
		{ name : "debug", long : "--debug", short : "-d", description: "shows debug information during execution." },
		{ name : "passthroughoutput", long : "--output", short : "-o", description: "shows output from all nested commands like git, haxe, and haxelib." }
	];

	static public function main() {
		
		// checks the args if we passed a parameter.
		// and then sets the file
		var args = Sys.args();

		
		// finds out what the command is and removes
		// it from the list of arguements.
		var command = args.shift();
		while (command != null && command.charAt(0) == "-") {
			// we have a switch and we need to set it globally.
			// we do it recursively so we can grab em all.

			// we check if its a valid switch and only add it if
			// it shows up, and we add the name, not the long or short.
			for (v in validSwitches) {
				if (v.short == command || v.long == command) {
					if (!switches.contains(v.name)) switches.push(v.name);
				}
			}

			command = args.shift();
		}
		if (command == null) command = "help";

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

			Io.println('Command $command is not a valid command.');
			for (c in commands) if (c.isCommand("help")) c.run([]);
		}


	}

}
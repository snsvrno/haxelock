package commands;

class Help implements Command {
	
	public var displayName : String = null;
	public var name : String = "help";
	public var doc : String = "shows this screen, and extended help information when used with other commands.";

	public function new() { }

	/**
	 * What is displayed when asking for help on this specific command.
	 */
	public function help() {
		Io.println('Usage: haxelock help <command>');
		
		Io.newline();

		Io.tab();
		Io.println("help can be used with each command to further describe the commands use and optional switches and parameters");	
	}

	public function run(?command : String, args : Array<String>) { 
		if (args.length == 0) {
			// runs the standard help for this program.
			generalHelpHeader();
			Io.println('Usage: haxelock <hxml  file|command>');
			
			Io.newline();

			Io.println('Commands:');
			for (c in Main.commands) {
				Io.tab();
				var name = if (c.displayName != null) c.displayName; else c.name; 
				Io.print(name, 14);
				Io.print(c.doc);
				Io.newline();
			}

			Io.newline();
			Io.println('General Switches:');
			for (s in Main.validSwitches) {
				Io.tab();

				if (s.short != null && s.long != null) Io.print(s.short + ", " + s.long,14);
				else if (s.short != null) Io.print(s.short, 14);
				else if (s.long != null) Io.print(s.long, 14);
				else Io.print("ERROR NO SWITCH", 14); 

				Io.print(s.description);
				Io.newline();
			}
		} else {
			var command = args.shift();
			var found = false;
			for (c in Main.commands) {
				if (c.name == command) { 
					generalHelpHeader();
					c.help();
					found = true;
				}
			}
			if (!found) Io.println('there is no know commaned called $command');
		}
	}

	private function generalHelpHeader() {
		Io.println('Haxelock ${Main.version}');
	}

	public function isCommand(parameter : String) : Bool return parameter == name;
}
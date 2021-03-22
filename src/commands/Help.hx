package commands;

class Help implements Command {
	
	public var name : String = "Help";
	public var doc : String = "helps";

	public function new() { }

	public function help() { 

		Sys.println("Help!");

	}


	public function run(?command : String, args : Array<String>) { 
		help();
	}

	public function isCommand(parameter : String) : Bool return parameter == "help";
}
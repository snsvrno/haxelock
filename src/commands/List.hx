package commands;

class List implements Command{

	public var name : String = "list";
	public var displayName : String = "list";
	public var doc : String = "lists all locked versions";
	
	public function new() {}

	public function run(?buildfile : String, args : Array<String>) {
		var lock = lock.Lockfile.open();
		
		if (lock == null) {
			Io.println('no haxe.lock file found, this project is not currently being tracked.');
			return;		
		}

		for (l in lock.libraries) {
			Io.println('${l.name}: ${l.getVersion()}');
		}		
	}

	/**
	 * checks that the passed parameter is a hxml file (at least in name only)
	 * @param parameter 
	 * @return Bool
	 */
	public function isCommand(parameter : String) : Bool return parameter == name;

	public function help() {
		Io.println('Usage: haxelock list');
		
		Io.newline();

		Io.tab();
		Io.println("lists all locked versions inside of a project by reading the contents of the lockfile.");
	}

}
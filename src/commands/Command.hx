package commands;

interface Command {
	public var name : String;
	public var doc : String;

	public function run(?command : String, args : Array<String>) : Void;
	public function help() : Void;
	public function isCommand(parameter : String) : Bool;
}
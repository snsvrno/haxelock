package libraries;

enum Result {
	Ok;
	WrongVersion;
	NotInstalled;
	Other(message : String);
}

interface Library {
	public final source : String;

	public final name : String;
	public function check() : Result;

	public function getVersion() : String;
}
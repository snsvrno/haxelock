package libraries;

/**
 * A library that is managed and on lib.haxe.org.
 */
class Haxelib implements Library {
	public final source : String = "haxelib";
	public final name : String;

	private var version : String;

	public function new(name : String, version : String) {
		this.name = name;
		this.version = version;
	}

	public function check() : libraries.Library.Result {
		var local = apps.Haxelib.getLibrary(name);

		if (local == null) return NotInstalled;
		else if (local.source != source) return WrongVersion;
		else {
			var localhaxelib = cast(local, Haxelib);
			if (localhaxelib.version == version) return Ok;
			else return WrongVersion;
		}

		return Other('general error.');
	}

	public function set() : apps.Result {
		var result = apps.Haxelib.runCommand(["set", name, version, "--always"]);
		return result;
	}

	public function getVersion() : String {
		return version;
	}
}
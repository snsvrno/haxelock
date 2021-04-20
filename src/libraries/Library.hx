package libraries;

/**
 * a matching result when comparing two libraries
 */
enum Result {
	/*** versions match */
	Ok;

	/**
	 * there are two different versions and they are not the same,
	 * doesn't matter if they are from the same source or not.
	 */
	WrongVersion;
	
	/**
	 * there is not any version of this library currently installed
	 * in the working haxelib repository
	 */
	NotInstalled;

	/**
	 * something bad happened, could be considered a failure or fault
	 */
	Other(message : String);
}

interface Library {
	/**
	 * the 'source' of this library, should be fixed at the class
	 * and will be used when comparing libraries so we know if they
	 * are from the same space.
	 * 
	 * and example is something from lib.haxe.org is called 'haxelib'
	 */
	public final source : String;

	/*** the name of the library, should be called in the constructor. */
	public final name : String;
	
	/**
	 * checks this version of the library against whatever is installed.
	 * 
	 * returns a result based on the matching.
	 * @return Result
	 */
	public function check() : Result;

	/**
	 * gets a nice string representation of this 'verson', should relay
	 * enough information to understand the library version.
	 * @return String
	 */
	public function getVersion() : String;

	/**
	 * Sets this library as the current library in haxelib.
	 * @return Bool
	 */
	public function set() : apps.Result;
}

import sys.io.Process;
import utest.Assert;
import utest.Async;

class Test extends utest.Test {

	static public function main() utest.UTest.run([new Test()]);

	/**
	 * Testing if it will correctly identify the current haxelib version
	 * and change it to the desired haxelib version when trying to build
	 * a project.
	 */
	public function testProject1() {

		// ensures we are in the test project folder.
		Sys.setCwd("tests/project1");

		// the setup, changing the library version to the "older" version.
		var process = new sys.io.Process("haxelib", ["set", "heaps", "1.9.0", "--always"]);
		process.close();

		// checks that the library is the version we want.
		Assert.equals("1.9.0", apps.Haxelib.getLibrary("heaps").getVersion());

		// running the build, equivalent to the user running a build with haxelock.
		var build = new commands.Build();
		build.run("build.hxml",[]);

		// checks to see if what expected happened, updating the version of 'heaps'
		// to the one listed in the lock file.
		Assert.equals("1.9.1", apps.Haxelib.getLibrary("heaps").getVersion());		
	}
}
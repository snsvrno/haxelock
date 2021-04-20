package apps;

/**
 * use when executing apps, returns the result of the execution
 * as well as any output from that app.
 */
enum Result {
	Ok(output : String);
	Error(output : String);
}

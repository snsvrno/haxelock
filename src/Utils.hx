class Utils {
	/**
	 * Trims white spaces and carage returns from a string.
	 * @param string 
	 * @return String
	 */
	static public function cleanString(string : String) : String {
		
		// trims the front of the string.
		while (string.length > 0 && string.charAt(0) == " ") string = string.substr(1);

		// trims the back end of the string.
		while (string.length > 0 
		&& (string.charAt(string.length-1) == "\n" 
			|| string.charAt(string.length-1) == "\r" 
			|| string.charAt(string.length-1) == " ")) 
		{
			string = string.substr(0, string.length-1);
		}

		return string;
	}

	/**
	 * Splits a string into lines.
	 * 
	 * Made this because there could be multiple line endings, and removes
	 * them from the strings so we don't have to worry about it anymore.
	 * 
	 * Looks for '\n' and '\r'
	 * 
	 * @param text 
	 * @return Array<String>
	 */
	public static function makeLines(text : String) : Array<String> {		
		var splits = new Array<String>();
		var line = "";
		for (i in 0 ... text.length) {

			var char = text.charAt(i);
			
			if (char == "\n" || char == "\r") {

				if (line.length > 0) splits.push(line);
				line = "";

			} else {
			
				line += char;
			
			}
		}

		// make sure to grab the last one if we haven't done it yet.
		if (line.length > 0) splits.push(line);
		return splits;
	}
}
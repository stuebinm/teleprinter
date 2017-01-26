using Gee;

using Teleprinter;


public string get_target_file (string input) {
	string output = input.replace (".print", ".html");
	stdout.printf ("output file for %s is %s\n", input,  output);
	return output;
}
public string get_aux_file (string input) {
	return input.replace (".printer", ".aux");
}
public string get_prefix (string input) {
	string [] dirs = input.split ("/");
	dirs [dirs.length-1] = "";
	return string.joinv ("/", dirs);
}


public class Printer : Object {

	public string path {public get; private set; default="";}
	public string target {public get; private set; default = "";}
	
	string markup;
	
	private DataOutputStream out_stream;
	
	Commands commands;
	
	public Printer.from_path (string path, Commands? commands, string? target = null) {
		
		this.path = path;
		this.target = target;
		this.commands = commands;
		if (this.commands == null) this.commands = new Commands ();
		this.commands.set_vars (path, target);
	}
	
	
	public int run (bool save, out string output = null) {
		
		File finput = File.new_for_path (this.path);
		
		if (!finput.query_exists ()) {
		    stderr.printf ("Input file %s could not be found; aborting.\n", this.path);
		    return 1;
		}
		this.markup = "";
		try {
		    var dis = new DataInputStream (finput.read ());
			string line;
			// Read lines until end of file (null) is reached
			while ((line = dis.read_line (null)) != null) {
				this.markup += "%s\n".printf (line);
			}
		} catch {
		    stderr.printf ("File Error");
		    return 1; // again, terminate in case of error
		}
		
		output = parse_line (markup);
    	
    	if (save) {
    	
			try {
				var file_out = File.new_for_path (this.target);

				// delete if the file already exists
				if (file_out.query_exists ()) {
					file_out.delete ();
				}
			
				this.out_stream = new DataOutputStream (file_out.create (FileCreateFlags.REPLACE_DESTINATION));
				this.out_stream.put_string (output);
			} catch (Error e) {
				stderr.printf ("%s\n", e.message);
			
			}
    	}
		return 0;
	}
	
	private string parse_line (string line) {
		string output = this.commands.parse_level (line);
		return output;
	}


}

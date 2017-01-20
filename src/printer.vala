using Gee;

using Teleprinter;

public class Printer : Object {

	public string path {public get; private set; default="";}
	public string target {public get; private set; default = "";}
	
	private DataOutputStream out_stream;
	
	Commands commands;
	
	public Printer.from_path (string path, string target) {
		
		this.path = path;
		this.target = target;
		this.commands = new Commands ();
		
		
		try {
		    var file_out = File.new_for_path (this.target);

		    // delete if the file already exists
		    if (file_out.query_exists ()) {
		        file_out.delete ();
		    }
		    
		    this.out_stream = new DataOutputStream (file_out.create (FileCreateFlags.REPLACE_DESTINATION));
		    
		} catch (Error e) {
		    stderr.printf ("%s\n", e.message);
		    
		}
	}
	
	public int run () {
		
		File finput = File.new_for_path (this.path);
		
		if (!finput.query_exists ()) {
		    stderr.printf ("Input file %s could not be found; aborting.\n", this.path);
		    return 1;
		}
		
		try {
		    var dis = new DataInputStream (finput.read ());
			string line;
			// Read lines until end of file (null) is reached
			while ((line = dis.read_line (null)) != null) {
				int code = this.parse_line (line);
				if (code != 0) return code;
			}
		} catch {
		    stderr.printf ("File Error");
		    return 1; // again, terminate in case of error
		}
    
		return 0;
	}
	
	private int parse_line (string line) {
		if (line != "") {
			string output = this.parse_level (line);
			stdout.printf ("%s\n", output);
		}
		return 0;
	}


	private string? parse_level (string input) {
	
		string output = "";
		
		MatchInfo m;
		Patterns.COMMAND.match (input, 0, out m);
		
		int p = 0;
		if (m.fetch(0) != null) {
			do {
				int start, end;
				m.fetch_pos (0, out start, out end);
				output = m.get_string().slice (p, start);
				p = end;
				output += parse_command (m.fetch (0));
				output += m.get_string().slice (p, m.get_string().length);
			}
			while (m.next ());
		} else {
			output = input;
		}
		
		return output;
	}

	private string? parse_command (string command) {
	
		MatchInfo m;
		Patterns.COMMAND_NAME.match (command, 0, out m);
		
		string name = m.fetch (0);
		
		
		if (!this.commands.is_defined (name)) {
			return command;
		}
		
		string[] args= get_arguments (command);
		return commands.execute (name, args);

	}
	
	string[] get_arguments (string command) {
		string[] ret = new string [0];
		
		MatchInfo m;
		Patterns.SINGLE_ARGUMENT.match (command, 0, out m);
		
		if (m.fetch(0) == null) return ret;
		do {
		    ret += parse_level (m.fetch(0).slice (1, m.fetch(0).length-1));
		} while (m.next ());
		
		
		return ret;
	}



}

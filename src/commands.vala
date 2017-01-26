using Gee;

namespace Teleprinter {


	private abstract class AbstractCommand : Object {
		public abstract string? execute (string name, string[] args);
	}


	private class SingleCommand : AbstractCommand {
		
		public command c;
		
		public SingleCommand (command c) {
			this.c = c;
		}
		
		
		public override string? execute (string name, string[] args) {
			return this.c (name, args);
		}
		
	}
	
	private class CustomCommand : AbstractCommand {
		private string[] argslist;
		private Commands commands;
		
		public CustomCommand (string[] args, Commands commands) {
			this.argslist = args;
			this.commands = commands;
		}
		
		public override string? execute (string name, string[] args) {
			string command;
			switch (args.length) {
				case 1:
					command = this.argslist [1].replace ("#1", args[0]);
					break;
				case 2:
					command = this.argslist [1].replace ("#1", args[0]);
					command = command.replace ("#2", args[1]);
					break;
				case 3:
					command = this.argslist [1].replace ("#1", args[0]);
					command = command.replace ("#2", args[1]);
					command = command.replace ("#3", args[2]);
					break;
				default:
					command = this.argslist [1];
					break;
			}
			return this.commands.parse_level (command);
		}
	}
	
	private delegate string? command (string name, string[] args);











	public class Commands : Object {
	
		private HashMap <string, AbstractCommand> c;
		
		private HashMap <string, string> vars;
		bool raw = false;
		
		private HashMap <string, string> begins;
		private HashMap <string, string> begin_extra;
		private HashMap <string, string> ends;
		
		public Commands () {
			this.c = new HashMap <string, AbstractCommand> ();
			this.vars = new HashMap <string, string> ();
			this.begins = new HashMap <string, string> ();
			this.begin_extra = new HashMap <string, string> ();
			this.ends = new HashMap <string, string> ();
			
			this.vars ["paragraph"] = "\n\n";
			
			this.c ["\\newcommand"] = new SingleCommand (this.add_command);
			this.c ["\\renewcommand"] = new SingleCommand (this.set_command);
			
			this.c ["\\set"] = new SingleCommand ((name, args) => {
			    this.vars [args[0]] = args [1];
			    return "";
			});
			
			this.c ["\\get"] = new SingleCommand ((name, args) => {
				if (!this.vars.has_key (args[0])) {
					stderr.printf ("variable %s was never defined! (in %s)\n", args[0], name);
					return "";
				}
			    return this.vars [args[0]];
			});
			
			this.c ["\\tag"] = new SingleCommand ((name, args) => {
				if (args.length == 1) return "<%s></%s>".printf (args[0], args[0]);
			    return "<%s>%s</%s>".printf (args[0], parse_level (args[1]), args[0]);
			});
			this.c ["\\openingtag"] = new SingleCommand ((name, args) => {
			    return "<%s>".printf (args[0]);
			});
			this.c ["\\closingtag"] = new SingleCommand ((name, args) => {
			    return "</%s>".printf (args[0]);
			});
			
			this.c ["\\documentclass"] = new SingleCommand ((name, args) => {
				this.include_path ("%s.documentclass".printf (args[0]), true);
				return "";
			});
			
			this.c ["\\newenv"] = new SingleCommand ((name, args) => {
				this.begins [args[0]] = args[1];
				this.ends [args[0]] = args[2];
				if (args.length == 4) this.begin_extra[args[0]] = args[3];
				return "";
			});
			
			this.c ["\\begin"] = new SingleCommand ((name, args) => {
				string test = parse_level (this.begins [args[0]]);
				if (this.begin_extra.has_key (args[0])) return "%s%s".printf (test, parse_level (this.begin_extra[args[0]]));
				return test;
			});
			
			this.c ["\\end"] = new SingleCommand ((name, args) => {
				return parse_level (this.ends [args[0]]);
			});
			
			this.c ["\\include"] = new SingleCommand ((name, args) => {
				return this.include_path (args[0].slice (1, args[0].length-1));
			});
			
			this.c ["\\includelinked"] = new SingleCommand ((name, args) => {
				Printer p;
				Commands c = new Commands ();
				p = new Printer.from_path (args[0], c, get_target_file (args[0]));
				p.run (true, null);
				return this.include_path ("%s%s".printf(get_prefix (args[0]),"description.aux"), true);
			});
			
			this.c ["\\writefile"] = new SingleCommand ((name, args) => {
				try {
					var file_out = File.new_for_path (get_prefix (this.vars["$source"]) + args[0]);

					// delete if the file already exists
					if (file_out.query_exists ()) {
						file_out.delete ();
					}
			
					DataOutputStream out_stream = new DataOutputStream (file_out.create (FileCreateFlags.REPLACE_DESTINATION));
					out_stream.put_string (parse_level (args[1]));
				} catch (Error e) {
					stderr.printf ("%s\n", e.message);
			
				}
				return "";
			});
			
		}
		
		public void set_vars (string source, string? target) {
			if (!this.vars.has_key ("$source")) this.vars ["$source"] = source;
			if (!this.vars.has_key ("$target")) this.vars ["$target"] = target;
		}
		
		private string? add_command (string name, string [] args) {
			if (this.c.has_key (args[0])) {
				stderr.printf ("Error: command %s is already definied.\n", args[0]);
				Posix.exit (1);
			}
			return this.set_command (name, args);
		}
		
		private string? set_command (string name, string [] args) {
			this.c [args[0]] = new CustomCommand (args, this);
			
			return "";
		}
		
		private string include_path (string path, bool pass_on = false, bool write = false) {
			Printer p;
			if (pass_on)
				p = new Printer.from_path (path, this);
			else
				p = new Printer.from_path (path, null);
			string markup;
			p.run (write, out markup);
			return markup;
		}
		
		public bool is_defined (string name) {
			return this.c.has_key (name);
		}
		
		public bool is_recursive (string name) {
		    return !(name == "\\newcommand" || name == "\\newenv");
		}
		
		public string execute (string name, string[] args) {
			return this.c[name].execute (name, args);
		}
		
		
	    public string? parse_level (string input) {
	    	if (this.raw) {
	    		string[] l = input.split ("\\endraw");
	    		if (l.length == 2) {
	    			this.raw = false;
	    			return "%s%s".printf (l[0], this.parse_level (l[1]));
	    		}
	    		return input;
	    	}
		    string output = "";
		
		    MatchInfo m;
		    Patterns.COMMAND.match (input, 0, out m);
		
		    int p = 0;
		    if (m.fetch(0) != null) {
			    do {
				    int start, end;
				    m.fetch_pos (0, out start, out end);
				    if (!this.raw) {
					    output += m.get_string().slice (p, start).replace ("\n\n", this.vars["paragraph"]);
				    	output += parse_command (m.fetch (0));
			    	} else {
			    		string text = m.get_string().slice (p, m.get_string().length);
			    		string[] l = text.split ("\\endraw", 2);
			    		if (l.length>1) {
			    			this.raw = false;
			    			return "%s%s%s".printf (output, l[0], this.parse_level (l[1]));
			    		}
			    		return text;
			    	}
				    p = end;
			    }
			    while (m.next ());
				output += m.get_string().slice (p, m.get_string().length).replace ("\n\n", this.vars["paragraph"]);
		    } else {
			    output = input;
		    }
		
		    return output;
	    }

	    private string? parse_command (string command) {
	
		    MatchInfo m;
		    Patterns.COMMAND_NAME.match (command, 0, out m);
		
		    string name = m.fetch (0);
		
		    if (name == "\\raw") {
		    	this.raw = true;
		    	return "";
		    }
		
		    if (!this.is_defined (name)) {
			    stderr.printf ("command %s was never defined\n", name);
			    Posix.exit (1);
			    return "";
		    }
		    
		    
		    string[] args;
		    if (this.is_recursive (name))
		        args = get_arguments (command);
	        else
	            args = get_raw_arguments (command);
		    return this.execute (name, args);

	    }
	    
        
        string [] get_raw_arguments (string command) {
            string[] ret = new string [0];
		
		    MatchInfo m;
		    Patterns.SINGLE_ARGUMENT.match (command, 0, out m);
		
		    if (m.fetch(0) == null) return ret;
		    do {
		        ret += m.fetch(0).slice (1, m.fetch(0).length-1);
		    } while (m.next ());
		
		
		    return ret;
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
	
	
}

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
			return this.commands.parse_level (this.argslist[1]);
		}
	}
	
	private delegate string? command (string name, string[] args);











	public class Commands : Object {
	
		private HashMap <string, AbstractCommand> c;
		
		private HashMap <string, string> vars;
		
		public Commands () {
			this.c = new HashMap <string, AbstractCommand> ();
			this.vars = new HashMap <string, string> ();
			
			this.c ["\\emph"] = new SingleCommand ((name, args) => {
				return "<em>%s</em>".printf (args[0]);
			});
		
			this.c ["\\newcommand"] = new SingleCommand (this.add_command);
			
			this.c ["\\set"] = new SingleCommand ((name, args) => {
			    this.vars [args[0]] = args [1];
			    return "";
			});
			
			this.c ["\\title"] = new SingleCommand ((name, args) => {
			    this.vars ["title"] = args[0];
			    return "";
			});
			
			this.c ["\\get"] = new SingleCommand ((name, args) => {
			    return this.vars [args[0]];
			});
			
			this.c ["\\tag"] = new SingleCommand ((name, args) => {
			    return "<%s>%s</%s>".printf (args[0], parse_level (args[1]), args[0]);
			});
		}
		
		private string? add_command (string name, string [] args) {
			if (this.c.has_key (args[0])) {
				stderr.printf ("Error: command %s is already definied.\n", name);
				return null;
			}
			this.c [args[0]] = new CustomCommand (args, this);
			
			return "";
		}
		
		public bool is_defined (string name) {
			return this.c.has_key (name);
		}
		
		public bool is_recursive (string name) {
		    return !(name == "\\newcommand");
		}
		
		public string execute (string name, string[] args) {
			return this.c[name].execute (name, args);
		}
		
		
	    public string? parse_level (string input) {
	
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
		
		
		    if (!this.is_defined (name)) {
			    //stderr.printf ("command %s was never defined\n", name);
			    //Posix.exit (1);
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

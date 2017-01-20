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
		
		public CustomCommand (string[] args) {
			this.argslist = args;
			stdout.printf ("creating new command, will print out %s\n", args[1]);
		}
		
		public override string? execute (string name, string[] args) {
			return this.argslist[1];
		}
	}
	
	private delegate string? command (string name, string[] args);

	public class Commands : Object {
	
		private HashMap <string, AbstractCommand> c;
		
		public Commands () {
			this.c = new HashMap <string, AbstractCommand> ();
			
			this.c ["\\emph"] = new SingleCommand ((name, args) => {
				return "<em>%s</em>".printf (args[0]);
			});
		
			this.c ["\\newcommand"] = new SingleCommand (this.add_command);
		}
		
		private string? add_command (string name, string [] args) {
			if (this.c.has_key (args[0])) {
				stderr.printf ("Error: command %s is already definied.\n", name);
				return null;
			}
			this.c [args[0]] = new CustomCommand (args);
			
			return "";
		}
		
		public bool is_defined (string name) {
			return this.c.has_key (name);
		}
		
		public string execute (string name, string[] args) {
			return this.c[name].execute (name, args);
		}
	
	}
	
	
}

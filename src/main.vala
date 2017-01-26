using Teleprinter;

int main (string[] argv) {
	
	if (argv.length != 2) {
		stderr.printf ("This program takes exactly one argument!\n");
		return 1;
	}

	Patterns.init ();
	
	Commands c = new Commands ();
	
	Printer p = new Printer.from_path (argv[1], c, get_target_file (argv[1]));
	p.run (true);
	
	return 0;
}

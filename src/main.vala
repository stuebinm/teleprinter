using Teleprinter;

int main (string[] argv) {
	
	if (argv.length != 2) {
		stderr.printf ("This program takes exactly one argument!\n");
		return 1;
	}

	Patterns.init ();

	Printer p = new Printer.from_path (argv[1], "output.html");
	p.run ();
	
	return 0;
}

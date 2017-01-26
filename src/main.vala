/* Copyright 2017 Matthias Stübinger
*
* This file is part of teleprinter.
*
* This program is free software: you can redistribute it
* and/or modify it under the terms of the GNU General Public License as
* published by the Free Software Foundation, either version 3 of the
* License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be
* useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
* Public License for more details.
*
* You should have received a copy of the GNU General Public License along
* with this program. If not, see http://www.gnu.org/licenses/.
*
*/

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

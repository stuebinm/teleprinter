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

public class Feed : Object {

	public string feed {public get; private set; default = "";}
	private string target;
	public static int id = 0;
	
	public Feed (string target) {
		this.target = target;
	}
	
	public void append (string title, string summary, string link) {
		this.feed += """<entry>
		<id>%d</id>
		<title type="html"><![CDATA[%s]]></title>
		<summary type="html"><![CDATA[%s]]></summary>
		<author>stuebinm</author>
		<link href="%s" />
		</entry>""".printf (id, title, summary, link);
		id++;
	}
	
	public void run () {
		try {
			var file_out = File.new_for_path (this.target);

			// delete if the file already exists
			if (file_out.query_exists ()) {
				file_out.delete ();
			}
		
			DataOutputStream out_stream = new DataOutputStream (file_out.create (FileCreateFlags.REPLACE_DESTINATION));
			out_stream.put_string ("""<?xml version="1.0" encoding="utf-8"?>
			<feed xmlns="http://www.w3.org/2005/Atom"
			 xmlns:dc="http://purl.org/dc/elements/1.1/"
			 xml:lang="de">
				<title type="html">~stuebinm</title>
				<link type="text/html" href="http://www.in.tum.de/~stuebinm/"/>
				<id>~stuebinm</id>
				%s
			</feed>
			""".printf (this.feed));
		} catch (Error e) {
			stderr.printf ("%s\n", e.message);
		
		}
	}


}


Regex command_reg;
Regex c_name_reg;
string title;

Gee.HashMap <string, env> envs;
Regex c_args_reg;
const string styles = """
	<style>
    @font-face {
        font-family: "CM Bold";
        src: url("fonts/cmunbmr.ttf");
      font-weight: normal; 
      font-style: normal;
    }
    @font-face {
        font-family: "CM Serif";
        src: url("fonts/cmunrm.ttf");
      font-weight: normal; 
      font-style: normal;
    }
    @font-face {
        font-family: "CM Typewriter";
        src: url("fonts/cmunorm.ttf");
      font-weight: italic; 
      font-style: normal;
    }
    .initial {
      float: left;
      padding: 0.27em 5px 0 0;
      font-size: 340%;
      font-weight: bold;
      line-height: 0.5;
    }
    .box-top {
      position: relative;
      width: 100%;
      background-color: #ddd;
      border: 1px solid #444;
      text-align: center;
    }
    .box-main {
      position: relative;
      width: 100%;
      background-color: #fff;
      border: 1px solid #444;
      border-top-style: none;
      text-align: justify;
    }
    .text {
      font-family: "CM Serif";
      line-height: 1.5;
      font-size: 12pt;
      color: #111;
      padding: 2vw; 
    }
    .box-header {
      top: 0px;
      left: 0px;
      position: absolute;
      margin-top: 0px;
      margin: auto;
      width: 100%;     
      z-index: 999;
      font-family: "CM Typewriter";
      line-height: 1.5;
      color: #111;
      
      padding-top: 13px;
      font-weight: normal; 
      font-style: normal; 
      background-color: white;
      border-bottom: 1px solid #444;
      border-top-style: none;
      text-align: center;
    }
    .header-title {
      font-size: 20pt;
    }
    .header-quote {
      font-size: 15pt;
      color: #333;
      margin-left: 2vw;
      margin-right: 2vw;
    }
    .title {
        font-size: 8vh;
        color: #111; 
        font-family: "CM Bold";
        font-weight: normal;
        margin-top: 2vh;
        margin-bottom: 2vh;
        margin-left: 1vw;
        margin-right: 1vw;
    }
    .content {
        margin-top: 30vh;
        margin-bottom: 20vh;
        margin-left: auto;
        margin-right: auto;
        width: 250mm;
        max-width: 98%;
        background-color: black;
    }
    .background {
        z-index: -10;
        position: fixed;
        top: 0vh;
        left: 0vw;
        width: 100%;
        height: 100%;
        background-image: url("background.png");
    }
    .link {
    	color: blue;
    	text-decoration: none;
    }
    .frame {
    	max-width:100%;
    	border: 1px solid #444;
    }
  </style>
	""";
string? parse_level (string input) {
    
    string output = "";
    
    MatchInfo m;
    command_reg.match (input, 0, out m);
    
    int p = 0;
    do {
        int start, end;
        m.fetch_pos (0, out start, out end);
        output += m.get_string().slice (p, start);
        p = end;
        output += parse_command (m.fetch (0));
    }
    while (m.next ());
    
    return output;
}

string? parse_command (string command) {

    MatchInfo m;
    c_name_reg.match (command, 0, out m);
    
    string name = m.fetch (0);
    
    
    switch (name) {
    case "\\begin":
            string arg = remove_whitespace (get_single_argument (command));
    
    if (!envs.has_key (arg)) {
         stderr.printf ("Unknown environment '%s'.\n", arg);
         return null;
    }
    return envs[arg].begin;
    case "\\end":
            string arg = remove_whitespace (get_single_argument (command));
    
    if (!envs.has_key (arg)) {
         stderr.printf ("Unknown environment '%s'.\n", arg);
         return null;
    }
    return envs[arg].end;
    case "\\emph":
            return "<em>%s</em>".printf (get_single_argument (command));

    case "\\title":
            string arg = get_single_argument (command);
    title = arg;
    return "";
    case "\\maketitle":
            return """
    <div class="box-top">
       <div class="title">
         %s
       </div>
    </div>
    <div class="box-main">
    <div class="text">
    """.printf (title);
    case "\\hr":
        return """
	</p>
    </div>
    </div>
    <div class="box-main">
    <div class="text">
    <p>
""";
    case "\\documentclass":
        
	return "";
    case "\\image":
    	string source = get_single_argument (command);
return "%s%s%s".printf("""</p><img src="""", source, """" class="frame"><p align=justify>""");
	case "\\raw":
			return """</p>""";
	case "\\text":
			return """<p align="justify">""";
	case "\\enquote":
			string text = get_single_argument (command);
	return "%s%s%s".printf ("""&ldquo;""", text, """&rdquo;""");
	case "\\link":
			string[] text = get_arguments (command);
	return "<a href=\"%s\" class=\"link\">%s</a>".printf (text[1], text[0]);
	case "\\center":
			string text = get_single_argument (command);
	return """</p><p align="center">""";
    default:
            stderr.printf ("undefined command '%s'!\n", name);
    return null;
}
    
    return null;

}
class env {
    public string begin;
    public string end;
}

env new_env (string begin, string end) {
    env ret = new env ();
    ret.begin = begin;
    ret.end = end;
    return ret;
}

string[] get_arguments (string command) {
    string[] ret = new string [0];
    
    MatchInfo m;
    c_args_reg.match (command, 0, out m);
    
    do {
        ret += (/(\{|\})/).replace (m.fetch (0), -1, 0, "");
    } while (m.next ());
    
    
    return ret;
}

string get_single_argument (string command) {
    string[] args = get_arguments (command);
    
    if (args.length != 1) {
        args_error (command, 1);
    }
    return args[0];
}

string remove_whitespace (string input) {
    return (/\s/).replace (input, -1, 0, "");
}
void args_error (string command, int number, int found=0) {
    stderr.printf ("%s takes exactly %d arguments, not %d!\n", command, number, found);
}

int main (string[] argv) {
    string input = "";
    		if (argv.length != 2) {
		stderr.printf ("this programm takes exactly one input file!\n");
		return 1;
	}
    File finput = File.new_for_path (argv[1]);
        if (!finput.query_exists ()) {
        stderr.printf ("Input doesn't exist!\n");
        return 1;
    }
    
    try {
            var dis = new DataInputStream (finput.read ());
    string line;
    // Read lines until end of file (null) is reached
    while ((line = dis.read_line (null)) != null) {
        input += "%s\n".printf (line);
    }
    } catch {
        stderr.printf ("File Error");
        return 1; // again, terminate in case of error
    }
    
    
    command_reg = /\\(\w*)\b(\s*{((?R)|.*)})*/;
c_name_reg = /\\\w*\b/;
title = "";

stdout.printf ("test\n");
envs = new Gee.HashMap <string ,env> ();


envs["document"] = new_env ("%s\n%s\n%s".printf("""
      <html>
      	<head> 
      	<title>~stuebinm</title>""",
      	styles,
      	"""</head>
        <body>
        <div class="background">
    </div>
  
    <header class="box-header">
        <div class="header-title">
        /~stuebinm
        </div>
        <div class="header-quote">
        &ldquo;Beware of bugs in the above code; I have only proved it correct, not tried it.&rdquo; &mdash; D. E. Knuth
        </div>
    </header>
  
          <div class="content"> <p>
    """), 
    """
    		  </p>
            </div>
          </div>
        </body>
      </html>
    """);


c_args_reg = /(?<arg> (\{)([^{}]+|(?&arg))*(\}))/;
    
    
    
    string output;
        
    output = parse_level (input);
    if (output == null) {
        stderr.printf ("Errors occured!\n");
    }

    
    
        string filename;
    
    string[] temp = argv[1].split(".");
    filename = "%s.html".printf (temp[0]);
    
    try {
        var file_out = File.new_for_path (filename);

        // delete if the file already exists
        if (file_out.query_exists ()) {
            file_out.delete ();
        }
        
        var dos = new DataOutputStream (file_out.create (FileCreateFlags.REPLACE_DESTINATION));
        
        dos.put_string (output); // put the whole thing out
        
    } catch (Error e) {
        stderr.printf ("%s\n", e.message);
        return 1; // this would be a file error, ergo error code 1.
    }
    
    return 0;
}
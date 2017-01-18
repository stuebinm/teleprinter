
Regex command_reg;
Regex c_name_reg;string title;
Gee.HashMap <string, env> envs;Regex c_args_reg;
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
    
    stdout.printf ("%s\n", name);
    
    switch (name) {
    case "\\begin":
            string arg = remove_whitespace (get_single_argument (command));
    
    if (!envs.has_key (arg)) {
         stderr.printf ("Unknown environment '%s'.\n", arg);
         return null;
    }
    return envs[arg].begin;
        break;
    case "\\end":
            string arg = remove_whitespace (get_single_argument (command));
    
    if (!envs.has_key (arg)) {
         stderr.printf ("Unknown environment '%s'.\n", arg);
         return null;
    }
    return envs[arg].end;
        break;
    case "\\emph":
            return "<em>%s</em>".printf (get_single_argument (command));

        break;
    case "\\title":
            string arg = get_single_argument (command);
    title = arg;
        break;
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
        break;
    case "\\hr":
        return """
    </div>
    </div>
    <div class="box-main">
    <div class="text">
""";
        break;
    case "\\documentclass":
        

        break;
    default:
            stderr.printf ("undefined command '%s'!\n", name);
    return null;
}
    
    return null;

}class env {
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
        args_error ("\\emph", 1);
    }
    return args[0];
}

string remove_whitespace (string input) {
    return (/\s/).replace (input, -1, 0, "");
}void args_error (string command, int number, int found=0) {
    stderr.printf ("%s takes exactly %d arguments, not %d!\n", command, number, found);
}

int main (string[] argv) {
    string input;
        input = """\documentclass {post}


\title {Post 1}


\begin {document}

\maketitle

This is just some basic text, diplaying the possibilies that I want implemented.

\emph {For example, {emphasised} text.}{and other text}

\hr

Or horizontal rulers.


\end {document}

""";
    
    command_reg = /\\\w*\b(\s*{((?R)|.*)})*/;
c_name_reg = /\\\w*\b/;title = "";
stdout.printf ("test\n");
envs = new Gee.HashMap <string ,env> ();


envs["document"] = new_env ("""
      <html>
        <body>
          <div class="content">
    """, 
    """
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

    
    stdout.printf ("%s\n", output);
    
    return 0;
}
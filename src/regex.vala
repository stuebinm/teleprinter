
namespace Teleprinter {

	namespace Patterns {

		Regex COMMAND;
		Regex SINGLE_ARGUMENT;
		Regex COMMAND_NAME;
		
		public void init () {
			COMMAND = /\\(\w*)\b(\s*{((?R)|.*)})*/;
			SINGLE_ARGUMENT = /(?<arg>(\{)([^{}]+|(?&arg))*(\}))/;
			COMMAND_NAME = /\\\w*\b/;
		}

	}

}

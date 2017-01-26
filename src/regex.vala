
namespace Teleprinter {

	namespace Patterns {

		Regex COMMAND;
		Regex SINGLE_ARGUMENT;
		Regex COMMAND_NAME;
		
		public void init () {
			COMMAND = /\\(\w+)(\s*{((?R)|((\\raw)(.|\n)*(\\endraw))|[^{}]*)*})*/;
			SINGLE_ARGUMENT = /(\{)([^{}]*|((\\raw)(.|\n)*(\\endraw))|\\(\w+)(\s*{((?R)|((\\raw)(.|\n)*(\\endraw))|[^{}]*)*})*)*(\})/;
			COMMAND_NAME = /\\\w*\b/;
		}

	}

}

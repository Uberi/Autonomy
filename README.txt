A lexer, parser, and interpreter for the AutoHotkey scripting language.


Status:

Error Handler:     WORKING
Lexer:             WORKING
Parser:            PENDING
Bytecode:          PENDING
Interpreter:       PENDING

Currently the lexer is in a working state, but as of now is not very useful on its own without the parser and interpreter. Error handler is fully working, but depends on other modules to actually detect the errors.

Goal: To create a set of basic tools for the AutoHotkey language that will enable the creation of code-modifying tools. Examples of these include code minifiers, code tidying and reformatting tools, translators to other languages, and eventually, a self hosting compiler.


Modules:

Get Error.ahk:   Implements error formatting. Can display line and column information, underline code causing the error, and point out a specific character.

Lexer.ahk:       Implements the tokenization of the raw source code given as input. Outputs a token array.

Parser.ahk:      Not yet implemented. Will parse a token array given as input and output an abstract syntax tree, and perform optimisations and tree transformations as well.

Bytecode.ahk:    Not yet implemented. Will accept an abstract syntax tree given as input and output a bytecode format suitable for interpretation or compilation.

Interpreter.ahk: Not yet implemented. Will execute bytecode given as input.
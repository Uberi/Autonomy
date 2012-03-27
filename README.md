Autonomy
========
A programming language inspired by AutoHotkey.

Progress
--------

| Module        | Status         |
|:--------------|:---------------|
| Lexer         | Working        |
| Preprocessor  | On Hold        |
| Parser        | Mostly Working |
| Simplifier    | Working        |
| Bytecode      | Mostly Working |
| Flow Graph    | In Progress    |
| Interpreter   | Pending        |
| Error Handler | Working        |

Currently running on top of AutoHotkey until the implementation is self hosting.


Goal
----

To create a set of basic tools for the AutoHotkey language that will enable the creation of code-modifying tools. Examples of these include code minifiers, code tidying and reformatting tools, translators to other languages, and eventually, a self hosting compiler.


Modules
-------

| Module                    | Function                                                     |
|:--------------------------|:-------------------------------------------------------------|
| Code.ahk                  | Initialization routines.                                     |
| Lexer.ahk                 | Tokenizes source code, outputting a token stream.            |
| Preprocessor.ahk          | Preprocesses a token stream.                                 |
| Parser.ahk                | Parses a token stream into a syntax tree.                    |
| Simplifier.ahk            | Simplifies a syntax tree.                                    |
| Bytecode.ahk              | Converts a syntax tree to bytecode.                          |
| Interpreter.ahk           | Executes bytecode.                                           |
| Resources/Get Error.ahk   | Formats error records into a human readable form.            |
| Resources/Functions.ahk   | Provides utility functions.                                  |
| Resources/Reconstruct.ahk | Reconstructs source code from token streams or syntax trees. |
| Resources/Operators.ahk   | Describes the language syntax for the lexer and parser.      |
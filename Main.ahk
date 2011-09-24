#NoEnv

/*
Copyright 2011 Anthony Zhang <azhang9@gmail.com>

This file is part of Autonomy. Source code is available at <https://github.com/Uberi/Autonomy>.

Autonomy is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#Warn All
#Warn LocalSameAsGlobal, Off

SetBatchLines(-1)

#Include Resources\Functions.ahk
#Include Resources\Get Error.ahk
#Include Resources\Reconstruct.ahk

#Include Code.ahk
#Include Lexer.ahk
#Include Preprocessor.ahk
#Include Parser.ahk

/*
TODO
----

Short term tasks:

* Duplicate LINE_END tokens can be present if there was an error that spanned an entire line. see Strings.txt unit test for example. see if this can be avoided
* Remove all label functionality and Gosub and Goto, add Statements.txt unit test with literal statements
* Escaping the end of a line with a backtick may result in an incorrect length for the token. need to add a length field for each token
* Preprocessor macros and a UNIQUE_SYMBOL macro defined by default that allows unnamed functions
* Syntax tree operator enumeration
* Hex and unicode escapes: "`cNN" or "`c[NN]" or `c[NNNN] or `c[NNNNNNNN], where N is a hex digit representing an ANSI or unicode offset
* Unit tests for error handler
* Error identifier enumeration
* Read mk:@MSITStore:C:\Program%20Files\AutoHotkey\AutoHotkey_L\AutoHotkey_L.chm::/docs/misc/Performance.htm

Long term tasks:

* Support a command syntax, that is translated to a function call on load (dotted notation only - no square brackets support). Detect this form in the parser by making sure the token is immediately after an opening parenthesis, opening square bracket, block brace, or line end, and the token after the function is either a literal, an identifier, a separator, an operator that doesn't take a parameter on its left, a block brace, or a line end: Math.Mod, 100, 5
* Warn if Return, Break, Continue, Goto are not the last statements in a block
* AST support for lambdas as operations, probably with generated names as the operation
* After the command syntax is implemented, the STATEMENT token type should be used only for literal statements, as the parser can now detect statements, fixing currently broken cases like the assignment "Else := Variable"
* Base object should not be enumerable or findable by ObjHasKey()
* Primitive type methods through augmentation: "".base.Trim := Trim ... "  test  ".Trim()
* Namespaces and the ability to define custom ones
* Script that converts AutoHotkey code to Autonomy
* Function definitions are variables holding function references (implemented as function pointers, and utilising reference counting), so variables and functions are in the same namespace
* Make implementation self hosting
* Scope info should be attached to each variable
* Library in non-annotated parse tree format; allows libraries to avoid recompilation each time by using a linker. Libraries cannot be in bytecode because of the type inferencer, unless each function in the library is changed to allow any type of argument at all, and then it would not have very good type checking or performance
* Multipass compilation by saving passes to file: Source files are *.ato, tokenized is *.att, parsed is *.ats, annotated is *.ata, bytecode is *.atc. this would also allow the preprocessor and etc. to not have to re-lex included files every time a script uses them
* Incremental parser and lexer for IDE use, have object mapping line numbers to token indexes, have parser save state at intervals, lex changed lines only, restore parser state to the saved state right before the token index of the changed token, keep parsing to the end of the file
* Lua-like _global[] and _local[] (_G[] in Lua) mechanism to replace dynamic variables. Afterwards remove dynamic variable functionality and make % the modulo or format string operator, and add the in place %= operator as well
* "local" keyword works on current block, instead of current function, and can make block assume-local: If Something { local SomeVar := "Test" } ;SomeVar is freed after the If block goes out of scope
*/

FileName := A_ScriptFullPath ;set the file name of the current file

Code = 
(
#Define SOME_DEFINITION := 1 + 2 * 3
Var := Something
#Define ANOTHER_DEFINITION := SOME_DEFINITION + 1
Return,, 1 + 1
)

;Code := "4-(2+4)*-5"

If CodeInit()
{
 Display("Error initializing code tools.`n") ;display error at standard output
 ExitApp(1) ;fatal error
}

CodeSetScript(FileName,Errors,Files) ;set the current script file

CodeLexInit()
CodeLex(Code,Tokens,Errors)
;DisplayObject(Tokens)
MsgBox % Clipboard := CodeReconstructShowTokens(Tokens)

CodePreprocessInit(Files)
CodePreprocess(Tokens,ProcessedTokens,Errors,Files)
DisplayObject(ProcessedTokens)
;MsgBox % Clipboard := CodeGetError(Code,Errors,Files)
DisplayObject(Errors)

CodeParseInit()
CodeParse(ProcessedTokens,SyntaxTree,Errors)
DisplayObject(SyntaxTree)

If (ObjMaxIndex(Errors) != "")
 Display(CodeGetError(Code,Errors,Files)) ;display error at standard output

;DisplayObject(SyntaxTree)
;MsgBox % CodeRecontructSyntaxTree(SyntaxTree)

ExitApp()
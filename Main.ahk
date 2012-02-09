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

SetBatchLines, -1

/*
TODO
----

Short term tasks:

* Remove prefix ++ operator and make the postfix version behave as the prefix does does now
* Allow backticks inline in code to represent literal versions of themselves in the code
* Support a command syntax, that is translated to a function call on load: Math.Mod 100, 5 or Web["HTTP"] "google.ca", "search". Also allow this for function definitions and anywhere parens can be used
* Operations in syntax tree do not have position or length or file info
* Duplicate LINE_END tokens can be present if there was an error that spanned an entire line. see Strings.txt unit test for example. see if this can be avoided
* Escaping the end of a line with a backtick may result in an incorrect length for the token. need to add a length field for each token
* Hex and unicode escapes: "`cNN" or "`c[NN]" or `c[NNNN] or `c[NNNNNNNN], where N is a hex digit representing a unicode offset
* Handle escapes in the lexer
* Warn if Return, Break, Continue, Goto are not the last statements in a block
* Unit tests for error handler

Long term tasks:

* gensym() compile-time function - generates a unique identifier
* "ensure" blocks allow code to be statically verified
* "switch" statement, without fallthrough, but allowing multiple possible arbitrary expressions per case, possibly comma separated?
* "with" statement, allowing a resource like a file to be unconditionally released regardless of how the statement block was exited
* Exceptions with try/catch/throw and "continue" in catch blocks
* Dynamic default values for optional function parameters: SomeFunction(Param := 2 * 8 + GlobalVar) { Function body here }
* macro { some compile-time related code } syntax and compile time defined type system
* After the command syntax is implemented, the STATEMENT token type should be used only for literal statements, as the parser can now detect statements, fixing currently broken cases like the assignment "Else := Variable"
* Base object should not be enumerable or findable by ObjHasKey()
* Primitive type methods through augmentation: String.Trim := Trim OR "".base.Trim := Trim ... "  test  ".Trim()
* Namespaces and the ability to define custom ones
* Script that converts AutoHotkey code to or from Autonomy
* Function definitions are variables holding function references (implemented as function pointers, and utilising reference counting), so variables and functions are in the same namespace
* Make implementation self hosting
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
Code =
(
abc param1, param2
def param1 + sin 45
!ghi + 5 * jkl 123, 456
)

;Code := "4-(2+4)*-5"

If CodeInit()
{
    Display("Error initializing code tools.`n") ;display error at standard output
    ExitApp ;fatal error
}

CodeSetScript(FileName,Errors,Files) ;set the current script file

CodeLexInit()
Tokens := CodeLex(Code,Errors)
MsgBox % Clipboard := CodeReconstructShowTokens(Tokens)

CodePreprocessInit(Files)
CodePreprocess(Tokens,ProcessedTokens,Errors,Files)
;MsgBox % Clipboard := CodeErrorFormat(Code,Errors,Files)

CodeTreeInit()
SyntaxTree := CodeParse(ProcessedTokens,Errors)
MsgBox % Clipboard := CodeReconstructShowSyntaxTree(SyntaxTree)

SimplifiedSyntaxTree := CodeSimplify(SyntaxTree)
MsgBox % Clipboard := CodeReconstructShowSyntaxTree(SimplifiedSyntaxTree)

Bytecode := CodeBytecode(SimplifiedSyntaxTree)
MsgBox % Clipboard := Bytecode

If (ObjMaxIndex(Errors) != "")
    Display(CodeErrorFormat(Code,Errors,Files)) ;display error at standard output

;DisplayObject(SyntaxTree)
;MsgBox % CodeRecontructSyntaxTree(SyntaxTree)

ExitApp

#Include Resources\Error Format.ahk
#Include Resources\Reconstruct.ahk

#Include Code.ahk
#Include Lexer.ahk
#Include Preprocessor.ahk
#Include Parser.ahk
#Include Simplifier.ahk
#Include Bytecode.ahk
#NoEnv

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

* Make literal statements handle comments
* Have more strings configurable in the lexer
* Hex escapes: "`xNN", where NN is a sequence of hex digits
* Unit tests for error handler
* Error identifier enumeration
* Make syntax tree types an enumeration
* Read mk:@MSITStore:C:\Program%20Files\AutoHotkey\AutoHotkey_L\AutoHotkey_L.chm::/docs/misc/Performance.htm
* Rewrite parser with TDOP/Pratt/Precedence Climbing parsing algorithm. Remove operator table if not needed afterwards

Long term tasks:

* Support a command syntax, that is translated to a function call on load (dotted notation only - no square brackets support). Detect this form in the parser by making sure the token is immediately after an opening parenthesis, opening square bracket, block brace, or line end, and the token after the function is either a literal, an identifier, a separator, an operator that doesn't take a parameter on its left, a block brace, or a line end: Math.Mod, 100, 5
* After the command syntax is implemented, remove the STATEMENT token type (as the parser can now detect statements, fixing currently broken cases like the assignment "Else := Variable"), and change it to the DIRECTIVE token type, for preprocessor directives only
* Script that converts AutoHotkey code to Autonomy
* Function definitions are variables holding function references (implemented as function pointers, and utilising reference counting), so variables and functions are in the same namespace
* Static tail call detection
* Make implementation self hosting and change the code to conform to the changed syntax
* Scope and info should be attached to each variable
* Incremental parser and lexer for IDE use, have object mapping line numbers to token indexes, have parser save state at intervals, lex changed lines only, restore parser state to the saved state right before the token index of the changed token, keep parsing to the end of the file
* Lua-like _global[] and _local[] (_G[] in Lua) mechanism to replace dynamic variables. Afterwards remove dynamic variable functionality and make % the modulo or format string operator with less precedence than it has now
* "local" keyword works on current block, instead of current function, and can make block assume-local: If Something { local SomeVar := "Test" } ;SomeVar is freed after the If block goes out of scope
* Distinct Array type using contingous memory, faster than Object hash table implementation
*/

FileName := A_ScriptFullPath ;set the file name of the current file

Code = 
(
#Define SOME_DEFINITION := 1 + 2 * 3
Var := Something
#Define ANOTHER_DEFINITION := SOME_DEFINITION + 1
Return, 1 + 1
)

Code := "4-(2+4)*-5"

If CodeInit()
{
 Display("Error initializing code tools.`n") ;display error at standard output
 ExitApp(1) ;fatal error
}

CodeSetScript(FileName,Errors,Files) ;set the current script file

CodeLexInit()
CodeLex(Code,Tokens,Errors)
DisplayObject(Tokens)

CodePreprocessInit(Files)
CodePreprocess(Tokens,ProcessedTokens,Errors,Files)
DisplayObject(ProcessedTokens)
;MsgBox % Clipboard := CodeGetError(Code,Errors,Files)
DisplayObject(Errors)

CodeParseInit()
CodeParse(ProcessedTokens,SyntaxTree,Errors)
;DisplayObject(SyntaxTree)

If (ObjMaxIndex(Errors) != "")
 Display(CodeGetError(Code,Errors,Files)) ;display error at standard output

;DisplayObject(SyntaxTree)
;MsgBox % CodeRecontructSyntaxTree(SyntaxTree)

ExitApp()
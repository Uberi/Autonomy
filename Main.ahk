#NoEnv

;#Warn All

SetBatchLines(-1)

#Include Resources\Functions.ahk
#Include Resources\Get Error.ahk
#Include Resources\Reconstruct.ahk

#Include Code.ahk
#Include Lexer.ahk
#Include Parser.ahk

/*
TODO
----

* Rewrite parser to not use shunting yard algorithm anymore, it's becoming a big, hackish mess. Look into TDOP/Pratt parser instead
* Ternary operator should be added to operator table
* Process directives in lexer
* Support a command syntax, that is translated to a function call on load: Math.Mod, 100, 5
*
* Scope info should be attached to each variable
* "local" keyword works on current block, instead of current function, and can make block assume-local: If Something { local SomeVar := "Test" } ;SomeVar is freed after the If block goes out of scope
* Function definitions are variables holding function references (implemented as function pointers, and utilising reference counting), so variables and functions are in the same namespace
* Static tail call detection
* Incremental parser and lexer for IDE use, have object mapping line numbers to token indexes, have parser save state at intervals, lex changed lines only, restore parser state the saved state right before the token index of the changed token, keep parsing to the end of the file
*/

Code = 
(
Var := Something
Return, 1 + 1
)

Code := "a + !b * (1 + 3)"

If CodeInit()
{
 Display("Error initializing code tools.`n") ;display error at standard output
 ExitApp(1)
}

CodeLexInit()
If CodeLex(Code,Tokens,Errors,Files,4)
{
 Display(CodeGetError(Code,Errors)) ;display error at standard output
 ExitApp(1)
}

If CodeParse(Tokens,SyntaxTree,Errors)
{
 Display(CodeGetError(Code,Errors)) ;display error at standard output
 ExitApp(1)
}

Display(ShowObject(SyntaxTree) . "`n")
MsgBox % CodeRecontructSyntaxTree(SyntaxTree)

ExitApp()
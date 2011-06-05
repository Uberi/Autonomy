#NoEnv

;#Warn All

SetBatchLines(-1)

#Include Resources\Functions.ahk
#Include Get Error.ahk

#Include Code.ahk
#Include Lexer.ahk
#Include Parser.ahk

;wip: ternary operator should be added to operator table
;wip: improve Files handling (storing the filename in each token takes too much memory, so use an index)
;wip: use enumerations for token types, such as "SYNTAX_ELEMENT", or "LITERAL_STRING". enumerations should be used instead of strings wherever possible
;wip: support a command syntax, that is translated to a function call on load: MsgBox, "Title", "Text"

;wip: scope info should be attached to each variable
;wip: "local" keyword works on current block, instead of current function, and can make block assume-local: If Something { local SomeVar := "Test" } ;SomeVar is freed after the If goes out of scope
;wip: function definitions are variables holding function references (implemented as function pointers, and utilising reference counting), so variables and functions are in the same namespace

Code = 
(
Var := Something
Return, 1 + 1
)

If CodeInit()
{
 Display("Error initializing code tools.") ;display error at standard output
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
ExitApp()
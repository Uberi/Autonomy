#NoEnv

;#Warn All

SetBatchLines(-1)

#Include Resources\Functions.ahk
#Include Get Error.ahk

#Include Code.ahk
#Include Lexer.ahk
#Include Parser.ahk

;wip: improve Files handling (storing the filename in each token takes too much memory, so use an index)

Code = 
(
Var := Something
Return, 1 + 1
)

If CodeInit()
{
 FileAppend("Error initializing code tools.","*") ;display error at standard output
 ExitApp(1)
}

CodeLexInit()
If CodeLex(Code,Tokens,Errors,Files,4)
{
 ErrorMessage := CodeGetError(Code,Errors)
 FileAppend(ErrorMessage,"*") ;display error at standard output
 ExitApp(1)
}
If CodeParse(Tokens,SyntaxTree,Errors)
{
 ErrorMessage := CodeGetError(Code,Errors)
 FileAppend(ErrorMessage,"*") ;display error at standard output
 ExitApp(1)
}
ExitApp()
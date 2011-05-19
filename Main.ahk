#NoEnv

;#Warn All

SetBatchLines(-1)

#Include Functions.ahk
#Include Get Error.ahk

#Include Lexer.ahk
#Include Parser.ahk

;wip: add file display to error handler

Code = 
(
MsgBox
Return, 1 + 1
)

CodeLexInit()
If CodeLex(Code,Tokens,Errors,Files)
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
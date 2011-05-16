#NoEnv

;#Warn All

SetBatchLines(-1)

#Include Functions.ahk
#Include Get Error.ahk

#Include Lexer.ahk
#Include Parser.ahk

;wip: give error handler different error levels: Info, Warning, and Error

Code = 
(
MsgBox
Return, 1 + 1
)

CodeLexInit()
If CodeLex(Code,Tokens,Errors)
{
 ErrorMessage := CodeGetError(Code,Errors)
 FileAppend(ErrorMessage,"*") ;display error at standard output
 ExitApp(1)
}
If CodeParse(Code)
{
 ErrorMessage := CodeGetError(Code,Errors)
 FileAppend(ErrorMessage,"*") ;display error at standard output
 ExitApp(1)
}

ExitApp()
#NoEnv

#Warn All

SetBatchLines(-1)

#Include %A_ScriptDir%\Functions.ahk
#Include %A_ScriptDir%\Get Error.ahk

#Include %A_ScriptDir%\Lexer.ahk
#Include %A_ScriptDir%\Parser.ahk

Code = 
(

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
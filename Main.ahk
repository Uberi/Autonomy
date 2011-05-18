#NoEnv

;#Warn All

SetBatchLines(-1)

#Include Functions.ahk
#Include Get Error.ahk

#Include Lexer.ahk
#Include Parser.ahk

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
If CodeParse(Tokens,SyntaxTree,Errors)
{
 ErrorMessage := CodeGetError(Code,Errors)
 FileAppend(ErrorMessage,"*") ;display error at standard output
 ExitApp(1)
}
ExitApp()
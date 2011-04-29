#NoEnv

SetBatchLines(-1)

#Include %A_ScriptDir%\Functions.ahk
#Include %A_ScriptDir%\Lexer.ahk
#Include %A_ScriptDir%\Get Error.ahk

EscapeChar := "``" ;the escape character
IdentifierChars := "abcdefghijklmnopqrstuvwxyz_1234567890#" ;characters that make up a an identifier
SyntaxElements := Object(3,"`n<<=`n>>=`n//=`n . `n",2,"`n*=`n.=`n|=`n&=`n^=`n-=`n+=`n||`n&&`n--`n==`n<>`n!=`n++`n/=`n>=`n<=`n:=`n**`n<<`n>>`n//`n",1,"`n/`n*`n-`n!`n~`n+`n|`n^`n&`n<`n>`n=`n.`n(`n)`n,`n[`n]`n{`n}`n?`n:`n") ;sorted by length
Statements := "`n#Include`n#IncludeAgain`n#Persistent`n#SingleInstance`n#Warn`nWhile`nLoop`nIf`nBreak`nContinue`nReturn`nGosub`nGoto`nlocal`nglobal`nstatic`n"

FileRead(Code,A_ScriptFullPath)

If CodeLex(Code,Tokens,Errors)
{
 ErrorMessage := CodeGetError(Code,Errors)
 FileAppend(ErrorMessage,"*") ;display error at standard output
 ExitApp(1)
}
MsgBox(Clipboard := ShowObject(Tokens))
ExitApp()
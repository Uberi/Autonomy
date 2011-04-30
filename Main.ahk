#NoEnv

#Warn All

SetBatchLines(-1)

#Include %A_ScriptDir%\Functions.ahk
#Include %A_ScriptDir%\Lexer.ahk
#Include %A_ScriptDir%\Get Error.ahk

EscapeChar := "``" ;the escape character
IdentifierChars := "abcdefghijklmnopqrstuvwxyz_1234567890#" ;characters that make up a an identifier
SyntaxElements := Object(3,"`n<<=`n>>=`n//=`n . `n",2,"`n*=`n.=`n|=`n&=`n^=`n-=`n+=`n||`n&&`n--`n==`n<>`n!=`n++`n/=`n>=`n<=`n:=`n**`n<<`n>>`n//`n",1,"`n/`n*`n-`n!`n~`n+`n|`n^`n&`n<`n>`n=`n.`n(`n)`n,`n[`n]`n{`n}`n?`n:`n") ;sorted by length
StatementList := "`n#Include`n#IncludeAgain`n#SingleInstance`n#Warn`nWhile`nLoop`nFor`nIf`nElse`nBreak`nContinue`nReturn`nGosub`nGoto`nlocal`nglobal`nstatic`n"

FileRead(Code,A_ScriptFullPath)

If CodeLex(Code,Tokens,Errors)
{
 MsgBox(ShowObject(Tokens))
 ErrorMessage := CodeGetError(Code,Errors)
 FileAppend(ErrorMessage,"*") ;display error at standard output
 ExitApp(1)
}
;MsgBox(Clipboard := ShowObject(Tokens))
MsgBox(Clipboard := CodeReconstruct(Tokens))
ExitApp()

CodeReconstruct(Tokens)
{
 Code := ""
 For Index, Token In Tokens
 {
  TokenType := Token.Type, TokenValue := Token.Value
  If (TokenType = "LITERAL_STRING") ;add quotes around a literal string
   Code .= """" . TokenValue . """"
  Else If (TokenType = "STATEMENT") ;add delimiter in a statement
   Code .= TokenValue . " "
  Else If ((TokenType = "IDENTIFIER") && (TokenValue = "ByRef")) ;add sufficient whitespace around byref parameter
   Code .= TokenValue . " "
  Else ;can be appended to code directly
   Code .= TokenValue
 }
 Return, Code
}
#NoEnv

;#Warn All

SetBatchLines(-1)

#Include %A_ScriptDir%\Functions.ahk
#Include %A_ScriptDir%\Lexer.ahk
#Include %A_ScriptDir%\Get Error.ahk

FileRead(Code,A_ScriptFullPath)

CodeLexInit()
If CodeLex(Code,Tokens,Errors)
{
 ;MsgBox(ShowObject(Tokens))
 ErrorMessage := CodeGetError(Code,Errors)
 FileAppend(ErrorMessage,"*") ;display error at standard output
 ExitApp(1)
}
MsgBox(Clipboard := ShowObject(Tokens))
;MsgBox(Clipboard := CodeReconstruct(Tokens))
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
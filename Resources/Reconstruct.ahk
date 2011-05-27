#NoEnv

CodeReconstructTokens(Tokens)
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
  Else If (TokenType = "LABEL") ;add colon to end of label name
   Code .= TokenValue . ":"
  Else ;can be appended to code directly
   Code .= TokenValue
 }
 Return, Code
}

CodeRecontructSyntaxTree(SyntaxTree)
{
 
 Return, Code
}
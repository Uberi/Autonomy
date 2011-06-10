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
  Else If (TokenType = "LABEL") ;add colon to end of label name
   Code .= TokenValue . ":"
  Else ;can be appended to code directly
   Code .= TokenValue
 }
 Return, Code
}

CodeRecontructSyntaxTree(SyntaxTree)
{
 ;MsgBox % ShowObject(SyntaxTree)
 If (SyntaxTree.1.Type = "OPERATOR")
  Operator := SyntaxTree.1.Value, ObjRemove(SyntaxTree,1,1)
 For Index, Node In SyntaxTree
 {
  NodeType := Node.Type, NodeValue := Node.Value
  If (NodeType = "NODE")
   Code .= CodeRecontructSyntaxTree(NodeValue)
  Else If (NodeType = "LITERAL_STRING")
   Code .= """" . NodeValue . """"
  Else If (NodeType = "STATEMENT")
   Code .= NodeValue . " "
  Else If (NodeType = "LABEL")
   Code .= NodeValue . ":"
  Else
   Code .= NodeValue
  Code .= ","
 }
 Return, Operator . "(" . SubStr(Code,1,-1) . ")"
}
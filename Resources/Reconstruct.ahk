#NoEnv

CodeReconstructTokens(Tokens)
{
 global CodeTokenTypes
 Code := ""
 For Index, Token In Tokens
 {
  TokenType := Token.Type, TokenValue := Token.Value
  If (TokenType = CodeTokenTypes.LITERAL_STRING) ;add quotes around a literal string
   Code .= """" . TokenValue . """"
  Else If (TokenType = CodeTokenTypes.STATEMENT) ;add delimiter in a statement
   Code .= TokenValue . " "
  Else If (TokenType = CodeTokenTypes.LABEL) ;add colon to end of label name
   Code .= TokenValue . ":"
  Else If (TokenType = CodeTokenTypes.LINE_END) ;add colon to end of label name
   Code .= "`r`n"
  Else ;can be appended to code directly
   Code .= TokenValue
 }
 Return, Code
}

CodeRecontructSyntaxTree(SyntaxTree) ;wip
{
 global CodeTokenTypes
 If (SyntaxTree.1.Type = CodeTokenTypes.OPERATOR)
  Operator := SyntaxTree.1.Value, ObjRemove(SyntaxTree,1,1)
 For Index, Node In SyntaxTree
 {
  NodeType := Node.Type, NodeValue := Node.Value
  If (NodeType = CodeTokenTypes.NODE)
   Code .= CodeRecontructSyntaxTree(NodeValue)
  Else If (NodeType = CodeTokenTypes.LITERAL_STRING)
   Code .= """" . NodeValue . """"
  Else If (NodeType = CodeTokenTypes.STATEMENT)
   Code .= NodeValue . " "
  Else If (NodeType = CodeTokenTypes.LABEL)
   Code .= NodeValue . ":"
  Else
   Code .= NodeValue
  Code .= ","
 }
 Return, Operator . "(" . SubStr(Code,1,-1) . ")"
}
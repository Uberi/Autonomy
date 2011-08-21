#NoEnv

/*
Copyright 2011 Anthony Zhang <azhang9@gmail.com>

This file is part of Autonomy. Source code is available at <https://github.com/Uberi/Autonomy>.

Autonomy is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

CodeReconstructTokens(Tokens)
{
 global CodeTokenTypes
 Code := ""
 For Index, Token In Tokens
 {
  TokenType := Token.Type, TokenValue := Token.Value
  If (TokenType = CodeTokenTypes.STRING) ;add quotes around a literal string
   Code .= """" . TokenValue . """"
  Else If (TokenType = CodeTokenTypes.SEPARATOR) ;add the separator character
   Code .= ","
  Else If (TokenType = CodeTokenTypes.GROUP_BEGIN) ;add the opening parenthesis character
   Code .= "("
  Else If (TokenType = CodeTokenTypes.GROUP_END) ;add the closing parenthesis character
   Code .= ")"
  Else If (TokenType = CodeTokenTypes.OBJECT_BEGIN) ;add the opening square bracket character
   Code .= "["
  Else If (TokenType = CodeTokenTypes.OBJECT_END) ;add the closing square bracket character
   Code .= "]"
  Else If (TokenType = CodeTokenTypes.BLOCK_BEGIN) ;add the opening curly bracket character
   Code .= "{"
  Else If (TokenType = CodeTokenTypes.BLOCK_END) ;add the closing curly bracket character
   Code .= "}"
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
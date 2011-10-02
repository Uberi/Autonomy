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

CodeReconstructShowSyntaxTree(SyntaxTree,Padding = "",Operation = 1)
{
 global CodeTreeTypes
 NodeType := SyntaxTree.1
 If (NodeType = CodeTreeTypes.OPERATION)
 {
  Result := (Operation ? "" : ("`n" . Padding)) . "(", Index := 2
  Loop, % ObjMaxIndex(SyntaxTree) - 1
   Result .= CodeReconstructShowSyntaxTree(SyntaxTree[Index],Padding . "`t",Index = 2) . " ", Index ++
  Return, SubStr(Result,1,-1) . ")"
 }
 Else If (NodeType = CodeTreeTypes.STRING)
  Return, """" . SyntaxTree.2 . """"
 Else If (NodeType = CodeTreeTypes.BLOCK)
  Return, "{" . CodeReconstructShowSyntaxTree(SyntaxTree.2) . "}"
 Else
  Return, SyntaxTree.2
}

CodeReconstructShowTokens(TokenStream)
{
 global CodeTokenTypes
 MaxFileLength := 0, MaxIdentifierLength := 0, MaxPositionLength := 0
 ;find the maximum lengths of each field
 For Index, Token In TokenStream
 {
  Temp1 := StrLen(Token.File), (Temp1 > MaxFileLength) ? (MaxFileLength := Temp1)
  Temp1 := StrLen(SearchObject(CodeTokenTypes,Token.Type)), (Temp1 > MaxIdentifierLength) ? (MaxIdentifierLength := Temp1)
  Temp1 := StrLen(Token.Position), (Temp1 > MaxPositionLength) ? (MaxPositionLength := Temp1)
 }
 ;build up the result string
 Result := ""
 For Index, Token In TokenStream
 {
  TypeIdentifier := SearchObject(CodeTokenTypes,Token.Type)
  Result .= "File " . Token.File . ": " . Pad(MaxFileLength - StrLen(Token.File)) . TypeIdentifier . Pad(MaxIdentifierLength - StrLen(TypeIdentifier)) . " (" . Token.Position . "): " . Pad(MaxPositionLength - StrLen(Token.Position)) . "'" . Token.Value . "'`n"
 }
 Return, SubStr(Result,1,-1)
}

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
  Else If (TokenType = CodeTokenTypes.LINE_END) ;add a new line
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
  Else
   Code .= NodeValue
  Code .= ","
 }
 Return, Operator . "(" . SubStr(Code,1,-1) . ")"
}
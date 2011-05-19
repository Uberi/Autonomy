#NoEnv

/*
Syntax Tree Format

[Index]: [Object]
	1: the operation to perform [String]
	[1 + Index]: the parameter or parameters of the operation [Object]
		Type: the type of the parameter (Object, String, Float, Integer, etc.) [Word]
		Value: the value of the parameter [String]

Example

1:
	1: +
	2:
		Type: INTEGER
		Value: 3
	3:
		Type: INTEGER
		Value: 8
*/

;initializes resources that the parser requires
CodeParseInit()
{
 
}

;parses AHK token stream
CodeParse(ByRef Tokens,ByRef SyntaxTree,ByRef Errors)
{
 SyntaxTree := Object(), ObjectPath := Object(), CurrentNode := SyntaxTree
 Loop, % ObjMaxIndex(Tokens)
 {
  CurrentToken := Tokens[A_Index], TokenType := CurrentToken.Type
  If (TokenType = "IDENTIFIER")
  {
   NextToken := Tokens[A_Index + 1]
   If (NextToken.Type = "SYNTAX_ELEMENT" && NextToken.Value = "(") ;opening parenthesis after identifier, is a function call
   {
    ;ObjInsert(CurrentNode,
   }
  }
 }
}
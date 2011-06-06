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
	Type: NODE
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
 global CodeOperatorTable
 SyntaxTree := Object(), ObjectPath := Object(), CurrentNode := SyntaxTree, Stack := Object() ;initialize variables
 Loop, % ObjMaxIndex(Tokens)
 {
  CurrentToken := Tokens[A_Index], TokenType := CurrentToken.Type, TokenValue := CurrentToken.Value
  If (TokenType = "IDENTIFIER")
  {
   NextToken := Tokens[A_Index + 1]
   If (NextToken.Type = "SYNTAX_ELEMENT" && NextToken.Value = "(") ;opening parenthesis after identifier, is a function call
    ObjInsert(Stack,Object("Type","FUNCTION","Value",TokenValue)) ;push function token onto stack
   Else ;variable reference
    ObjInsert(CurrentNode,Object("Type","VARIABLE","Value",TokenValue)) ;add variable reference to output tree
  }
  Else If (TokenType = "SYNTAX_ELEMENT") ;a syntax element
  {
   If (TokenValue = ",") ;function argument separator or multiline expression
   {
    MaxIndex := ObjMaxIndex(Stack), ObjInsert(CurrentNode,Stack[MaxIndex]), ObjRemove(Stack), MaxIndex -- ;pop operators off the stack and onto the tree
    Loop ;go through the stack until a left parenthesis is found
    {
     Temp1 := Stack[MaxIndex] ;last stack entry
     If (Temp1.Type = "SYNTAX_ELEMENT" && Temp1.Value = "(") ;found a left parenthesis
      Break
     ObjInsert(CurrentNode,Temp1),ObjRemove(Stack), MaxIndex -- ;pop operators off the stack and onto the tree
    }
    ;wip: error checking reduced here due to comma also being used to separate multiline expressions
   }
  }
  Else If (TokenType = "OPERATOR") ;an operator
  {
   ;wip: not handling polymorphic operators for now
   MaxIndex := ObjMaxIndex(Stack), Temp2 := CodeOperatorTable[TokenValue], CurrentPrecedence := Temp2.Precedence, CurrentAssociativity := Temp2.Associativity
   Loop
   {
    Temp1 := Stack[MaxIndex] ;get top stack entry
    If (Temp1.Type <> "OPERATOR") ;must loop only while there are operators at the top of the stack
     Break
    TempPrecedence := CodeOperatorTable[Temp1.Value].Precedence
    If (CurrentAssociativity = "L" && CurrentPrecedence > TempPrecedence) ;if the current operator is left associative, the precedence must be less than or equal to that of the operator on the stack
     Break
    If (CurrentAssociativity = "R" && CurrentPrecedence >= TempPrecedence) ;if the current operator is right associative, the precedence must be less than that of the operator on the stack
     Break
    ObjInsert(CurrentNode,), ObjRemove(Stack), MaxIndex -- ;pop operators off the stack and onto the tree
   }
   ObjInsert(Stack,Object("Type","OPERATOR","Value",TokenValue) ;push the operator onto the stack
  }
 }
}
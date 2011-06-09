#NoEnv

/*
Syntax Tree Format
------------------

[Index]: [Object]
	1: the operation to perform [String]
	[1 + Index]: the parameter or parameters of the operation [Object]
		Type: the type of the parameter (Object, String, Float, Integer, etc.) [Word]
		Value: the value of the parameter [String]

Example
-------

1:
	Type: NODE ;type information
	1: + ;node name
	2: ;subnode
		Type: LITERAL_NUMBER ;type information
		Value: 3 ;literal value
	3: ;subnode
		Type: LITERAL_NUMBER ;type information
		Value: 8 ;literal value
*/

;initializes resources that the parser requires
CodeParseInit()
{
 
}

;parses AHK token stream
CodeParse(ByRef Tokens,ByRef SyntaxTree,ByRef Errors)
{
 global CodeOperatorTable
 SyntaxTree := Object(), Stack := Object(), TreeIndex := 0, StackIndex := 0 ;initialize variables
 Loop, % ObjMaxIndex(Tokens)
 {
  CurrentToken := Tokens[A_Index], TokenType := CurrentToken.Type, TokenValue := CurrentToken.Value

  If (TokenType = "LITERAL_STRING" || TokenType = "LITERAL_NUMBER") ;literal
   ObjInsert(SyntaxTree,Object("Type",TokenType,"Value",TokenValue)), TreeIndex ++ ;append literal to the output
  Else If (TokenType = "IDENTIFIER") ;function or variable
  {
   NextToken := Tokens[A_Index + 1]
   If (NextToken.Type = "SYNTAX_ELEMENT" && NextToken.Value = "(") ;opening parenthesis after identifier, is a function call or definition ;wip: not handling definitions yet
    ObjInsert(Stack,Object("Type","FUNCTION","Value",TokenValue)), StackIndex ++ ;push function token onto stack
   Else ;variable reference
    ObjInsert(SyntaxTree,Object("Type","VARIABLE","Value",TokenValue)), TreeIndex ++ ;append variable reference to the output
  }
  Else If (TokenType = "SYNTAX_ELEMENT") ;a syntax element
  {
   If (TokenValue = ",") ;function argument separator or multiline expression
   {
    ObjInsert(SyntaxTree,Stack[StackIndex]), TreeIndex ++, ObjRemove(Stack), StackIndex -- ;pop operators off the stack and onto the output
    Loop ;go through the stack until a left parenthesis is found
    {
     Temp1 := Stack[StackIndex] ;top stack entry
     If (Temp1.Type = "SYNTAX_ELEMENT" && Temp1.Value = "(") ;found a left parenthesis
      Break
     ObjInsert(SyntaxTree,Temp1),ObjRemove(Stack), StackIndex -- ;pop operators off the stack and onto the output
    }
    ;wip: error checking reduced here due to comma also being used to separate multiline expressions
   }
  }
  Else If (TokenType = "OPERATOR") ;an operator
  {
   ;wip: not handling polymorphic operators for now
   Temp2 := CodeOperatorTable[TokenValue], CurrentPrecedence := Temp2.Precedence, CurrentAssociativity := Temp2.Associativity
   Loop
   {
    Temp1 := Stack[StackIndex] ;get top stack entry
    If (Temp1.Type <> "OPERATOR") ;must loop only while there are operators at the top of the stack
     Break
    TempOperator := CodeOperatorTable[Temp1.Value]
    If (CurrentAssociativity = "L" && CurrentPrecedence > TempOperator.Precedence) ;if the current operator is left associative, the precedence must be less than or equal to that of the operator on the stack
     Break
    If (CurrentAssociativity = "R" && CurrentPrecedence >= TempOperator.Precedence) ;if the current operator is right associative, the precedence must be less than that of the operator on the stack
     Break
    CodeParseStackPop(SyntaxTree,TreeIndex,Stack,StackIndex)
   }
   ObjInsert(Stack,Object("Type","OPERATOR","Value",TokenValue)), StackIndex ++ ;push the current operator onto the stack
  }
 }
 Loop, %StackIndex%
  CodeParseStackPop(SyntaxTree,TreeIndex,Stack,StackIndex) ;pop remaining operators on the stack onto the output ;wip: error checking for mismatched parenthesis
}

CodeParseStackPushToken(ByRef Stack,ByRef StackIndex,TokenType,TokenValue)
{
 
}

;builds a subtree out of the current tree, the stack, and an operator, and inserts it into the syntax tree
CodeParseStackPop(ByRef SyntaxTree,ByRef TreeIndex,ByRef Stack,ByRef StackIndex)
{
 global CodeOperatorTable
 StackOperator := Stack[StackIndex], ObjRemove(Stack), StackIndex -- ;pop the operator off of the stack
 TreeNode := Object("Type","NODE",1,StackOperator.Value) ;initialise the node to be inserted into the tree
 Loop, % CodeOperatorTable[StackOperator.Value].Arity
  ObjInsert(TreeNode,SyntaxTree[TreeIndex]), ObjRemove(SyntaxTree), TreeIndex -- ;pop operators off the stack and onto the output
 ObjInsert(SyntaxTree,TreeNode), TreeIndex ++
}
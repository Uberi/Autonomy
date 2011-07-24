#NoEnv

/*
Syntax Tree Format
------------------

* _[Index]_:         the index of the tree node                                       _[Object]_
    * 1:             the operation to perform                                         _[String]_
    * _[1 + Index]_: the parameter or parameters of the operation                     _[Object]_
        * Type:      the type of the parameter (Object, String, Float, Integer, etc.) _[Identifier]_
        * Value:     the value of the parameter                                       _[String]_

Example
-------

(2 * 3) + 8

    1:
        Type: NODE ;type information
        Value: ;node value
            1:
                Type: OPERATOR
                Value: +
            2:
                Type: NODE
                Value: ;subnode
                    1:
                        Type: OPERATOR
                        Value: *
                    2:
                        Type: LITERAL_NUMBER
                        Value: 2
                    3:
                        Type: LITERAL_NUMBER
                        Value: 3
            3:
                Type: LITERAL_NUMBER
                Value: 8
*/

;parses AHK token stream
CodeParse(ByRef Tokens,ByRef SyntaxTree,ByRef Errors)
{
 global CodeOperatorTable
 SyntaxTree := Object(), Stack := Object(), TreeIndex := 0, StackIndex := 0 ;initialize variables
 Loop, % ObjMaxIndex(Tokens) ;wip: loop is incorrect
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
   If (TokenValue = "(") ;opening parenthesis
    ObjInsert(Stack,Object("Type","SYNTAX_ELEMENT","Value","(")), StackIndex ++ ;push onto the stack
   Else If (TokenValue = ")") ;closing parenthesis
   {
    If CodeParseStackMatchParenthesis(SyntaxTree,TreeIndex,Stack,StackIndex) ;match the parenthesis
    {
     ;wip: parenthesis mismatch error handling here
    }
    ObjRemove(Stack), StackIndex -- ;remove the operator from the stack
    ;process function here
   }
   Else If (TokenValue = ",") ;function argument separator or multiline expression
   {
    CodeParseStackMatchParenthesis(SyntaxTree,TreeIndex,Stack,StackIndex) ;output the function parameter
    ;wip: error checking reduced here due to comma also being used to separate multiline expressions
   }
  }
  Else If (TokenType = "OPERATOR") ;an operator
  {
   ;wip: not handling polymorphic operators for now
   Temp2 := CodeOperatorTable[TokenValue], CurrentPrecedence := Temp2.Precedence, CurrentAssociativity := Temp2.Associativity
   Loop ;iterate through the operators on the stack
   {
    Temp1 := Stack[StackIndex] ;get top stack entry
    If (Temp1.Type != "OPERATOR") ;must loop only while there are operators at the top of the stack
     Break
    TempOperator := CodeOperatorTable[Temp1.Value]
    If (CurrentAssociativity = "L" && CurrentPrecedence > TempOperator.Precedence) ;if the current operator is left associative, must loop only when the precedence is less than or equal to that of the operator on the stack
     Break
    If (CurrentAssociativity = "R" && CurrentPrecedence >= TempOperator.Precedence) ;if the current operator is right associative, must loop only when the precedence is less than that of the operator on the stack
     Break
    CodeParseStackPop(SyntaxTree,TreeIndex,Stack,StackIndex)
   }
   ObjInsert(Stack,Object("Type","OPERATOR","Value",TokenValue)), StackIndex ++ ;push the current operator onto the stack
  }
 }
 Loop, %StackIndex% ;wip: loop is incorrect
 {
  Temp1 := Stack[StackIndex]
  If (Temp1.Type = "SYNTAX_ELEMENT" && Temp1.Value = "(") ;mismatched parenthesis
  {
   ;wip: error handling here
  }
  CodeParseStackPop(SyntaxTree,TreeIndex,Stack,StackIndex) ;pop remaining operators on the stack onto the output ;wip: error checking for mismatched parenthesis
 }
}

;builds a subtree out of the current tree, the stack, and an operator, and inserts it into the syntax tree
CodeParseStackPop(ByRef SyntaxTree,ByRef TreeIndex,ByRef Stack,ByRef StackIndex)
{ ;returns 1 on failure, 0 otherwise
 global CodeOperatorTable
 If (StackIndex = 0)
 {
  ;wip: handle stack underflow
  Return, 1
 }
 StackOperator := Stack[StackIndex], ObjRemove(Stack), StackIndex -- ;pop the operator off of the stack
 If (StackOperator.Type != "OPERATOR" && StackOperator.Type != "FUNCTION") ;wip: if the type is FUNCTION, the number of parameters (arity) is not known.
 {
  ObjInsert(SyntaxTree,StackOperator), TreeIndex ++ ;append the operator to the output
  Return, 0
 }
 TreeNode := Object(1,StackOperator) ;initialise the node to be inserted into the tree
 Arity := CodeOperatorTable[StackOperator.Value].Arity, NodeIndex := Arity + 1 ;get the number of arguments the current operator accepts
 Loop, %Arity% ;remove the previous parameters to add them to the operator's subtree ;wip: loop is incorrect
  ObjInsert(TreeNode,NodeIndex,SyntaxTree[TreeIndex]), NodeIndex --, ObjRemove(SyntaxTree), TreeIndex -- ;pop operators off the stack and place them onto the output in their original order
 ObjInsert(SyntaxTree,Object("Type","NODE","Value",TreeNode)), TreeIndex ++ ;insert the subtree into the main tree
 Return, 0
}

;iterates through the stack until an opening parenthesis is found, while updating the syntax tree
CodeParseStackMatchParenthesis(ByRef SyntaxTree,ByRef TreeIndex,ByRef Stack,ByRef StackIndex)
{ ;return 1 on error, 0 otherwise
 Loop ;iterate through the stack until a left parenthesis is found
 {
  If (StackIndex = 0) ;stack is empty
   Return, 1
  Temp1 := Stack[StackIndex] ;top stack entry
  If (Temp1.Type = "SYNTAX_ELEMENT" && Temp1.Value = "(") ;found a left parenthesis
   Return, 0
  CodeParseStackPop(SyntaxTree,TreeIndex,Stack,StackIndex) ;pop operator off the stack and onto the output
 }
}
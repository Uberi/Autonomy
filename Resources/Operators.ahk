#NoEnv

CodeCreateOperatorTable()
{
 global CodeOperatorTable
 CodeOperatorTable := Object("NullDenotation",Object(),"LeftDenotation",Object())

 ErrorHandler := Func("CodeParseOperatorError")
 PrefixHandler := Func("CodeParseOperatorPrefix")
 InfixHandler := Func("CodeParseOperatorInfix")
 PostfixHandler := Func("CodeParseOperatorPostfix")

 CodeOperatorCreateLeftDenotation("ASSIGN",":=",10,9,InfixHandler)
 CodeOperatorCreateLeftDenotation("ASSIGN_ADD","+=",10,9,InfixHandler)
 CodeOperatorCreateLeftDenotation("ASSIGN_SUBTRACT","-=",10,9,InfixHandler)
 CodeOperatorCreateLeftDenotation("ASSIGN_MULTIPLY","*=",10,9,InfixHandler)
 CodeOperatorCreateLeftDenotation("ASSIGN_DIVIDE","/=",10,9,InfixHandler)
 CodeOperatorCreateLeftDenotation("ASSIGN_DIVIDE_FLOOR","//=",10,9,InfixHandler)
 CodeOperatorCreateLeftDenotation("ASSIGN_CONCATENATE",".=",10,9,InfixHandler)
 CodeOperatorCreateLeftDenotation("ASSIGN_BITWISE_OR","|=",10,9,InfixHandler)
 CodeOperatorCreateLeftDenotation("ASSIGN_BITWISE_AND","&=",10,9,InfixHandler)
 CodeOperatorCreateLeftDenotation("ASSIGN_BITWISE_XOR","^=",10,9,InfixHandler)
 CodeOperatorCreateLeftDenotation("ASSIGN_BITWISE_SHIFT_LEFT","<<=",10,9,InfixHandler)
 CodeOperatorCreateLeftDenotation("ASSIGN_BITWISE_SHIFT_RIGHT",">>=",10,9,InfixHandler)
 CodeOperatorCreateLeftDenotation("TERNARY_IF","?",20,19,Func("CodeParseOperatorTernary"))
 CodeOperatorCreateLeftDenotation("TERNARY_ELSE",":",0,0,ErrorHandler) ;wip: colon operator, not ternary
 CodeOperatorCreateLeftDenotation("LOGICAL_OR","||",40,40,InfixHandler)
 CodeOperatorCreateLeftDenotation("LOGICAL_AND","&&",50,50,InfixHandler)
 CodeOperatorCreateLeftDenotation("LOGICAL_EQUAL_CASE_INSENSITIVE","=",70,70,InfixHandler)
 CodeOperatorCreateLeftDenotation("LOGICAL_EQUAL_CASE_SENSITIVE","==",70,70,InfixHandler)
 CodeOperatorCreateLeftDenotation("LOGICAL_NOT_EQUAL_CASE_INSENSITIVE","!=",70,70,InfixHandler)
 CodeOperatorCreateLeftDenotation("LOGICAL_NOT_EQUAL_CASE_SENSITIVE","!==",70,70,InfixHandler)
 CodeOperatorCreateLeftDenotation("LOGICAL_GREATER_THAN",">",80,80,InfixHandler)
 CodeOperatorCreateLeftDenotation("LOGICAL_LESS_THAN","<",80,80,InfixHandler)
 CodeOperatorCreateLeftDenotation("LOGICAL_GREATER_THAN_OR_EQUAL",">=",80,80,InfixHandler)
 CodeOperatorCreateLeftDenotation("LOGICAL_LESS_THAN_OR_EQUAL","<=",80,80,InfixHandler)
 CodeOperatorCreateLeftDenotation("CONCATENATE"," . ",90,90,InfixHandler)
 CodeOperatorCreateLeftDenotation("BITWISE_AND","&",100,100,InfixHandler)
 CodeOperatorCreateLeftDenotation("BITWISE_EXCLUSIVE_OR","^",100,100,InfixHandler)
 CodeOperatorCreateLeftDenotation("BITWISE_OR","|",100,100,InfixHandler)
 CodeOperatorCreateLeftDenotation("BITWISE_SHIFT_LEFT","<<",110,110,InfixHandler)
 CodeOperatorCreateLeftDenotation("BITWISE_SHIFT_RIGHT",">>",110,110,InfixHandler)
 CodeOperatorCreateLeftDenotation("ADD","+",120,120,InfixHandler)
 CodeOperatorCreateLeftDenotation("SUBTRACT","-",120,120,InfixHandler)
 CodeOperatorCreateLeftDenotation("MULTIPLY","*",130,130,InfixHandler)
 CodeOperatorCreateLeftDenotation("DIVIDE","/",130,130,InfixHandler)
 CodeOperatorCreateLeftDenotation("DIVIDE_FLOOR","//",130,130,InfixHandler)
 CodeOperatorCreateNullDenotation("LOGICAL_NOT","!",140,PrefixHandler)
 CodeOperatorCreateNullDenotation("INVERT","-",140,PrefixHandler)
 CodeOperatorCreateNullDenotation("BITWISE_NOT","~",140,PrefixHandler)
 CodeOperatorCreateNullDenotation("ADDRESS","&",140,PrefixHandler)
 CodeOperatorCreateLeftDenotation("EXPONENTIATE","**",150,149,InfixHandler)
 CodeOperatorCreateNullDenotation("INCREMENT","++",160,PrefixHandler)
 CodeOperatorCreateNullDenotation("DECREMENT","--",160,PrefixHandler)
 CodeOperatorCreateLeftDenotation("INCREMENT","++",160,0,PostfixHandler)
 CodeOperatorCreateLeftDenotation("DECREMENT","--",160,0,PostfixHandler)

 CodeOperatorCreateNullDenotation("EVALUATE","(",0,Func("CodeParseOperatorEvaluate"))
 CodeOperatorCreateLeftDenotation("CALL","(",170,0,Func("CodeParseOperatorCall"))
 CodeOperatorCreateLeftDenotation("GROUP_END",")",0,0,ErrorHandler)

 CodeOperatorCreateNullDenotation("OBJECT","{",0,Func("CodeParseOperatorObject"))
 CodeOperatorCreateLeftDenotation("BLOCK","{",170,0,Func("CodeParseOperatorBlock"))
 CodeOperatorCreateLeftDenotation("BLOCK_END","}",0,0,ErrorHandler)

 CodeOperatorCreateNullDenotation("ARRAY","[",0,Func("CodeParseOperatorArray"))
 CodeOperatorCreateLeftDenotation("OBJECT_ACCESS_DYNAMIC","[",180,0,Func("CodeParseOperatorObjectAccess"))
 CodeOperatorCreateLeftDenotation("OBJECT_END","]",0,0,ErrorHandler)

 CodeOperatorCreateLeftDenotation("OBJECT_ACCESS",".",180,180,InfixHandler)
 CodeOperatorCreateNullDenotation("DEREFERENCE","%",190,Func("CodeParseOperatorDereference"))
}

CodeParseOperatorError(ByRef Tokens,ByRef Errors,Operator,LeftSide = "")
{
 MsgBox
 Return, "Error: Unexpected operator." ;wip: better error handling
}

CodeParseOperatorEvaluate(ByRef Tokens,ByRef Errors,Operator)
{
 global CodeTokenTypes, CodeTreeTypes, CodeOperatorTable
 Result := [CodeTreeTypes.OPERATION,[CodeTreeTypes.IDENTIFIER,Operator.Identifier]]
 Token := CodeParseToken(Tokens,0)
 If (Token.Type = CodeTokenTypes.OPERATOR ;operator token
    && CodeOperatorTable.LeftDenotation[Token.Value].IDENTIFIER = "GROUP_END") ;closing parenthesis operator token
 {
  CodeParseToken(Tokens) ;move past the closing parenthesis token
  Return, Result ;wip: empty set of parentheses should give an error
 }
 Loop ;loop through one subexpression at a time
 {
  ObjInsert(Result,CodeParseExpression(Tokens,Errors))
  Try Token := CodeParseToken(Tokens) ;move past the separator token
  Catch ;end of token stream
   Break
  If (Token.Type = CodeTokenTypes.LINE_END) ;line end token
  {
   ;wip: process line end here
  }
  Else If (Token.Type != CodeTokenTypes.SEPARATOR)
   Break ;stop parsing subexpressions
 }
 If !(Token.Type = CodeTokenTypes.OPERATOR ;operator token
    && CodeOperatorTable.LeftDenotation[Token.Value].IDENTIFIER = "GROUP_END") ;closing parenthesis operator token
 {
  MsgBox
  Return, "ERROR: Unmatched parenthesis" ;wip: better error handling
 }
 If (ObjMaxIndex(Result) = 3) ;there was only one expression inside the parentheses
  Result := Result[3] ;remove the evaluate operation and directly return the result
 Return, Result
}

CodeParseOperatorCall(ByRef Tokens,ByRef Errors,Operator,LeftSide)
{
 global CodeTreeTypes, CodeTokenTypes, CodeOperatorTable
 Result := [CodeTreeTypes.OPERATION,LeftSide]
 Token := CodeParseToken(Tokens,0)
 If (Token.Type = CodeTokenTypes.OPERATOR ;operator token
    && CodeOperatorTable.LeftDenotation[Token.Value].IDENTIFIER = "GROUP_END") ;closing parenthesis operator token
 {
  CodeParseToken(Tokens) ;move past the closing parenthesis token
  Return, Result
 }
 Loop ;loop through one argument at a time
 {
  ObjInsert(Result,CodeParseExpression(Tokens,Errors)) ;parse the argument
  Try Token := CodeParseToken(Tokens)
  Catch ;end of token stream
   Break
  If (Token.Type = CodeTokenTypes.LINE_END) ;line end token
  {
   ;wip: process line end here
  }
  Else If (Token.Type != CodeTokenTypes.SEPARATOR) ;break the loop if there is no argument separator present
   Break ;stop parsing parameters
 }
 If !(Token.Type = CodeTokenTypes.OPERATOR ;operator token
    && CodeOperatorTable.LeftDenotation[Token.Value].IDENTIFIER = "GROUP_END") ;closing parenthesis operator token
 {
  MsgBox
  Return, "ERROR: Unmatched parenthesis" ;wip: better error handling
 }
 Return, Result
}

CodeParseOperatorObject(ByRef Tokens,ByRef Errors,Operator)
{
 ;wip
}

CodeParseOperatorBlock(ByRef Tokens,ByRef Errors,Operator,LeftSide)
{
 global CodeTokenTypes, CodeTreeTypes, CodeOperatorTable
 Result := [CodeTreeTypes.BLOCK,LeftSide]
 Token := CodeParseToken(Tokens,0)
 If (Token.Type = CodeTokenTypes.OPERATOR ;operator token
    && CodeOperatorTable.LeftDenotation[Token.Value].IDENTIFIER = "BLOCK_END") ;closing block brace operator token
 {
  CodeParseToken(Tokens) ;move past the closing block brace token
  Return, Result
 }
 Loop ;loop through one argument at a time
 {
  ObjInsert(Result,CodeParseExpression(Tokens,Errors)) ;parse the argument
  Try Token := CodeParseToken(Tokens)
  Catch ;end of token stream
   Break
  If (Token.Type = CodeTokenTypes.LINE_END) ;line end token
  {
   ;wip: process line end here
  }
  Else If (Token.Type != CodeTokenTypes.SEPARATOR) ;break the loop if there is no argument separator present
   Break ;stop parsing parameters
 }
 If !(Token.Type = CodeTokenTypes.OPERATOR ;operator token
    && CodeOperatorTable.LeftDenotation[Token.Value].IDENTIFIER = "BLOCK_END") ;closing parenthesis operator token
 {
  MsgBox
  Return, "ERROR: Unmatched block brace." ;wip: better error handling
 }
 Return, Result
}

CodeParseOperatorArray(ByRef Tokens,ByRef Errors,Operator)
{
 global CodeTokenTypes, CodeTreeTypes, CodeOperatorTable
 Result := [CodeTreeTypes.OPERATION,[CodeTreeTypes.IDENTIFIER,Operator.Identifier]]
 Token := CodeParseToken(Tokens,0) ;retrieve the token after the array begin token
 If (Token.Type = CodeTokenTypes.OPERATOR && CodeOperatorTable.LeftDenotation[Token.Value].IDENTIFIER = "OBJECT_END") ;empty braces
 {
  CodeParseToken(Tokens) ;move past the closing brace token
  Return, Result
 }
 Loop ;loop through one subexpression at a time
 {
  ObjInsert(Result,CodeParseExpression(Tokens,Errors))
  Try Token := CodeParseToken(Tokens) ;move past the separator token
  Catch ;end of token stream
   Break
  If (Token.Type != CodeTokenTypes.SEPARATOR)
   Break ;stop parsing subexpressions
 }
 If !(Token.Type = CodeTokenTypes.OPERATOR && CodeOperatorTable.LeftDenotation[Token.Value].IDENTIFIER = "OBJECT_END") ;mismatched braces
 {
  MsgBox
  Return, "ERROR: Invalid array." ;wip: better error handling
 }
 Return, Result
}

CodeParseOperatorObjectAccess(ByRef Tokens,ByRef Errors,Operator,LeftSide)
{
 global CodeTreeTypes, CodeTokenTypes, CodeOperatorTable
 Token := CodeParseToken(Tokens,0)
 If (Token.Type = CodeTokenTypes.OPERATOR ;operator token
    && CodeOperatorTable.LeftDenotation[Token.Value].IDENTIFIER = "OBJECT_END") ;object end operator token
 {
  CodeParseToken(Tokens) ;move past the closing brace token
  Return, "ERROR: Blank object access." ;wip: empty set of object braces should give an error
 }
 Result := [CodeTreeTypes.OPERATION,[CodeTreeTypes.IDENTIFIER,Operator.Identifier],LeftSide,CodeParseExpression(Tokens,Errors)]
 Token := CodeParseToken(Tokens)
 If !(Token.Type = CodeTokenTypes.OPERATOR && CodeOperatorTable.LeftDenotation[Token.Value].IDENTIFIER = "OBJECT_END") ;mismatched parentheses
 {
  MsgBox
  Return, "ERROR: Invalid object access." ;wip: better error handling
 }
 Return, Result
}

CodeParseOperatorTernary(ByRef Tokens,ByRef Errors,Operator,LeftSide) ;wip
{
 global CodeTokenTypes, CodeTreeTypes, CodeOperatorTable
 FirstBranch := CodeParseExpression(Tokens,Errors,Operator.RightBindingPower) ;parse the first branch
 Token := CodeParseToken(Tokens,0) ;retrieve the current token
 If !(Token.Type = CodeTokenTypes.OPERATOR ;operator token
    && CodeOperatorTable.LeftDenotation[Token.Value].Identifier = "TERNARY_ELSE") ;ternary else operator token
 {
  ;wip: implement binary ternary operator here
  Return, "ERROR: Ternary operator missing ELSE branch" ;wip: better error handling
 }
 CodeParseToken(Tokens) ;move to the next token
 SecondBranch := CodeParseExpression(Tokens,Errors,Operator.RightBindingPower) ;parse the second branch
 Return, [CodeTreeTypes.OPERATION
  ,[CodeTreeTypes.IDENTIFIER,Operator.IDENTIFIER]
  ,LeftSide
  ,FirstBranch
  ,SecondBranch]
}

CodeParseOperatorDereference(ByRef Tokens,ByRef Errors,Operator) ;wip
{
 
}

CodeOperatorCreateNullDenotation(Identifier,Value,RightBindingPower,Handler)
{
 global CodeOperatorTable
 Operator := Object()
 Operator.Identifier := Identifier
 Operator.LeftBindingPower := 0
 Operator.RightBindingPower := RightBindingPower
 Operator.Handler := Handler
 CodeOperatorTable.NullDenotation[Value] := Operator
}

CodeOperatorCreateLeftDenotation(Identifier,Value,LeftBindingPower,RightBindingPower,Handler)
{
 global CodeOperatorTable
 Operator := Object()
 Operator.Identifier := Identifier
 Operator.LeftBindingPower := LeftBindingPower
 Operator.RightBindingPower := RightBindingPower
 Operator.Handler := Handler
 CodeOperatorTable.LeftDenotation[Value] := Operator
}
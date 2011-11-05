#NoEnv

;wip: use custom handlers for all these types

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
 CodeOperatorCreateLeftDenotation("TERNARY_IF","?",20,19,Func("CodeParseOperatorLeftDenotationTernary"))
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
 CodeOperatorCreateNullDenotation("EVALUATE","(",0,Func("CodeParseOperatorNullDenotationGroup"))
 CodeOperatorCreateLeftDenotation("GROUP_END",")",0,0,ErrorHandler) ;wip
 CodeOperatorCreateLeftDenotation("CALL","(",170,0,Func("CodeParseOperatorLeftDenotationGroup"))
 CodeOperatorCreateLeftDenotation("ACCESS_PROPERTY",".",180,180,InfixHandler)
 CodeOperatorCreateNullDenotation("DEREFERENCE","%",190,Func("CodeParseOperatorNullDenotationDereference"))
}

CodeParseOperatorError(ByRef Tokens,ByRef Errors,Operator,LeftSide = "")
{
 MsgBox
 Return, "Error: Unexpected operator." ;wip: better error handling
}

CodeParseOperatorNullDenotationGroup(ByRef Tokens,ByRef Errors,Operator) ;wip
{
 global CodeTokenTypes, CodeTreeTypes, CodeOperatorTable
 Result := [CodeTreeTypes.OPERATION,[CodeTreeTypes.IDENTIFIER,Operator.Identifier]]
 Token := CodeParseToken(Tokens,0)
 If (Token.Type = CodeTokenTypes.OPERATOR && CodeOperatorTable.LeftDenotation[Token.Value].IDENTIFIER = "GROUP_END") ;empty parentheses
  Return, Result ;wip: empty set of parentheses should give a warning
 Loop ;loop through one subexpression at a time
 {
  ObjInsert(Result,CodeParseExpression(Tokens,Errors))
  Try Token := CodeParseToken(Tokens) ;move past the separator token
  Catch ;end of token stream
   Break
  If (Token.Type != CodeTokenTypes.SEPARATOR)
   Break ;stop parsing subexpressions
 }
 If !(Token.Type = CodeTokenTypes.OPERATOR && CodeOperatorTable.LeftDenotation[Token.Value].IDENTIFIER = "GROUP_END") ;mismatched parentheses
 {
  MsgBox
  Return, "ERROR: Unmatched parenthesis" ;wip: better error handling
 }
 If (ObjMaxIndex(Result) = 3) ;there was only one expression inside the parentheses
  Result := Result[3] ;remove the evaluate operation and directly return the result
 Return, Result
}

CodeParseOperatorNullDenotationDereference(ByRef Tokens,ByRef Errors,Operator) ;wip
{
 
}

CodeParseOperatorLeftDenotationGroup(ByRef Tokens,ByRef Errors,Operator,LeftSide) ;wip
{
 global CodeTreeTypes, CodeTokenTypes, CodeOperatorTable
 Result := [CodeTreeTypes.OPERATION,LeftSide]
 Token := CodeParseToken(Tokens,0)
 If (Token.Type = CodeTokenTypes.OPERATOR && CodeOperatorTable.LeftDenotation[Token.Value].IDENTIFIER = "GROUP_END") ;empty parentheses
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
  If (Token.Type != CodeTokenTypes.SEPARATOR) ;break the loop if there is no argument separator present
   Break ;stop parsing parameters
 }
 If !(Token.Type = CodeTokenTypes.OPERATOR && CodeOperatorTable.LeftDenotation[Token.Value].IDENTIFIER = "GROUP_END") ;mismatched parentheses
 {
  MsgBox
  Return, "ERROR: Unmatched parenthesis" ;wip: better error handling
 }
 Return, Result
}

CodeParseOperatorLeftDenotationTernary(ByRef Tokens,ByRef Errors,Operator,LeftSide) ;wip
{
 global CodeTokenTypes, CodeTreeTypes, CodeOperatorTable
 FirstBranch := CodeParseExpression(Tokens,Errors,Operator.RightBindingPower) ;parse the first branch
 Token := CodeParseToken(Tokens,0) ;retrieve the current token
 If !(Token.Type = CodeTokenTypes.OPERATOR && CodeOperatorTable.LeftDenotation[Token.Value].Identifier = "TERNARY_ELSE") ;ensure the current token is a ternary else token
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
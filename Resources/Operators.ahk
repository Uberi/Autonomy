#NoEnv

;wip: use custom handlers for all these types

CodeCreateOperatorTable()
{
 global CodeOperatorTable
 CodeOperatorTable := Object("NullDenotation",Object(),"LeftDenotation",Object())

 PrefixHandler := Func("CodeParseOperatorPrefix")
 InfixHandler := Func("CodeParseOperatorInfix")
 PostfixHandler := Func("CodeParseOperatorPostfix")

 CodeOperatorCreateInfix("ASSIGN",":=",10,9,InfixHandler)
 CodeOperatorCreateInfix("ASSIGN_ADD","+=",10,9,InfixHandler)
 CodeOperatorCreateInfix("ASSIGN_SUBTRACT","-=",10,9,InfixHandler)
 CodeOperatorCreateInfix("ASSIGN_MULTIPLY","*=",10,9,InfixHandler)
 CodeOperatorCreateInfix("ASSIGN_DIVIDE","/=",10,9,InfixHandler)
 CodeOperatorCreateInfix("ASSIGN_DIVIDE_FLOOR","//=",10,9,InfixHandler)
 CodeOperatorCreateInfix("ASSIGN_CONCATENATE",".=",10,9,InfixHandler)
 CodeOperatorCreateInfix("ASSIGN_BITWISE_OR","|=",10,9,InfixHandler)
 CodeOperatorCreateInfix("ASSIGN_BITWISE_AND","&=",10,9,InfixHandler)
 CodeOperatorCreateInfix("ASSIGN_BITWISE_XOR","^=",10,9,InfixHandler)
 CodeOperatorCreateInfix("ASSIGN_BITWISE_SHIFT_LEFT","<<=",10,9,InfixHandler)
 CodeOperatorCreateInfix("ASSIGN_BITWISE_SHIFT_RIGHT",">>=",10,9,InfixHandler)
 CodeOperatorCreateInfix("TERNARY_IF","?",20,19,Func("CodeParseOperatorLeftDenotationTernary"))
 CodeOperatorCreateInfix("TERNARY_ELSE",":",0,0) ;wip: colon operator, not ternary
 CodeOperatorCreateInfix("LOGICAL_OR","||",40,40,InfixHandler)
 CodeOperatorCreateInfix("LOGICAL_AND","&&",50,50,InfixHandler)
 CodeOperatorCreateInfix("LOGICAL_EQUAL_CASE_INSENSITIVE","=",70,70,InfixHandler)
 CodeOperatorCreateInfix("LOGICAL_EQUAL_CASE_SENSITIVE","==",70,70,InfixHandler)
 CodeOperatorCreateInfix("LOGICAL_NOT_EQUAL_CASE_INSENSITIVE","!=",70,70,InfixHandler)
 CodeOperatorCreateInfix("LOGICAL_NOT_EQUAL_CASE_SENSITIVE","!==",70,70,InfixHandler)
 CodeOperatorCreateInfix("LOGICAL_GREATER_THAN",">",80,80,InfixHandler)
 CodeOperatorCreateInfix("LOGICAL_LESS_THAN","<",80,80,InfixHandler)
 CodeOperatorCreateInfix("LOGICAL_GREATER_THAN_OR_EQUAL",">=",80,80,InfixHandler)
 CodeOperatorCreateInfix("LOGICAL_LESS_THAN_OR_EQUAL","<=",80,80,InfixHandler)
 CodeOperatorCreateInfix("CONCATENATE"," . ",90,90,InfixHandler)
 CodeOperatorCreateInfix("BITWISE_AND","&",100,100,InfixHandler)
 CodeOperatorCreateInfix("BITWISE_EXCLUSIVE_OR","^",100,100,InfixHandler)
 CodeOperatorCreateInfix("BITWISE_OR","|",100,100,InfixHandler)
 CodeOperatorCreateInfix("BITWISE_SHIFT_LEFT","<<",110,110,InfixHandler)
 CodeOperatorCreateInfix("BITWISE_SHIFT_RIGHT",">>",110,110,InfixHandler)
 CodeOperatorCreateInfix("ADD","+",120,120,InfixHandler)
 CodeOperatorCreateInfix("SUBTRACT","-",120,120,InfixHandler)
 CodeOperatorCreateInfix("MULTIPLY","*",130,130,InfixHandler)
 CodeOperatorCreateInfix("DIVIDE","/",130,130,InfixHandler)
 CodeOperatorCreateInfix("DIVIDE_FLOOR","//",130,130,InfixHandler)
 CodeOperatorCreatePrefix("LOGICAL_NOT","!",140,PrefixHandler)
 CodeOperatorCreatePrefix("INVERT","-",140,PrefixHandler)
 CodeOperatorCreatePrefix("BITWISE_NOT","~",140,PrefixHandler)
 CodeOperatorCreatePrefix("ADDRESS","&",140,PrefixHandler)
 CodeOperatorCreateInfix("EXPONENTIATE","**",150,149,InfixHandler)
 CodeOperatorCreatePrefix("INCREMENT","++",160,PrefixHandler)
 CodeOperatorCreateInfix("DECREMENT","--",160,PrefixHandler)
 CodeOperatorCreateInfix("INCREMENT","++",160,0,PostfixHandler)
 CodeOperatorCreateInfix("DECREMENT","--",160,0,PostfixHandler)
 CodeOperatorCreatePrefix("EVALUATE","(",0,Func("CodeParseOperatorNullDenotationGroup"))
 CodeOperatorCreateInfix("CALL","(",170,0,Func("CodeParseOperatorLeftDenotationGroup"))
 CodeOperatorCreateInfix("ACCESS_PROPERTY",".",180,180,InfixHandler)
 CodeOperatorCreatePrefix("DEREFERENCE","%",190,Func("CodeParseOperatorNullDenotationDereference"))
}

CodeParseOperatorNullDenotationGroup() ;wip
{
 
}

CodeParseOperatorNullDenotationDereference() ;wip
{
 
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

CodeParseOperatorLeftDenotationGroup() ;wip
{
 
}

CodeOperatorCreatePrefix(Identifier = "",Value = "",RightBindingPower = 0,Handler = "")
{
 global CodeOperatorTable
 Operator := Object()
 Operator.Identifier := Identifier
 Operator.LeftBindingPower := 0
 Operator.RightBindingPower := RightBindingPower
 Operator.Handler := Handler
 CodeOperatorTable.NullDenotation[Value] := Operator
}

CodeOperatorCreateInfix(Identifier = "",Value = "",LeftBindingPower = 0,RightBindingPower = 0,Handler = "")
{
 global CodeOperatorTable
 Operator := Object()
 Operator.Identifier := Identifier
 Operator.LeftBindingPower := LeftBindingPower
 Operator.RightBindingPower := RightBindingPower
 Operator.Handler := Handler
 CodeOperatorTable.LeftDenotation[Value] := Operator
}
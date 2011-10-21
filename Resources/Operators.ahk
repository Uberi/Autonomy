#NoEnv

CodeCreateOperatorTable()
{
 global CodeOperatorTable
 CodeOperatorTable := Object("NullDenotation",Object(),"LeftDenotation",Object())

 CodeOperatorCreateInfix("ASSIGN",":=",10,9)
 CodeOperatorCreateInfix("ASSIGN_ADD","+=",10,9)
 CodeOperatorCreateInfix("ASSIGN_SUBTRACT","-=",10,9)
 CodeOperatorCreateInfix("ASSIGN_MULTIPLY","*=",10,9)
 CodeOperatorCreateInfix("ASSIGN_DIVIDE","/=",10,9)
 CodeOperatorCreateInfix("ASSIGN_DIVIDE_FLOOR","//=",10,9)
 CodeOperatorCreateInfix("ASSIGN_CONCATENATE",".=",10,9)
 CodeOperatorCreateInfix("ASSIGN_BITWISE_OR","|=",10,9)
 CodeOperatorCreateInfix("ASSIGN_BITWISE_AND","&=",10,9)
 CodeOperatorCreateInfix("ASSIGN_BITWISE_XOR","^=",10,9)
 CodeOperatorCreateInfix("ASSIGN_BITWISE_SHIFT_LEFT","<<=",10,9)
 CodeOperatorCreateInfix("ASSIGN_BITWISE_SHIFT_RIGHT",">>=",10,9)
 CodeOperatorCreateInfix("TERNARY_IF","?",20,20,Func("CodeParseOperatorLeftDenotationTernary"))
 CodeOperatorCreateInfix("TERNARY_ELSE",":",0,0) ;wip: colon operator, not ternary
 CodeOperatorCreateInfix("LOGICAL_OR","||",40,40)
 CodeOperatorCreateInfix("LOGICAL_AND","&&",50,50)
 CodeOperatorCreateInfix("LOGICAL_EQUAL_CASE_INSENSITIVE","=",70,70)
 CodeOperatorCreateInfix("LOGICAL_EQUAL_CASE_SENSITIVE","==",70,70)
 CodeOperatorCreateInfix("LOGICAL_NOT_EQUAL_CASE_INSENSITIVE","!=",70,70)
 CodeOperatorCreateInfix("LOGICAL_NOT_EQUAL_CASE_SENSITIVE","!==",70,70)
 CodeOperatorCreateInfix("LOGICAL_GREATER_THAN",">",80,80)
 CodeOperatorCreateInfix("LOGICAL_LESS_THAN","<",80,80)
 CodeOperatorCreateInfix("LOGICAL_GREATER_THAN_OR_EQUAL",">=",80,80)
 CodeOperatorCreateInfix("LOGICAL_LESS_THAN_OR_EQUAL","<=",80,80)
 CodeOperatorCreateInfix("CONCATENATE"," . ",90,90)
 CodeOperatorCreateInfix("BITWISE_AND","&",100,100)
 CodeOperatorCreateInfix("BITWISE_EXCLUSIVE_OR","^",100,100)
 CodeOperatorCreateInfix("BITWISE_OR","|",100,100)
 CodeOperatorCreateInfix("BITWISE_SHIFT_LEFT","<<",110,110)
 CodeOperatorCreateInfix("BITWISE_SHIFT_RIGHT",">>",110,110)
 CodeOperatorCreateInfix("ADD","+",120,120)
 CodeOperatorCreateInfix("SUBTRACT","-",120,120)
 CodeOperatorCreateInfix("MULTIPLY","*",130,130)
 CodeOperatorCreateInfix("DIVIDE","/",130,130)
 CodeOperatorCreateInfix("DIVIDE_FLOOR","//",130,130)
 CodeOperatorCreatePrefix("LOGICAL_NOT","!",140)
 CodeOperatorCreatePrefix("INVERT","-",140)
 CodeOperatorCreatePrefix("BITWISE_NOT","~",140)
 CodeOperatorCreatePrefix("ADDRESS","&",140)
 CodeOperatorCreateInfix("EXPONENTIATE","**",150,149)
 CodeOperatorCreatePrefix("INCREMENT","++",160)
 CodeOperatorCreatePrefix("DECREMENT","--",160)
 CodeOperatorCreatePostfix("INCREMENT","++",160)
 CodeOperatorCreatePostfix("DECREMENT","--",160)
 CodeOperatorCreatePrefix("EVALUATE","(",0,Func("CodeParseOperatorNullDenotationGroup"))
 CodeOperatorCreateInfix("CALL","(",170,0,Func("CodeParseOperatorLeftDenotationGroup"))
 CodeOperatorCreateInfix("ACCESS_PROPERTY",".",180,180)
 CodeOperatorCreatePrefix("DEREFERENCE","%",190,Func("CodeParseOperatorNullDenotationDereference"))
}

CodeParseOperatorLeftDenotationTernary() ;wip
{
 
}

CodeParseOperatorLeftDenotationGroup() ;wip
{
 
}

CodeParseOperatorNullDenotationGroup() ;wip
{
 
}

CodeParseOperatorNullDenotationDereference() ;wip
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

CodeOperatorCreatePostfix(Identifier = "",Value = "",LeftBindingPower = 0,Handler = "")
{
 global CodeOperatorTable
 Operator := Object()
 Operator.Identifier := Identifier
 Operator.LeftBindingPower := LeftBindingPower
 Operator.RightBindingPower := -1
 Operator.Handler := Handler
 CodeOperatorTable.LeftDenotation[Value] := Operator
}
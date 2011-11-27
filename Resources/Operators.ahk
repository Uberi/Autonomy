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

CodeCreateOperatorTable()
{
 global CodeOperatorTable
 CodeOperatorTable := Object()
 CodeOperatorTable.NullDenotation := Object()
 CodeOperatorTable.LeftDenotation := Object()

 Invalid := Func("CodeParseOperatorError")
 Prefix := Func("CodeParseOperatorPrefix")
 Infix := Func("CodeParseOperatorInfix")
 Postfix := Func("CodeParseOperatorPostfix")

 CodeOperatorTable.LeftDenotation[":="]  := CodeOperatorCreate("ASSIGN"                             ,10 ,9  ,Infix)
 CodeOperatorTable.LeftDenotation["+="]  := CodeOperatorCreate("ASSIGN_ADD"                         ,10 ,9  ,Infix)
 CodeOperatorTable.LeftDenotation["-="]  := CodeOperatorCreate("ASSIGN_SUBTRACT"                    ,10 ,9  ,Infix)
 CodeOperatorTable.LeftDenotation["*="]  := CodeOperatorCreate("ASSIGN_MULTIPLY"                    ,10 ,9  ,Infix)
 CodeOperatorTable.LeftDenotation["/="]  := CodeOperatorCreate("ASSIGN_DIVIDE"                      ,10 ,9  ,Infix)
 CodeOperatorTable.LeftDenotation["//="] := CodeOperatorCreate("ASSIGN_DIVIDE_FLOOR"                ,10 ,9  ,Infix)
 CodeOperatorTable.LeftDenotation[".="]  := CodeOperatorCreate("ASSIGN_CONCATENATE"                 ,10 ,9  ,Infix)
 CodeOperatorTable.LeftDenotation["|="]  := CodeOperatorCreate("ASSIGN_BITWISE_OR"                  ,10 ,9  ,Infix)
 CodeOperatorTable.LeftDenotation["&="]  := CodeOperatorCreate("ASSIGN_BITWISE_AND"                 ,10 ,9  ,Infix)
 CodeOperatorTable.LeftDenotation["^="]  := CodeOperatorCreate("ASSIGN_BITWISE_XOR"                 ,10 ,9  ,Infix)
 CodeOperatorTable.LeftDenotation["<<="] := CodeOperatorCreate("ASSIGN_BITWISE_SHIFT_LEFT"          ,10 ,9  ,Infix)
 CodeOperatorTable.LeftDenotation[">>="] := CodeOperatorCreate("ASSIGN_BITWISE_SHIFT_RIGHT"         ,10 ,9  ,Infix)
 CodeOperatorTable.LeftDenotation["?"]   := CodeOperatorCreate("TERNARY_IF"                         ,20 ,19 ,Func("CodeParseOperatorTernaryIf"))
 CodeOperatorTable.LeftDenotation[":"]   := CodeOperatorCreate("TERNARY_ELSE"                       ,0  ,0  ,Invalid) ;wip: colon operator, not ternary
 CodeOperatorTable.LeftDenotation["||"]  := CodeOperatorCreate("LOGICAL_OR"                         ,40 ,40 ,Infix)
 CodeOperatorTable.LeftDenotation["&&"]  := CodeOperatorCreate("LOGICAL_AND"                        ,50 ,50 ,Infix)
 CodeOperatorTable.LeftDenotation["="]   := CodeOperatorCreate("LOGICAL_EQUAL_CASE_INSENSITIVE"     ,70 ,70 ,Infix)
 CodeOperatorTable.LeftDenotation["=="]  := CodeOperatorCreate("LOGICAL_EQUAL_CASE_SENSITIVE"       ,70 ,70 ,Infix)
 CodeOperatorTable.LeftDenotation["!="]  := CodeOperatorCreate("LOGICAL_NOT_EQUAL_CASE_INSENSITIVE" ,70 ,70 ,Infix)
 CodeOperatorTable.LeftDenotation["!=="] := CodeOperatorCreate("LOGICAL_NOT_EQUAL_CASE_SENSITIVE"   ,70 ,70 ,Infix)
 CodeOperatorTable.LeftDenotation[">"]   := CodeOperatorCreate("LOGICAL_GREATER_THAN"               ,80 ,80 ,Infix)
 CodeOperatorTable.LeftDenotation["<"]   := CodeOperatorCreate("LOGICAL_LESS_THAN"                  ,80 ,80 ,Infix)
 CodeOperatorTable.LeftDenotation[">="]  := CodeOperatorCreate("LOGICAL_GREATER_THAN_OR_EQUAL"      ,80 ,80 ,Infix)
 CodeOperatorTable.LeftDenotation["<="]  := CodeOperatorCreate("LOGICAL_LESS_THAN_OR_EQUAL"         ,80 ,80 ,Infix)
 CodeOperatorTable.LeftDenotation[" . "] := CodeOperatorCreate("CONCATENATE"                        ,90 ,90 ,Infix)
 CodeOperatorTable.LeftDenotation["&"]   := CodeOperatorCreate("BITWISE_AND"                        ,100,100,Infix)
 CodeOperatorTable.LeftDenotation["^"]   := CodeOperatorCreate("BITWISE_EXCLUSIVE_OR"               ,100,100,Infix)
 CodeOperatorTable.LeftDenotation["|"]   := CodeOperatorCreate("BITWISE_OR"                         ,100,100,Infix)
 CodeOperatorTable.LeftDenotation["<<"]  := CodeOperatorCreate("BITWISE_SHIFT_LEFT"                 ,110,110,Infix)
 CodeOperatorTable.LeftDenotation[">>"]  := CodeOperatorCreate("BITWISE_SHIFT_RIGHT"                ,110,110,Infix)
 CodeOperatorTable.LeftDenotation["+"]   := CodeOperatorCreate("ADD"                                ,120,120,Infix)
 CodeOperatorTable.LeftDenotation["-"]   := CodeOperatorCreate("SUBTRACT"                           ,120,120,Infix)
 CodeOperatorTable.LeftDenotation["*"]   := CodeOperatorCreate("MULTIPLY"                           ,130,130,Infix)
 CodeOperatorTable.LeftDenotation["/"]   := CodeOperatorCreate("DIVIDE"                             ,130,130,Infix)
 CodeOperatorTable.LeftDenotation["//"]  := CodeOperatorCreate("DIVIDE_FLOOR"                       ,130,130,Infix)
 CodeOperatorTable.NullDenotation["!"]   := CodeOperatorCreate("LOGICAL_NOT"                        ,0  ,140,Prefix)
 CodeOperatorTable.NullDenotation["-"]   := CodeOperatorCreate("INVERT"                             ,0  ,140,Prefix)
 CodeOperatorTable.NullDenotation["~"]   := CodeOperatorCreate("BITWISE_NOT"                        ,0  ,140,Prefix)
 CodeOperatorTable.NullDenotation["&"]   := CodeOperatorCreate("ADDRESS"                            ,0  ,140,Prefix)
 CodeOperatorTable.LeftDenotation["**"]  := CodeOperatorCreate("EXPONENTIATE"                       ,150,149,Infix)
 CodeOperatorTable.NullDenotation["++"]  := CodeOperatorCreate("INCREMENT"                          ,0  ,160,Prefix)
 CodeOperatorTable.NullDenotation["--"]  := CodeOperatorCreate("DECREMENT"                          ,0  ,160,Prefix)
 CodeOperatorTable.LeftDenotation["++"]  := CodeOperatorCreate("INCREMENT"                          ,160,0  ,Postfix)
 CodeOperatorTable.LeftDenotation["--"]  := CodeOperatorCreate("DECREMENT"                          ,160,0  ,Postfix)

 CodeOperatorTable.NullDenotation["("]   := CodeOperatorCreate("EVALUATE"                           ,0  ,0  ,Func("CodeParseOperatorEvaluate"))
 CodeOperatorTable.LeftDenotation["("]   := CodeOperatorCreate("CALL"                               ,170,0  ,Func("CodeParseOperatorCall"))
 CodeOperatorTable.LeftDenotation[")"]   := CodeOperatorCreate("GROUP_END"                          ,0  ,0  ,Invalid)

 CodeOperatorTable.NullDenotation["{"]   := CodeOperatorCreate("OBJECT"                             ,0  ,0  ,Func("CodeParseOperatorObject"))
 CodeOperatorTable.LeftDenotation["{"]   := CodeOperatorCreate("BLOCK"                              ,170,0  ,Func("CodeParseOperatorBlock"))
 CodeOperatorTable.LeftDenotation["}"]   := CodeOperatorCreate("BLOCK_END"                          ,0  ,0  ,Invalid)

 CodeOperatorTable.NullDenotation["["]   := CodeOperatorCreate("ARRAY"                              ,0  ,0  ,Func("CodeParseOperatorArray"))
 CodeOperatorTable.LeftDenotation["["]   := CodeOperatorCreate("OBJECT_ACCESS_DYNAMIC"              ,180,0  ,Func("CodeParseOperatorObjectAccess"))
 CodeOperatorTable.LeftDenotation["]"]   := CodeOperatorCreate("OBJECT_END"                         ,0  ,0  ,Invalid)

 CodeOperatorTable.LeftDenotation["."]   := CodeOperatorCreate("OBJECT_ACCESS"                      ,180,180,Infix)
 CodeOperatorTable.NullDenotation["%"]   := CodeOperatorCreate("DEREFERENCE"                        ,0  ,190,Func("CodeParseOperatorDereference"))
}

CodeParseOperatorError(ByRef Tokens,ByRef Errors,Operator,LeftSide = "")
{
 MsgBox
 Return, "Error: Unexpected operator (" . Operator.Identifier . ")." ;wip: better error handling
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
   CodeParseStatement(Tokens,Errors)
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
   CodeParseStatement(Tokens,Errors)
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
   CodeParseStatement(Tokens,Errors)
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

CodeParseOperatorTernaryIf(ByRef Tokens,ByRef Errors,Operator,LeftSide)
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

CodeParseStatement(ByRef Tokens,ByRef Errors)
{
 ;wip: parse statement here
}

CodeOperatorCreate(Identifier,LeftBindingPower,RightBindingPower,Handler)
{
 Operator := Object()
 Operator.Identifier := Identifier
 Operator.LeftBindingPower := LeftBindingPower
 Operator.RightBindingPower := RightBindingPower
 Operator.Handler := Handler
 Return, Operator
}
#NoEnv

/*
Copyright 2011-2012 Anthony Zhang <azhang9@gmail.com>

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

class Operator
{
    __New(Identifier,LeftBindingPower,RightBindingPower,Handler)
    {
        this.Identifier := Identifier
        this.LeftBindingPower := LeftBindingPower
        this.RightBindingPower := RightBindingPower
        this.Handler := Handler
    }
}

CreateOperatorTable()
{
    Operators := Object()
    Operators.NullDenotation := Object()
    Operators.LeftDenotation := Object()

    Invalid := Func("CodeParseOperatorError")
    Prefix := Func("CodeParseOperatorPrefix")
    Infix := Func("CodeParseOperatorInfix")
    Postfix := Func("CodeParseOperatorPostfix")

    Operators.LeftDenotation[":="]  := new Code.Operator("assign"                             ,10  ,9   ,Infix)
    Operators.LeftDenotation["+="]  := new Code.Operator("assign_add"                         ,10  ,9   ,Infix)
    Operators.LeftDenotation["-="]  := new Code.Operator("assign_subtract"                    ,10  ,9   ,Infix)
    Operators.LeftDenotation["*="]  := new Code.Operator("assign_multiply"                    ,10  ,9   ,Infix)
    Operators.LeftDenotation["/="]  := new Code.Operator("assign_divide"                      ,10  ,9   ,Infix)
    Operators.LeftDenotation["//="] := new Code.Operator("assign_divide_floor"                ,10  ,9   ,Infix)
    Operators.LeftDenotation["%="]  := new Code.Operator("assign_modulo"                      ,10  ,9   ,Infix)
    Operators.LeftDenotation["**="] := new Code.Operator("assign_exponentiate"                ,10  ,9   ,Infix)
    Operators.LeftDenotation[".="]  := new Code.Operator("assign_concatenate"                 ,10  ,9   ,Infix)
    Operators.LeftDenotation["|="]  := new Code.Operator("assign_bitwise_or"                  ,10  ,9   ,Infix)
    Operators.LeftDenotation["&="]  := new Code.Operator("assign_bitwise_and"                 ,10  ,9   ,Infix)
    Operators.LeftDenotation["^="]  := new Code.Operator("assign_bitwise_xor"                 ,10  ,9   ,Infix)
    Operators.LeftDenotation["<<="] := new Code.Operator("assign_bitwise_shift_left"          ,10  ,9   ,Infix)
    Operators.LeftDenotation[">>="] := new Code.Operator("assign_bitwise_shift_right"         ,10  ,9   ,Infix)
    Operators.LeftDenotation["||="] := new Code.Operator("assign_logical_or"                  ,10  ,9   ,Infix)
    Operators.LeftDenotation["&&="] := new Code.Operator("assign_logical_and"                 ,10  ,9   ,Infix)
    Operators.LeftDenotation["?"]   := new Code.Operator("if"                                 ,20  ,19  ,Func("CodeParseOperatorTernaryIf"))
    Operators.LeftDenotation[":"]   := new Code.Operator("else"                               ,0   ,0   ,Invalid) ;wip: colon operator, not ternary
    Operators.LeftDenotation["||"]  := new Code.Operator("logical_or"                         ,40  ,40  ,Func("CodeParseBooleanShortCircuit"))
    Operators.LeftDenotation["&&"]  := new Code.Operator("logical_and"                        ,50  ,50  ,Func("CodeParseBooleanShortCircuit"))
    Operators.LeftDenotation["="]   := new Code.Operator("logical_equal_case_insensitive"     ,70  ,70  ,Infix)
    Operators.LeftDenotation["=="]  := new Code.Operator("logical_equal_case_sensitive"       ,70  ,70  ,Infix)
    Operators.LeftDenotation["!="]  := new Code.Operator("logical_not_equal_case_insensitive" ,70  ,70  ,Infix)
    Operators.LeftDenotation["!=="] := new Code.Operator("logical_not_equal_case_sensitive"   ,70  ,70  ,Infix)
    Operators.LeftDenotation[">"]   := new Code.Operator("logical_greater_than"               ,80  ,80  ,Infix)
    Operators.LeftDenotation["<"]   := new Code.Operator("logical_less_than"                  ,80  ,80  ,Infix)
    Operators.LeftDenotation[">="]  := new Code.Operator("logical_greater_than_or_equal"      ,80  ,80  ,Infix)
    Operators.LeftDenotation["<="]  := new Code.Operator("logical_less_than_or_equal"         ,80  ,80  ,Infix)
    Operators.LeftDenotation[".."]  := new Code.Operator("concatenate"                        ,90  ,90  ,Infix)
    Operators.LeftDenotation["|"]   := new Code.Operator("bitwise_or"                         ,100 ,100 ,Infix)
    Operators.LeftDenotation["^"]   := new Code.Operator("bitwise_exclusive_or"               ,110 ,110 ,Infix)
    Operators.LeftDenotation["&"]   := new Code.Operator("bitwise_and"                        ,120 ,120 ,Infix)
    Operators.LeftDenotation["<<"]  := new Code.Operator("bitwise_shift_left"                 ,130 ,130 ,Infix)
    Operators.LeftDenotation[">>"]  := new Code.Operator("bitwise_shift_right"                ,130 ,130 ,Infix)
    Operators.LeftDenotation["+"]   := new Code.Operator("add"                                ,140 ,140 ,Infix)
    Operators.LeftDenotation["-"]   := new Code.Operator("subtract"                           ,140 ,140 ,Infix)
    Operators.LeftDenotation["*"]   := new Code.Operator("multiply"                           ,150 ,150 ,Infix)
    Operators.LeftDenotation["/"]   := new Code.Operator("divide"                             ,150 ,150 ,Infix)
    Operators.LeftDenotation["//"]  := new Code.Operator("divide_floor"                       ,150 ,150 ,Infix)
    Operators.LeftDenotation["%"]   := new Code.Operator("modulo"                             ,150 ,150 ,Infix) ;wip: also should be the format string operator
    Operators.NullDenotation["!"]   := new Code.Operator("logical_not"                        ,0   ,160 ,Prefix)
    Operators.NullDenotation["-"]   := new Code.Operator("invert"                             ,0   ,160 ,Prefix)
    Operators.NullDenotation["~"]   := new Code.Operator("bitwise_not"                        ,0   ,160 ,Prefix)
    Operators.NullDenotation["&"]   := new Code.Operator("address"                            ,0   ,160 ,Prefix)
    Operators.LeftDenotation["**"]  := new Code.Operator("exponentiate"                       ,170 ,169 ,Infix)
    Operators.LeftDenotation["++"]  := new Code.Operator("increment"                          ,180 ,0   ,Postfix)
    Operators.LeftDenotation["--"]  := new Code.Operator("decrement"                          ,180 ,0   ,Postfix)

    Operators.NullDenotation["("]   := new Code.Operator("evaluate"                           ,0   ,0   ,Func("CodeParseOperatorEvaluate"))
    Operators.LeftDenotation["("]   := new Code.Operator("call"                               ,190 ,0   ,Func("CodeParseOperatorCall"))
    Operators.LeftDenotation[")"]   := new Code.Operator("group_end"                          ,0   ,0   ,Invalid)

    Operators.NullDenotation["{"]   := new Code.Operator("block"                              ,0   ,0   ,Func("CodeParseOperatorBlock"))
    ;Operators.LeftDenotation["{"]   := new Code.Operator("call"                              ,0   ,0   ,Func("CodeParseOperatorCall")) ;wip: this is for cases like: func { stuff }
    Operators.LeftDenotation["}"]   := new Code.Operator("block_end"                          ,0   ,0   ,Invalid)

    Operators.NullDenotation["["]   := new Code.Operator("array"                              ,0   ,0   ,Func("CodeParseOperatorArray"))
    Operators.LeftDenotation["["]   := new Code.Operator("subscript"                          ,200 ,0   ,Func("CodeParseOperatorObjectAccessDynamic"))
    Operators.LeftDenotation["]"]   := new Code.Operator("subscript_end"                      ,0   ,0   ,Invalid)

    Operators.LeftDenotation["."]   := new Code.Operator("subscript_identifier"               ,200 ,200 ,Infix)

    Return, Operators
}

CodeParseStatement(Tokens,ByRef Index,ByRef Errors)
{
    global CodeTokenTypes, CodeOperatorTable
    Statement := Tokens[Index], Index ++ ;retrieve the statement identifier
    Try Token := CodeParseToken(Tokens,Index)
    Catch ;no tokens remain
        Return, CodeTreeOperation(CodeTreeIdentifier(Statement.Value))
    If (Token.Type = CodeTokenTypes.LINE_END ;line end token
        || (Token.Type = CodeTokenTypes.OPERATOR ;operator token
            && CodeOperatorTable.LeftDenotation.HasKey(Token.Value) ;operator has a left denotation
            && CodeOperatorTable.LeftDenotation[Token.Value].LeftBindingPower = 0)) ;operator left binding power is 0
        Return, CodeTreeOperation(CodeTreeIdentifier(Statement.Value))
    Operands := []
    Loop ;loop through one subexpression at a time
    {
        Operands.Insert(CodeParseExpression(Tokens,Index,Errors,0)) ;parse an expression and add it to the operand array
        Try CurrentToken := CodeParseToken(Tokens,Index)
        Catch ;end of token stream
            Break
        If (CurrentToken.Type = CodeTokenTypes.LINE_END) ;line end token
            Break
        Else If (CurrentToken.Type != CodeTokenTypes.SEPARATOR) ;not a separator token
        {
            If (Token.Type != CodeTokenTypes.OPERATOR ;operator token
                || !CodeOperatorTable.LeftDenotation.HasKey(Token.Value) ;operator does not have a left denotation
                || CodeOperatorTable.LeftDenotation[Token.Value].LeftBindingPower > 0) ;operator left binding power is greater than 0
            {
                ;wip: handle errors here
            }
            Break ;stop parsing subexpressions
        }
        Index ++
    }
    Return, CodeTreeOperation(CodeTreeIdentifier(Statement.Value),Operands)
}

CodeParseOperatorError(Tokens,ByRef Index,ByRef Errors,Operator,LeftSide = "")
{
    MsgBox Unexpected operator.
    Return, "Error: Unexpected operator (" . Operator.Identifier . ")." ;wip: better error handling
}

CodeParseBooleanShortCircuit(Tokens,ByRef Index,ByRef Errors,Operator,LeftSide)
{
    Return, CodeTreeOperation(CodeTreeIdentifier(Operator.Identifier)
                ,[CodeTreeBlock([LeftSide]),CodeTreeBlock([CodeParseLine(Tokens,Index,Errors,Operator.RightBindingPower)])])
}

CodeParseOperatorEvaluate(Tokens,ByRef Index,ByRef Errors,Operator)
{
    global CodeTokenTypes, CodeOperatorTable
    Token := CodeParseToken(Tokens,Index) ;retrieve the current token
    If (Token.Type = CodeTokenTypes.OPERATOR ;operator token
        && CodeOperatorTable.LeftDenotation[Token.Value].IDENTIFIER = "GROUP_END") ;closing parenthesis operator token
    {
        CodeParseToken(Tokens,Index), Index ++ ;move past the closing parenthesis token ;wip: handle errors
        Return, CodeTreeOperation(CodeTreeIdentifier(Operator.Identifier)) ;wip: empty set of parentheses should give an error
    }
    Operands := []
    Loop ;loop through one subexpression at a time
    {
        If (Token.Type = CodeTokenTypes.LINE_END || A_Index = 1) ;beginning of a line ;wip: remove A_Index
            Operands.Insert(CodeParseLine(Tokens,Index,Errors)) ;parse a line and add it to the operand array
        Else
            Operands.Insert(CodeParseExpression(Tokens,Index,Errors,0)) ;parse the argument
        Try Token := CodeParseToken(Tokens,Index), Index ++ ;move past the separator token
        Catch ;end of token stream
            Break
        If (Token.Type != CodeTokenTypes.LINE_END && Token.Type != CodeTokenTypes.SEPARATOR) ;break the loop if there are no subexpressions left
            Break ;stop parsing subexpressions
    }
    If !(Token.Type = CodeTokenTypes.OPERATOR ;operator token
        && CodeOperatorTable.LeftDenotation[Token.Value].IDENTIFIER = "GROUP_END") ;closing parenthesis operator token
    {
        MsgBox Unmatched parenthesis.
        Return, "ERROR: Unmatched parenthesis." ;wip: better error handling
    }
    Return, CodeTreeOperation(CodeTreeIdentifier(Operator.Identifier),Operands)
}

CodeParseOperatorCall(Tokens,ByRef Index,ByRef Errors,Operator,LeftSide)
{
    global CodeTokenTypes, CodeOperatorTable
    Token := CodeParseToken(Tokens,Index) ;retrieve the current token ;wip: check for stream end
    If (Token.Type = CodeTokenTypes.OPERATOR ;operator token
        && CodeOperatorTable.LeftDenotation[Token.Value].IDENTIFIER = "GROUP_END") ;closing parenthesis operator token
    {
        CodeParseToken(Tokens,Index), Index ++ ;move past the closing parenthesis token ;wip: handle errors
        Return, CodeTreeOperation(LeftSide)
    }
    Operands := []
    Loop ;loop through one argument at a time
    {
        If (Token.Type = CodeTokenTypes.LINE_END || A_Index = 1) ;beginning of a line
            Operands.Insert(CodeParseLine(Tokens,Index,Errors)) ;parse a line and add it to the operand array
        Else
            Operands.Insert(CodeParseExpression(Tokens,Index,Errors,0)) ;parse the argument
        Try Token := CodeParseToken(Tokens,Index), Index ++
        Catch ;end of token stream
            Break
        If (Token.Type != CodeTokenTypes.LINE_END && Token.Type != CodeTokenTypes.SEPARATOR) ;break the loop if there are no subexpressions left
            Break ;stop parsing parameters
    }
    If !(Token.Type = CodeTokenTypes.OPERATOR ;operator token
        && CodeOperatorTable.LeftDenotation[Token.Value].IDENTIFIER = "GROUP_END") ;closing parenthesis operator token
    {
        MsgBox Unmatched parenthesis.
        Return, "ERROR: Unmatched parenthesis." ;wip: better error handling
    }
    Return, CodeTreeOperation(LeftSide,Operands)
}

CodeParseOperatorBlock(Tokens,ByRef Index,ByRef Errors,Operator)
{
    global CodeTokenTypes, CodeOperatorTable
    Token := CodeParseToken(Tokens,Index)
    If (Token.Type = CodeTokenTypes.OPERATOR ;operator token
        && CodeOperatorTable.LeftDenotation[Token.Value].IDENTIFIER = "BLOCK_END") ;closing block brace operator token
    {
        CodeParseToken(Tokens,Index), Index ++ ;move past the closing block brace token ;wip: handle errors
        Return, CodeTreeBlock() ;empty block
    }
    Operands := []
    Loop ;loop through one argument at a time
    {
        If (Token.Type = CodeTokenTypes.LINE_END || A_Index = 1) ;beginning of a line ;wip: remove A_Index
            Operands.Insert(CodeParseLine(Tokens,Index,Errors)) ;parse a line and add it to the operand array
        Else
            Operands.Insert(CodeParseExpression(Tokens,Index,Errors,0)) ;parse the argument
        Try Token := CodeParseToken(Tokens,Index), Index ++
        Catch ;end of token stream
            Break
        If (Token.Type != CodeTokenTypes.LINE_END && Token.Type != CodeTokenTypes.SEPARATOR) ;break the loop if there are no subexpressions left
            Break ;stop parsing parameters
    }
    If !(Token.Type = CodeTokenTypes.OPERATOR ;operator token
        && CodeOperatorTable.LeftDenotation[Token.Value].IDENTIFIER = "BLOCK_END") ;closing parenthesis operator token
    {
        MsgBox Unmatched block brace.
        Return, "ERROR: Unmatched block brace." ;wip: better error handling
    }
    Return, CodeTreeBlock(Operands)
}

CodeParseOperatorArray(Tokens,ByRef Index,ByRef Errors,Operator)
{
    global CodeTokenTypes, CodeOperatorTable
    Token := CodeParseToken(Tokens,Index) ;retrieve the token after the array begin token
    If (Token.Type = CodeTokenTypes.OPERATOR && CodeOperatorTable.LeftDenotation[Token.Value].IDENTIFIER = "SUBSCRIPT_END") ;empty braces
    {
        CodeParseToken(Tokens,Index), Index ++ ;move past the closing brace token ;wip: handle errors
        Return, CodeTreeOperation(CodeTreeIdentifier(Operator.Identifier))
    }
    Operands := []
    Loop ;loop through one subexpression at a time
    {
        If (Token.Type = CodeTokenTypes.LINE_END || A_Index = 1) ;beginning of a line ;wip: remove A_Index
            Operands.Insert(CodeParseLine(Tokens,Index,Errors)) ;parse a line and add it to the operand array
        Else
            Operands.Insert(CodeParseExpression(Tokens,Index,Errors,0)) ;parse the argument
        Try Token := CodeParseToken(Tokens,Index), Index ++ ;move past the separator token
        Catch ;end of token stream
            Break
        If (Token.Type != CodeTokenTypes.LINE_END && Token.Type != CodeTokenTypes.SEPARATOR) ;break the loop if there are no subexpressions left
            Break ;stop parsing subexpressions
    }
    If !(Token.Type = CodeTokenTypes.OPERATOR && CodeOperatorTable.LeftDenotation[Token.Value].IDENTIFIER = "SUBSCRIPT_END") ;mismatched braces
    {
        MsgBox Invalid array literal.
        Return, "ERROR: Invalid array literal." ;wip: better error handling
    }
    Return, CodeTreeOperation(CodeTreeIdentifier(Operator.Identifier),Operands)
}

CodeParseOperatorObjectAccessDynamic(Tokens,ByRef Index,ByRef Errors,Operator,LeftSide)
{
    global CodeTokenTypes, CodeOperatorTable
    Token := CodeParseToken(Tokens,Index) ;retrieve the current token
    If (Token.Type = CodeTokenTypes.OPERATOR ;operator token
        && CodeOperatorTable.LeftDenotation[Token.Value].IDENTIFIER = "SUBSCRIPT_END") ;object end operator token
    {
        CodeParseToken(Tokens,Index), Index ++ ;move past the closing brace token ;wip: handle errors
        Return, "ERROR: Blank object access." ;wip: empty set of object braces should give an error
    }
    Key := CodeParseExpression(Tokens,Index,Errors,0)
    Token := CodeParseToken(Tokens,Index), Index ++ ;wip: handle errors
    If !(Token.Type = CodeTokenTypes.OPERATOR && CodeOperatorTable.LeftDenotation[Token.Value].IDENTIFIER = "SUBSCRIPT_END") ;mismatched parentheses
    {
        MsgBox Invalid object access.
        Return, "ERROR: Invalid object access." ;wip: better error handling
    }
    Return, CodeTreeOperation(CodeTreeIdentifier(Operator.Identifier)
                                 ,[LeftSide,Key])
}

CodeParseOperatorTernaryIf(Tokens,ByRef Index,ByRef Errors,Operator,LeftSide)
{
    global CodeTokenTypes, CodeOperatorTable
    ;wip: handle first branch being blank
    FirstBranch := CodeTreeBlock([CodeParseExpression(Tokens,Index,Errors,Operator.RightBindingPower)]) ;parse the first branch
    Token := CodeParseToken(Tokens,Index) ;retrieve the current token
    If !(Token.Type = CodeTokenTypes.OPERATOR ;operator token
        && CodeOperatorTable.LeftDenotation[Token.Value].Identifier = "ELSE") ;ternary else operator token
        Return, CodeTreeOperation(CodeTreeIdentifier(Operator.Identifier)
                                 ,[LeftSide,FirstBranch])
    Index ++ ;move to the next token
    SecondBranch := CodeTreeBlock([CodeParseExpression(Tokens,Index,Errors,Operator.RightBindingPower)]) ;parse the second branch
    Return, CodeTreeOperation(CodeTreeIdentifier(Operator.Identifier)
                                 ,[LeftSide,FirstBranch,SecondBranch])
}
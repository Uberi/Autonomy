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
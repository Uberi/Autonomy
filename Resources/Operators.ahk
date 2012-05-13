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

CodeParseBooleanShortCircuit(Tokens,ByRef Index,ByRef Errors,Operator,LeftSide)
{
    Return, CodeTreeOperation(CodeTreeIdentifier(Operator.Identifier)
                ,[CodeTreeBlock([LeftSide]),CodeTreeBlock([CodeParseLine(Tokens,Index,Errors,Operator.RightBindingPower)])])
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
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
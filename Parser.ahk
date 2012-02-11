#NoEnv

#Include Resources/Operators.ahk
#Include Resources/Syntax Tree.ahk

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

;wip: position info for operation nodes
;wip: check for recursion depth terminating the expression by checking to make sure the token is the last one before returning, otherwise skip over close paren and keep parsing
;wip: type verification (possibly implement in type analyser module). need to add type information to operator table
;wip: treat line_end tokens as operators
;wip: unit test for blocks and statements
;wip: handle skipped parameters: Function(Param,,Param)

;/*
;#Warn All
;#Warn LocalSameAsGlobal, Off

#Include Resources\Reconstruct.ahk
#Include Lexer.ahk

SetBatchLines, -1

Code = 
(
Something a, b, c
4+5
Test 1, 2, 3
)
Code = 
(
a ? b : c
d && e || f
)

If CodeInit()
{
    Display("Error initializing code tools.`n") ;display error at standard output
    ExitApp ;fatal error
}

FileName := A_ScriptFullPath
CodeSetScript(FileName,Errors,Files) ;set the current script file

CodeLexInit()
Tokens := CodeLex(Code,Errors)

TimerBefore := 0, DllCall("QueryPerformanceCounter","Int64*",TimerBefore)

CodeTreeInit()

SyntaxTree := CodeParse(Tokens,Errors)

TimerAfter := 0, DllCall("QueryPerformanceCounter","Int64*",TimerAfter)
TickFrequency := 0, DllCall("QueryPerformanceFrequency","Int64*",TickFrequency)
TimerAfter := (TimerAfter - TimerBefore) / (TickFrequency / 1000)
MsgBox % TimerAfter . " ms`n`n" . Clipboard := CodeReconstructShowSyntaxTree(SyntaxTree)
ExitApp
*/

;parses a token stream
CodeParse(Tokens,ByRef Errors)
{ ;returns 1 on parsing error, 0 otherwise
    global CodeTokenTypes

    Index := 1
    ;wip: check for statements as the first line
    Try Token := CodeParseToken(Tokens,Index)
    Catch
        Return, CodeTreeOperation(CodeTreeIdentifier("EVALUATE")) ;empty evaluation node

    Operands := []
    Loop ;loop through one subexpression at a time
    {
        If (Token.Type = CodeTokenTypes.LINE_END || Index = 1) ;beginning of a line
            ObjInsert(Operands,CodeParseLine(Tokens,Index,Errors)) ;parse a line and add it to the operand array
        Else
            ObjInsert(Operands,CodeParseExpression(Tokens,Index,Errors,0)) ;parse an expression and add it to the operand array
        Try Token := CodeParseToken(Tokens,Index)
        Catch ;end of token stream
            Break
        If (Token.Type != CodeTokenTypes.LINE_END && Token.Type != CodeTokenTypes.SEPARATOR) ;invalid token
        {
            ;wip: handle errors here
            Break ;stop parsing subexpressions
        }
        Index ++
    }

    If (Index <= ObjMaxIndex(Tokens)) ;did not reach the end of the token stream
    {
        ;wip: better error handling
    }

    Return, CodeTreeGroup(Operands)
}

CodeParseLine(Tokens,ByRef Index,ByRef Errors,RightBindingPower = 0) ;wip: handle object.method or object[method] as a statement too
{
    global CodeTokenTypes, CodeOperatorTable
    ;check whether the line is a statement or not
    Statement := Tokens[Index]
    If ObjHasKey(Tokens,Index + 1) ;no tokens remain
    {
        NextToken := Tokens[Index + 1] ;wip: check for token stream end
        If (Statement.Type = CodeTokenTypes.IDENTIFIER ;current token is an identifier
            && (NextToken.Type = CodeTokenTypes.NUMBER ;next token is a number
                || NextToken.Type = CodeTokenTypes.STRING ;next token is a string
                || NextToken.Type = CodeTokenTypes.IDENTIFIER ;next token is an identifier
                || (NextToken.Type = CodeTokenTypes.OPERATOR ;next token is an operator
                    && !ObjHasKey(CodeOperatorTable.LeftDenotation,NextToken.Value)))) ;operator does not have a left denotation
            Return, CodeParseStatement(Tokens,Index,Errors)
    }
    Return, CodeParseExpression(Tokens,Index,Errors,RightBindingPower)
}

;parses an expression
CodeParseExpression(Tokens,ByRef Index,ByRef Errors,RightBindingPower)
{
    Try CurrentToken := CodeParseToken(Tokens,Index), Index ++
    Catch
    {
        MsgBox Missing token.
        Return, "ERROR: Missing token." ;wip: better error handling
    }
    LeftSide := CodeParseDispatchNullDenotation(Tokens,Index,Errors,CurrentToken) ;handle the null denotation - the token does not require tokens to its left
    Try NextToken := CodeParseToken(Tokens,Index)
    Catch ;end of token stream
        Return, LeftSide
    While, (RightBindingPower < CodeParseDispatchLeftBindingPower(NextToken)) ;loop while the current right binding power is less than that of the left binding power of the next token
    {
        CurrentToken := NextToken, NextToken := CodeParseToken(Tokens,Index), Index ++ ;store the token and move to the next one
        LeftSide := CodeParseDispatchLeftDenotation(Tokens,Index,Errors,CurrentToken,LeftSide) ;handle the left denotation - the token requires tokens to its left
        Try NextToken := CodeParseToken(Tokens,Index) ;retrieve the next token
        Catch
            Break
    }
    Return, LeftSide
}

;dispatches the retrieval of the left binding power of a given token
CodeParseDispatchLeftBindingPower(Token)
{ ;returns the left binding power of the given token
    global CodeTokenTypes
    TokenType := Token.Type
    If (TokenType = CodeTokenTypes.OPERATOR) ;operator token
        Return, CodeParseOperatorLeftBindingPower(Token)
    If (TokenType = CodeTokenTypes.NUMBER ;integer token
        || TokenType = CodeTokenTypes.STRING ;string token
        || TokenType = CodeTokenTypes.IDENTIFIER ;identifier token
        || TokenType = CodeTokenTypes.LINE_END) ;line end token
        Return, 0
    If (TokenType = CodeTokenTypes.SEPARATOR) ;separator token
        Return, 0
}

;dispatches the invocation of the null denotation handler of a given token
CodeParseDispatchNullDenotation(Tokens,ByRef Index,ByRef Errors,Token)
{
    global CodeTokenTypes
    TokenType := Token.Type
    If (TokenType = CodeTokenTypes.OPERATOR) ;operator token
        Return, CodeParseOperatorNullDenotation(Tokens,Index,Errors,Token) ;parse the operator in null denotation
    If (TokenType = CodeTokenTypes.NUMBER) ;integer token
        Return, CodeTreeNumber(Token.Value,Token.Position,Token.File) ;create an number tree node
    If (TokenType = CodeTokenTypes.STRING) ;string token
        Return, CodeTreeString(Token.Value,Token.Position,Token.File) ;create a string tree node
    If (TokenType = CodeTokenTypes.IDENTIFIER) ;identifier token
        Return, CodeTreeIdentifier(Token.Value,Token.Position,Token.File) ;create an identifier tree node
    If (TokenType = CodeTokenTypes.LINE_END) ;line end token
    {
        Token := CodeParseToken(Tokens,Index), Index ++ ;retrieve the token after the line end token
        Return, CodeParseDispatchNullDenotation(Tokens,Index,Errors,Token) ;dispatch the null denotation handler of the next token
    }
}

;dispatches the invocation of the left denotation handler of a given token
CodeParseDispatchLeftDenotation(Tokens,ByRef Index,ByRef Errors,Token,LeftSide)
{
    global CodeTokenTypes
    TokenType := Token.Type
    If (TokenType = CodeTokenTypes.OPERATOR) ;operator token
        Return, CodeParseOperatorLeftDenotation(Tokens,Index,Errors,Token,LeftSide)
    If (TokenType = CodeTokenTypes.NUMBER ;integer token
        || TokenType = CodeTokenTypes.STRING ;string token
        || TokenType = CodeTokenTypes.IDENTIFIER ;identifier token
        || TokenType = CodeTokenTypes.LINE_END) ;line end token ;wip: identifiers should allow for the command syntax
    {
        MsgBox Missing operator.
        Return, "ERROR: Missing operator." ;wip: better error handling
    }
}

CodeParseOperatorLeftBindingPower(Token)
{
    global CodeOperatorTable
    If ObjHasKey(CodeOperatorTable.LeftDenotation,Token.Value)
        Return, CodeOperatorTable.LeftDenotation[Token.Value].LeftBindingPower
    Return, CodeOperatorTable.NullDenotation[Token.Value].LeftBindingPower
}

CodeParseOperatorNullDenotation(Tokens,ByRef Index,ByRef Errors,Token)
{
    global CodeOperatorTable
    If ObjHasKey(CodeOperatorTable.NullDenotation,Token.Value)
    {
        Operator := CodeOperatorTable.NullDenotation[Token.Value] ;retrieve operator object
        Return, Operator.Handler.(Tokens,Index,Errors,Operator) ;dispatch the null denotation handler for the operator ;wip: function reference call
    }
    MsgBox Invalid operator usage.
    Return, "ERROR: Invalid operator usage." ;wip: better error handling
}

CodeParseOperatorLeftDenotation(Tokens,ByRef Index,ByRef Errors,Token,LeftSide)
{
    global CodeTokenTypes, CodeOperatorTable
    If !ObjHasKey(CodeOperatorTable.LeftDenotation,Token.Value)
    {
        MsgBox Invalid operator usage.
        Return, "ERROR: Invalid operator usage." ;wip: better error handling
    }
    Operator := CodeOperatorTable.LeftDenotation[Token.Value] ;retrieve operator object
    Return, Operator.Handler.(Tokens,Index,Errors,Operator,LeftSide) ;dispatch the left denotation handler for the operator ;wip: function reference call
}

CodeParseOperatorPrefix(Tokens,ByRef Index,ByRef Errors,Operator)
{
    Return, CodeTreeOperation(CodeTreeIdentifier(Operator.Identifier)
                ,[CodeParseLine(Tokens,Index,Errors,Operator.RightBindingPower)])
}

CodeParseOperatorInfix(Tokens,ByRef Index,ByRef Errors,Operator,LeftSide)
{
    Return, CodeTreeOperation(CodeTreeIdentifier(Operator.Identifier)
                ,[LeftSide,CodeParseLine(Tokens,Index,Errors,Operator.RightBindingPower)])
}

CodeParseOperatorPostfix(Tokens,ByRef Index,ByRef Errors,Operator,LeftSide)
{
    Return, CodeTreeOperation(CodeTreeIdentifier(Operator.Identifier)
                ,[LeftSide])
}

;get the next token
CodeParseToken(Tokens,ByRef Index)
{
    If (Index > ObjMaxIndex(Tokens))
        Throw Exception("Token stream end.",-1)
    Return, Tokens[Index]
}
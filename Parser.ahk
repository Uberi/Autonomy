#NoEnv

#Include Resources/Operators.ahk
#Include Resources/Syntax Tree.ahk

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

;wip: position info for operation nodes
;wip: check for recursion depth terminating the expression by checking to make sure the token is the last one before returning, otherwise skip over close paren and keep parsing
;wip: type verification (possibly implement in type analyser module). need to add type information to operator table
;wip: treat line_end tokens as operators
;wip: unit test for blocks and statements
;wip: handle skipped parameters: Function(Param,,Param)

;/*
#Warn All
#Warn LocalSameAsGlobal, Off

#Include Resources\Functions.ahk
#Include Resources\Reconstruct.ahk
#Include Lexer.ahk

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
Code = abc 123

l := new Lexer(Code)
p := new Parser(l)

MsgBox % ShowObject(p.Expression(0))
ExitApp

MsgBox % Clipboard := CodeReconstructShowSyntaxTree(SyntaxTree)
ExitApp
*/

class Parser
{
    __New(Lexer)
    {
        this.Lexer := Lexer
    }

    class Node
    {
        class Operation ;wip: add position and length according to the position and length of the operator
        {
            __New(Value,Parameters)
            {
                this.Type := "Operation"
                this.Value := Value
                this.Parameters := Parameters
            }
        }

        class Block
        {
            __New(Value,Position,Length)
            {
                this.Type := "Block"
                this.Value := Value
                this.Position := Position
                this.Length := Length
            }
        }

        class String
        {
            __New(Value,Position,Length)
            {
                this.Type := "String"
                this.Value := Value
                this.Position := Position
            }
        }

        class Identifier
        {
            __New(Value,Position,Length)
            {
                this.Type := "Identifier"
                this.Value := Value
                this.Position := Position
                this.Length := Length
            }
        }

        class Number
        {
            __New(Value,Position,Length)
            {
                this.Type := "Number"
                this.Value := Value
                this.Position := Position
                this.Length := Length
            }
        }
    }

    Statement(RightBindingPower)
    {
        Result := this.Expression(RightBindingPower) ;parse either the expression or the beginning of the statement

        this.Ignore()

        ;check for line end or end of input
        try Token := this.Lexer.Line()
        catch
            Return, Result ;not a statement

        ;parse the statement parameters ;wip: support multiple parameters
        Parameters := this.Expression(RightBindingPower)
        Return, new this.Node.Operation(Result,Parameters,Token.Position,0) ;wip: position and length
    }

    Expression(RightBindingPower)
    {
        try LeftSide := this.NullDenotation(Token)
        catch
            throw Exception("Missing token.",A_ThisFunc,this.Lexer.Position)

        ;retrieve the next token
        try Token := this.Lexer.Next()
        catch
            Return, LeftSide

        While, RightBindingPower < this.LeftBindingPower(Token)
        {
            LeftSide := this.LeftDenotation(Token,LeftSide)

            try Token := this.Lexer.Peek() ;wip: should get the token before this one
            catch
                Break
        }
        Return, LeftSide
    }

    LeftBindingPower(Token)
    {
        If Token.Type = "Operator"
            Return, 0 ;wip
        If Token.Type = "Line"
        {
            ;wip
        }
        If Token.Type = "String"
            Return, 0
        If Token.Type = "Identifier"
            Return, 0
        If Token.Type = "Number"
            Return, 0
        If Token.Type = "Comment"
        {
            ;wip
        }
        throw Exception("Invalid token.",A_ThisFunc,Token.Position)
    }

    NullDenotation()
    {
        try
        {
            Token := this.Lexer.OperatorNull()
            Return, this.OperatorPrefix(Token)
        }
        catch
        try
        {
            Token := this.Lexer.Line()
            ;wip
        }
        catch
        try
        {
            Token := this.Lexer.String()
            Return, new this.Node.String(Token.Value,Token.Position,Token.Length)
        }
        catch
        try
        {
            Token := this.Lexer.Identifier()
            Return, new this.Node.Identifier(Token.Value,Token.Position,Token.Length)
        }
        catch
        try
        {
            Token := this.Lexer.Number()
            Return, new this.Node.Number(Token.Value,Token.Position,Token.Length)
        }
        catch
        try
        {
            Token := this.Lexer.Comment()
            ;wip
        }
        throw Exception("Invalid token.",A_ThisFunc,Token.Position)
    }

    LeftDenotation(LeftSide)
    {
        try
        {
            Token := this.Lexer.OperatorLeft()
            Return, new this.Node.Operation(Token.Value,Parameters,Token.Position,Token.Length) ;wip: parameters
        }
        catch
            throw Exception("Invalid token.",A_ThisFunc,Token.Position)
    }

    OperatorPrefix(Token)
    {
        Operation := new this.Node.Identifier(Token.Value,Token.Position,Token.Length)
        Parameters := [this.Expression(RightBindingPower)]
        Return, new this.Node.Operation(Operation,Parameters)
    }

    OperatorInfix(Token,LeftSide)
    {
        Operation := new this.Node.Identifier(Token.Value,Token.Position,Token.Length)
        Parameters := [LeftSide,this.Expression(RightBindingPower)]
        Return, new this.Node.Operation(Operation,Parameters)
    }

    OperatorPostfix(Token,LeftSide)
    {
        Operation := new this.Node.Identifier(Token.Value,Token.Position,Token.Length)
        Parameters := [LeftSide]
        Return, new this.Node.Operation(Operation,Parameters)
    }

    OperatorEvaluate(Token)
    {
        Token := this.Lexer.OperatorNull()
        If Token.Value != "evaluate"
            throw Exception("Invalid evaluation.",A_ThisFunc,Token.Position)
    }

    OperatorBlock(Token)
    {
        
    }

    OperatorArray(Token)
    {
        
    }

    OperatorTernary(Token,LeftSide)
    {
        
    }

    OperatorCall(Token,LeftSide)
    {
        
    }

    OperatorSubscript(Token,LeftSide)
    {
        
    }

    Ignore()
    {
        Loop
        {
            try this.Lexer.Whitespace()
            catch
            try this.Lexer.Comment()
            catch
                Break
        }
        try this.Lexer.Whitespace()
        catch
        {
            
        }
    }
}

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
            Operands.Insert(CodeParseLine(Tokens,Index,Errors)) ;parse a line and add it to the operand array
        Else
            Operands.Insert(CodeParseExpression(Tokens,Index,Errors,0)) ;parse an expression and add it to the operand array
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

    If (Index <= Tokens.MaxIndex()) ;did not reach the end of the token stream
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
    If Tokens.HasKey(Index + 1) ;no tokens remain
    {
        NextToken := Tokens[Index + 1] ;wip: check for token stream end
        If (Statement.Type = CodeTokenTypes.IDENTIFIER ;current token is an identifier
            && (NextToken.Type = CodeTokenTypes.NUMBER ;next token is a number
                || NextToken.Type = CodeTokenTypes.STRING ;next token is a string
                || NextToken.Type = CodeTokenTypes.IDENTIFIER ;next token is an identifier
                || (NextToken.Type = CodeTokenTypes.OPERATOR ;next token is an operator
                    && !CodeOperatorTable.LeftDenotation.HasKey(NextToken.Value)))) ;operator does not have a left denotation
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
        CurrentToken := NextToken, Index ++ ;store the token and move to the next one
        LeftSide := CodeParseDispatchLeftDenotation(Tokens,Index,Errors,CurrentToken,LeftSide) ;handle the left denotation - the token requires tokens to its left
        Try NextToken := CodeParseToken(Tokens,Index) ;retrieve the next token
        Catch
            Break
    }
    Return, LeftSide
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

CodeParseOperatorLeftBindingPower(Token)
{
    global CodeOperatorTable
    If CodeOperatorTable.LeftDenotation.HasKey(Token.Value)
        Return, CodeOperatorTable.LeftDenotation[Token.Value].LeftBindingPower
    Return, CodeOperatorTable.NullDenotation[Token.Value].LeftBindingPower
}

CodeParseOperatorNullDenotation(Tokens,ByRef Index,ByRef Errors,Token)
{
    global CodeOperatorTable
    If CodeOperatorTable.NullDenotation.HasKey(Token.Value)
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
    If !CodeOperatorTable.LeftDenotation.HasKey(Token.Value)
    {
        MsgBox Invalid operator usage.
        Return, "ERROR: Invalid operator usage." ;wip: better error handling
    }
    Operator := CodeOperatorTable.LeftDenotation[Token.Value] ;retrieve operator object
    Return, Operator.Handler.(Tokens,Index,Errors,Operator,LeftSide) ;dispatch the left denotation handler for the operator ;wip: function reference call
}

;get the next token
CodeParseToken(Tokens,ByRef Index)
{
    If (Index > Tokens.MaxIndex())
        Throw Exception("Token stream end.",-1)
    Return, Tokens[Index]
}
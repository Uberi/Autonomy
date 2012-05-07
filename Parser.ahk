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

;wip: position info for operation nodes
;wip: check for recursion depth terminating the expression by checking to make sure the token is the last one before returning, otherwise skip over close paren and keep parsing
;wip: type verification (possibly implement in type analyser module). need to add type information to operator table
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
            try LeftSide := this.LeftDenotation(Token,LeftSide) ;wip: there may be errors other than the lack of tokens
            catch
                Break

            try Token := this.Lexer.Peek() ;wip: maybe should get the token before this one, or maybe this isn't needed at all
            catch
                Break
        }
        Return, LeftSide
    }

    LeftBindingPower(Token)
    {
        If Token.Type = "Operator"
            Return, Token.Value.LeftBindingPower
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
            throw Exception("Invalid operator.",A_ThisFunc,Token.Position)
    }

    OperatorPrefix(Token)
    {
        Operation := new this.Node.Identifier(Token.Value.Identifier,Token.Position,Token.Length)
        Parameters := [this.Expression(Token.Value.RightBindingPower)]
        Return, new this.Node.Operation(Operation,Parameters)
    }

    OperatorInfix(Token,LeftSide)
    {
        Operation := new this.Node.Identifier(Token.Value.Identifier,Token.Position,Token.Length)
        Parameters := [LeftSide,this.Expression(Token.Value.RightBindingPower)]
        Return, new this.Node.Operation(Operation,Parameters)
    }

    OperatorPostfix(Token,LeftSide)
    {
        Operation := new this.Node.Identifier(Token.Value.Identifier,Token.Position,Token.Length)
        Parameters := [LeftSide]
        Return, new this.Node.Operation(Operation,Parameters)
    }

    OperatorEvaluate(Token)
    {
        Token := this.Lexer.OperatorNull()
        If Token.Value != "evaluate"
            throw Exception("Invalid evaluation.",A_ThisFunc,Token.Position)
        Parameters := []
        Loop
        {
            ;wip
        }
        Return, new this.Node.Operation(Token.Value,Parameters)
    }

    OperatorBlock(Token)
    {
        ;wip
    }

    OperatorArray(Token)
    {
        ;wip
    }

    OperatorTernary(Token,LeftSide)
    {
        ;wip
    }

    OperatorCall(Token,LeftSide)
    {
        ;wip
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
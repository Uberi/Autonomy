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
Code = abc 123, 456
Code = 1 - 2 * 3 + 5 ** 3

l := new Lexer(Code)
p := new Parser(l)

MsgBox % Reconstruct.Tree(p.Expression())
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
        class Operation
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

    Statement(RightBindingPower = 0)
    {
        Value := this.Expression(RightBindingPower) ;parse either the expression or the beginning of the statement
        this.Ignore()

        ;check for line end or end of input
        try Token := this.Lexer.Line()
        catch ;wip: should ignore end of input as statement call
        {
            Parameters := []
            Loop
            {
                this.Ignore()
                Parameters.Insert(this.Expression(RightBindingPower)) ;wip: should use this.Statement, but can't right now because of infinite recursion
                this.Ignore()
                try this.Lexer.Separator()
                catch
                    Break
            }
            Return, new this.Node.Operation(Value,Parameters,this.Lever.Position,0) ;wip: position and length
        }
        Return, Result ;not a statement
    }

    Expression(RightBindingPower = 0)
    {
        try LeftSide := this.NullDenotation()
        catch
            throw Exception("Missing token.",A_ThisFunc,this.Lexer.Position)

        Loop
        {
            this.Ignore()
            Position1 := this.Lexer.Position
            try Operator := this.Lexer.OperatorLeft()
            catch
                Break

            If Operator.Value.LeftBindingPower <= RightBindingPower
                Break

            this.Ignore()
            LeftSide := this.OperatorInfix(Operator,LeftSide)
        }
        this.Lexer.Position := Position1
        Return, LeftSide
    }

    NullDenotation()
    {
        this.Ignore()
        try
        {
            Operator := this.Lexer.OperatorLeft()
            Return, this.OperatorPrefix(Operator)
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
        throw Exception("Invalid token.",A_ThisFunc,this.Lexer.Position)
    }

    OperatorPrefix(Operator)
    {
        RightSide := this.Expression(Operator.Value.RightBindingPower)

        Operation := new this.Node.Identifier(Operator.Value.Identifier,Operator.Position,Operator.Length)
        Parameters := [RightSide]
        Return, new this.Node.Operation(Operation,Parameters)
    }

    OperatorInfix(Operator,LeftSide)
    {
        RightSide := this.Expression(Operator.Value.RightBindingPower)

        Operation := new this.Node.Identifier(Operator.Value.Identifier,Operator.Position,Operator.Length)
        Parameters := [LeftSide,RightSide]
        Return, new this.Node.Operation(Operation,Parameters)
    }

    OperatorEvaluate(Token)
    {
        Position1 := this.Lexer.Position
        Token := this.Lexer.OperatorNull()
        If Token.Value != "evaluate"
        {
            this.Lexer.Position := Position1
            throw Exception("Invalid evaluation.",A_ThisFunc,Token.Position)
        }
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
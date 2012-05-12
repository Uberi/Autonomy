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

;wip: handle skipped parameters: Function(Param,,Param)
;wip: when AHKv2 gets the new behavior for logical AND and OR (returns matched value on success), use idioms like "this.Statement() || this.Expression()" and "this.Identifier() && this.Expression()"

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
Code = 1 - 2 * (3 + 5) ** 3

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

        ;wip: should ignore end of input as statement call
        ;check for line end or end of input
        If !this.Lexer.Line()
        {
            Parameters := []
            Loop
            {
                this.Ignore()
                Parameters.Insert(this.Expression(RightBindingPower)) ;wip: should use this.Statement, but can't right now because of infinite recursion
                this.Ignore()
                If !this.Lexer.Separator()
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
            Operator := this.Lexer.OperatorLeft()

            If !Operator
                Break
            If Operator.Value.LeftBindingPower <= RightBindingPower
                Break

            this.Ignore()
            LeftSide := this.OperatorLeft(Operator,LeftSide)
        }
        this.Lexer.Position := Position1
        Return, LeftSide
    }

    NullDenotation()
    {
        this.Ignore()

        Token := this.Lexer.OperatorNull()
        If Token
            Return, this.OperatorNull(Token)

        Token := this.Lexer.Line()
        If Token
            Return ;wip

        Token := this.Lexer.String()
        If Token
            Return, new this.Node.String(Token.Value,Token.Position,Token.Length)

        Token := this.Lexer.Identifier()
        If Token
            Return, new this.Node.Identifier(Token.Value,Token.Position,Token.Length)

        Token := this.Lexer.Number()
            Return, new this.Node.Number(Token.Value,Token.Position,Token.Length)

        throw Exception("Invalid token.",A_ThisFunc,this.Lexer.Position)
    }

    OperatorNull(Operator)
    {
        Result := this.OperatorEvaluate(Operator)
        If Result
            Return, Result

        RightSide := this.Expression(Operator.Value.RightBindingPower)
        Operation := new this.Node.Identifier(Operator.Value.Identifier,Operator.Position,Operator.Length)
        Parameters := [RightSide]
        Return, new this.Node.Operation(Operation,Parameters)
    }

    OperatorLeft(Operator,LeftSide)
    {
        RightSide := this.Expression(Operator.Value.RightBindingPower)
        Operation := new this.Node.Identifier(Operator.Value.Identifier,Operator.Position,Operator.Length)
        Parameters := [LeftSide,RightSide]
        Return, new this.Node.Operation(Operation,Parameters)
    }

    OperatorEvaluate(Operator)
    {
        If Operator.Value.Identifier != "evaluate"
            Return, False
        Parameters := []
        Loop
        {
            ;Parameters.Insert(this.Statement())
            Parameters.Insert(this.Expression())

            Position1 := this.Lexer.Position
            If !(this.Lexer.Separator()
                || this.Lexer.Line())
            {
                Token := this.Lexer.OperatorLeft()
                If Token && Token.Value.Identifier = "end"
                    Break
                this.Lexer.Position := Position1
                throw Exception("Invalid operator.")
            }
        }
        Operation := new this.Node.Identifier(Operator.Value.Identifier,Operator.Position,Operator.Length)
        Return, new this.Node.Operation(Operation,Parameters)
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
            If !(this.Lexer.Whitespace()
                || this.Lexer.Comment())
                Break
        }
        this.Lexer.Whitespace()
    }
}
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
;Code = 1 + sin x, y
;Code = sin x + 1, y
;Code = 1 - 2 * 3 + 5 ** 3
;Code = 1 - 2 * (3 + 5, 6e3) ** 3
;Code = a[b][c]
;Code = a(b)(c,d)(e)
Code = a ? b := 2 : c := 3

l := new Lexer(Code)
p := new Parser(l)

;MsgBox % Reconstruct.Tree(p.Expression())
MsgBox % Reconstruct.Tree(p.Statement())
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
            __New(Contents,Position,Length)
            {
                this.Type := "Block"
                this.Contents := Contents
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

        ;check for line end
        this.Ignore()
        Position1 := this.Lexer.Position
        If this.Lexer.Line() || this.Lexer.Separator() || this.Lexer.Map() || this.Lexer.OperatorLeft() ;statement not found
        {
            this.Lexer.Position := Position1 ;move back to before the line of separator
            Return, Value
        }

        ;wip: need a better way to check end of input
        ;check for end of input
        Position1 := this.Lexer.Position
        Token := this.Lexer.Next()
        this.Lexer.Position := Position1
        If !Token ;statement not found
            Return, Value

        Parameters := []
        Loop
        {
            this.Ignore()
            Parameters.Insert(this.Statement())
            this.Ignore()
            If !this.Lexer.Separator()
                Break
        }
        Return, new this.Node.Operation(Value,Parameters)
    }

    Expression(RightBindingPower = 0)
    {
        LeftSide := this.NullDenotation()
        Loop
        {
            this.Ignore()
            Position1 := this.Lexer.Position
            Operator := this.Lexer.OperatorLeft()

            If !Operator
                Break
            If Operator.Value.LeftBindingPower <= RightBindingPower
            {
                this.Lexer.Position := Position1
                Break
            }

            this.Ignore()
            LeftSide := this.OperatorLeft(Operator,LeftSide)
        }
        Return, LeftSide
    }

    NullDenotation()
    {
        this.Ignore()

        Token := this.Lexer.OperatorNull()
        If Token
            Return, this.OperatorNull(Token)

        If this.Lexer.Line()
            Return, this.NullDenotation()

        Token := this.Lexer.String()
        If Token
            Return, new this.Node.String(Token.Value,Token.Position,Token.Length)

        Token := this.Lexer.Identifier()
        If Token
            Return, new this.Node.Identifier(Token.Value,Token.Position,Token.Length)

        Token := this.Lexer.Number()
        If Token
            Return, new this.Node.Number(Token.Value,Token.Position,Token.Length)

        throw Exception("Missing token.",A_ThisFunc,this.Lexer.Position)
    }

    OperatorNull(Operator)
    {
        Result := this.Evaluate(Operator)
        If Result
            Return, Result
        Result := this.Block(Operator)
        If Result
            Return, Result
        Result := this.Array(Operator)
        If Result
            Return, Result

        RightSide := this.Statement(Operator.Value.RightBindingPower)

        Operation := new this.Node.Identifier(Operator.Value.Identifier,Operator.Position,Operator.Length)
        Parameters := [RightSide]
        Return, new this.Node.Operation(Operation,Parameters)
    }

    OperatorLeft(Operator,LeftSide)
    {
        Result := this.Call(Operator,LeftSide)
        If Result
            Return, Result
        Result := this.Subscript(Operator,LeftSide)
        If Result
            Return, Result
        Result := this.Ternary(Operator,LeftSide)
        If Result
            Return, Result
        Result := this.BooleanShortCircuit(Operator,LeftSide)
        If Result
            Return, Result

        RightSide := this.Statement(Operator.Value.RightBindingPower)

        Operation := new this.Node.Identifier(Operator.Value.Identifier,Operator.Position,Operator.Length)
        Parameters := [LeftSide,RightSide]
        Return, new this.Node.Operation(Operation,Parameters)
    }

    Evaluate(Operator)
    {
        If Operator.Value.Identifier != "evaluate"
            Return, False

        Parameters := []
        Loop
        {
            Parameters.Insert(this.Statement())

            If !(this.Lexer.Separator()
                || this.Lexer.Line())
            {
                Position1 := this.Lexer.Position
                Token := this.Lexer.OperatorLeft()
                If Token && Token.Value.Identifier = "end"
                    Break
                throw Exception("Invalid evaluation end.",A_ThisFunc,Position1)
            }
        }

        Operation := new this.Node.Identifier(Operator.Value.Identifier,Operator.Position,Operator.Length)
        Return, new this.Node.Operation(Operation,Parameters)
    }

    Block(Operator)
    {
        If Operator.Value.Identifier != "block"
            Return, False

        Contents := []

        ;check for empty block
        this.Ignore()
        Position1 := this.Lexer.Position
        Token := this.Lexer.OperatorLeft()
        If Token && Token.Value.Identifier = "block_end"
        {
            Length := this.Lexer.Position - Position1
            Return, new this.Node.Block(Contents,Position1,Length)
        }
        this.Lexer.Position := Position1

        Loop
        {
            Contents.Insert(this.Statement())

            If !(this.Lexer.Separator()
                || this.Lexer.Line())
            {
                Position1 := this.Lexer.Position
                Token := this.Lexer.OperatorLeft()
                If Token && Token.Value.Identifier = "block_end"
                    Break
                throw Exception("Invalid block end.",A_ThisFunc,Position1)
            }
        }

        Length := this.Lexer.Position - Position1
        Return, new this.Node.Block(Contents,Position1,Length)
    }

    Array(Operator)
    {
        If Operator.Value.Identifier != "array"
            Return, False

        Parameters := []

        ;check for empty array
        this.Ignore()
        Position1 := this.Lexer.Position
        Token := this.Lexer.OperatorLeft()
        If Token && Token.Value.Identifier = "subscript_end"
        {
            Operation := new this.Node.Identifier(Operator.Value.Identifier,Operator.Position,Operator.Length)
            Return, new this.Node.Operation(Operation,Parameters)
        }
        this.Lexer.Position := Position1

        Loop
        {
            Parameters.Insert(this.Statement())

            If !(this.Lexer.Separator()
                || this.Lexer.Line())
            {
                Position1 := this.Lexer.Position
                Token := this.Lexer.OperatorLeft()
                If Token && Token.Value.Identifier = "subscript_end"
                    Break
                throw Exception("Invalid array end.",A_ThisFunc,Position1)
            }
        }

        Operation := new this.Node.Identifier(Operator.Value.Identifier,Operator.Position,Operator.Length)
        Return, new this.Node.Operation(Operation,Parameters)
    }

    Call(Operator,LeftSide)
    {
        If Operator.Value.Identifier != "call"
            Return, False

        Parameters := []
        Loop
        {
            Parameters.Insert(this.Statement())

            If !this.Lexer.Separator()
            {
                Position1 := this.Lexer.Position
                Token := this.Lexer.OperatorLeft()
                If Token && Token.Value.Identifier = "end"
                    Break
                throw Exception("Invalid call end.",A_ThisFunc,Position1)
            }
        }

        Return, new this.Node.Operation(LeftSide,Parameters)
    }

    Subscript(Operator,LeftSide)
    {
        If Operator.Value.Identifier != "subscript"
            Return, False

        RightSide := this.Statement()

        Position1 := this.Lexer.Position
        Token := this.Lexer.OperatorLeft()
        If Token && Token.Value.Identifier = "subscript_end"
        {
            Operation := new this.Node.Identifier(Operator.Value.Identifier,Operator.Position,Operator.Length)
            Parameters := [LeftSide,RightSide]
            Return, new this.Node.Operation(Operation,Parameters)
        }
        throw Exception("Invalid subscript end.",A_ThisFunc,Position1)
    }

    Ternary(Operator,LeftSide)
    {
        If Operator.Value.Identifier != "if"
            Return, False

        Branch := this.Statement(Operator.RightBindingPower)
        If !this.Lexer.Map()
        {
            ;wip: binary ternary operator
            throw Exception("Invalid ternary else.",A_ThisFunc,Position1)
        }
        Alternative := this.Statement(Operator.RightBindingPower)

        Branch := new this.Node.Block([Branch],0,0)
        Alternative := new this.Node.Block([Alternative],0,0)

        Operation := new this.Node.Identifier(Operator.Value.Identifier,Operator.Position,Operator.Length)
        Parameters := [LeftSide,Branch,Alternative]
        Return, new this.Node.Operation(Operation,Parameters)
    }

    BooleanShortCircuit(Operator,LeftSide)
    {
        If Operator.Value.Identifier != "or" && Operator.Value.Identifier != "and"
            Return, False

        RightSide := this.Statement(Operator.Value.RightBindingPower)

        LeftSide := new this.Node.Block([LeftSide],0,0)
        RightSide := new this.Node.Block([RightSide],0,0)

        Operation := new this.Node.Identifier(Operator.Value.Identifier,Operator.Position,Operator.Length)
        Parameters := [LeftSide,RightSide]
        Return, new this.Node.Operation(Operation,Parameters)
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
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
;wip: handle named parameters, including dynamically calculated ones, in Call() and in Statement()
;wip: when AHKv2 gets the new behavior for logical AND and OR (returns matched value on success), use idioms like "this.Statement() || this.Expression()" and "this.Identifier() && this.Expression()"

/*
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
;Code = x !y
;Code = 1 - 2 * 3 + 5 ** 3
;Code = 1 - 2 * (3 + 5, 6e3) ** 3
;Code = a.b[c].d.e[f]
;Code = a(b)(c,d)(e)
;Code = a ? b := 2 : c := 3
;Code = {}()
Code = x := 'name

l := new Lexer(Code)
p := new Parser(l)

;MsgBox % Reconstruct.Tree(p.Expression())
;MsgBox % Reconstruct.Tree(p.Statement())
MsgBox % Reconstruct.Tree(p.Parse())
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
            __New(Value,Parameters,Position,Length)
            {
                this.Type := "Operation"
                this.Value := Value
                this.Parameters := Parameters
                this.Position := Position
                this.Length := Length
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

        class Symbol
        {
            __New(Value,Position,Length)
            {
                this.Type := "Symbol"
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
                this.Length := Length
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

    Parse()
    {
        Position1 := this.Lexer.Position
        this.Ignore()

        Parameters := []
        Loop
        {
            ;parse a statement
            Parameters.Insert(this.Statement())

            ;ensure the statement is terminated by a
            If !this.Lexer.Line()
            {
                ;check for end of input
                Position2 := this.Lexer.Position
                If !this.Lexer.Next()
                    Break
                this.Lexer.Position := Position2
                throw Exception("Invalid statement end.",A_ThisFunc,Position1)
            }
        }

        Operation := new this.Node.Identifier("_evaluate",Position1,0)
        Length := this.Lexer.Position - Position1
        Return, new this.Node.Operation(Operation,Parameters,Position1,Length)
    }

    Statement(RightBindingPower = 0)
    {
        ;parse either the expression or the beginning of the statement
        Position1 := this.Lexer.Position
        Value := this.Expression(RightBindingPower)

        ;check for line end
        Position2 := this.Lexer.Position
        this.Ignore()
        If this.Lexer.Line() || this.Lexer.Separator() || this.Lexer.Map() || this.Lexer.OperatorLeft() ;statement not found
        {
            this.Lexer.Position := Position2 ;move back to before this token
            Return, Value
        }

        ;check for end of input
        Position2 := this.Lexer.Position
        If !this.Lexer.Next() ;statement not found
            Return, Value
        this.Lexer.Position := Position2

        ;parse the parameters
        Parameters := []
        Loop
        {
            Parameters.Insert(this.Statement())
            this.Ignore()
            If !this.Lexer.Separator()
                Break
        }

        Length := this.Lexer.Position - Position1
        Return, new this.Node.Operation(Value,Parameters,Position1,Length)
    }

    Expression(RightBindingPower = 0)
    {
        this.Ignore()
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
        Token := this.Lexer.OperatorNull()
        If Token
            Return, this.OperatorNull(Token)

        If this.Lexer.Line()
            Return, this.NullDenotation()

        Token := this.Lexer.Symbol()
        If Token
            Return, new this.Node.Symbol(Token.Value,Token.Position,Token.Length)

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
        Length := this.Lexer.Position - Operator.Position
        Return, new this.Node.Operation(Operation,Parameters,Operator.Position,Length)
    }

    OperatorLeft(Operator,LeftSide)
    {
        Result := this.Call(Operator,LeftSide)
        If Result
            Return, Result
        Result := this.Subscript(Operator,LeftSide)
        If Result
            Return, Result
        Result := this.SubscriptIdentifier(Operator,LeftSide)
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
        ;wip: length and position
        Return, new this.Node.Operation(Operation,Parameters,0,0)
    }

    Evaluate(Operator)
    {
        If Operator.Value.Identifier != "_evaluate"
            Return, False

        Parameters := []
        Loop
        {
            ;parse a statement
            Parameters.Insert(this.Statement())

            If !this.Lexer.Line()
            {
                Position1 := this.Lexer.Position
                Token := this.Lexer.OperatorLeft()
                If Token && Token.Value.Identifier = "_end"
                    Break
                throw Exception("Invalid statement end.",A_ThisFunc,Position1)
            }
        }

        Operation := new this.Node.Identifier(Operator.Value.Identifier,Operator.Position,Operator.Length)
        Length := this.Lexer.Position - Operator.Position
        Return, new this.Node.Operation(Operation,Parameters,Operator.Position,Length)
    }

    Block(Operator)
    {
        If Operator.Value.Identifier != "_block"
            Return, False

        Contents := []

        ;check for empty block
        this.Ignore()
        Position1 := this.Lexer.Position
        Token := this.Lexer.OperatorLeft()
        If Token && Token.Value.Identifier = "_block_end"
        {
            Length := this.Lexer.Position - Position1
            Return, new this.Node.Block(Contents,Position1,Length)
        }
        this.Lexer.Position := Position1

        Loop
        {
            Contents.Insert(this.Statement())

            If !this.Lexer.Line()
            {
                Position1 := this.Lexer.Position
                Token := this.Lexer.OperatorLeft()
                If Token && Token.Value.Identifier = "_block_end"
                    Break
                throw Exception("Invalid block end.",A_ThisFunc,Position1)
            }
        }

        Length := this.Lexer.Position - Position1
        Return, new this.Node.Block(Contents,Position1,Length)
    }

    Array(Operator)
    {
        If Operator.Value.Identifier != "_array"
            Return, False

        Parameters := []

        ;check for empty array
        this.Ignore()
        Position1 := this.Lexer.Position
        Token := this.Lexer.OperatorLeft()
        If Token && Token.Value.Identifier = "_subscript_end"
        {
            Operation := new this.Node.Identifier(Operator.Value.Identifier,Operator.Position,Operator.Length)
            Length := this.Lexer.Position - Operator.Position
            Return, new this.Node.Operation(Operation,Parameters,Operator.Position,Length)
        }
        this.Lexer.Position := Position1

        Loop
        {
            Parameters.Insert(this.Statement())

            If !this.Lexer.Separator()
            {
                Position1 := this.Lexer.Position
                Token := this.Lexer.OperatorLeft()
                If Token && Token.Value.Identifier = "_subscript_end"
                    Break
                throw Exception("Invalid array end.",A_ThisFunc,Position1)
            }
        }

        Operation := new this.Node.Identifier(Operator.Value.Identifier,Operator.Position,Operator.Length)
        Length := this.Lexer.Position - Operator.Position
        Return, new this.Node.Operation(Operation,Parameters,Operator.Position,Length)
    }

    Call(Operator,LeftSide)
    {
        If Operator.Value.Identifier != "_call"
            Return, False

        Parameters := []

        ;check for empty parameter list
        this.Ignore()
        Position1 := this.Lexer.Position
        Token := this.Lexer.OperatorLeft()
        If Token && Token.Value.Identifier = "_end"
        {
            ;wip: position and length
            Return, new this.Node.Operation(LeftSide,Parameters,0,0)
        }
        this.Lexer.Position := Position1

        Loop
        {
            ;parse a statement
            Parameters.Insert(this.Statement())

            If !this.Lexer.Separator()
            {
                Position1 := this.Lexer.Position
                Token := this.Lexer.OperatorLeft()
                If Token && Token.Value.Identifier = "_end"
                    Break
                throw Exception("Invalid call end.",A_ThisFunc,Position1)
            }
        }

        ;wip: position and length
        Return, new this.Node.Operation(LeftSide,Parameters,0,0)
    }

    Subscript(Operator,LeftSide)
    {
        If Operator.Value.Identifier != "_subscript"
            Return, False

        RightSide := this.Statement()

        Position1 := this.Lexer.Position
        Token := this.Lexer.OperatorLeft()
        If Token && Token.Value.Identifier = "_subscript_end"
        {
            Operation := new this.Node.Identifier(Operator.Value.Identifier,Operator.Position,Operator.Length)
            Parameters := [LeftSide,RightSide]
            ;wip: position and length
            Return, new this.Node.Operation(Operation,Parameters,0,0)
        }
        throw Exception("Invalid subscript end.",A_ThisFunc,Position1)
    }

    SubscriptIdentifier(Operator,LeftSide)
    {
        If Operator.Value.Identifier != "_subscript_identifier"
            Return, False

        RightSide := this.Statement(Operator.Value.RightBindingPower)
        RightSide := new this.Node.Symbol(RightSide,0,0)

        Operation := new this.Node.Identifier(Operator.Value.Identifier,Operator.Position,Operator.Length)
        Parameters := [LeftSide,RightSide]
        ;wip: length and position
        Return, new this.Node.Operation(Operation,Parameters,0,0)
    }

    Ternary(Operator,LeftSide)
    {
        If Operator.Value.Identifier != "_if"
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
        ;wip: position and length
        Return, new this.Node.Operation(Operation,Parameters,0,0)
    }

    BooleanShortCircuit(Operator,LeftSide)
    {
        If Operator.Value.Identifier != "_or" && Operator.Value.Identifier != "_and"
            Return, False

        RightSide := this.Statement(Operator.Value.RightBindingPower)
        RightSide := new this.Node.Block([RightSide],0,0)

        Operation := new this.Node.Identifier(Operator.Value.Identifier,Operator.Position,Operator.Length)
        Parameters := [LeftSide,RightSide]
        ;wip: position and length
        Return, new this.Node.Operation(Operation,Parameters,0,0)
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
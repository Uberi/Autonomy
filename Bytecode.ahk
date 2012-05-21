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

/*
Bytecode format
---------------

Stack based virtual machine implementing a few simple instructions:

label value                     label definition for a location in the bytecode.

push value                      pushes a value onto the stack.

call parameter_count            pops and stores the jump target.
                                pushes the parameter count onto the stack.
                                pushes the current stack base onto the stack.
                                pushes the current instruction index onto the stack.
                                jumps to the stored jump target.

return                          pops the return value off of the stack and stores it.
                                pops the intruction index off of the stack and stores it.
                                pops the stack base off of the stack and stores it.
                                pops the parameter count off of the stack.
                                pops the parameters off of the stack.
                                jumps to the stored instruction index.
                                sets the stack base to the stored stack base.
                                pushes the return value back onto the stack.

jump                            pops the jump target off of the stack.
                                jumps to the stored jump target.

conditional                     pops the value off of the stack and stores it.
                                pops the potential jump target off of the stack and stores it.
                                jumps to the stored potential jump target if the stored value is truthy.

;wip: generated identifiers are not always unique
;wip: static tail call detection
;wip: distinct Array type using contiguous memory, faster than Object hash table implementation
;wip: dead/unreachable code elimination
*/

;/*
Code = fn {1 + 2}

l := new Lexer(Code)
p := new Parser(l)

Tree := p.Parse()

b := new Bytecode(Tree)

Result := b.Convert(Tree)

MsgBox % Reconstruct.Bytecode(Result)
ExitApp

#Include Lexer.ahk
#Include Parser.ahk

#Include Resources/Reconstruct.ahk
*/

class Bytecode
{
    __New()
    {
        this.LabelCounter := 0
    }

    class Code
    {
        class DefineLabel
        {
            __New(Label,Position,Length)
            {
                this.Identifier := "label"
                this.Value := Label
                this.Position := Position
                this.Length := Length
            }
        }

        class Jump
        {
            __New(Position,Length)
            {
                this.Identifier := "jump"
                this.Position := Position
                this.Length := Length
            }
        }

        class Call
        {
            __New(ParameterCount,Position,Length)
            {
                this.Identifier := "call"
                this.Value := ParameterCount
                this.Position := Position
                this.Length := Length
            }
        }

        class PushLabel
        {
            __New(Label,Position,Length)
            {
                this.Identifier := "push_label"
                this.Value := Label
                this.Position := Position
                this.Length := Length
            }
        }

        class PushString
        {
            __New(String,Position,Length)
            {
                this.Identifier := "push_string"
                this.Value := String
                this.Position := Position
                this.Length := Length
            }
        }

        class PushIdentifier
        {
            __New(Identifier,Position,Length)
            {
                this.Identifier := "push_identifier"
                this.Value := Identifier
                this.Position := Position
                this.Length := Length
            }
        }

        class PushNumber
        {
            __New(Number,Position,Length)
            {
                this.Identifier := "push_number"
                this.Value := Number
                this.Position := Position
                this.Length := Length
            }
        }
    }

    Convert(Tree,Labels = "")
    {
        If !IsObject(Labels)
            Labels := []

        Result := this.Operation(Tree)
        If Result
            Return, Result
        Result := this.Block(Tree)
        If Result
            Return, Result
        Result := this.String(Tree)
        If Result
            Return, Result
        Result := this.Identifier(Tree)
        If Result
            Return, Result
        Result := this.Number(Tree)
        If Result
            Return, Result

        throw Exception("Unknown tree node type.",A_ThisFunc)
    }

    Operation(Tree)
    {
        If Tree.Type != "Operation"
            Return, False

        Result := []

        ParameterCount := 0
        For Index, Parameter In Tree.Parameters
        {
            ParameterCount ++
            For Index, Node In this.Convert(Parameter)
                Result.Insert(Node)
        }

        For Index, Node In this.Convert(Tree.Value)
            Result.Insert(Node)

        Result.Insert(new this.Code.Call(ParameterCount,Tree.Position,Tree.Length))
        Return, Result
    }

    Block(Tree)
    {
        If Tree.Type != "Block"
            Return, False

        Result := []

        BlockLabel := new this.Code.DefineLabel(this.LabelCounter,0,0) ;wip: position and length
        this.LabelCounter ++
        TargetLabel := new this.Code.DefineLabel(this.LabelCounter,0,0) ;wip: position and length
        this.LabelCounter ++

        Result.Insert(new this.Code.PushLabel(TargetLabel.Value,0,0)) ;wip: position and length
        Result.Insert(new this.Code.Jump(0,0)) ;wip: position and length

        Result.Insert(BlockLabel)

        For Index, Content In Tree.Contents
        {
            For Index, Node In this.Convert(Content)
                Result.Insert(Node)
        }

        Result.Insert(TargetLabel)

        Result.Insert(new this.Code.PushLabel(BlockLabel.Value,0,0)) ;wip: position and length

        Return, Result
    }

    String(Tree)
    {
        If Tree.Type != "String"
            Return, False

        Return, [new this.Code.PushString(Tree.Value,Tree.Position,Tree.Length)]
    }

    Identifier(Tree)
    {
        If Tree.Type != "Identifier"
            Return, False

        Return, [new this.Code.PushIdentifier(Tree.Value,Tree.Position,Tree.Length)]
    }

    Number(Tree)
    {
        If Tree.Type != "Number"
            Return, False

        Return, [new this.Code.PushNumber(Tree.Value,Tree.Position,Tree.Length)]
    }
}
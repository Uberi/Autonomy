#NoEnv

#Warn All
#Warn LocalSameAsGlobal, Off

/*
Copyright 2011-2013 Anthony Zhang <azhang9@gmail.com>

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

Value = print "hello" * 8
;Value = print 2 || 3 && 4
;Value = print {print args[1] ``n 123}((1 + 3) * 2)
;Value = print {args[2]}("First","Second","Third")
;Value = print 3 = 3 `n print 1 = 2
;Value = print([54][1])
;Value = print "c" .. print "b" .. print "a"
;Value = x:=2`nprint x

l := new Code.Lexer(Value)
p := new Code.Parser(l)
b := new Code.Bytecoder()

Tree := p.Parse()
Bytecode := b.Convert(Tree)
;MsgBox % Reconstruct.Tree(Tree)
;MsgBox % Dump.Bytecode(Bytecode)

Environment := new Builtins.Array(Builtins,{})
i := new Interpreter(Bytecode,Environment)
i.Run()
ExitApp

#Include Builtins.ahk

#Include ..
#Include Code.ahk
#Include Resources/Reconstruct.ahk

class Interpreter
{
    __New(Bytecode,Environment)
    {
        this.Bytecode := Bytecode
        this.Environment := Environment
        this.Index := 1
        this.LabelMap := {}
        this.Stack := []
    }

    Run()
    {
        Loop
        {
            If !this.Bytecode.HasKey(this.Index)
                Break
            Entry := this.Bytecode[this.Index]
            If Entry.Identifier = "Label"
            {
                this.Index ++
                this.LabelMap[Entry.Value] := this.Index
            }
            Else If Entry.Identifier = "Jump" ;wip: not sure if this is implementable with call
            {
                Location := this.Stack.Remove()
                If Location.Type != "Label"
                    throw Exception("Invalid jump target.")
                this.Index := Location.Value
            }
            Else If Entry.Identifier = "Call"
            {
                Arguments := [] ;wip: support named params
                MsgBox % Show(this.Stack)
                Callable := this.Stack.Remove()
                If !(IsFunc(Callable) || Callable.__Call)
                    throw Exception("Invalid callable.")
                Loop, % Entry.Count
                {
                    Value := this.Stack.Remove()
                    Arguments.Insert(Value)
                }
                Callable.(this,Arguments,this.Environment)
            }
            Else If Entry.Identifier = "Push"
            {
                this.Stack.Insert({Type: Entry.Type, Value: Entry.Value}) ;wip: create the objects here
                this.Index ++
            }
            Else If Entry.Identifier = "Load"
            {
                ;wip
                this.Stack.Insert("test123") ;wip: create the objects here
                this.Index ++
            }
            Else
                throw Exception("Invalid bytecode.")
        }
    }
}
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

;Value = print "hello" * 8
;Value = print 2 || 3 && 4
;Value = print {print args[1] ``n 123}((1 + 3) * 2)
;Value = print {args[2]}("First","Second","Third")
;Value = print 3 = 3 `n print 1 = 2
;Value = print([54][1])
;Value = print "c" .. print "b" .. print "a"
;Value = x:=2`nprint x
Value = {print 123}()

l := new Code.Lexer(Value)
p := new Code.Parser(l)
b := new Code.Bytecoder()

Tree := p.Parse()
Bytecode := b.Convert(Tree)
;MsgBox % Reconstruct.Tree(Tree)
MsgBox % Dump.Bytecode(Bytecode)

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
        ;build mapping of labels to indices
        For Index, Entry In this.Bytecode
        {
            If Entry.Identifier = "Label"
                this.LabelMap[Entry.Value] := Index
        }

        ;execute bytecode
        Loop
        {
            If !this.Bytecode.HasKey(this.Index) ;end of program
                Break
            Entry := this.Bytecode[this.Index]
            FileAppend, % this.Index . "`t" . Dump.Bytecode([Entry]), *
            If Entry.Identifier = "Label"
                this.Index ++
            Else If Entry.Identifier = "Jump" ;wip: implement this with call
            {
                Location := this.Stack.Remove()
                If !Location.Target
                    throw Exception("Invalid jump target.")
                this.Index := Location.Target
            }
            Else If Entry.Identifier = "Call"
            {
                Callable := this.Stack.Remove()
                If !(IsFunc(Callable) || Callable.__Call)
                    throw Exception("Invalid callable.")
                Arguments := [] ;wip: support named params
                Loop, % Entry.Count
                {
                    Value := this.Stack.Remove()
                    Arguments[(Entry.Count - A_Index) + 1] := Value
                }
                Result := Callable.(this,Arguments,this.Environment)
                this.Stack.Insert(Result)
                this.Index ++ ;wip
            }
            Else If Entry.Identifier = "Push"
            {
                If Entry.Type = "Label"
                {
                    If !this.LabelMap.HasKey(Entry.Value)
                        throw Exception("Invalid label.")
                    Value := new Builtins.Block(this.LabelMap[Entry.Value])
                }
                Else If Entry.Type = "Symbol"
                    Value := new Builtins.Symbol(Entry.Value)
                Else If Entry.Type = "Self"
                    Value := this.Environment
                Else If Entry.Type = "String"
                    Value := new Builtins.String(Entry.Value)
                Else If Entry.Type = "Number"
                    Value := new Builtins.Number(Entry.Value)
                Else
                    throw Exception("Unknown value type.")
                this.Stack.Insert(Value)
                this.Index ++
            }
            Else If Entry.Identifier = "Load"
            {
                Value := this.Environment._subscript([new Builtins.Symbol(Entry.Value)],this.Environment)
                this.Stack.Insert(Value)
                this.Index ++
            }
            Else
                throw Exception("Invalid bytecode.")
        }
    }
}
#NoEnv

#Warn All
#Warn LocalSameAsGlobal, Off

;wip: store environment in which the object was created with the object as the closure

;Value = print "hello" * 8
;Value = print 2 || 3
;Value = print {print args[1] ``n 123}((1 + 3) * 2)
;Value = print {args[2]}("First","Second","Third")
;Value = print 3 = 3 `n print 1 = 2
;Value = print([54][1])
;Value = print "c" .. print "b" .. print "a"
Value = x:=2`nprint x

l := new Code.Lexer(Value)
p := new Code.Parser(l)

Tree := p.Parse()

Environment := new DefaultEnvironment
Result := Eval(Tree,Environment)
MsgBox % ShowObject(Environment)
;MsgBox % ShowObject(Result)
Return

#Include Code.ahk

Eval(Tree,Environment)
{
    If Tree.Type = "Operation"
    {
        Callable := Eval(Tree.Value,Environment)
        If !IsFunc(Callable.call)
            throw Exception("Callable not found.")

        Arguments := []
        For Key, Value In Tree.Parameters
            Arguments[Key] := Eval(Value,Environment)

        Return, Callable.call(Callable,Arguments,Environment)
    }
    If Tree.Type = "Block"
        Return, new Environment.Block(Tree.Contents,Environment)
    If Tree.Type = "Symbol"
        Return, new Environment.Symbol(Tree.Value)
    If Tree.Type = "String"
        Return, new Environment.String(Tree.Value)
    If Tree.Type = "Identifier"
    {
        ;Key := Tree._hash.call(Tree,[],Environment)
        Value := Environment[Tree.Value]
        Return, Value ? Value : Environment.None
    }
    If Tree.Type = "Number"
        Return, new Environment.Number(Tree.Value)
    If Tree.Type = "Self"
        Return, new Environment.Array(Environment)
    throw Exception("Invalid token.")
}

class DefaultEnvironment
{
    class Object
    {
        class _boolean
        {
            call(Self,Arguments,Environment)
            {
                Return, Environment.True
            }
        }

        class _string
        {
            call(Self,Arguments,Environment)
            {
                Return, new Environment.String("<" . Self.__Class . " " . &Self . ">")
            }
        }

        class _hash
        {
            call(Self,Arguments,Environment)
            {
                Return new Environment.Number(&Self)
            }
        }
    }

    ;wip: these are already implemented in core.ato
    class None extends DefaultEnvironment.Object
    {
        class _string
        {
            call(Self,Arguments,Environment)
            {
                Return, new Environment.String("None")
            }
        }
    }

    class True extends DefaultEnvironment.Object
    {
        class _string
        {
            call(Self,Arguments,Environment)
            {
                Return, new Environment.String("True")
            }
        }
    }

    class False extends DefaultEnvironment.Object
    {
        class _string
        {
            call(Self,Arguments,Environment)
            {
                Return, new Environment.String("False")
            }
        }
    }

    class Array extends DefaultEnvironment.Object
    {
        __New(Value)
        {
            this.Value := Value
        }

        class _boolean
        {
            call(Self,Arguments,Environment)
            {
                Return, ObjNewEnum(Self.Value).Next(Key) ? Environment.True : Environment.False
            }
        }

        class _subscript
        {
            call(Self,Arguments,Environment)
            {
                Key := Arguments[1]._hash.call(Arguments[1],[],Environment).Value
                If ObjHasKey(Self.Value,Key)
                    Return, Self.Value[Key]
                Return, Environment.None
            }
        }

        class _assign
        {
            call(Self,Arguments,Environment)
            {
                Key := Arguments[1]._hash.call(Arguments[1],[],Environment).Value
                Self.Value[Key] := Arguments[2]
            }
        }
    }

    class Block extends DefaultEnvironment.Object
    {
        __New(Contents,Environment)
        {
            this.Contents := Contents
            this.Environment := Environment
        }

        call(Self,Arguments,Environment)
        {
            ;set up an inner environment with self and arguments ;wip: make this a bit more minimal
            InnerEnvironment := Object()
            InnerEnvironment.base := Self.Environment
            InnerEnvironment.self := Self
            InnerEnvironment.args := new InnerEnvironment.Array(Arguments)

            ;evaluate the contents of the block
            Result := Environment.None
            For Index, Content In Self.Contents
                Result := Eval(Content,InnerEnvironment)
            Return, Result
        }

        class _subscript
        {
            call(Self,Arguments,Environment)
            {
                Key := Arguments[1].Value
                If (Key = "arguments")
                    Return, Self.Arguments
                throw Exception("Invalid property: " . Key)
            }
        }
    }

    class Symbol extends DefaultEnvironment.Object
    {
        __New(Value)
        {
            this.Value := Value
        }

        class _equals
        {
            call(Self,Arguments,Environment)
            {
                Return, Self.Value = Arguments[1].Value
            }
        }

        class _equals_strict
        {
            call(Self,Arguments,Environment)
            {
                Return, Self.Value == Arguments[1].Value
            }
        }
    }

    class String extends DefaultEnvironment.Object
    {
        __New(Value)
        {
            this.Value := Value
        }

        class _boolean
        {
            call(Self,Arguments,Environment)
            {
                Return, Self.Value = "" ? Environment.True : Environment.False
            }
        }

        class _equals
        {
            call(Self,Arguments,Environment)
            {
                Return, Self.Value = Arguments[1].Value
            }
        }

        class _equals_strict
        {
            call(Self,Arguments,Environment)
            {
                Return, Self.Value == Arguments[1].Value
            }
        }

        class _multiply
        {
            call(Self,Arguments,Environment)
            {
                Result := ""
                Loop, % Arguments[1].Value
                    Result .= Self.Value
                Return, new Self.base(Result)
            }
        }

        class _subscript
        {
            call(Self,Arguments,Environment)
            {
                Return, new Self.base(SubStr(Self.Value,Arguments[1].Value,1))
            }
        }

        class _string
        {
            call(Self,Arguments,Environment)
            {
                Return, Self
            }
        }
    }

    class Number extends DefaultEnvironment.Object
    {
        __New(Value)
        {
            this.Value := Value
        }

        class _boolean
        {
            call(Self,Arguments,Environment)
            {
                Return, Self.Value = 0 ? Environment.False : Environment.True
            }
        }

        class _equals
        {
            call(Self,Arguments,Environment)
            {
                Return, Self.Value = Arguments[1].Value ? Environment.True : Environment.False ;wip: try to convert to number
            }
        }

        class _equals_strict
        {
            call(Self,Arguments,Environment)
            {
                Return, Self.Value == Arguments[1].Value
            }
        }

        class _add
        {
            call(Self,Arguments,Environment)
            {
                Return, new Self.base(Self.Value + Arguments[1].Value)
            }
        }

        class _multiply
        {
            call(Self,Arguments,Environment)
            {
                Return, new Self.base(Self.Value * Arguments[1].Value)
            }
        }

        class _string
        {
            call(Self,Arguments,Environment)
            {
                Return, new Environment.String(Self.Value)
            }
        }

        class _hash
        {
            call(Self,Arguments,Environment)
            {
                Return, Self
            }
        }
    }

    ;wip: should be implemented in core.ato
    class _array
    {
        call(Self,Arguments,Environment)
        {
            Return, new Environment.Array(Arguments)
        }
    }

    class _assign
    {
        call(Self,Arguments,Environment)
        {
            Return, Arguments[1]._assign.call(Arguments[1],[Arguments[2],Arguments[3]],Environment)
        }
    }

    class _if
    {
        call(Self,Arguments,Environment)
        {
            If Arguments[1]._boolean.call(Arguments[1],[],Environment)
                Return, Arguments[2].call(Arguments[2],[],Environment)
            Return, Arguments[3].call(Arguments[3],[],Environment)
        }
    }

    class _or
    {
        call(Self,Arguments,Environment)
        {
            If Arguments[1]._boolean.call(Arguments[1],[],Environment)
                Return, Arguments[1]
            Return, Arguments[2].call(Arguments[2],[],Environment)
        }
    }

    class _and
    {
        call(Self,Arguments,Environment)
        {
            If !Arguments[1]._boolean.call(Arguments[1],[],Environment)
                Return, Arguments[1]
            Return, Arguments[2].call(Arguments[2],[],Environment)
        }
    }

    class _equals
    {
        call(Self,Arguments,Environment)
        {
            Return, Arguments[1]._equals.call(Arguments[1],[Arguments[2]],Environment)
        }
    }

    class _equals_strict
    {
        call(Self,Arguments,Environment)
        {
            Return, Arguments[1]._equals_strict.call(Arguments[1],[Arguments[2]],Environment)
        }
    }

    class _add
    {
        call(Self,Arguments,Environment)
        {
            Return, Arguments[1]._add.call(Arguments[1],[Arguments[2]],Environment)
        }
    }

    class _multiply
    {
        call(Self,Arguments,Environment)
        {
            Return, Arguments[1]._multiply.call(Arguments[1],[Arguments[2]],Environment)
        }
    }

    class _evaluate
    {
        call(Self,Arguments,Environment)
        {
            ;return the last parameter
            If ObjMaxIndex(Arguments)
                Return, Arguments[ObjMaxIndex(Arguments)]
            Return, Environment.None
        }
    }

    class _subscript
    {
        call(Self,Arguments,Environment)
        {
            Return, Arguments[1]._subscript.call(Arguments[1],[Arguments[2]],Environment)
        }
    }

    class print
    {
        call(Self,Arguments,Environment)
        {
            FileAppend, % Arguments[1]._string.call(Arguments[1],[],Environment).Value . "`n", *
            Return, Arguments[1]
        }
    }
}
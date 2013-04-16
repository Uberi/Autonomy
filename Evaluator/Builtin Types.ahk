class BuiltinTypes
{
    class Object
    {
        class _boolean
        {
            call(Self,Arguments,Environment)
            {
                Return, BuiltinTypes.True
            }
        }

        class _string
        {
            call(Self,Arguments,Environment)
            {
                Return, new BuiltinTypes.String("<" . Self.__Class . " " . &Self . ">")
            }
        }

        class _hash
        {
            call(Self,Arguments,Environment)
            {
                Return new BuiltinTypes.Number(&Self)
            }
        }
    }

    ;wip: these are already implemented in core.ato
    class None extends BuiltinTypes.Object
    {
        class _string
        {
            call(Self,Arguments,Environment)
            {
                Return, new BuiltinTypes.String("None")
            }
        }
    }

    class True extends BuiltinTypes.Object
    {
        class _string
        {
            call(Self,Arguments,Environment)
            {
                Return, new BuiltinTypes.String("True")
            }
        }
    }

    class False extends BuiltinTypes.Object
    {
        class _string
        {
            call(Self,Arguments,Environment)
            {
                Return, new BuiltinTypes.String("False")
            }
        }
    }

    class Array extends BuiltinTypes.Object
    {
        __New(Value)
        {
            this.Value := Value
        }

        class _boolean
        {
            call(Self,Arguments,Environment)
            {
                Return, ObjNewEnum(Self.Value).Next(Key) ? BuiltinTypes.True : BuiltinTypes.False
            }
        }

        class _subscript
        {
            call(Self,Arguments,Environment)
            {
                Key := Arguments[1]._hash.call(Arguments[1],[],Environment).Value
                If ObjHasKey(Self.Value,Key)
                    Return, Self.Value[Key]
                MsgBox % Arguments[1].Value
                Return, BuiltinTypes.None
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

    class Block extends BuiltinTypes.Object
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
            InnerEnvironment.args := new Environment.Array(Arguments)

            ;evaluate the contents of the block
            Result := BuiltinTypes.None
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

    class Symbol extends BuiltinTypes.Object
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

        class _hash
        {
            call(Self,Arguments,Environment)
            {
                Value := DllCall( "ntdll\RtlComputeCrc32","UInt",0,"UPtr",ObjGetAddress(Self,"Value"),"UPtr",StrLen(Self.Value))
                Return, new BuiltinTypes.Number(Value)
            }
        }
    }

    class String extends BuiltinTypes.Object
    {
        __New(Value)
        {
            this.Value := Value
        }

        class _boolean
        {
            call(Self,Arguments,Environment)
            {
                Return, Self.Value = "" ? BuiltinTypes.True : BuiltinTypes.False
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
                Return, new Self.base(SubStr(Self.Value,Arguments[1].Value,1)) ;wip: cast to string
            }
        }

        class _concatenate
        {
            call(Self,Arguments,Environment)
            {
                Return, new Self.base(Self.Value . Arguments[1].Value) ;wip: cast to string
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

    class Number extends BuiltinTypes.Object
    {
        __New(Value)
        {
            this.Value := Value
        }

        class _boolean
        {
            call(Self,Arguments,Environment)
            {
                Return, Self.Value = 0 ? BuiltinTypes.False : BuiltinTypes.True
            }
        }

        class _equals
        {
            call(Self,Arguments,Environment)
            {
                Return, Self.Value = Arguments[1].Value ? BuiltinTypes.True : BuiltinTypes.False ;wip: try to convert to number
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
                Return, new BuiltinTypes.String(Self.Value)
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
}
class BuiltinTypes
{
    class Object
    {
        _boolean(Self,Arguments,Environment)
        {
            Return, BuiltinTypes.True
        }

        _string(Self,Arguments,Environment)
        {
            Return, new BuiltinTypes.String("<" . Self.__Class . " " . &Self . ">")
        }

        _hash(Self,Arguments,Environment)
        {
            Return new BuiltinTypes.Number(&Self)
        }
    }

    ;wip: these are already implemented in core.ato
    class None extends BuiltinTypes.Object
    {
        _string(Self,Arguments,Environment)
        {
            Return, new BuiltinTypes.String("None")
        }
    }

    class True extends BuiltinTypes.Object
    {
        _string(Self,Arguments,Environment)
        {
            Return, new BuiltinTypes.String("True")
        }
    }

    class False extends BuiltinTypes.Object
    {
        _string(Self,Arguments,Environment)
        {
            Return, new BuiltinTypes.String("False")
        }
    }

    class Array extends BuiltinTypes.Object
    {
        __New(Value,Environment)
        {
            this.Value := {}
            For Key, Entry In Value
            {
                If Key Is Number
                    Key := new BuiltinTypes.Number(Key)
                Else
                    Key := new BuiltinTypes.Symbol(Key)
                this._assign(this,[Key,Entry],Environment)
            }
        }

        _boolean(Self,Arguments,Environment)
        {
            Return, ObjNewEnum(Self.Value).Next(Key) ? BuiltinTypes.True : BuiltinTypes.False
        }

        _subscript(Self,Arguments,Environment)
        {
            Key := Arguments[1]._hash(Arguments[1],[],Environment).Value
            Return, Self.Value[Key] ? Self.Value[Key] : BuiltinTypes.None
        }

        _assign(Self,Arguments,Environment)
        {
            Key := Arguments[1]._hash(Arguments[1],[],Environment).Value
            Self.Value[Key] := Arguments[2]
        }
    }

    class Block extends BuiltinTypes.Object
    {
        __New(Contents,Environment)
        {
            this.Contents := Contents
            this.Environment := Environment
        }

        __Call(Key,Instance,Self,Arguments,Environment)
        {
            ;set up an inner environment with self and arguments ;wip: make this a bit more minimal
            InnerEnvironment := new BuiltinTypes.Array({self: Self, args: new BuiltinTypes.Array(Arguments,Environment)},Environment)
            InnerEnvironment.Value.base := Environment.Value

            ;evaluate the contents of the block
            Result := BuiltinTypes.None
            For Index, Content In Self.Contents
                Result := Eval(Content,InnerEnvironment)
            Return, Result
        }

        _subscript(Self,Arguments,Environment)
        {
            Key := Arguments[1].Value
            If (Key = "arguments")
                Return, Self.Arguments
            throw Exception("Invalid property: " . Key)
        }
    }

    class Symbol extends BuiltinTypes.Object
    {
        __New(Value)
        {
            this.Value := Value
        }

        _equals(Self,Arguments,Environment)
        {
            Return, Self.Value = Arguments[1].Value
        }

        _equals_strict(Self,Arguments,Environment)
        {
            Return, Self.Value == Arguments[1].Value
        }

        _hash(Self,Arguments,Environment)
        {
            Value := DllCall( "ntdll\RtlComputeCrc32","UInt",0,"UPtr",ObjGetAddress(Self,"Value"),"UPtr",StrLen(Self.Value))
            Return, new BuiltinTypes.Number(Value)
        }
    }

    class String extends BuiltinTypes.Object
    {
        __New(Value)
        {
            this.Value := Value
        }

        _boolean(Self,Arguments,Environment)
        {
            Return, Self.Value = "" ? BuiltinTypes.True : BuiltinTypes.False
        }

        _equals(Self,Arguments,Environment)
        {
            Return, Self.Value = Arguments[1].Value
        }

        _equals_strict(Self,Arguments,Environment)
        {
            Return, Self.Value == Arguments[1].Value
        }

        _multiply(Self,Arguments,Environment)
        {
            Result := ""
            Loop, % Arguments[1].Value
                Result .= Self.Value
            Return, new Self.base(Result)
        }

        _subscript(Self,Arguments,Environment)
        {
            Return, new Self.base(SubStr(Self.Value,Arguments[1].Value,1)) ;wip: cast to string
        }

        _concatenate(Self,Arguments,Environment)
        {
            Return, new Self.base(Self.Value . Arguments[1].Value) ;wip: cast to string
        }

        _string(Self,Arguments,Environment)
        {
            Return, Self
        }
    }

    class Number extends BuiltinTypes.Object
    {
        __New(Value)
        {
            this.Value := Value
        }

        _boolean(Self,Arguments,Environment)
        {
            Return, Self.Value = 0 ? BuiltinTypes.False : BuiltinTypes.True
        }

        _equals(Self,Arguments,Environment)
        {
            Return, Self.Value = Arguments[1].Value ? BuiltinTypes.True : BuiltinTypes.False ;wip: try to convert to number
        }

        _equals_strict(Self,Arguments,Environment)
        {
            Return, Self.Value == Arguments[1].Value
        }

        _add(Self,Arguments,Environment)
        {
            Return, new Self.base(Self.Value + Arguments[1].Value)
        }

        _multiply(Self,Arguments,Environment)
        {
            Return, new Self.base(Self.Value * Arguments[1].Value)
        }

        _string(Self,Arguments,Environment)
        {
            Return, new BuiltinTypes.String(Self.Value)
        }

        _hash(Self,Arguments,Environment)
        {
            Return, Self
        }
    }
}
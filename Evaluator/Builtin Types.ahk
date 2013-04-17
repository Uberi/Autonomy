class BuiltinTypes
{
    class Object
    {
        _boolean(Arguments,Environment)
        {
            Return, BuiltinTypes.True
        }

        _string(Arguments,Environment)
        {
            Return, new BuiltinTypes.String("<" . this.__Class . " " . &this . ">")
        }

        _hash(Arguments,Environment)
        {
            Return new BuiltinTypes.Number(&this)
        }
    }

    ;wip: these are already implemented in core.ato
    class None extends BuiltinTypes.Object
    {
        _string(Arguments,Environment)
        {
            Return, new BuiltinTypes.String("None")
        }
    }

    class True extends BuiltinTypes.Object
    {
        _string(Arguments,Environment)
        {
            Return, new BuiltinTypes.String("True")
        }
    }

    class False extends BuiltinTypes.Object
    {
        _string(Arguments,Environment)
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
                this._assign([Key,Entry],Environment)
            }
        }

        _boolean(Arguments,Environment)
        {
            Return, ObjNewEnum(this.Value).Next(Key) ? BuiltinTypes.True : BuiltinTypes.False
        }

        _subscript(Arguments,Environment)
        {
            Key := Arguments[1]._hash([],Environment).Value
            Return, this.Value[Key] ? this.Value[Key] : BuiltinTypes.None
        }

        _assign(Arguments,Environment)
        {
            Key := Arguments[1]._hash([],Environment).Value
            this.Value[Key] := Arguments[2]
        }
    }

    class Block extends BuiltinTypes.Object
    {
        __New(Contents,Environment)
        {
            this.Contents := Contents
            this.Environment := Environment
        }

        __Call(Key,Instance,Arguments,Environment)
        {
            ;set up an inner environment with self and arguments ;wip: make this a bit more minimal
            InnerEnvironment := new BuiltinTypes.Array({self: this, args: new BuiltinTypes.Array(Arguments,Environment)},Environment)
            InnerEnvironment.Value.base := Environment.Value

            ;evaluate the contents of the block
            Result := BuiltinTypes.None
            For Index, Content In this.Contents
                Result := Eval(Content,InnerEnvironment)
            Return, Result
        }
    }

    class Symbol extends BuiltinTypes.Object
    {
        __New(Value)
        {
            this.Value := Value
        }

        _equals(Arguments,Environment)
        {
            Return, this.Value = Arguments[1].Value
        }

        _equals_strict(Arguments,Environment)
        {
            Return, this.Value == Arguments[1].Value
        }

        _hash(Arguments,Environment)
        {
            Value := DllCall( "ntdll\RtlComputeCrc32","UInt",0,"UPtr",ObjGetAddress(this,"Value"),"UPtr",StrLen(this.Value))
            Return, new BuiltinTypes.Number(Value)
        }
    }

    class String extends BuiltinTypes.Object
    {
        __New(Value)
        {
            this.Value := Value
        }

        _boolean(Arguments,Environment)
        {
            Return, this.Value = "" ? BuiltinTypes.True : BuiltinTypes.False
        }

        _equals(Arguments,Environment)
        {
            Return, this.Value = Arguments[1].Value
        }

        _equals_strict(Arguments,Environment)
        {
            Return, this.Value == Arguments[1].Value
        }

        _multiply(Arguments,Environment)
        {
            Result := ""
            Loop, % Arguments[1].Value
                Result .= this.Value
            Return, new this.base(Result)
        }

        _subscript(Arguments,Environment)
        {
            Return, new this.base(SubStr(this.Value,Arguments[1].Value,1)) ;wip: cast to string
        }

        _concatenate(Arguments,Environment)
        {
            Return, new this.base(this.Value . Arguments[1].Value) ;wip: cast to string
        }

        _string(Arguments,Environment)
        {
            Return, this
        }
    }

    class Number extends BuiltinTypes.Object
    {
        __New(Value)
        {
            this.Value := Value
        }

        _boolean(Arguments,Environment)
        {
            Return, this.Value = 0 ? BuiltinTypes.False : BuiltinTypes.True
        }

        _equals(Arguments,Environment)
        {
            Return, this.Value = Arguments[1].Value ? BuiltinTypes.True : BuiltinTypes.False ;wip: try to convert to number
        }

        _equals_strict(Arguments,Environment)
        {
            Return, this.Value == Arguments[1].Value
        }

        _add(Arguments,Environment)
        {
            Return, new this.base(this.Value + Arguments[1].Value)
        }

        _multiply(Arguments,Environment)
        {
            Return, new this.base(this.Value * Arguments[1].Value)
        }

        _string(Arguments,Environment)
        {
            Return, new BuiltinTypes.String(this.Value)
        }

        _hash(Arguments,Environment)
        {
            Return, this
        }
    }
}
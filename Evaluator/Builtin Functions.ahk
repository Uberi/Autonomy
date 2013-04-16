class BuiltinFunctions
{
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

    class _concatenate
    {
        call(Self,Arguments,Environment)
        {
            Return, Arguments[1]._concatenate.call(Arguments[1],[Arguments[2]],Environment)
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
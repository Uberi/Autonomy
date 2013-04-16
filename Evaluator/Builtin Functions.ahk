class BuiltinFunctions
{
    ;wip: should be implemented in core.ato
    _array(Self,Arguments,Environment)
    {
        Return, new BuiltinTypes.Array(Arguments,Environment)
    }

    _assign(Self,Arguments,Environment)
    {
        Return, Arguments[1]._assign(Arguments[1],[Arguments[2],Arguments[3]],Environment)
    }

    _if(Self,Arguments,Environment)
    {
        If Arguments[1]._boolean(Arguments[1],[],Environment)
            Return, Arguments[2](Arguments[2],[],Environment)
        Return, Arguments[3](Arguments[3],[],Environment)
    }

    _or(Self,Arguments,Environment)
    {
        If Arguments[1]._boolean(Arguments[1],[],Environment)
            Return, Arguments[1]
        Return, Arguments[2](Arguments[2],[],Environment)
    }

    _and(Self,Arguments,Environment)
    {
        If !Arguments[1]._boolean(Arguments[1],[],Environment)
            Return, Arguments[1]
        Return, Arguments[2](Arguments[2],[],Environment)
    }

    _equals(Self,Arguments,Environment)
    {
        Return, Arguments[1]._equals(Arguments[1],[Arguments[2]],Environment)
    }

    _equals_strict(Self,Arguments,Environment)
    {
        Return, Arguments[1]._equals_strict(Arguments[1],[Arguments[2]],Environment)
    }

    _add(Self,Arguments,Environment)
    {
        Return, Arguments[1]._add(Arguments[1],[Arguments[2]],Environment)
    }

    _multiply(Self,Arguments,Environment)
    {
        Return, Arguments[1]._multiply(Arguments[1],[Arguments[2]],Environment)
    }

    _evaluate(Self,Arguments,Environment)
    {
        ;return the last parameter
        If ObjMaxIndex(Arguments)
            Return, Arguments[ObjMaxIndex(Arguments)]
        Return, Environment.None
    }

    _subscript(Self,Arguments,Environment)
    {
        Return, Arguments[1]._subscript(Arguments[1],[Arguments[2]],Environment)
    }

    _concatenate(Self,Arguments,Environment)
    {
        Return, Arguments[1]._concatenate(Arguments[1],[Arguments[2]],Environment)
    }

    print(Self,Arguments,Environment)
    {
        FileAppend, % Arguments[1]._string(Arguments[1],[],Environment).Value . "`n", *
        Return, Arguments[1]
    }
}
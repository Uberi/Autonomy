class BuiltinFunctions
{
    ;wip: should be implemented in core.ato
    _array(Arguments,Environment)
    {
        Return, new BuiltinTypes.Array(Arguments,Environment)
    }

    _assign(Arguments,Environment)
    {
        Return, Arguments[1]._assign([Arguments[2],Arguments[3]],Environment)
    }

    _if(Arguments,Environment)
    {
        If Arguments[1]._boolean([],Environment)
            Return, Arguments[2]([],Environment)
        Return, Arguments[3]([],Environment)
    }

    _or(Arguments,Environment)
    {
        If Arguments[1]._boolean([],Environment)
            Return, Arguments[1]
        Return, Arguments[2]([],Environment)
    }

    _and(Arguments,Environment)
    {
        If !Arguments[1]._boolean([],Environment)
            Return, Arguments[1]
        Return, Arguments[2]([],Environment)
    }

    _equals(Arguments,Environment)
    {
        Return, Arguments[1]._equals([Arguments[2]],Environment)
    }

    _equals_strict(Arguments,Environment)
    {
        Return, Arguments[1]._equals_strict([Arguments[2]],Environment)
    }

    _add(Arguments,Environment)
    {
        Return, Arguments[1]._add([Arguments[2]],Environment)
    }

    _multiply(Arguments,Environment)
    {
        Return, Arguments[1]._multiply([Arguments[2]],Environment)
    }

    _evaluate(Arguments,Environment)
    {
        ;return the last parameter
        If ObjMaxIndex(Arguments)
            Return, Arguments[Arguments.MaxIndex()]
        Return, Environment.None
    }

    _subscript(Arguments,Environment)
    {
        Return, Arguments[1]._subscript([Arguments[2]],Environment)
    }

    _concatenate(Arguments,Environment)
    {
        Return, Arguments[1]._concatenate([Arguments[2]],Environment)
    }

    print(Arguments,Environment)
    {
        FileAppend, % Arguments[1]._string([],Environment).Value . "`n", *
        Return, Arguments[1]
    }
}
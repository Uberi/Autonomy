#NoEnv

Code = "hello" + 2 + 3

l := new Lexer(Code)
p := new Parser(l)

;Tree := p.Parse() ;wip
Tree := p.Expression()

Environment := new DefaultEnvironment
MsgBox % ShowObject(Eval(Tree,Environment))
Return

#Include Lexer.ahk
#Include Parser.ahk

Eval(Tree,Environment)
{
    If Tree.Type = "Operation"
    {
        Callable := Eval(Tree.Value,Environment)

        Parameters := []
        For Key, Value In Tree.Parameters
            Parameters[Key] := Eval(Value,Environment)

        Return, Callable.call(Callable,Parameters)
    }
    If Tree.Type = "Block"
        Return, Environment.Block.new(Tree.Contents,Environment)
    If Tree.Type = "String"
        Return, Environment.String.new(Tree.Value)
    If Tree.Type = "Identifier"
        Return, Environment[Tree.Value]
    If Tree.Type = "Number"
        Return, Environment.Number.new(Tree.Value)
    throw Exception("Invalid token.")
}

class DefaultEnvironment
{
    class Block
    {
        new(Contents,Environment)
        {
            v := Object()
            v.base := this

            v.Contents := Contents
            v.Environment := Environment

            Return, v
        }

        call(Current,Parameters)
        {
            ;set up an inner scope with the parameters
            InnerEnvironment := Object()
            InnerEnvironment.base := Current.Environment
            For Key, Value In Parameters
                InnerEnvironment[Key] := Value

            ;evaluate the contents of the block
            ;Result := null ;wip
            For Index, Content In Current.Contents
                Result := Eval(Content,InnerEnvironment)
            Return, Result
        }
    }

    class String
    {
        new(Value)
        {
            v := Object()
            v.base := this

            v.Value := Value
            Return, v
        }

        class _add
        {
            call(Current,Parameters)
            {
                Return, Current.new(Current.Value . Parameters[1].Value)
            }
        }
    }

    class Number
    {
        new(Value)
        {
            v := Object()
            v.base := this

            v.Value := Value
            Return, v
        }

        class _add
        {
            call(Current,Parameters)
            {
                Return, Current.new(Current.Value + Parameters[1].Value)
            }
        }
    }

    class _add
    {
        call(Current,Parameters)
        {
            Return, Parameters[1]._add.call(Parameters[1],[Parameters[2]])
        }
    }
}
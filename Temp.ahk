#NoEnv

Code = "hello" * 8
Code =  2 || 3
Code = {123}((1 + 3) * 2)
Code = {this["arguments"][1]}(4)

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
        If !IsFunc(Callable.call)
            throw Exception("Callable not found.")

        Arguments := []
        For Key, Value In Tree.Parameters
            Arguments[Key] := Eval(Value,Environment)

        Return, Callable.call(Callable,Arguments)
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
    class Object
    {
        new()
        {
            v := Object()
            v.base := this

            v.Values := Object()
            Return, v
        }

        class _boolean
        {
            call(Current,Arguments)
            {
                Return, !!ObjNewEnum(Current).Next(Key,Value)
            }
        }

        class _subscript
        {
            call(Current,Arguments)
            {
                Return, Current.Values[Arguments[1].Value]
            }
        }
    }

    class Block
    {
        new(Contents,Environment)
        {
            v := Object()
            v.base := this

            v.Contents := Contents
            v.Environment := Environment
            v.Arguments := Object()
            Return, v
        }

        call(Current,Arguments)
        {
            ;set up an inner scope with the Arguments
            InnerEnvironment := Object()
            InnerEnvironment.base := Current.Environment
            InnerEnvironment.this := Current

            Current.Arguments := Current.Environment.Object.new()
            For Key, Value In Arguments
                Current.Arguments.values[Key] := Value

            ;evaluate the contents of the block
            ;Result := null ;wip
            Result := 0
            For Index, Content In Current.Contents
                Result := Eval(Content,InnerEnvironment)
            Return, Result
        }

        class _boolean
        {
            call(Current,Arguments)
            {
                Return, True
            }
        }

        class _subscript
        {
            call(Current,Arguments)
            {
                If Arguments[1].Value = "arguments"
                    Return, Current.Arguments
                throw Exception("Invalid property: " . Arguments[1].Value)
            }
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

        class _boolean
        {
            call(Current,Arguments)
            {
                Return, Current.Value != ""
            }
        }

        class _add
        {
            call(Current,Arguments)
            {
                Return, Current.new(Current.Value . Arguments[1].Value)
            }
        }

        class _multiply
        {
            call(Current,Arguments)
            {
                Result := ""
                Loop, % Arguments[1].Value
                    Result .= Current.Value
                Return, Current.new(Result)
            }
        }

        class _subscript
        {
            call(Current,Arguments)
            {
                Return, SubStr(Current.Value,Arguments[1].Value,1)
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

        class _boolean
        {
            call(Current,Arguments)
            {
                Return, Current.Value != 0
            }
        }

        class _add
        {
            call(Current,Arguments)
            {
                Return, Current.new(Current.Value + Arguments[1].Value)
            }
        }

        class _multiply
        {
            call(Current,Arguments)
            {
                Return, Current.new(Current.Value * Arguments[1].Value)
            }
        }
    }

    class _or
    {
        call(Current,Arguments)
        {
            If Arguments[1]._boolean.call(Arguments[1],[])
                Return, Arguments[1]
            Return, Arguments[2].call(Arguments[2],[])
        }
    }

    class _and
    {
        call(Current,Arguments)
        {
            If !Arguments[1]._boolean.call(Arguments[1],[])
                Return, Arguments[1]
            Return, Arguments[2].call(Arguments[2],[])
        }
    }

    class _add
    {
        call(Current,Arguments)
        {
            Return, Arguments[1]._add.call(Arguments[1],[Arguments[2]])
        }
    }

    class _multiply
    {
        call(Current,Arguments)
        {
            Return, Arguments[1]._multiply.call(Arguments[1],[Arguments[2]])
        }
    }

    class _evaluate
    {
        call(Current,Arguments)
        {
            ;return the last parameter
            If ObjMaxIndex(Arguments)
                Return, Arguments[ObjMaxIndex(Arguments)]
            ;Return, null ;wip
            Return, 0
        }
    }

    class _subscript
    {
        call(Current,Arguments)
        {
            Return, Arguments[1]._subscript.call(Arguments[1],[Arguments[2]])
        }
    }
}
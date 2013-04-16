#NoEnv

#Warn All
#Warn LocalSameAsGlobal, Off

;wip: store environment in which the object was created with the object as the closure
;wip: stop passing Self around and use "this" instead

;Value = print "hello" * 8
;Value = print 2 || 3
;Value = print {print args[1] ``n 123}((1 + 3) * 2)
Value = print {args[2]}("First","Second","Third")
;Value = print 3 = 3 `n print 1 = 2
;Value = print([54][1])
;Value = print "c" .. print "b" .. print "a"
;Value = x:=2`nprint x

l := new Code.Lexer(Value)
p := new Code.Parser(l)

Tree := p.Parse()

Environment := CreateEnvironment()
Result := Eval(Tree,Environment)
;MsgBox % ShowObject(Environment)
;MsgBox % ShowObject(Result)
Return

#Include Builtin Types.ahk
#Include Builtin Functions.ahk

#Include ..
#Include Code.ahk

CreateEnvironment()
{
    Environment := new BuiltinTypes.Array(BuiltinTypes,{})
    For Key, Value In BuiltinFunctions
        Environment._assign(Environment,[new BuiltinTypes.Symbol(Key),Value],Environment)
    Return, Environment
}

Eval(Tree,Environment)
{
    If Tree.Type = "Operation"
    {
        Callable := Eval(Tree.Value,Environment)
        If !(IsFunc(Callable) || Callable.__Call)
            throw Exception("Callable not found.")

        Arguments := []
        For Key, Value In Tree.Parameters
            Arguments[Key] := Eval(Value,Environment)
        Return, Callable.(Callable,Callable,Arguments,Environment)
    }
    If Tree.Type = "Block"
        Return, new BuiltinTypes.Block(Tree.Contents,Environment)
    If Tree.Type = "Symbol"
        Return, new BuiltinTypes.Symbol(Tree.Value)
    If Tree.Type = "String"
        Return, new BuiltinTypes.String(Tree.Value)
    If Tree.Type = "Identifier"
        Return, Environment._subscript(Environment,[new BuiltinTypes.Symbol(Tree.Value)],Environment)
    If Tree.Type = "Number"
        Return, new BuiltinTypes.Number(Tree.Value)
    If Tree.Type = "Self"
        Return, Environment
    throw Exception("Invalid token.")
}
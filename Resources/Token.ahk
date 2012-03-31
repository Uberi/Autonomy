#NoEnv

CodeTokenInit()
{
    global CodeTokenTypes
    ;set up token type enumeration
    CodeTokenTypes := Object("OPERATOR",0
                            ,"NUMBER",1
                            ,"STRING",2
                            ,"IDENTIFIER",3
                            ,"SEPARATOR",4
                            ,"LINE_END",5)
}

CodeTokenOperator(Operator,Position,File)
{
    global CodeTokenTypes
    Return, Object("Type",CodeTokenTypes.OPERATOR,"Value",Operator,"Position",Position,"File",File)
}

CodeTokenNumber(Value,Position,File)
{
    global CodeTokenTypes
    Return, Object("Type",CodeTokenTypes.NUMBER,"Value",Value,"Position",Position,"File",File)
}

CodeTokenString(Value,Position,File)
{
    global CodeTokenTypes
    Return, Object("Type",CodeTokenTypes.STRING,"Value",Value,"Position",Position,"File",File)
}

CodeTokenIdentifier(Name,Position,File)
{
    global CodeTokenTypes
    Return, Object("Type",CodeTokenTypes.IDENTIFIER,"Value",Name,"Position",Position,"File",File)
}

CodeTokenSeparator(Position,File)
{
    global CodeTokenTypes
    Return, Object("Type",CodeTokenTypes.SEPARATOR,"Value","","Position",Position,"File",File)
}

CodeTokenLineEnd(Position,File)
{
    global CodeTokenTypes
    Return, Object("Type",CodeTokenTypes.LINE_END,"Value","","Position",Position,"File",File)
}
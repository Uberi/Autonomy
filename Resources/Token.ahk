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

CodeTokenNumber()
{
    global CodeTokenTypes
    
}

CodeTokenString()
{
    global CodeTokenTypes
    
}

CodeTokenIdentifier()
{
    global CodeTokenTypes
    
}

CodeTokenSeparator()
{
    global CodeTokenTypes
    
}

CodeTokenLineEnd()
{
    global CodeTokenTypes
    
}
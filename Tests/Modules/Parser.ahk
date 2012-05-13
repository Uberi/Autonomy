#NoEnv

class Category_Parser
{
    
}

ParserTest(Parser,Result,Value,Position)
{
    If !Equal(Result,Value)
        throw "Invalid output."
    If Parser.Lexer.Position != Position
        throw "Invalid position."
}
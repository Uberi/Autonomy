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

ParserTestException(Result,Message,Location,Position)
{
    If Result.Message != Message
        throw "Invalid error message."
    If Result.What != Location
        throw "Invalid error location."
    If Result.Extra != Position
        throw "Invalid error position."
}
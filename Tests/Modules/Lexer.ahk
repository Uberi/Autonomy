#NoEnv

class Category_Lexer
{
    class Category_OperatorNull
    {
        Test_Blank()
        {
            l := new Lexer("")
            Tests.LexerTest(l,l.OperatorNull(),False,1)
        }

        Test_Invalid()
        {
            l := new Lexer("@")
            Tests.LexerTest(l,l.OperatorNull(),False,1)
        }

        Test_InputEnd()
        {
            l := new Lexer("!")
            Tests.LexerTest(l,l.OperatorNull(),new Lexer.Token.OperatorNull(Lexer.Operators.NullDenotation["!"],1,1),2)
        }

        Test_Simple()
        {
            l := new Lexer("!`n")
            Tests.LexerTest(l,l.OperatorNull(),new Lexer.Token.OperatorNull(Lexer.Operators.NullDenotation["!"],1,1),2)
        }
    }

    class Category_OperatorLeft
    {
        Test_Blank()
        {
            l := new Lexer("")
            Tests.LexerTest(l,l.OperatorLeft(),False,1)
        }

        Test_Invalid()
        {
            l := new Lexer("@")
            Tests.LexerTest(l,l.OperatorLeft(),False,1)
        }

        Test_InputEnd()
        {
            l := new Lexer("+")
            Tests.LexerTest(l,l.OperatorLeft(),new Lexer.Token.OperatorLeft(Lexer.Operators.LeftDenotation["+"],1,1),2)
        }

        Test_Simple()
        {
            l := new Lexer("+`n")
            Tests.LexerTest(l,l.OperatorLeft(),new Lexer.Token.OperatorLeft(Lexer.Operators.LeftDenotation["+"],1,1),2)
        }
    }

    class Category_Symbol
    {
        Test_Blank()
        {
            l := new Lexer("")
            Tests.LexerTest(l,l.Symbol(),False,1)
        }

        Test_Invalid()
        {
            l := new Lexer("@")
            Tests.LexerTest(l,l.Symbol(),False,1)
        }

        Test_InvalidChar()
        {
            l := new Lexer("'@")
            try l.Symbol()
            catch e
            {
                Tests.LexerTestException(e,"Invalid symbol.","Lexer.Symbol",1)
                Return
            }
            throw "Invalid error."
        }

        Test_InputEnd()
        {
            l := new Lexer("'abc")
            Tests.LexerTest(l,l.Symbol(),new Lexer.Token.Symbol("abc",1,4),5)
        }

        Test_Simple()
        {
            l := new Lexer("'abc`n")
            Tests.LexerTest(l,l.Symbol(),new Lexer.Token.Symbol("abc",1,4),5)
        }
    }

    class Category_String
    {
        Test_Blank()
        {
            l := new Lexer("")
            Tests.LexerTest(l,l.String(),False,1)
        }

        Test_Invalid()
        {
            l := new Lexer("$")
            Tests.LexerTest(l,l.String(),False,1)
        }

        Test_InputEnd()
        {
            l := new Lexer("""Hello, world!")
            try l.String()
            catch e
            {
                Tests.LexerTestException(e,"Invalid string.","Lexer.String",1)
                Return
            }
            throw "Invalid error."
        }

        Test_Unclosed()
        {
            l := new Lexer("""Hello, world!`nmore text")
            try l.String()
            catch e
            {
                Tests.LexerTestException(e,"Invalid string.","Lexer.String",1)
                Return
            }
            throw "Invalid error."
        }

        Test_Empty()
        {
            l := new Lexer("""""")
            Tests.LexerTest(l,l.String(),new Lexer.Token.String("",1,2),3)
        }

        Test_Simple()
        {
            l := new Lexer("""Hello, world!""")
            Tests.LexerTest(l,l.String(),new Lexer.Token.String("Hello, world!",1,15),16)
        }

        class Category_Escape
        {
            Test_InvalidCharacter()
            {
                ;wip: invalid escape sequence test
            }

            Test_InvalidCode()
            {
                ;wip: invalid escape character code test
            }

            Test_Character()
            {
                l := new Lexer("""escaped```` ``""quote``"" and``ttab``n""")
                Tests.LexerTest(l,l.String(),new Lexer.Token.String("escaped`` ""quote"" and`ttab`n",1,32),33)
            }

            Test_Code()
            {
                l := new Lexer("""``c[32]``c[97]123``c[102]""")
                Tests.LexerTest(l,l.String(),new Lexer.Token.String(" a123f",1,24),25)
            }

            Test_Newline()
            {
                l := new Lexer("""line 1```r`nline 2```rline 3```nline 4""")
                Tests.LexerTest(l,l.String(),new Lexer.Token.String("line 1`nline 2`nline 3`nline 4",1,33),34)
            }
        }
    }

    class Category_Identifier
    {
        Test_Blank()
        {
            l := new Lexer("")
            Tests.LexerTest(l,l.Identifier(),False,1)
        }

        Test_Invalid()
        {
            l := new Lexer("@")
            Tests.LexerTest(l,l.Identifier(),False,1)
        }

        Test_InputEnd()
        {
            l := new Lexer("abc")
            Tests.LexerTest(l,l.Identifier(),new Lexer.Token.Identifier("abc",1,3),4)
        }

        Test_Simple()
        {
            l := new Lexer("abc`n")
            Tests.LexerTest(l,l.Identifier(),new Lexer.Token.Identifier("abc",1,3),4)
        }
    }

    class Category_Number
    {
        Test_Blank()
        {
            l := new Lexer("")
            Tests.LexerTest(l,l.Number(),False,1)
        }

        Test_Invalid()
        {
            l := new Lexer("@")
            If !Equal(l.Number(),False)
                throw "Invalid output."
            If l.Position != 1
                throw "Invalid position."
            Tests.LexerTest(l,l.Number(),False,1)
        }

        Test_Simple()
        {
            l := new Lexer("123")
            Tests.LexerTest(l,l.Number(),new Lexer.Token.Number(123,1,3),4)
        }

        Test_ObjectAccess()
        {
            l := new Lexer("123.property")
            Tests.LexerTest(l,l.Number(),new Lexer.Token.Number(123,1,3),4)
        }

        Test_Base()
        {
            l := new Lexer("0xBE4")
            Tests.LexerTest(l,l.Number(),new Lexer.Token.Number(0xBE4,1,5),6)
        }

        Test_Decimal()
        {
            l := new Lexer("123.456")
            Tests.LexerTest(l,l.Number(),new Lexer.Token.Number(123.456,1,7),8)
        }

        Test_Exponent()
        {
            l := new Lexer("123e4")
            Tests.LexerTest(l,l.Number(),new Lexer.Token.Number(1230000,1,5),6)
        }

        Test_BaseDecimal()
        {
            l := new Lexer("0b101.011")
            Tests.LexerTest(l,l.Number(),new Lexer.Token.Number(5.375,1,9),10)
        }

        Test_ExponentDecimal()
        {
            l := new Lexer("123.456e4")
            Tests.LexerTest(l,l.Number(),new Lexer.Token.Number(1234560,1,9),10)
        }

        Test_BaseExponent()
        {
            l := new Lexer("0b1e4")
            Tests.LexerTest(l,l.Number(),new Lexer.Token.Number(16,1,5),6)
        }

        Test_BaseExponentDecimal()
        {
            l := new Lexer("0b101.011e4")
            Tests.LexerTest(l,l.Number(),new Lexer.Token.Number(86,1,11),12)
        }
    }

    class Category_Line
    {
        Test_Blank()
        {
            l := new Lexer("")
            Tests.LexerTest(l,l.Line(),False,1)
        }

        Test_Invalid()
        {
            l := new Lexer("@")
            Tests.LexerTest(l,l.Line(),False,1)
        }

        Test_InputEnd()
        {
            l := new Lexer("`r`n")
            Tests.LexerTest(l,l.Line(),new Lexer.Token.Line(1,2),3)
        }

        Test_Simple()
        {
            l := new Lexer("`r`nabc")
            Tests.LexerTest(l,l.Line(),new Lexer.Token.Line(1,2),3)
        }
    }

    class Category_Separator
    {
        Test_Blank()
        {
            l := new Lexer("")
            Tests.LexerTest(l,l.Separator(),False,1)
        }

        Test_Invalid()
        {
            l := new Lexer("@")
            Tests.LexerTest(l,l.Separator(),False,1)
        }

        Test_InputEnd()
        {
            l := new Lexer(",")
            Tests.LexerTest(l,l.Separator(),new Lexer.Token.Separator(1,1),2)
        }

        Test_Simple()
        {
            l := new Lexer(",`n")
            Tests.LexerTest(l,l.Separator(),new Lexer.Token.Separator(1,1),2)
        }
    }

    class Category_Map
    {
        Test_Blank()
        {
            l := new Lexer("")
            Tests.LexerTest(l,l.Map(),False,1)
        }

        Test_Invalid()
        {
            l := new Lexer("@")
            Tests.LexerTest(l,l.Map(),False,1)
        }

        Test_InputEnd()
        {
            l := new Lexer(":")
            Tests.LexerTest(l,l.Map(),new Lexer.Token.Map(1,1),2)
        }

        Test_Simple()
        {
            l := new Lexer(":`n")
            Tests.LexerTest(l,l.Map(),new Lexer.Token.Map(1,1),2)
        }
    }

    class Category_Comment
    {
        Test_Blank()
        {
            l := new Lexer("")
            Tests.LexerTest(l,l.Comment(),False,1)
        }

        Test_Invalid()
        {
            l := new Lexer("@")
            Tests.LexerTest(l,l.Comment(),False,1)
        }

        class Category_SingleLine
        {
            Test_InputEnd()
            {
                l := new Lexer(";test")
                Tests.LexerTest(l,l.Comment(),new Lexer.Token.Comment("test",1,5),6)
            }

            Test_Simple()
            {
                l := new Lexer(";test`n")
                Tests.LexerTest(l,l.Comment(),new Lexer.Token.Comment("test",1,5),6)
            }
        }

        class Category_Multiline
        {
            Test_InputEnd()
            {
                l := new Lexer("/*test")
                Tests.LexerTest(l,l.Comment(),new Lexer.Token.Comment("test",1,6),7)
            }

            Test_Simple()
            {
                l := new Lexer("/*test*/")
                Tests.LexerTest(l,l.Comment(),new Lexer.Token.Comment("test",1,8),9)
            }

            Test_Nested()
            {
                l := new Lexer("/*/**/*/")
                Tests.LexerTest(l,l.Comment(),new Lexer.Token.Comment("/**/",1,8),9)
            }
        }
    }
}

LexerTest(Lexer,Result,Value,Position)
{
    If !Equal(Result,Value)
        throw "Invalid output."
    If Lexer.Position != Position
        throw "Invalid position."
}

LexerTestException(Value,Message,Location,Position)
{
    If Value.Message != Message
        throw "Invalid error message."
    If Value.What != Location
        throw "Invalid error location."
    If Value.Extra != Position
        throw "Invalid error position."
}
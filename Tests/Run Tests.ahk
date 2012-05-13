#NoEnv

/*
Copyright 2011-2012 Anthony Zhang <azhang9@gmail.com>

This file is part of Autonomy. Source code is available at <https://github.com/Uberi/Autonomy>.

Autonomy is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#Include Unit Test.ahk

#Warn All
#Warn LocalSameAsGlobal, Off

UnitTest.Initialize()
UnitTest.Test(AutonomyTests)
Return

class AutonomyTests
{
    class Category_Lexer
    {
        class Category_OperatorNull
        {
            Test_Blank()
            {
                l := new Lexer("")
                TestFunctions.LexerTest(l,l.OperatorNull(),False,1)
            }

            Test_Invalid()
            {
                l := new Lexer("@")
                TestFunctions.LexerTest(l,l.OperatorNull(),False,1)
            }

            Test_InputEnd()
            {
                l := new Lexer("!")
                TestFunctions.LexerTest(l,l.OperatorNull(),new Lexer.Token.OperatorNull(Lexer.Operators.NullDenotation["!"],1,1),2)
            }

            Test_Simple()
            {
                l := new Lexer("!`n")
                TestFunctions.LexerTest(l,l.OperatorNull(),new Lexer.Token.OperatorNull(Lexer.Operators.NullDenotation["!"],1,1),2)
            }
        }

        class Category_OperatorLeft
        {
            Test_Blank()
            {
                l := new Lexer("")
                TestFunctions.LexerTest(l,l.OperatorLeft(),False,1)
            }

            Test_Invalid()
            {
                l := new Lexer("@")
                TestFunctions.LexerTest(l,l.OperatorLeft(),False,1)
            }

            Test_InputEnd()
            {
                l := new Lexer("+")
                TestFunctions.LexerTest(l,l.OperatorLeft(),new Lexer.Token.OperatorLeft(Lexer.Operators.LeftDenotation["+"],1,1),2)
            }

            Test_Simple()
            {
                l := new Lexer("+`n")
                TestFunctions.LexerTest(l,l.OperatorLeft(),new Lexer.Token.OperatorLeft(Lexer.Operators.LeftDenotation["+"],1,1),2)
            }
        }

        class Category_String
        {
            Test_Blank()
            {
                l := new Lexer("")
                TestFunctions.LexerTest(l,l.String(),False,1)
            }

            Test_Invalid()
            {
                l := new Lexer("$")
                TestFunctions.LexerTest(l,l.String(),False,1)
            }

            Test_InputEnd()
            {
                l := new Lexer("""Hello, world!")
                TestFunctions.LexerTest(l,l.String(),False,1)
            }

            Test_Unclosed()
            {
                l := new Lexer("""Hello, world!`nmore text")
                TestFunctions.LexerTest(l,l.String(),False,1)
            }

            Test_Empty()
            {
                l := new Lexer("""""")
                TestFunctions.LexerTest(l,l.String(),new Lexer.Token.String("",1,2),3)
            }

            Test_Simple()
            {
                l := new Lexer("""Hello, world!""")
                TestFunctions.LexerTest(l,l.String(),new Lexer.Token.String("Hello, world!",1,15),16)
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
                    TestFunctions.LexerTest(l,l.String(),new Lexer.Token.String("escaped`` ""quote"" and`ttab`n",1,32),33)
                }

                Test_Code()
                {
                    l := new Lexer("""``c[32]``c[97]123``c[102]""")
                    TestFunctions.LexerTest(l,l.String(),new Lexer.Token.String(" a123f",1,24),25)
                }

                Test_Newline()
                {
                    l := new Lexer("""line 1```r`nline 2```rline 3```nline 4""")
                    TestFunctions.LexerTest(l,l.String(),new Lexer.Token.String("line 1`nline 2`nline 3`nline 4",1,33),34)
                }
            }
        }

        class Category_Identifier
        {
            Test_Blank()
            {
                l := new Lexer("")
                TestFunctions.LexerTest(l,l.Identifier(),False,1)
            }

            Test_Invalid()
            {
                l := new Lexer("@")
                TestFunctions.LexerTest(l,l.Identifier(),False,1)
            }

            Test_InputEnd()
            {
                l := new Lexer("abc")
                TestFunctions.LexerTest(l,l.Identifier(),new Lexer.Token.Identifier("abc",1,3),4)
            }

            Test_Simple()
            {
                l := new Lexer("abc`n")
                TestFunctions.LexerTest(l,l.Identifier(),new Lexer.Token.Identifier("abc",1,3),4)
            }
        }

        class Category_Number
        {
            Test_Blank()
            {
                l := new Lexer("")
                TestFunctions.LexerTest(l,l.Number(),False,1)
            }

            Test_Invalid()
            {
                l := new Lexer("@")
                If !Equal(l.Number(),False)
                    throw "Invalid output."
                If l.Position != 1
                    throw "Invalid position."
                TestFunctions.LexerTest(l,l.Number(),False,1)
            }

            Test_Simple()
            {
                l := new Lexer("123")
                TestFunctions.LexerTest(l,l.Number(),new Lexer.Token.Number(123,1,3),4)
            }

            Test_Base()
            {
                l := new Lexer("0x123")
                TestFunctions.LexerTest(l,l.Number(),new Lexer.Token.Number(0x123,1,5),6)
            }

            Test_BaseDecimal()
            {
                l := new Lexer("0x123.456")
                TestFunctions.LexerTest(l,l.Number(),new Lexer.Token.Number(0x123,1,5),6)
            }

            Test_ObjectAccess()
            {
                l := new Lexer("123.property")
                TestFunctions.LexerTest(l,l.Number(),new Lexer.Token.Number(123,1,3),4)
            }

            Test_Decimal()
            {
                l := new Lexer("123.456")
                TestFunctions.LexerTest(l,l.Number(),new Lexer.Token.Number(123.456,1,7),8)
            }
        }
    }

    class Category_Parser
    {
        
    }
}

class TestFunctions
{
    LexerTest(Lexer,Result,Value,Position)
    {
        If !Equal(Result,Value)
            throw "Invalid output."
        If Lexer.Position != Position
            throw "Invalid position."
    }
}

Equal(Value1,Value2,CaseSensitive = 1)
{
    If !IsObject(Value1)
    {
        If IsObject(Value2)
            Return, False
        If CaseSensitive
            Return, Value1 == Value2
        Else
            Return, Value1 = Value2
    }
    If !IsObject(Value2)
        Return, False

    For Key, Value In Value1
    {
        If !ObjHasKey(Value2,Key)
            Return, False
        If !Equal(Value,Value2[Key],CaseSensitive)
            Return, False
    }

    For Key, Value In Value2
    {
        If !ObjHasKey(Value1,Key)
            Return, False
        If !Equal(Value,Value1[Key],CaseSensitive)
            Return, False
    }

    Return, True
}

#Include ../
#Include Lexer.ahk
#Include Parser.ahk
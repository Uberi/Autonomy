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
                If !Equal(l.OperatorNull(),False)
                    throw "Invalid output."
                If l.Position != 1
                    throw "Invalid position."
            }

            Test_Invalid()
            {
                l := new Lexer("@")
                If !Equal(l.OperatorNull(),False)
                    throw "Invalid output."
                If l.Position != 1
                    throw "Invalid position."
            }

            Test_Valid()
            {
                l := new Lexer("!")
                If !Equal(l.OperatorNull()
                    ,new Lexer.Token.OperatorNull(Object("Identifier","not","LeftBindingPower",0,"RightBindingPower",160),1,1))
                    throw "Invalid output."
                If l.Position != 2
                    throw "Invalid position."
            }
        }

        class Category_OperatorLeft
        {
            Test_Blank()
            {
                l := new Lexer("")
                If !Equal(l.OperatorLeft(),False)
                    throw "Invalid output."
                If l.Position != 1
                    throw "Invalid position."
            }

            Test_Invalid()
            {
                l := new Lexer("$")
                If !Equal(l.OperatorLeft(),False)
                    throw "Invalid output."
                If l.Position != 1
                    throw "Invalid position."
            }

            Test_Valid()
            {
                l := new Lexer(":=")
                If !Equal(l.OperatorLeft()
                    ,new Lexer.Token.OperatorLeft(Object("Identifier","assign","LeftBindingPower",170,"RightBindingPower",9),1,2))
                    throw "Invalid output."
                If l.Position != 3
                    throw "Invalid position."
            }
        }

        class Category_String
        {
            Test_Blank()
            {
                l := new Lexer("")
                If !Equal(l.String(),False)
                    throw "Invalid output."
                If l.Position != 1
                    throw "Invalid position."
            }

            Test_Invalid()
            {
                l := new Lexer("$")
                If !Equal(l.String(),False)
                    throw "Invalid output."
                If l.Position != 1
                    throw "Invalid position."
            }

            Test_InputEnd()
            {
                l := new Lexer("""Hello, world!")
                If !Equal(l.String(),False)
                    throw "Invalid output."
                If l.Position != 1
                    throw "Invalid position."
            }

            Test_Unclosed()
            {
                l := new Lexer("""Hello, world!`nmore text")
                If !Equal(l.String(),False)
                    throw "Invalid output."
                If l.Position != 1
                    throw "Invalid position."
            }

            Test_Empty()
            {
                l := new Lexer("""""")
                If !Equal(l.String()
                    ,new Lexer.Token.String("",1,2))
                    throw "Invalid output."
                If l.Position != 3
                    throw "Invalid position."
            }

            Test_Simple()
            {
                l := new Lexer("""Hello, world!""")
                If !Equal(l.String()
                    ,new Lexer.Token.String("Hello, world!",1,15))
                    throw "Invalid output."
                If l.Position != 16
                    throw "Invalid position."
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
                    If !Equal(l.String()
                        ,new Lexer.Token.String("escaped`` ""quote"" and`ttab`n",1,32))
                        throw "Invalid output."
                    If l.Position != 33
                        throw "Invalid position."
                }

                Test_Code()
                {
                    l := new Lexer("""``c[32]``c[97]123``c[102]""")
                    If !Equal(l.String()
                        ,new Lexer.Token.String(" a123f",1,24))
                        throw "Invalid output."
                    If l.Position != 25
                        throw "Invalid position."
                }

                Test_Newline()
                {
                    l := new Lexer("""line 1```r`nline 2```rline 3```nline 4""")
                    If !Equal(l.String()
                        ,new Lexer.Token.String("line 1`nline 2`nline 3`nline 4",1,33))
                        throw "Invalid output."
                    If l.Position != 34
                        throw "Invalid position."
                }
            }
        }
    }

    class Category_Parser
    {
        
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
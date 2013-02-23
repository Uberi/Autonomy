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

class Lexer
{
    static Operators := Code.Lexer.GetOperatorTable()

    class Operator
    {
        __New(Identifier,LeftBindingPower,RightBindingPower)
        {
            this.Identifier := Identifier
            this.LeftBindingPower := LeftBindingPower
            this.RightBindingPower := RightBindingPower
        }
    }

    GetOperatorTable()
    {
        Operators := Object()
        Operators.NullDenotation := Object()
        Operators.LeftDenotation := Object()

        Operators.LeftDenotation[":="]  := new this.Operator("_assign"                 ,170 ,9)
        Operators.LeftDenotation["+="]  := new this.Operator("_assign_add"             ,170 ,9)
        Operators.LeftDenotation["-="]  := new this.Operator("_assign_subtract"        ,170 ,9)
        Operators.LeftDenotation["*="]  := new this.Operator("_assign_multiply"        ,170 ,9)
        Operators.LeftDenotation["/="]  := new this.Operator("_assign_divide"          ,170 ,9)
        Operators.LeftDenotation["//="] := new this.Operator("_assign_divide_floor"    ,170 ,9)
        Operators.LeftDenotation["%="]  := new this.Operator("_assign_remainder"       ,170 ,9)
        Operators.LeftDenotation["%%="] := new this.Operator("_assign_modulo"          ,170 ,9)
        Operators.LeftDenotation["**="] := new this.Operator("_assign_exponentiate"    ,170 ,9)
        Operators.LeftDenotation[".="]  := new this.Operator("_assign_concatenate"     ,170 ,9)
        Operators.LeftDenotation["|="]  := new this.Operator("_assign_bit_or"          ,170 ,9)
        Operators.LeftDenotation["&="]  := new this.Operator("_assign_bit_and"         ,170 ,9)
        Operators.LeftDenotation["^="]  := new this.Operator("_assign_bit_xor"         ,170 ,9)
        Operators.LeftDenotation["<<="] := new this.Operator("_assign_bit_shift_left"  ,170 ,9)
        Operators.LeftDenotation[">>="] := new this.Operator("_assign_bit_shift_right" ,170 ,9)
        Operators.LeftDenotation["||="] := new this.Operator("_assign_or"              ,170 ,9)
        Operators.LeftDenotation["&&="] := new this.Operator("_assign_and"             ,170 ,9)
        Operators.LeftDenotation["?"]   := new this.Operator("_if"                     ,20  ,19)
        Operators.LeftDenotation["||"]  := new this.Operator("_or"                     ,40  ,40)
        Operators.LeftDenotation["&&"]  := new this.Operator("_and"                    ,50  ,50)
        Operators.LeftDenotation["="]   := new this.Operator("_equals"                 ,70  ,70)
        Operators.LeftDenotation["=="]  := new this.Operator("_equals_strict"          ,70  ,70)
        Operators.LeftDenotation["!="]  := new this.Operator("_not_equals"             ,70  ,70)
        Operators.LeftDenotation["!=="] := new this.Operator("_not_equals_strict"      ,70  ,70)
        Operators.LeftDenotation[">"]   := new this.Operator("_greater_than"           ,80  ,80)
        Operators.LeftDenotation["<"]   := new this.Operator("_less_than"              ,80  ,80)
        Operators.LeftDenotation[">="]  := new this.Operator("_greater_than_or_equal"  ,80  ,80)
        Operators.LeftDenotation["<="]  := new this.Operator("_less_than_or_equal"     ,80  ,80)
        Operators.LeftDenotation[".."]  := new this.Operator("_concatenate"            ,90  ,90)
        Operators.LeftDenotation["|"]   := new this.Operator("_bit_or"                 ,100 ,100)
        Operators.LeftDenotation["^"]   := new this.Operator("_bit_exclusive_or"       ,110 ,110)
        Operators.LeftDenotation["&"]   := new this.Operator("_bit_and"                ,120 ,120)
        Operators.LeftDenotation["<<"]  := new this.Operator("_shift_left"             ,130 ,130)
        Operators.LeftDenotation[">>"]  := new this.Operator("_shift_right"            ,130 ,130)
        Operators.LeftDenotation[">>>"] := new this.Operator("_shift_right_unsigned"   ,130 ,130)
        Operators.LeftDenotation["+"]   := new this.Operator("_add"                    ,140 ,140)
        Operators.LeftDenotation["-"]   := new this.Operator("_subtract"               ,140 ,140)
        Operators.LeftDenotation["*"]   := new this.Operator("_multiply"               ,150 ,150)
        Operators.LeftDenotation["/"]   := new this.Operator("_divide"                 ,150 ,150)
        Operators.LeftDenotation["//"]  := new this.Operator("_divide_floor"           ,150 ,150)
        Operators.LeftDenotation["%"]   := new this.Operator("_remainder"              ,150 ,150)
        Operators.LeftDenotation["%%"]  := new this.Operator("_modulo"                 ,150 ,150)
        Operators.NullDenotation["!"]   := new this.Operator("_not"                    ,0   ,160)
        Operators.NullDenotation["-"]   := new this.Operator("_invert"                 ,0   ,160)
        Operators.NullDenotation["~"]   := new this.Operator("_bit_not"                ,0   ,160)
        Operators.NullDenotation["&"]   := new this.Operator("_address"                ,0   ,160)
        Operators.LeftDenotation["**"]  := new this.Operator("_exponentiate"           ,170 ,169)

        Operators.NullDenotation["("]   := new this.Operator("_evaluate"               ,0   ,0)
        Operators.LeftDenotation["("]   := new this.Operator("_call"                   ,190 ,0)
        Operators.LeftDenotation[")"]   := new this.Operator("_end"                    ,0   ,0)

        Operators.NullDenotation["{"]   := new this.Operator("_block"                  ,0   ,0)
        Operators.LeftDenotation["}"]   := new this.Operator("_block_end"              ,0   ,0)

        Operators.NullDenotation["["]   := new this.Operator("_array"                  ,0   ,0)
        Operators.LeftDenotation["["]   := new this.Operator("_subscript"              ,200 ,0)
        Operators.LeftDenotation["]"]   := new this.Operator("_subscript_end"          ,0   ,0)

        Operators.LeftDenotation["."]   := new this.Operator("_subscript_identifier"   ,200 ,200)

        ;obtain the length of the longest null denotation operator
        Operators.MaxNullLength := 0
        For Operator In Operators.NullDenotation
        {
            Length := StrLen(Operator)
            If (Length > Operators.MaxNullLength)
                Operators.MaxNullLength := Length
        }

        ;obtain the length of the longest left denotation operator
        Operators.MaxLeftLength := 0
        For Operator In Operators.LeftDenotation
        {
            Length := StrLen(Operator)
            If (Length > Operators.MaxLeftLength)
                Operators.MaxLeftLength := Length
        }

        Return, Operators
    }

    __New(Text,Position = 1)
    {
        this.Text := Text
        this.Position := Position
    }

    class Token
    {
        class OperatorNull
        {
            __New(Value,Position,Length)
            {
                this.Type := "OperatorNull"
                this.Value := Value
                this.Position := Position
                this.Length := Length
            }
        }

        class OperatorLeft
        {
            __New(Value,Position,Length)
            {
                this.Type := "OperatorLeft"
                this.Value := Value
                this.Position := Position
                this.Length := Length
            }
        }

        class Line
        {
            __New(Position,Length)
            {
                this.Type := "Line"
                this.Position := Position
                this.Length := Length
            }
        }

        class Separator
        {
            __New(Position,Length)
            {
                this.Type := "Separator"
                this.Position := Position
                this.Length := Length
            }
        }

        class Map
        {
            __New(Position,Length)
            {
                this.Type := "Map"
                this.Position := Position
                this.Length := Length
            }
        }

        class Symbol
        {
            __New(Value,Position,Length)
            {
                this.Type := "Symbol"
                this.Value := Value
                this.Position := Position
                this.Length := Length
            }
        }

        class String
        {
            __New(Value,Position,Length)
            {
                this.Type := "String"
                this.Value := Value
                this.Position := Position
                this.Length := Length
            }
        }

        class Identifier
        {
            __New(Value,Position,Length)
            {
                this.Type := "Identifier"
                this.Value := Value
                this.Position := Position
                this.Length := Length
            }
        }

        class Number
        {
            __New(Value,Position,Length)
            {
                this.Type := "Number"
                this.Value := Value
                this.Position := Position
                this.Length := Length
            }
        }

        class Comment
        {
            __New(Value,Position,Length)
            {
                this.Type := "Comment"
                this.Value := Value
                this.Position := Position
                this.Length := Length
            }
        }
    }

    Next()
    {
        Position1 := this.Position

        this.Whitespace()

        If SubStr(this.Text,this.Position,1) = "" ;past end of text
        {
            this.Position := Position1
            Return, False
        }

        Token := this.OperatorNull()
        If Token
            Return, Token

        Token := this.OperatorLeft()
        If Token
            Return, Token

        Token := this.Line()
        If Token
            Return, Token

        Token := this.Separator()
        If Token
            Return, Token

        Token := this.Map()
        If Token
            Return, Token

        Token := this.Symbol()
        If Token
            Return, Token

        Token := this.String()
        If Token
            Return, Token

        Token := this.Identifier()
        If Token
            Return, Token

        Token := this.Number()
        If Token
            Return, Token

        Token := this.Comment()
        If Token
            Return, Token

        throw Exception("Invalid token.",A_ThisFunc,this.Position)
    }

    OperatorNull()
    {
        Length := this.Operators.MaxNullLength
        While, Length > 0
        {
            Output := SubStr(this.Text,this.Position,Length)
            If StrLen(Output) = Length ;operator is not truncated at the end of input
                && this.Operators.NullDenotation.HasKey(Output) ;operator found
            {
                ;if the operator ends in an identifier character, ensure that the ending is not an identifier
                If !(InStr("abcdefghijklmnopqrstuvwxyz0123456789",SubStr(Output,0))
                    && (NextChar := SubStr(this.Text,this.Position + Length,1)) != ""
                    && InStr("abcdefghijklmnopqrstuvwxyz0123456789",NextChar))
                {
                    Position1 := this.Position
                    this.Position += Length
                    Operator := this.Operators.NullDenotation[Output]
                    Return, new this.Token.OperatorNull(Operator,Position1,Length)
                }
            }
            Length --
        }
        Return, False
    }

    OperatorLeft()
    {
        Length := this.Operators.MaxLeftLength
        While, Length > 0
        {
            Output := SubStr(this.Text,this.Position,Length)
            If StrLen(Output) = Length ;operator is not truncated at the end of input
                && this.Operators.LeftDenotation.HasKey(Output) ;operator found
            {
                ;if the operator ends in an identifier character, ensure that the ending is not an identifier
                If !(InStr("abcdefghijklmnopqrstuvwxyz0123456789",SubStr(Output,0))
                    && (NextChar := SubStr(this.Text,this.Position + Length,1)) != ""
                    && InStr("abcdefghijklmnopqrstuvwxyz0123456789",NextChar))
                {
                    Position1 := this.Position
                    this.Position += Length
                    Operator := this.Operators.LeftDenotation[Output]
                    Return, new this.Token.OperatorLeft(Operator,Position1,Length)
                }
            }
            Length --
        }
        Return, False
    }

    Symbol()
    {
        Position1 := this.Position
        If SubStr(this.Text,Position1,1) != "'" ;check for symbol character
            Return, False
        this.Position ++

        Output := SubStr(this.Text,this.Position,1)
        If (Output = "" || !InStr("abcdefghijklmnopqrstuvwxyz_",Output)) ;check first character against valid identifier characters
        {
            ;wip: nonfatal error
            throw Exception("Invalid symbol.",A_ThisFunc,Position1)
        }
        this.Position ++ ;move past the first character of the symbol

        ;obtain the rest of the symbol
        While, (CurrentChar := SubStr(this.Text,this.Position,1)) != "" && InStr("abcdefghijklmnopqrstuvwxyz_0123456789",CurrentChar)
            Output .= CurrentChar, this.Position ++

        Length := this.Position - Position1
        Return, new this.Token.Symbol(Output,Position1,Length)
    }

    String()
    {
        Position1 := this.Position
        If SubStr(this.Text,Position1,1) != """" ;check for opening quote
            Return, False
        this.Position ++ ;move past the opening quote

        Output := ""
        While, (CurrentChar := SubStr(this.Text,this.Position,1)) != "" && CurrentChar != "`r" && CurrentChar != "`n" ;loop through string contents
        {
            If (CurrentChar = """") ;check for closing quote
            {
                this.Position ++ ;move past closing quote
                Length := this.Position - Position1
                Return, new this.Token.String(Output,Position1,Length)
            }

            Value := this.Escape() ;check for escape sequence
            If Value
                Output .= Value
            Else
                Output .= CurrentChar, this.Position ++
        }
        throw Exception("Invalid string.",A_ThisFunc,Position1)
    }

    Identifier()
    {
        Position1 := this.Position
        Output := SubStr(this.Text,Position1,1)
        If (Output = "" || !InStr("abcdefghijklmnopqrstuvwxyz_",Output)) ;check first character against valid identifier characters
            Return, False
        this.Position ++ ;move past the first character of the identifier

        ;obtain the rest of the identifier
        While, (CurrentChar := SubStr(this.Text,this.Position,1)) != "" && InStr("abcdefghijklmnopqrstuvwxyz_0123456789",CurrentChar)
            Output .= CurrentChar, this.Position ++

        Length := this.Position - Position1
        Return, new this.Token.Identifier(Output,Position1,Length)
    }

    Number()
    {
        Position1 := this.Position
        Output := SubStr(this.Text,Position1,1)
        If (Output = "" || !InStr("0123456789",Output)) ;check for numerical digits
            Return, False
        this.Position ++ ;move past the first digit

        Exponent := 0
        NumberBase := 10, CharSet := "0123456789"
        If Output = 0 ;starting digit is 0
        {
            CurrentChar := SubStr(this.Text,this.Position,1)
            If (CurrentChar = "x") ;hexidecimal base
            {
                this.Position ++
                NumberBase := 16, CharSet := "0123456789ABCDEF"
            }
            Else If (CurrentChar = "b") ;binary base
            {
                this.Position ++
                NumberBase := 2, CharSet := "01"
            }
        }

        ;handle integer digits of number
        While, (CurrentChar := SubStr(this.Text,this.Position,1)) != "" ;not past the end of the input
            && (Value := InStr(CharSet,CurrentChar)) ;character is numeric
            Output := (Output * NumberBase) + (Value - 1), this.Position ++

        ;handle decimal point if present, disambiguating the decimal point from the object access operator
        If SubStr(this.Text,this.Position,1) = "." ;period found
        {
            If (NumberBase != 16 ;decimals should not be available in hexadecimal numbers
                && (CurrentChar := SubStr(this.Text,this.Position + 1,1)) != "" ;not past end of the input
                && InStr(CharSet,CurrentChar)) ;character after period is numeric
            {
                this.Position ++

                ;handle decimal digits of number
                While, (CurrentChar := SubStr(this.Text,this.Position,1)) != "" ;not past the end of the input
                    && (Value := InStr(CharSet,CurrentChar)) ;character is numeric
                    Output := (Output * NumberBase) + (Value - 1), this.Position ++, Exponent --
            }
            Else ;object access operator
            {
                Length := this.Position - Position1
                Return, new this.Token.Number(Output,Position1,Length)
            }
        }

        If (NumberBase != 16 ;exponents should not be available in hexadecimal numbers
            && SubStr(this.Text,this.Position,1) = "e") ;exponent found
        {
            this.Position ++

            If (CurrentChar = "-") ;exponent is negative
                Sign := -1, this.Position ++
            Else
                Sign := 1

            Value := SubStr(this.Text,this.Position,1)
            If (Value = "" || !InStr("0123456789",Value)) ;check for numeric exponent
            {
                ;wip: nonfatal error
                throw Exception("Invalid exponent.",A_ThisFunc,Position1)
            }
            this.Position ++ ;move past the first character of the exponent

            ;handle digits of the exponent
            While, (CurrentChar := SubStr(this.Text,this.Position,1)) != "" && InStr("0123456789",CurrentChar)
                Value := (Value * 10) + CurrentChar, this.Position ++

            Exponent += Value * Sign
        }

        ;check for invalid identifier
        CurrentChar := SubStr(this.Text,this.Position,1)
        If (CurrentChar != "" && InStr("abcdefghijklmnopqrstuvwxyz_",CurrentChar))
        {
            ;wip: nonfatal error
            throw Exception("Invalid identifier.",A_ThisFunc,this.Position)
        }

        ;apply exponent
        Output *= NumberBase ** Exponent

        Length := this.Position - Position1
        Return, new this.Token.Number(Output,Position1,Length)
    }

    Line()
    {
        Position1 := this.Position

        ;check for line end
        CurrentChar := SubStr(this.Text,Position1,1)
        If (CurrentChar != "`r" && CurrentChar != "`n")
            Return, False
        this.Position ++ ;move past the line end

        ;move past any remaining line end characters
        While, (CurrentChar := SubStr(this.Text,this.Position,1)) = "`r" || CurrentChar = "`n"
            this.Position ++

        Length := this.Position - Position1
        Return, new this.Token.Line(Position1,Length)
    }

    Separator()
    {
        Position1 := this.Position

        ;check for separator
        If (SubStr(this.Text,Position1,1) != ",")
            Return, False

        this.Position ++ ;move past the separator
        Return, new this.Token.Separator(Position1,1)
    }

    Map()
    {
        Position1 := this.Position

        ;check for map
        If (SubStr(this.Text,Position1,1) != ":")
            Return, False

        this.Position ++ ;move past the map
        Return, new this.Token.Map(Position1,1)
    }

    Comment()
    {
        Position1 := this.Position
        If SubStr(this.Text,this.Position,1) = ";"
        {
            Output := ""
            this.Position ++ ;move past comment marker
            While, (CurrentChar := SubStr(this.Text,this.Position,1)) != "" && CurrentChar != "`r" && CurrentChar != "`n"
                Output .= CurrentChar, this.Position ++
            Length := this.Position - Position1
            Return, new this.Token.Comment(Output,Position1,Length)
        }
        If SubStr(this.Text,this.Position,2) = "/*"
        {
            Output := ""
            this.Position += 2 ;move past the comment start
            CommentLevel := 1
            Loop
            {
                CurrentChar := SubStr(this.Text,this.Position,2)
                If (CurrentChar = "") ;past end of input
                    Break
                If (CurrentChar = "/*") ;comment start
                {
                    CommentLevel ++
                    this.Position += 2 ;move past the comment start
                    Output .= CurrentChar
                }
                Else If (CurrentChar = "*/") ;comment end
                {
                    CommentLevel --
                    this.Position += 2 ;move past the comment end
                    If CommentLevel = 0 ;original comment end
                        Break
                    Output .= CurrentChar
                }
                Else
                {
                    this.Position ++
                    Output .= SubStr(CurrentChar,1,1)
                }
            }
            Length := this.Position - Position1
            Return, new this.Token.Comment(Output,Position1,Length)
        }
        Return, False
    }

    Whitespace()
    {
        CurrentChar := SubStr(this.Text,this.Position,1)
        If (CurrentChar != " " && CurrentChar != "`t")
            Return, False
        this.Position ++ ;move past whitespace

        ;move past any remaining whitespace
        While, (CurrentChar := SubStr(this.Text,this.Position,1)) = " " || CurrentChar = "`t"
            this.Position ++
        Return, True
    }

    Escape()
    {
        If SubStr(this.Text,this.Position,1) != "``" ;check for escape character
            Return, False
        this.Position ++ ;move past escape character

        CurrentChar := SubStr(this.Text,this.Position,1) ;obtain the escaped character
        If (CurrentChar = "`n") ;newline escaped
            Output := "`n", this.Position ++
        Else If (CurrentChar = "`r") ;carriage return escaped
        {
            If SubStr(this.Text,this.Position + 1,1) = "`n" ;check for newline and ignore if present
                this.Position ++
            Output := "`n", this.Position ++
        }
        Else If (CurrentChar = "``") ;literal backtick
            Output := "``", this.Position ++
        Else If (CurrentChar = """") ;literal quote
            Output := """", this.Position ++
        Else If (CurrentChar = "r") ;literal carriage return
            Output := "`r", this.Position ++
        Else If (CurrentChar = "n") ;literal newline
            Output := "`n", this.Position ++
        Else If (CurrentChar = "t") ;literal tab
            Output := "`t", this.Position ++
        Else If (CurrentChar = "c") ;character code
        {
            this.Position ++ ;move past the character code marker

            If SubStr(this.Text,this.Position,1) = "[" ;character code start
                this.Position ++ ;move past opening square bracket
            Else
            {
                ;wip: nonfatal error
            }

            CharacterCode := SubStr(this.Text,this.Position,1)
            If (CharacterCode != "" && InStr("0123456789",CharacterCode)) ;character is numeric
            {
                this.Position ++ ;move past first digit of character code
                While, (CurrentChar := SubStr(this.Text,this.Position,1)) != "" && InStr("0123456789",CurrentChar) ;character is numeric
                    CharacterCode .= CurrentChar, this.Position ++
                If (CurrentChar = "]") ;character code end
                    this.Position ++ ;move past closign square bracket
                Else
                {
                    ;wip: nonfatal error
                }
                Output := Chr(CharacterCode)
            }
            Else
            {
                ;wip: nonfatal error
            }
        }
        Else
        {
            ;wip: nonfatal error goes here
            this.Position ++
        }
        Return, Output
    }
}
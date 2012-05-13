#NoEnv

/*
#Warn All
#Warn LocalSameAsGlobal, Off

Code = +=
l := new Lexer(Code)
t := l.OperatorLeft()
MsgBox % "Position: " . t.Position . "`nLength: " . t.Length . "`nNext: " . l.Position . "`n`n" . ShowObject(t.Value)

;Code = 0x123.4
Code = 123.456e5
l := new Lexer(Code)
t := l.Number()
MsgBox % "Position: " . t.Position . "`nLength: " . t.Length . "`nNext: " . l.Position . "`n`n" . t.Value

Code = "s````tri``c[123]ng``""
l := new Lexer(Code)
t := l.String()
MsgBox % "Position: " . t.Position . "`nLength: " . t.Length . "`nNext: " . l.Position . "`n`n" . t.Value
ExitApp
*/

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
    static Operators := Lexer.GetOperatorTable()

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

        Operators.LeftDenotation[":="]  := new Lexer.Operator("assign"                     ,170 ,9)
        Operators.LeftDenotation["+="]  := new Lexer.Operator("assign_add"                 ,170 ,9)
        Operators.LeftDenotation["-="]  := new Lexer.Operator("assign_subtract"            ,170 ,9)
        Operators.LeftDenotation["*="]  := new Lexer.Operator("assign_multiply"            ,170 ,9)
        Operators.LeftDenotation["/="]  := new Lexer.Operator("assign_divide"              ,170 ,9)
        Operators.LeftDenotation["//="] := new Lexer.Operator("assign_divide_floor"        ,170 ,9)
        Operators.LeftDenotation["%="]  := new Lexer.Operator("assign_modulo"              ,170 ,9)
        Operators.LeftDenotation["**="] := new Lexer.Operator("assign_exponentiate"        ,170 ,9)
        Operators.LeftDenotation[".="]  := new Lexer.Operator("assign_concatenate"         ,170 ,9)
        Operators.LeftDenotation["|="]  := new Lexer.Operator("assign_bitwise_or"          ,170 ,9)
        Operators.LeftDenotation["&="]  := new Lexer.Operator("assign_bitwise_and"         ,170 ,9)
        Operators.LeftDenotation["^="]  := new Lexer.Operator("assign_bitwise_xor"         ,170 ,9)
        Operators.LeftDenotation["<<="] := new Lexer.Operator("assign_bitwise_shift_left"  ,170 ,9)
        Operators.LeftDenotation[">>="] := new Lexer.Operator("assign_bitwise_shift_right" ,170 ,9)
        Operators.LeftDenotation["||="] := new Lexer.Operator("assign_or"                  ,170 ,9)
        Operators.LeftDenotation["&&="] := new Lexer.Operator("assign_and"                 ,170 ,9)
        Operators.LeftDenotation["?"]   := new Lexer.Operator("if"                         ,20  ,19)
        Operators.LeftDenotation["||"]  := new Lexer.Operator("or"                         ,40  ,40)
        Operators.LeftDenotation["&&"]  := new Lexer.Operator("and"                        ,50  ,50)
        Operators.LeftDenotation["="]   := new Lexer.Operator("equals_strict"              ,70  ,70)
        Operators.LeftDenotation["=="]  := new Lexer.Operator("equals"                     ,70  ,70)
        Operators.LeftDenotation["!="]  := new Lexer.Operator("not_equals"                 ,70  ,70)
        Operators.LeftDenotation["!=="] := new Lexer.Operator("not_equals_strict"          ,70  ,70)
        Operators.LeftDenotation[">"]   := new Lexer.Operator("greater_than"               ,80  ,80)
        Operators.LeftDenotation["<"]   := new Lexer.Operator("less_than"                  ,80  ,80)
        Operators.LeftDenotation[">="]  := new Lexer.Operator("greater_than_or_equal"      ,80  ,80)
        Operators.LeftDenotation["<="]  := new Lexer.Operator("less_than_or_equal"         ,80  ,80)
        Operators.LeftDenotation[".."]  := new Lexer.Operator("concatenate"                ,90  ,90)
        Operators.LeftDenotation["|"]   := new Lexer.Operator("bitwise_or"                 ,100 ,100)
        Operators.LeftDenotation["^"]   := new Lexer.Operator("bitwise_exclusive_or"       ,110 ,110)
        Operators.LeftDenotation["&"]   := new Lexer.Operator("bitwise_and"                ,120 ,120)
        Operators.LeftDenotation["<<"]  := new Lexer.Operator("bitwise_shift_left"         ,130 ,130)
        Operators.LeftDenotation[">>"]  := new Lexer.Operator("bitwise_shift_right"        ,130 ,130)
        Operators.LeftDenotation["+"]   := new Lexer.Operator("add"                        ,140 ,140)
        Operators.LeftDenotation["-"]   := new Lexer.Operator("subtract"                   ,140 ,140)
        Operators.LeftDenotation["*"]   := new Lexer.Operator("multiply"                   ,150 ,150)
        Operators.LeftDenotation["/"]   := new Lexer.Operator("divide"                     ,150 ,150)
        Operators.LeftDenotation["//"]  := new Lexer.Operator("divide_floor"               ,150 ,150)
        Operators.LeftDenotation["%"]   := new Lexer.Operator("modulo"                     ,150 ,150) ;wip: also should be the format string operator
        Operators.NullDenotation["!"]   := new Lexer.Operator("not"                        ,0   ,160)
        Operators.NullDenotation["-"]   := new Lexer.Operator("invert"                     ,0   ,160)
        Operators.NullDenotation["~"]   := new Lexer.Operator("bitwise_not"                ,0   ,160)
        Operators.NullDenotation["&"]   := new Lexer.Operator("address"                    ,0   ,160)
        Operators.LeftDenotation["**"]  := new Lexer.Operator("exponentiate"               ,170 ,169)

        Operators.NullDenotation["("]   := new Lexer.Operator("evaluate"                   ,0   ,0)
        Operators.LeftDenotation["("]   := new Lexer.Operator("call"                       ,190 ,0)
        Operators.LeftDenotation[")"]   := new Lexer.Operator("end"                        ,0   ,0)

        Operators.NullDenotation["{"]   := new Lexer.Operator("block"                      ,0   ,0)
        Operators.LeftDenotation["}"]   := new Lexer.Operator("block_end"                  ,0   ,0)

        Operators.NullDenotation["["]   := new Lexer.Operator("array"                      ,0   ,0)
        Operators.LeftDenotation["["]   := new Lexer.Operator("subscript"                  ,200 ,0)
        Operators.LeftDenotation["]"]   := new Lexer.Operator("subscript_end"              ,0   ,0)

        Operators.LeftDenotation["."]   := new Lexer.Operator("subscript_identifier"       ,200 ,200)

        ;obtain the length of the longest null denotation operator
        Operators.MaxNullLength :=  := 0
        For Operator In Operators.NullDenotation
            Length := StrLen(Operator), (Length > Operators.MaxNullLength) ? (Operators.MaxNullLength := Length) : ""

        ;obtain the length of the longest left denotation operator
        Operators.MaxLeftLength := 0
        For Operator In Operators.LeftDenotation
            Length := StrLen(Operator), (Length > Operators.MaxLeftLength) ? (Operators.MaxLeftLength := Length) : ""

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
        If SubStr(this.Text,this.Position,1) = "" ;past end of text
            Return, False

        this.Whitespace()

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
        this.Position := Position1
        Return, False
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
                    CommentLevel ++
                Else If (CurrentChar = "*/") ;comment end
                {
                    CommentLevel --
                    If CommentLevel = 0 ;original comment end
                    {
                        this.Position += 2 ;move past the comment end
                        Break
                    }
                }
                Output .= SubStr(CurrentChar,1,1), this.Position ++
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
        Position1 := this.Position
        If SubStr(this.Text,Position1,1) != "``" ;check for escape character
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
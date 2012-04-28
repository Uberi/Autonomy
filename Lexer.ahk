#NoEnv

#Include Resources/Token.ahk

Code = 0x123.456e5
Code = "string``""
l := new Lexer(Code)
;MsgBox % l.Number()[1].Value
MsgBox % l.String()[1].Value
ExitApp

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
    static Operators := Object("LeftDenotation",Object("and","")) ;wip: debug
    ;static MaxOperatorLength := Code.Lexer.GetMaxOperatorLength() ;wip: calculate this on the fly
    static MaxOperatorLength := Lexer.GetMaxOperatorLength() ;wip: calculate this on the fly

    GetMaxOperatorLength()
    {
        MaxLength := 0
        For Operator In this.Operators.NullDenotation ;get the length of the longest null denotation operator
            Length := StrLen(Operator), (Length > MaxLength) ? (MaxLength := Length) : ""
        For Operator In this.Operators.LeftDenotation ;get the length of the longest left denotation operator
        {
            Length := StrLen(Operator), (Length > MaxLength) ? (MaxLength := Length) : ""
        }
        Return, MaxLength
    }

    __New(Text)
    {
        this.Text := Text
        this.Position := 1
    }

    class Token
    {
        class Operator
        {
            __New(Value,Position,Length)
            {
                this.Type := "Operator"
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

        class Line
        {
            __New(Position,Length)
            {
                this.Type := "Line"
                this.Value := ""
                this.Position := Position
                this.Length := Length
            }
        }
    }

    Next()
    {
        Result := []

        If SubStr(this.Text,this.Position,1) = "" ;past end of text
            Return, Result

        try For Index, Token In this.Ignore()
            Result.Insert(Token)
        catch e
        {
            
        }

        try For Index, Token In this.Operator()
            Result.Insert(Token)
        catch e
        try For Index, Token In this.Line()
            Result.Insert(Token)
        catch e
        try For Index, Token In this.String()
            Result.Insert(Token)
        catch e
        try For Index, Token In this.Identifier()
            Result.Insert(Token)
        catch e
        try For Index, Token In this.Number()
            Result.Insert(Token)
        catch e
            throw Exception("Invalid token.","Next",e.Extra)

        Return, Result
    }

    Ignore()
    {
        Result := []

        try For Index, Token In this.Whitespace()
            Result.Insert(Token)
        catch e
        try For Index, Token In this.Comment()
            Result.Insert(Token)
        catch e
            throw Exception("Invalid ignore.","Ignore",this.Position)

        Loop
        {
            try For Index, Token In this.Whitespace()
                Result.Insert(Token)
            catch e
            try For Index, Token In this.Comment()
                Result.Insert(Token)
            catch e
                Break
        }
        Return, Result
    }

    Operator()
    {
        Position := this.Position
        Length := this.MaxOperatorLength
        While, Length > 0
        {
            Output := SubStr(this.Text,Position,Length)
            If (this.Operators.NullDenotation.HasKey(Output)
                || this.Operators.LeftDenotation.HasKey(Output))
            {
                If !(InStr("abcdefghijklmnopqrstuvwxyz0123456789",SubStr(Output,0))
                    && (NextChar := SubStr(this.Text,Position + Length,1)) != ""
                    && InStr("abcdefghijklmnopqrstuvwxyz0123456789",NextChar))
                {
                    this.Position += StrLen(Output)
                    Return, [new this.Token.Operator(Output,Position,Length)]
                }
            }
            Length --
        }
        throw Exception("Invalid operator.","Operator",Position)
    }

    String()
    {
        Position1 := this.Position
        If SubStr(this.Text,Position1,1) != """" ;check for opening quote
            throw Exception("Invalid string.","String",Position1)
        this.Position ++ ;move past the opening quote

        Output := ""
        While, (CurrentChar := SubStr(this.Text,this.Position,1)) != "" && CurrentChar != "`r" && CurrentChar != "`n" ;loop through string contents
        {
            If (CurrentChar = """") ;check for closing quote
            {
                this.Position ++ ;move past closing quote
                Length := this.Position - Position1
                Return, [new this.Token.String(Output,Position1,Length)]
            }
            try Output .= this.Escape() ;check for escape sequence
            catch e
                Output .= CurrentChar, this.Position ++
        }
        this.Position := Position1
        throw Exception("Invalid string.","String",Position1)
    }

    Identifier()
    {
        Output := SubStr(this.Text,this.Position,1)
        Position := this.Position
        If !InStr("abcdefghijklmnopqrstuvwxyz_",Output) ;check first character against valid identifier characters
            throw Exception("Invalid identifier.","Identifier",Position)
        Position ++ ;move past the first character of the identifier

        ;obtain the rest of the identifier
        While, (CurrentChar := SubStr(this.Text,Position,1)) != "" && InStr("abcdefghijklmnopqrstuvwxyz_0123456789",CurrentChar)
            Output .= CurrentChar, Position ++

        Length := Position - this.Position
        this.Position := Position
        Return, [new this.Token.Identifier(Output,Position,Length)]
    }

    Number()
    {
        Position := this.Position

        Output := SubStr(this.Text,Position,1)
        If !InStr("0123456789",Output) ;check for numerical digits
            throw Exception("Invalid number.","Number",Position)
        Position ++ ;move past the first digit

        Exponent := 0
        NumberBase := 10, CharSet := "0123456789"
        If Output = 0 ;starting digit is 0
        {
            CurrentChar := SubStr(this.Text,Position,1)
            If (CurrentChar = "x") ;hexidecimal base
            {
                Position ++
                NumberBase := 16, CharSet := "0123456789ABCDEF"
            }
            Else If (CurrentChar = "b") ;binary base
            {
                Position ++
                NumberBase := 2, CharSet := "01"
            }
        }

        ;handle integer digits of number
        While, (CurrentChar := SubStr(this.Text,Position,1)) != "" ;not past the end of the input
            && (Value := InStr(CharSet,CurrentChar)) ;character is numeric
            Output := (Output * NumberBase) + (Value - 1), Position ++

        ;handle decimal point if present, disambiguating the decimal point from the object access operator
        If SubStr(this.Text,Position,1) = "." ;period found
        {
            If (NumberBase = 10 ;decimal points only available in decimal numbers
                && (CurrentChar := SubStr(this.Text,Position + 1,1)) != "" ;not past end of the input
                && InStr(CharSet,CurrentChar)) ;character after period is numeric
            {
                Position ++

                ;handle decimal digits of number
                While, (CurrentChar := SubStr(this.Text,Position,1)) != "" ;not past the end of the input
                    && (Value := InStr(CharSet,CurrentChar)) ;character is numeric
                    Output := (Output * NumberBase) + (Value - 1), Position ++, Exponent --
            }
            Else ;object access operator
            {
                Length := Position - this.Position
                this.Position := Position
                Return, [new this.Token.Number(Output,Position,Length)]
            }
        }

        If SubStr(this.Text,Position,1) = "e" ;exponent found
        {
            Position ++

            If (CurrentChar = "-") ;exponent is negative
                Sign := -1, Position ++
            Else
                Sign := 1

            If !InStr("0123456789",SubStr(this.Text,Position,1)) ;check for numeric exponent
                throw Exception("Invalid exponent.","Number",Position) ;wip: nonfatal error

            ;handle digits of the exponent
            While, (CurrentChar := SubStr(this.Text,Position,1)) != "" && InStr("0123456789",CurrentChar)
                Value := (Value * 10) + CurrentChar, Position ++

            Exponent += Value * Sign
        }

        ;apply exponent
        Output *= NumberBase ** Exponent

        Length := Position - this.Position
        this.Position := Position
        Return, [new this.Token.Number(Output,Position,Length)]
    }

    Whitespace()
    {
        CurrentChar := SubStr(this.Text,this.Position,1)
        If (CurrentChar != " " && CurrentChar != "`t")
            throw Exception("Invalid whitespace.","Whitespace",this.Position)
        this.Position ++ ;move past whitespace

        ;move past any remaining whitespace
        While, (CurrentChar := SubStr(this.Text,this.Position,1)) = " " || CurrentChar = "`t"
            this.Position ++

        Return, []
    }

    Line()
    {
        Result := []
        Position := this.Position

        ;check for line end
        CurrentChar := SubStr(this.Text,this.Position,1)
        If (CurrentChar != "`r" && CurrentChar != "`n")
            throw Exception("Invalid line.","Line",Position)
        this.Position ++ ;move past the line end

        Loop
        {
            ;move past line end
            While, (CurrentChar := SubStr(this.Text,this.Position,1)) = "`r" || CurrentChar = "`n"
                this.Position ++

            ;handle input that should be ignored
            try For Index, Token In this.Ignore()
                Result.Insert(Token)
            catch e
                Break
        }

        Length := this.Position - Position
        Return, [new this.Token.Line(Position,Length)]
    }

    Comment() ;wip: maybe should return comment tokens as well
    {
        If SubStr(this.Text,this.Position,1) = ";"
        {
            this.Position ++ ;move past comment marker
            While, (CurrentChar := SubStr(this.Text,this.Position,1)) != "" && CurrentChar != "`r" && CurrentChar != "`n"
                this.Position ++
            Return, []
        }
        If SubStr(this.Text,this.Position,2) = "/*"
        {
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
                this.Position ++
            }
            Return, []
        }
        throw Exception("Invalid comment.","Comment",this.Position)
    }

    Escape()
    {
        Position := this.Position
        If SubStr(this.Text,Position,1) != "``" ;check for escape character
            throw Exception("Invalid escape.","Escape",Position)
        Position ++ ;move past escape character

        CurrentChar := SubStr(this.Text,Position,1) ;obtain the escaped character
        If (CurrentChar = "`n") ;newline escaped
            Output .= "`n", Position ++
        Else If (CurrentChar = "`r") ;carriage return escaped
        {
            If SubStr(this.Text,Position + 1,1) = "`n" ;check for newline and ignore if present
                Position ++
            Output .= "`n", Position ++
        }
        Else If (CurrentChar = "``") ;literal backtick
            Output .= "``", Position ++
        Else If (CurrentChar = """") ;literal quote
            Output .= """", Position ++
        Else If (CurrentChar = "r") ;literal carriage return
            Output .= "`r", Position ++
        Else If (CurrentChar = "n") ;literal newline
            Output .= "`n", Position ++
        Else If (CurrentChar = "t") ;literal tab
            Output .= "`t", Position ++
        Else If (CurrentChar = "c") ;character code
        {
            Position ++ ;move past the character code marker

            If SubStr(this.Text,Position,1) = "[" ;character code start
                Position ++ ;move past opening square bracket
            Else
            {
                ;wip: nonfatal error
            }

            CharacterCode := SubStr(this.Text,Position,1)
            If (CharacterCode != "" && InStr("0123456789",CharacterCode)) ;character is numeric
            {
                Position ++ ;move past first digit of character code
                While, (CurrentChar := SubStr(this.Text,Position,1)) != "" && InStr("0123456789",CharacterCode) ;character is numeric
                    CharacterCode .= CurrentChar, Position ++
                If (CurrentChar = "]") ;character code end
                    Position ++ ;move past closign square bracket
                Else
                {
                    ;wip: nonfatal error
                }
                Output .= Chr(CharacterCode)
            }
            Else
            {
                ;wip: nonfatal error
            }
        }
        Else
        {
            ;wip: nonfatal error goes here
            Position ++
        }
        this.Position := Position
        Return, Output
    }
}
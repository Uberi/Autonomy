#NoEnv

#Include Resources/Token.ahk

Code = _1
l := new Lexer(Code)
MsgBox % l.Identifier()[1].Value
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

;wip: add length field to tokens

class Lexer
{
    static MaxOperatorLength := Code.Lexer.GetMaxOperatorLength() ;wip: calculate this on the fly

    GetMaxOperatorLength()
    {
        MaxLength := 0
        For Operator In CodeOperatorTable.NullDenotation ;get the length of the longest null denotation operator
            Length := StrLen(Operator), (Length > MaxLength) ? (MaxLength := Length) : ""
        For Operator In CodeOperatorTable.LeftDenotation ;get the length of the longest left denotation operator
            Length := StrLen(Operator), (Length > MaxLength) ? (MaxLength := Length) : ""
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
            __New(Value,Position)
            {
                this.Type := "Operator"
                this.Value := Value
                this.Position := Position
            }
        }

        class String
        {
            __New(Value,Position)
            {
                this.Type := "String"
                this.Value := Value
                this.Position := Position
            }
        }

        class Identifier
        {
            __New(Value,Position)
            {
                this.Type := "Identifier"
                this.Value := Value
                this.Position := Position
            }
        }

        class Number
        {
            __New(Value,Position)
            {
                this.Type := "Number"
                this.Value := Value
                this.Position := Position
            }
        }
    }

    Next()
    {
        Result := []

        If this.Position > StrLen(this.Text) ;past end of text
            Return, Result

        For Index, Token In this.Ignore()
            Result.Insert(Token)

        try For Index, Token In this.Operator()
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

    Operator() ;wip: lexer doesn't have the Operators property yet, this is broken
    {
        Position := this.Position
        Length := this.MaxOperatorLength
        While, Length > 0
        {
            Output := SubStr(this.Text,Position,Length), Length --
            If this.Operators.NullDenotation.HasKey(Output)
            || this.Operators.LeftDenotation.HasKey(Output)
            {
                this.Position += StrLen(Output)
                Return, [new this.Token.Operator(Output,Position)]
            }
        }
        throw Exception("Invalid operator.","Operator",Position)
    }

    String()
    {
        Position := this.Position
        If SubStr(this.Text,Position,1) != """" ;check for opening quote
            throw Exception("Invalid string.","String",Position)
        Position ++ ;move past the opening quote

        Output := ""
        While, (CurrentChar := SubStr(this.Text,Position,1)) != "" && CurrentChar != "`r" && CurrentChar != "`n" ;loop through certain characters
        {
            If (CurrentChar = """") ;check for closing quote
            {
                this.Position := Position + 1 ;set the new position to the character after the closing quote
                Return, [new this.Token.String(Output,Position)]
            }
            If (CurrentChar = "``") ;check for escape character
            {
                Position ++ ;move past the escape character
                NextChar := SubStr(this.Text,Position,1) ;obtain the character after the escape character
                If (NextChar = "`n") ;newline escaped
                    Output .= "`n"
                Else If (NextChar = "`r") ;carriage return escaped
                {
                    If SubStr(this.Text,Position + 1,1) = "`n" ;check for newline and ignore if present
                        Position ++
                    Output .= "`n"
                }
                Else If (NextChar = "``") ;literal backtick
                    Output .= "``"
                Else If (NextChar = """") ;literal quote
                    Output .= """"
                Else If (NextChar = "r") ;literal carriage return
                    Output .= "`r"
                Else If (NextChar = "n") ;literal newline
                    Output .= "`n"
                Else If (NextChar = "t") ;literal tab
                    Output .= "`t"
                Else
                {
                    ;wip: nonfatal error goes here
                }
            }
            Else
                Output .= CurrentChar ;add character to output
            Position ++ ;move past the character
        }
        throw Exception("Invalid string.","String",this.Position)
    }

    Identifier()
    {
        Output := SubStr(this.Text,this.Position,1)
        If !InStr("abcdefghijklmnopqrstuvwxyz_",Output) ;check first character against valid identifier characters
            throw Exception("Invalid identifier.","Identifier",this.Position)
        this.Position ++ ;move past the first character of the identifier

        ;obtain the rest of the characters
        While, (CurrentChar := SubStr(this.Text,this.Position,1)) != "" && InStr("abcdefghijklmnopqrstuvwxyz_0123456789",CurrentChar)
            Output .= CurrentChar, this.Position ++

        Return, [new this.Token.Identifier(Output,Position)]
    }

    Number()
    {
        Position := this.Position
        If !RegExMatch(this.Text,"AS)-?(?:0[xXbB])?\d(?:\.\d+)?(?:[eE]-?\d+)",Output,Position)
            throw Exception("Invalid number.","Number",Position)
        this.Position += StrLen(Output)
        Return, [new this.Token.Number(Output,Position)]
    }

    Whitespace()
    {
        If (CurrentChar != " " && CurrentChar != "`t" && CurrentChar != "`r" && CurrentChar != "`n")
            throw Exception("Invalid whitespace.","Whitespace",this.Position)
        this.Position ++ ;move past whitespace character

        ;move past any remaining whitespace characters
        While, (CurrentChar := SubStr(this.Text,this.Position,1)) != "" && CurrentChar != " " && CurrentChar != "`t" && CurrentChar != "`r" && CurrentChar != "`n"
            this.Position ++

        Return, []
    }

    Comment()
    {
        If RegExMatch(this.Text,"AS);[^\r\n]*[\r\n]?",Output,this.Position) ;single line comment
        {
            this.Position += StrLen(Output)
            Return, []
        }
        Else If RegExMatch(this.Text,"AsS)/\*.*?\*/",Output,this.Position) ;multiline comment ;wip: does not support nested comments
        {
            this.Position += StrLen(Output)
            Return, []
        }
        throw Exception("Invalid comment.","Comment",this.Position)
    }
}

;lexes operators and syntax elements
CodeLexSyntaxElement(ByRef Code,ByRef Position,ByRef Tokens,ByRef FileIndex)
{ ;returns 1 if no syntax element was found, 0 otherwise
    global CodeOperatorTable, CodeLexerConstants, CodeLexerOperatorMaxLength
    Temp1 := CodeLexerOperatorMaxLength, Position1 := Position
    Loop, %CodeLexerOperatorMaxLength% ;loop until a valid token is found
    {
        SyntaxElement := SubStr(Code,Position,Temp1)
        If (SyntaxElement = CodeLexerConstants.SEPARATOR) ;found separator
            Tokens.Insert(CodeTokenSeparator(Position1,FileIndex)) ;add separator to the token array
        Else If ((ObjHasKey(CodeOperatorTable.NullDenotation,SyntaxElement) || ObjHasKey(CodeOperatorTable.LeftDenotation,SyntaxElement)) ;found operator in null or left denotation of the operator table
                && !(InStr(CodeLexerConstants.IDENTIFIER,SubStr(SyntaxElement,0)) ;last character of the operator is an identifier character
                && (CurrentChar := SubStr(Code,Position + Temp1,1)) != "" ;operator is not at the end of the source file
                && InStr(CodeLexerConstants.IDENTIFIER,CurrentChar))) ;character after the operator is an identifier character
            Tokens.Insert(CodeTokenOperator(SyntaxElement,Position1,FileIndex)) ;add the operator to the token array
        Else
        {
            Temp1 -- ;reduce the length of the input to be checked
            Continue
        }
        Position += StrLen(SyntaxElement) ;move past the syntax element, making sure the position is not past the end of the file
        Return, 0
    }
    Return, 1 ;not a syntax element
}
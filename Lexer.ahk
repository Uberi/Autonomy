#NoEnv

/*
Token Stream Format
-------------------

* _[Index]_:    the index of the token                         _[Object]_
    * Type:     the type of the token                          _[Integer]_
    * Value:    the value of the token                         _[String]_
    * Position: position of token within the file              _[Integer]_
    * File:     the file index the current token is located in _[Integer]_

Example Token Stream
--------------------

    2:
        Type: IDENTIFIER
        Value: SomeVariable
        Position: 15
        File: 3
*/

;initializes resources that the lexer requires
CodeLexInit()
{
 global CodeOperatorTable, LexerEscapeChar, LexerIdentifierChars, LexerStatementList, LexerStatementLiteralList, LexerOperatorMaxLength
 LexerEscapeChar := "``" ;the escape character
 LexerIdentifierChars := "abcdefghijklmnopqrstuvwxyz_1234567890#" ;characters that make up a an identifier
 LexerStatementList := Object("#Include","","#SingleInstance","","#Warn","","#Define","","#Undefine","","#If","","#Else","","#ElseIf","","#EndIf","","While","","Loop","","For","","If","","Else","","Break","","Continue","","Return","","Gosub","","Goto","","local","","global","","static","") ;statements that can be found on the beginning of a line
 LexerStatementLiteralList := Object("#Include","","#SingleInstance","","#Warn","","#Define","","#Undefine","","#IfDefinition","","#IfNotDefinition","","#Else","","#ElseIfDefinition","","#ElseIfNotDefinition","","#EndIf","","Break","","Continue","","Gosub","","Goto","") ;statements that accept literals as parameters

 LexerOperatorMaxLength := 1 ;one is the maximum length of the other syntax elements - commas, parentheses, square brackets, and curly brackets
 For Temp1 In CodeOperatorTable ;get the length of the longest operator
  Temp2 := StrLen(Temp1), (Temp2 > LexerOperatorMaxLength) ? (LexerOperatorMaxLength := Temp2) : ""
}

;lexes AHK code, including all syntax
CodeLex(ByRef Code,ByRef Tokens,ByRef Errors,ByRef FileIndex = 1)
{ ;returns 1 on error, 0 otherwise
 global CodeTokenTypes, LexerIdentifierChars
 Tokens := Array(), Position := 1, LexerError := 0 ;initialize variables
 Loop
 {
  CurrentChar := SubStr(Code,Position,1)
  If (CurrentChar = "") ;past the end of the string
   Break
  CurrentTwoChar := SubStr(Code,Position,2), Position1 := Position
  If (CurrentChar = "`r" || CurrentChar = "`n" || A_Index = 1) ;beginning of a line
  {
   While, (InStr("`r`n`t ",CurrentChar := SubStr(Code,Position,1)) && (CurrentChar <> "")) ;move past any whitespace
    Position ++
   If (SubStr(Code,Position,1) = ";") ;single line comment
   {
    CodeLexSingleLineComment(Code,Position) ;skip over comment
    If (A_Index = 1) ;on the first iteration, skip insertion of a line end token
    {
     While, (InStr("`r`n`t ",CurrentChar := SubStr(Code,Position,1)) && (CurrentChar <> "")) ;move past any whitespace
      Position ++
    }
    CodeLexLine(Code,Position,Tokens,FileIndex) ;check for statements
   }
   Else ;input is a multiline comment or normal line
   {
    If (SubStr(Code,Position,2) = "/*") ;begin multiline comment
    {
     CodeLexMultilineComment(Code,Position) ;skip over the comment block
     While, ((CurrentChar := SubStr(Code,Position,1)) = "`r" || CurrentChar = "`n") ;move past any whitespace, to ensure there are no duplicate lines
      Position ++
    }
    If (A_Index <> 1) ;skip insertion of line end token on first iteration
     ObjInsert(Tokens,Object("Type",CodeTokenTypes.LINE_END,"Value","","Position",Position - 1,"File",FileIndex)) ;add the statement end to the token array
    CodeLexLine(Code,Position,Tokens,FileIndex) ;check for statements
   }
  }
  Else If (CurrentChar = """") ;begin literal string
   CodeLexString(Code,Position,Tokens,Errors,LexerError,Output,FileIndex)
  Else If (CurrentTwoChar = "/*") ;begin multiline comment
   CodeLexMultilineComment(Code,Position) ;skip over the comment block
  Else If (CurrentTwoChar = "*/") ;end multiline comment
   Position += 2 ;can be skipped over
  Else If (CurrentChar = "%") ;dynamic variable reference or dynamic function call
   CodeLexDynamicReference(Code,Position,Tokens,Errors,LexerError,Output,FileIndex)
  Else If (CurrentChar = ".") ;object access (explicit handling ensures that Var.123.456 will have the purely numerical keys interpreted as identifiers instead of numbers)
  {
   ObjInsert(Tokens,Object("Type",CodeTokenTypes.OPERATOR,"Value",".","Position",Position,"File",FileIndex)) ;add a object access token to the token array
   Position ++, CurrentChar := SubStr(Code,Position,1) ;move to next char
   If (CurrentChar = " " || CurrentChar = "`t") ;object access operator cannot be followed by whitespace
    ObjInsert(Errors,Object("Identifier","INVALID_OBJECT_ACCESS","Level","Error","Highlight",Object("Position",Position1,"Length",Position - Position1),"Caret",Position,"File",FileIndex)), LexerError := 1 ;add an error to the error log
   CodeLexIdentifier(Code,Position,Tokens,FileIndex) ;lex identifier
  }
  Else If (CurrentChar = " " || CurrentChar = "`t") ;whitespace
  {
   Position ++, CurrentChar := SubStr(Code,Position,1) ;skip over whitespace, retrieve character from updated position
   If (CurrentChar = ";") ;single line comment
    CodeLexSingleLineComment(Code,Position) ;skip over comment
   Else If (CurrentChar = ".") ;concatenation operator (whitespace preceded it)
   {
    ObjInsert(Tokens,Object("Type",CodeTokenTypes.OPERATOR,"Value"," . ","Position",Position,"File",FileIndex)), Position ++ ;add a concatenation token to the token array, move past dot operator
    CurrentChar := SubStr(Code,Position,1)
    If !(CurrentChar = " " || CurrentChar = "`t") ;there must be whitespace on both sides of the concat operator
     ObjInsert(Errors,Object("Identifier","INVALID_CONCATENATION","Level","Error","Highlight",Object("Position",Position1,"Length",Position - Position1),"Caret",Position,"File",FileIndex)), LexerError := 1 ;add an error to the error log
   }
  }
  Else If (CodeLexSyntaxElement(Code,Position,Tokens,FileIndex) = 0) ;input is a syntax element
  {
   
  }
  Else If (InStr("1234567890",CurrentChar) && CodeLexNumber(Code,Position,Output) = 0) ;a number, not an identifier
   ObjInsert(Tokens,Object("Type",CodeTokenTypes.LITERAL_NUMBER,"Value",Output,"Position",Position1,"File",FileIndex)) ;add the number literal to the token array
  Else If InStr(LexerIdentifierChars,CurrentChar) ;an identifier
   CodeLexIdentifier(Code,Position,Tokens,FileIndex)
  Else ;invalid character
  {
   ObjInsert(Errors,Object("Identifier","INVALID_CHARACTER","Level","Error","Highlight","","Caret",Position,"File",FileIndex)), LexerError := 1 ;add an error to the error log
   Position ++
  }
 }
 Temp1 := ObjMaxIndex(Tokens) ;get the highest token index
 If (Tokens[Temp1].Type = CodeTokenTypes.LINE_END) ;token is a newline
  ObjRemove(Tokens,Temp1,"") ;remove the last token
 Return, LexerError
}

;lexes a new line, to find control structures, directives, etc.
CodeLexLine(ByRef Code,ByRef Position,ByRef Tokens,ByRef FileIndex)
{ ;returns 1 if the line cannot be lexed as a statement, 0 otherwise
 global CodeTokenTypes, LexerIdentifierChars, LexerStatementList, LexerStatementLiteralList

 ;store the candidate statement
 Position1 := Position, Statement := ""
 Loop
 {
  CurrentChar := SubStr(Code,Position,1)
  If ((CurrentChar = "") || !InStr(LexerIdentifierChars,CurrentChar))
   Break
  Statement .= CurrentChar, Position ++
 }

 ;detect labels
 If ((CurrentChar = ":") && InStr("`r`n`t ",SubStr(Code,Position + 1,1))) ;is a label
 {
  Position ++
  While, (InStr("`t ",CurrentChar := SubStr(Code,Position,1)) && (CurrentChar <> "")) ;move past whitespace
   Position ++
  ObjInsert(Tokens,Object("Type",CodeTokenTypes.LABEL,"Value",Statement,"Position",Position1,"File",FileIndex)) ;add the label to the token array
  Return, 0
 }

 ;determine whether the line should be processed as an expression instead of a statement
 If !(InStr("`r`n`t, ",SubStr(Code,Position,1)) && ObjHasKey(LexerStatementList,Statement)) ;not a statement, so must be expression
 {
  Position := Position1 ;move the position back to the beginning of the line, to allow it to be processed again as an expression
  Return, 1
 }

 ObjInsert(Tokens,Object("Type",CodeTokenTypes.STATEMENT,"Value",Statement,"Position",Position1,"File",FileIndex)) ;add the statement to the token array

 ;skip past whitespace, and up to one comma
 While, ((CurrentChar := SubStr(Code,Position,1)) = "`t" || CurrentChar = " ")
  Position ++
 If (CurrentChar = ",") ;comma found
 {
  Position ++ ;move past the comma
  While, ((CurrentChar := SubStr(Code,Position,1)) = "`t" || CurrentChar = " ") ;skip over any remaining whitespace
   Position ++
 }

 If ObjHasKey(LexerStatementLiteralList,Statement) ;the current statement accepts the parameters literally
 {
  ;extract statement parameters
  Parameters := "", Position1 := Position
  While, (!((CurrentChar := SubStr(Code,Position,1)) = "`r" || CurrentChar = "`n") && CurrentChar <> "") ;move to the end of the line
   Position ++, Parameters .= CurrentChar

  ;trim trailing whitespace from paramters
  Length := Position - Position1
  While, ((CurrentChar := SubStr(Parameters,Length,1)) = " " || CurrentChar = "`t")
   Length --
  Parameters := SubStr(Parameters,1,Length)

  ObjInsert(Tokens,Object("Type",CodeTokenTypes.LITERAL_STRING,"Value",Parameters,"Position",Position1,"File",FileIndex)) ;add the statement parameters to the token array
 }
 Return, 0
}

;lexes a quoted string, handling escaped characters
CodeLexString(ByRef Code,ByRef Position,ByRef Tokens,ByRef Errors,ByRef LexerError,ByRef Output,ByRef FileIndex) ;input code, current position in code, output to store the detected string in, name of input file
{ ;returns 1 on error, 0 otherwise
 global CodeTokenTypes, LexerEscapeChar
 Position1 := Position, Output := "", Position ++ ;move to after the opening quotation mark
 Loop
 {
  CurrentChar := SubStr(Code,Position,1)
  If (CurrentChar = LexerEscapeChar) ;next character is escaped
  {
   Position ++, NextChar := SubStr(Code,Position,1) ;get the next character
   ;handle the escaping of the end of a line
   If (NextChar = "`r")
   {
    If (SubStr(Code,Position + 1,1) = "`n")
     Position ++ ;move to the next character
    Output .= LexerEscapeChar . "n", Position ++ ;always concatenate with the newline character
    Continue
   }
   If (NextChar = "`n")
    NextChar := "n" ;change the escape sequence character to "n"
   Output .= LexerEscapeChar . NextChar, Position ++ ;append the escape sequence to the output, and move past it
  }
  Else If (CurrentChar = "" || InStr("`r`n",CurrentChar)) ;past end of string, or reached a newline before the open quote has been closed
  {
   ObjInsert(Errors,Object("Identifier","UNMATCHED_QUOTE","Level","Error","Highlight",Object("Position",Position1,"Length",Position - Position1),"Caret",Position,"File",FileIndex)), LexerError := 1 ;add an error to the error log
   Return, 1
  }
  Else If (CurrentChar = """") ;closing quote mark found
   Break
  Else ;string contents
   Output .= CurrentChar, Position ++ ;append the character to the output
 }
 Position ++ ;move to after the closing quotation mark
 ObjInsert(Tokens,Object("Type",CodeTokenTypes.LITERAL_STRING,"Value",Output,"Position",Position1,"File",FileIndex)) ;add the string literal to the token array
 Return, 0
}

;lexes a single line comment
CodeLexSingleLineComment(ByRef Code,ByRef Position)
{
 Position ++ ;skip over semicolon
 While, !InStr("`r`n",SubStr(Code,Position,1)) ;loop until a newline is found
  Position ++
}

;lexes a multiline comment, including any nested comments it may contain
CodeLexMultilineComment(ByRef Code,ByRef Position)
{
 global LexerEscapeChar
 CommentLevel := 1
 While, CommentLevel ;loop until the comment has ended
 {
  Position ++
  CurrentChar := SubStr(Code,Position,1), CurrentTwoChar := SubStr(Code,Position,2)
  If (CurrentChar = "")
   Return
  If (CurrentChar = LexerEscapeChar) ;an escaped character in the comment
   Position += 2 ;skip over the entire esape sequence (allows escaping of comment chars: /* Some `/* Comment */)
  Else If (CurrentTwoChar = "/*") ;found a nested comment
   CommentLevel ++
  Else If (CurrentTwoChar = "*/") ;found a closing comment
   CommentLevel --
 }
 Position += 2 ;skip over the closing comment
}

;lexes dynamic variable and function references
CodeLexDynamicReference(ByRef Code,ByRef Position,ByRef Tokens,ByRef Errors,ByRef LexerError,ByRef Output,ByRef FileIndex)
{ ;returns 1 on error, 0 otherwise
 global CodeTokenTypes, LexerIdentifierChars
 Output := "", Position1 := Position
 Loop
 {
  Position ++, CurrentChar := SubStr(Code,Position,1)
  If (CurrentChar = "%") ;found percent sign
   Break
  If (CurrentChar = "" || InStr("`r`n",CurrentChar)) ;past end of string, or found newline before percent sign was matched
  {
   ObjInsert(Errors,Object("Identifier","UNMATCHED_PERCENT_SIGN","Level","Error","Highlight",Object("Position",Position1,"Length",Position - Position1),"Caret",Position1,"File",FileIndex)), LexerError := 1 ;add an error to the error log
   Return, 1
  }
  If !InStr(LexerIdentifierChars,CurrentChar) ;invalid character found
  {
   ObjInsert(Errors,Object("Identifier","INVALID_IDENTIFIER","Level","Error","Highlight",Object("Position",Position1,"Length",Position - Position1),"Caret",Position,"File",FileIndex)), LexerError := 1 ;add an error to the error log
   Return, 1
  }
  Output .= CurrentChar
 }
 Position ++ ;move past matching percent sign
 ObjInsert(Tokens,Object("Type",CodeTokenTypes.OPERATOR,"Value","%","Position",Position1,"File",FileIndex)) ;add the dereference operator to the token array
 ObjInsert(Tokens,Object("Type",CodeTokenTypes.IDENTIFIER,"Value",Output,"Position",Position1 + 1,"File",FileIndex)) ;add the identifier to the token array
 Return, 0
}

;lexes a syntax token
CodeLexSyntaxElement(ByRef Code,ByRef Position,ByRef Tokens,ByRef FileIndex)
{ ;returns 1 on error, 0 otherwise
 global CodeOperatorTable, CodeTokenTypes, LexerOperatorMaxLength, LexerIdentifierChars
 Temp1 := LexerOperatorMaxLength, Position1 := Position
 Loop, %LexerOperatorMaxLength% ;loop until a valid token is found or 
 {
  Output := SubStr(Code,Position,Temp1)
  IdentifierChar := InStr(LexerIdentifierChars,SubStr(Output,0)) ;last character of output is an identifier character, make sure output is not an identifier
  If (ObjHasKey(CodeOperatorTable,Output) && (!IdentifierChar || IdentifierChar && !InStr(LexerIdentifierChars,SubStr(Code,Position + Temp1,1)))) ;found operator
   TokenType := CodeTokenTypes.OPERATOR
  Else If (Output = ",") ;found separator
   TokenType := CodeTokenTypes.SEPARATOR
  Else If (Output = "(" || Output = ")") ;found parenthesis
   TokenType := CodeTokenTypes.PARENTHESIS
  Else If (Output = "[" || Output = "]") ;found object braces
   TokenType := CodeTokenTypes.OBJECT_BRACE
  Else If (Output = "{" || Output = "}") ;found block braces
   TokenType := CodeTokenTypes.BLOCK_BRACE
  Else
  {
   Temp1 -- ;reduce the length of the input to be checked
   Continue
  }
  Position += StrLen(Output) ;move past the syntax element, making sure the position is not past the end of the file
  ObjInsert(Tokens,Object("Type",TokenType,"Value",Output,"Position",Position1,"File",FileIndex)) ;add the found syntax element to the token array
  Return, 0
 }
 Return, 1 ;not an operator or syntax element
}

;lexes a number, and if it is not a valid number, notify that it may be an identifier
CodeLexNumber(ByRef Code,ByRef Position,ByRef Output)
{ ;returns 1 when parsing failed, 0 otherwise
 global LexerIdentifierChars
 Output := "", Position1 := Position, NumberChars := "1234567890", DecimalUsed := 0
 If (SubStr(Code,Position,2) = "0x") ;hexidecimal number
  DecimalUsed := 1, Position += 2, Output .= "0x", NumberChars .= "abcdefABCDEF" ;prevent the usage of decimals in hex numbers, skip over the identifying characters, append them to the number, and expand the valid number characters set
 Loop
 {
  CurrentChar := SubStr(Code,Position,1)
  If (CurrentChar = "") ;past end of string
   Return, 0
  If InStr(NumberChars,CurrentChar) ;is a valid number character
   Output .= CurrentChar
  Else If (CurrentChar = ".") ;is a decimal point
  {
   If DecimalUsed ;input already had a decimal point, so is probably an identifier
   {
    Position := Position1 ;return the position back to the start of this section, to try to process it again as an identifier
    Return, 1
   }
   Output .= CurrentChar, DecimalUsed := 1 ;set a flag to show that a decimal point has been used
  }
  Else If InStr(LexerIdentifierChars,CurrentChar) ;notify if the code is a valid identifier char if it cannot be processed as a number
  {
   Position := Position1 ;return the position back to the start of this section, to try to parse it again as an identifier
   Return, 1
  }
  Else ;end of number
   Return, 0
  Position ++
 }
}

;lexes an identifier
CodeLexIdentifier(ByRef Code,ByRef Position,ByRef Tokens,ByRef FileIndex)
{
 global CodeTokenTypes, LexerIdentifierChars
 Output := "", Position1 := Position
 Loop
 {
  CurrentChar := SubStr(Code,Position,1)
  If (CurrentChar = "" || !InStr(LexerIdentifierChars,CurrentChar)) ;past end of string, or found a character that was not part of the identifier
   Break
  Output .= CurrentChar, Position ++
 }
 ObjInsert(Tokens,Object("Type",CodeTokenTypes.IDENTIFIER,"Value",Output,"Position",Position1,"File",FileIndex)) ;add the identifier to the token array
}
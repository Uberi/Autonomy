#NoEnv

;wip: attach position info and file name to each token, to allow error handler to 

;parses AHK code, including all syntax
CodeLex(Code,ByRef Tokens,ByRef Errors)
{ ;returns 1 on error, nothing otherwise
 global IdentifierChars
 Position := 1, Tokens := Object(), Errors := Object()
 Loop
 {
  CurrentChar := SubStr(Code,Position,1), CurrentTwoChar := SubStr(Code,Position,2)
  If (CurrentChar = "") ;past the end of the string
   Break
  If ((InStr("`r`n",CurrentChar) <> 0) || (A_Index = 1)) ;line is a statement
  {
   While, InStr("`r`n " . A_Tab,SubStr(Code,Position,1)) ;move past blank lines and whitespace
    Position ++
   CurrentChar := SubStr(Code,Position,1), CurrentTwoChar := SubStr(Code,Position,2)
   If (CurrentChar = "") ;past the end of the string
    Break
   If CodeLexLine(Code,Position,Errors,Output)
   {
    ;wip: statement processing code
    ObjInsert(Tokens,Object("Type","STATEMENT","Value",Output)) ;add the statement to the token array ;wip: triggers too many times
    ObjInsert(Tokens,Object("Type","COMMAND","Value","STATEMENT_END")) ;add the statement end to the token array
   }
  }
  If (CurrentChar = """") ;begin literal string
  {
   If CodeLexString(Code,Position,Errors,Output) ;invalid string
    Return, 1
   ObjInsert(Tokens,Object("Type","LITERAL_STRING","Value",Output)) ;add the string literal to the token array
  }
  Else If (InStr(" " . A_Tab,CurrentChar) && (SubStr(Code,Position + 1) = ";")) ;single line comment
   CodeLexSingleLineComment(Code,Position)
  Else If (CurrentTwoChar = "/*") ;begin comment
   CodeLexMultilineComment(Code,Position) ;skip over the comment block
  Else If (CurrentTwoChar = "*/") ;end comment
   Position += 2 ;can be skipped over
  Else If InStr(" " . A_Tab,CurrentChar) ;not a syntactically meaningful character
   Position ++
  Else If (CurrentChar = "%") ;dynamic variable reference or dynamic function call
  {
   If CodeLexDynamicReference(Code,Position,Errors,Output) ;invalid dynamic reference
    Return, 1
   ObjInsert(Tokens,Object("Type","SYNTAX_ELEMENT","Value","%")) ;add the dereference operator to the token array
   ObjInsert(Tokens,Object("Type","IDENTIFIER","Value",Output)) ;add the identifier to the token array
  }
  Else If (InStr("1234567890",CurrentChar) && !CodeLexNumber(Code,Position,Output)) ;a number or identifier
   ObjInsert(Tokens,Object("Type","LITERAL_NUMBER","Value",Output)) ;add the number literal to the token array
  Else If InStr(IdentifierChars,CurrentChar) ;an identifier
   CodeLexIdentifier(Code,Position,Output), ObjInsert(Tokens,Object("Type","IDENTIFIER","Value",Output)) ;add the identifier to the token array
  Else ;is either a syntax element or an invalid character
  {
   If CodeLexSyntaxElement(Code,Position,Errors,Output)
    Return, 1
   ObjInsert(Tokens,Object("Type","SYNTAX_ELEMENT","Value",Output)) ;add the found syntax element to the token array
  }
 }
}

;parses a new line, to find control structures, directives, etc.
CodeLexLine(ByRef Code,ByRef Position,ByRef Errors,ByRef Output)
{ ;returns 1 if the line cannot be parsed as a statement, nothing otherwise
 global IdentifierChars, Statements
 Position1 := Position, Output := ""
 MsgBox % """" . SubStr(Code,Position)
 Loop
 {
  CurrentChar := SubStr(Code,Position,1)
  If ((CurrentChar = "") || !InStr(IdentifierChars,CurrentChar))
   Break
  Output .= CurrentChar, Position ++
 }
 ;MsgBox % Position . "`n""" . Output . """`n""" . SubStr(Code,Position)
 If !(InStr("`r`n, " . A_Tab,SubStr(Code,Position,1)) && InStr(Statements,"`n" . Output . "`n")) ;determine whether the line should be parsed as an expression instead of a statement
 {
  Position := Position1 ;move the position back to the beginning of the line, to allow it to be parsed again as an expression
  Return, 1
 }
}

;parses a quoted string, handling escaped characters
CodeLexString(ByRef Code,ByRef Position,ByRef Errors,ByRef Output) ;input code, current position in code, output to store the detected string in
{ ;returns 1 on error, nothing otherwise
 global EscapeChar
 Position1 := Position, Output := "", Position ++ ;move to after the opening quotation mark
 Loop
 {
  CurrentChar := SubStr(Code,Position,1)
  If (CurrentChar = EscapeChar) ;next character is escaped
   Output .= SubStr(Code,Position,2), Position += 2 ;append the escape sequence to the output, and move past it
  Else If (CurrentChar = "" || InStr("`r`n",CurrentChar)) ;past end of string, or reached a newline before the open quote has been closed
  {
   ObjInsert(Errors,Object("Identifier","UNMATCHED_QUOTE","Highlight",Object("Position",Position1,"Length",Position - Position1)),"Caret",Position) ;add an error to the error log
   Return, 1
  }
  Else If (CurrentChar = """") ;closing quote mark found
   Break
  Else ;string contents
   Output .= CurrentChar, Position ++ ;append the character to the output
 }
 Position ++ ;move to after the closing quotation mark
}

;parses a single line comment
CodeLexSingleLineComment(ByRef Code,ByRef Position)
{
 Position += 2
 While, !InStr("`r`n",SubStr(Code,Position,1)) ;loop until a newline is found
  Position ++
}

;parses a multiline comment, including any nested comments it may contain
CodeLexMultilineComment(ByRef Code,ByRef Position)
{
 global EscapeChar
 CommentLevel := 1
 While, CommentLevel ;loop until the comment has ended
 {
  Position ++
  Temp1 := SubStr(Code,Position,1)
  If (Temp1 = "")
   Return
  If (Temp1 = EscapeChar) ;an escaped character in the comment
  {
   Position += 2 ;skip over the entire esape sequence (allows escaping of comment chars: /* Some `/* Comment */)
   Continue
  }
  If (SubStr(Code,Position,2) = "/*") ;found a nested comment
   CommentLevel ++
  Else If (SubStr(Code,Position,2) = "*/") ;found a closing comment
   CommentLevel --
 }
 Position += 2 ;skip over the closing comment
}

;parses dynamic variable and function references
CodeLexDynamicReference(ByRef Code,ByRef Position,ByRef Errors,ByRef Output)
{ ;returns 1 on error, nothing otherwise
 global IdentifierChars
 Output := "", Position1 := Position
 Loop
 {
  Position ++, CurrentChar := SubStr(Code,Position,1)
  If (CurrentChar = "%") ;found percent sign
   Break
  If (CurrentChar = "") ;past end of string
  {
   ObjInsert(Errors,Object("Identifier","UNMATCHED_PERCENT_SIGN","Highlight",Object("Position",Position1,"Length",Position - Position1)),"Caret",Position1) ;add an error to the error log
   Return, 1
  }
  If !InStr(IdentifierChars,CurrentChar) ;invalid character found
  {
   ObjInsert(Errors,Object("Identifier","INVALID_IDENTIFIER","Highlight",Object("Position",Position1,"Length",Position - Position1)),"Caret",Position) ;add an error to the error log
   Return, 1
  }
  Output .= CurrentChar
 }
 Position ++
}

;parses a number, and if it is not parsable, notify that it may be an identifier
CodeLexNumber(ByRef Code,ByRef Position,ByRef Output)
{ ;returns 1 when parsing failed, nothing otherwise
 global IdentifierChars
 Output := "", Position1 := Position, NumberChars := "1234567890"
 If (SubStr(Code,Position,2) = "0x") ;hexidecimal number
  Position += 2, Output .= "0x", NumberChars .= "abcdefABCDEF" ;skip over the identifying characters, append them to the number, and expand the valid number characters set
 Loop
 {
  CurrentChar := SubStr(Code,Position,1)
  If (CurrentChar = "") ;past end of string
   Return
  If InStr(NumberChars,CurrentChar) ;is a valid number character
   Output .= CurrentChar
  Else If InStr(IdentifierChars,CurrentChar) ;notify if the code is a valid identifier char if it cannot be parsed as a number, otherwise end number
  {
   Position := Position1 ;return the position back to the start of this section, to try to parse it again as an identifier
   Return, 1
  }
  Else
   Return
  Position ++
 }
}

;parses an identifier
CodeLexIdentifier(ByRef Code,ByRef Position,ByRef Output)
{
 global IdentifierChars
 Output := ""
 Loop
 {
  CurrentChar := SubStr(Code,Position,1)
  If (CurrentChar = "" || !InStr(IdentifierChars,CurrentChar)) ;past end of string, or found a character that was not part of the identifier
   Return
  Output .= CurrentChar, Position ++
 }
}

;parses a syntax token
CodeLexSyntaxElement(ByRef Code,ByRef Position,ByRef Errors,ByRef Output)
{ ;returns 1 on error, nothing otherwise
 global SyntaxElements
 MaxLength := SyntaxElements._MaxIndex(), Temp1 := MaxLength
 Loop, %MaxLength%
 {
  If InStr(SyntaxElements[Temp1],"`n" . (Output := SubStr(Code,Position,Temp1)) . "`n") ;check for a match with a syntax element
  {
   Position += Temp1
   Return
  }
  Temp1 --
 }
 ObjInsert(Errors,Object("Identifier","INVALID_CHARACTER","Highlight","","Caret",Position)) ;add an error to the error log
 Return, 1
}
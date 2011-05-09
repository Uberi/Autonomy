#NoEnv

;wip: attach position info and file name to each token, to allow error handler to display errors from parser

;wip: multiline expressions, remove globals (use params instead)

;initializes resources that the lexer requires
CodeLexInit()
{
 global LexerEscapeChar, LexerIdentifierChars, LexerStatementList, LexerSyntaxElements

 LexerEscapeChar := "``" ;the escape character
 LexerIdentifierChars := "abcdefghijklmnopqrstuvwxyz_1234567890#" ;characters that make up a an identifier
 LexerStatementList := "`n#Include`n#IncludeAgain`n#SingleInstance`n#Warn`nWhile`nLoop`nFor`nIf`nElse`nBreak`nContinue`nReturn`nGosub`nGoto`nlocal`nglobal`nstatic`n"
 LexerSyntaxElements := "<<=`n>>=`n//=`n . `n*=`n.=`n|=`n&=`n^=`n-=`n+=`n||`n&&`n--`n==`n<>`n!=`n++`n/=`n>=`n<=`n:=`n**`n<<`n>>`n//`n/`n*`n-`n!`n~`n+`n|`n^`n&`n<`n>`n=`n.`n(`n)`n,`n[`n]`n{`n}`n?`n:"

 Temp1 := LexerSyntaxElements, LexerSyntaxElements := Object()
 Loop, Parse, Temp1, `n
 {
  Length := StrLen(A_LoopField)
  If IsObject(LexerSyntaxElements[Length])
   ObjInsert(LexerSyntaxElements[Length],A_LoopField,"")
  Else
   LexerSyntaxElements[Length] := Object(A_LoopField,"")
 }
}

;parses AHK code, including all syntax
CodeLex(Code,ByRef Tokens,ByRef Errors,ByRef Position = 1)
{ ;returns 1 on error, nothing otherwise
 global LexerIdentifierChars
 Tokens := Object(), Errors := Object()
 Loop
 {
  CurrentChar := SubStr(Code,Position,1), CurrentTwoChar := SubStr(Code,Position,2)
  If (CurrentChar = "") ;past the end of the string
   Break
  If ((InStr("`r`n",CurrentChar) <> 0) || (A_Index = 1)) ;beginning of a line
  {
   ;move past any whitespace
   While, (InStr("`r`n " . A_Tab,CurrentChar := SubStr(Code,Position,1)) && (CurrentChar <> ""))
    Position ++
   If (SubStr(Code,Position,1) = ";") ;single line comment
    CodeLexSingleLineComment(Code,Position) ;skip over comment
   Else If (SubStr(Code,Position,2) = "/*") ;begin multiline comment
   {
    CodeLexMultilineComment(Code,Position) ;skip over the comment block
    ;move past any whitespace, to ensure there are no duplicate lines
    While, (InStr("`r`n",CurrentChar := SubStr(Code,Position,1)) && (CurrentChar <> ""))
     Position ++
    ObjInsert(Tokens,Object("Type","SYNTAX_ELEMENT","Value","`n")) ;add the statement end to the token array
   }
   Else
   {
    ;wip: check if line is not multiline expression first
    ObjInsert(Tokens,Object("Type","SYNTAX_ELEMENT","Value","`n")) ;add the statement end to the token array
    CodeLexLine(Code,Position,Tokens,Errors) ;line is a statement
   }
  }
  Else If (CurrentChar = """") ;begin literal string
  {
   If CodeLexString(Code,Position,Tokens,Errors,Output) ;invalid string
    Return, 1
  }
  Else If (CurrentTwoChar = "/*") ;begin multiline comment
   CodeLexMultilineComment(Code,Position) ;skip over the comment block
  Else If (CurrentTwoChar = "*/") ;end multiline comment
   Position += 2 ;can be skipped over
  Else If (CurrentChar = "%") ;dynamic variable reference or dynamic function call
  {
   If CodeLexDynamicReference(Code,Position,Tokens,Errors,Output) ;invalid dynamic reference
    Return, 1
  }
  Else If (InStr("1234567890",CurrentChar) && !CodeLexNumber(Code,Position,Tokens,Output)) ;a number, not an identifier
  {
   
  }
  Else If InStr(LexerIdentifierChars,CurrentChar) ;an identifier
   CodeLexIdentifier(Code,Position,Tokens,Output)
  Else If CodeLexSyntaxElement(Code,Position,Tokens,Errors,Output) ;invalid character
  {
   If InStr(" " . A_Tab,CurrentChar) ;whitespace
   {
    If (SubStr(Code,Position + 1,1) = ";") ;single line comment
     CodeLexSingleLineComment(Code,Position) ;skip over comment
    Else
     Position ++
   }
   Else
   {
    ObjInsert(Errors,Object("Identifier","INVALID_CHARACTER","Highlight","","Caret",Position)) ;add an error to the error log
    Return, 1
   }
  }
 }
}

;parses a new line, to find control structures, directives, etc.
CodeLexLine(ByRef Code,ByRef Position,ByRef Tokens,ByRef Errors)
{ ;returns 1 if the line cannot be parsed as a statement, nothing otherwise
 global LexerIdentifierChars, LexerStatementList

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
 If ((CurrentChar = ":") && InStr("`r`n " . A_Tab,SubStr(Code,Position + 1,1))) ;is a label
 {
  Position ++
  While, (InStr(" " . A_Tab,CurrentChar := SubStr(Code,Position,1)) && (CurrentChar <> "")) ;move past whitespace
   Position ++
  ObjInsert(Tokens,Object("Type","LABEL","Value",Statement)) ;add the label to the token array
  Return
 }

 ;determine whether the line should be parsed as an expression instead of a statement
 If !(InStr("`r`n, " . A_Tab,SubStr(Code,Position,1)) && InStr(LexerStatementList,"`n" . Statement . "`n")) ;not a statement, so must be expression
 {
  Position := Position1 ;move the position back to the beginning of the line, to allow it to be parsed again as an expression
  Return, 1
 }

 ;line is a statement, so skip over whitespace, and up to one comma
 Temp1 := ","
 While, (InStr(" " . A_Tab . Temp1,CurrentChar := SubStr(Code,Position,1)) && (CurrentChar <> ""))
  Position ++, (CurrentChar = ",") ? (Temp1 := "") : ""

 ;extract statement parameters
 Parameters := ""
 While, !InStr("`r`n",CurrentChar := SubStr(Code,Position,1))
  Position ++, Parameters .= CurrentChar

 ObjInsert(Tokens,Object("Type","STATEMENT","Value",Statement)) ;add the statement to the token array
 ObjInsert(Tokens,Object("Type","STATEMENT_PARAMETERS","Value",Parameters)) ;add the statement parameters to the token array
}

;parses a quoted string, handling escaped characters
CodeLexString(ByRef Code,ByRef Position,ByRef Tokens,ByRef Errors,ByRef Output) ;input code, current position in code, output to store the detected string in
{ ;returns 1 on error, nothing otherwise
 global LexerEscapeChar
 Position1 := Position, Output := "", Position ++ ;move to after the opening quotation mark
 Loop
 {
  CurrentChar := SubStr(Code,Position,1)
  If (CurrentChar = LexerEscapeChar) ;next character is escaped
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
 ObjInsert(Tokens,Object("Type","LITERAL_STRING","Value",Output)) ;add the string literal to the token array
}

;parses a single line comment
CodeLexSingleLineComment(ByRef Code,ByRef Position)
{
 Position ++
 While, !InStr("`r`n",SubStr(Code,Position,1)) ;loop until a newline is found
  Position ++
}

;parses a multiline comment, including any nested comments it may contain
CodeLexMultilineComment(ByRef Code,ByRef Position)
{
 global LexerEscapeChar
 CommentLevel := 1
 While, CommentLevel ;loop until the comment has ended
 {
  Position ++
  Temp1 := SubStr(Code,Position,1)
  If (Temp1 = "")
   Return
  If (Temp1 = LexerEscapeChar) ;an escaped character in the comment
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
CodeLexDynamicReference(ByRef Code,ByRef Position,ByRef Tokens,ByRef Errors,ByRef Output)
{ ;returns 1 on error, nothing otherwise
 global LexerIdentifierChars
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
  If !InStr(LexerIdentifierChars,CurrentChar) ;invalid character found
  {
   ObjInsert(Errors,Object("Identifier","INVALID_IDENTIFIER","Highlight",Object("Position",Position1,"Length",Position - Position1)),"Caret",Position) ;add an error to the error log
   Return, 1
  }
  Output .= CurrentChar
 }
 Position ++
 ObjInsert(Tokens,Object("Type","SYNTAX_ELEMENT","Value","%")) ;add the dereference operator to the token array
 ObjInsert(Tokens,Object("Type","IDENTIFIER","Value",Output)) ;add the identifier to the token array
}

;parses a number, and if it is not parsable, notify that it may be an identifier
CodeLexNumber(ByRef Code,ByRef Position,ByRef Tokens,ByRef Output)
{ ;returns 1 when parsing failed, nothing otherwise
 global LexerIdentifierChars
 Output := "", Position1 := Position, NumberChars := "1234567890"
 If (SubStr(Code,Position,2) = "0x") ;hexidecimal number
  Position += 2, Output .= "0x", NumberChars .= "abcdefABCDEF" ;skip over the identifying characters, append them to the number, and expand the valid number characters set
 Loop
 {
  CurrentChar := SubStr(Code,Position,1)
  If (CurrentChar = "") ;past end of string
   Break
  If InStr(NumberChars,CurrentChar) ;is a valid number character
   Output .= CurrentChar
  Else If InStr(LexerIdentifierChars,CurrentChar) ;notify if the code is a valid identifier char if it cannot be parsed as a number, otherwise end number
  {
   Position := Position1 ;return the position back to the start of this section, to try to parse it again as an identifier
   Return, 1
  }
  Else
   Break
  Position ++
 }
 ObjInsert(Tokens,Object("Type","LITERAL_NUMBER","Value",Output)) ;add the number literal to the token array
}

;parses an identifier
CodeLexIdentifier(ByRef Code,ByRef Position,ByRef Tokens,ByRef Output)
{
 global LexerIdentifierChars
 Output := ""
 Loop
 {
  CurrentChar := SubStr(Code,Position,1)
  If (CurrentChar = "" || !InStr(LexerIdentifierChars,CurrentChar)) ;past end of string, or found a character that was not part of the identifier
   Break
  Output .= CurrentChar, Position ++
 }
 ObjInsert(Tokens,Object("Type","IDENTIFIER","Value",Output)) ;add the identifier to the token array
}

;parses a syntax token
CodeLexSyntaxElement(ByRef Code,ByRef Position,ByRef Tokens,ByRef Errors,ByRef Output)
{ ;returns 1 on error, nothing otherwise
 global LexerSyntaxElements
 MaxLength := LexerSyntaxElements._MaxIndex(), Temp1 := MaxLength
 Loop, %MaxLength%
 {
  If ObjHasKey(LexerSyntaxElements[Temp1],Output := SubStr(Code,Position,Temp1)) ;check for a match with a syntax element
  {
   Position += Temp1
   ObjInsert(Tokens,Object("Type","SYNTAX_ELEMENT","Value",Output)) ;add the found syntax element to the token array
   Return
  }
  Temp1 --
 }
 Return, 1
}
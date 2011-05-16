#NoEnv

;initializes resources that the lexer requires
CodeLexInit()
{
 global LexerEscapeChar, LexerIdentifierChars, LexerStatementList, LexerStatementLiteralList, LexerSyntaxElements

 LexerEscapeChar := "``" ;the escape character
 LexerIdentifierChars := "abcdefghijklmnopqrstuvwxyz_1234567890#" ;characters that make up a an identifier
 LexerStatementList := "#Include`n#IncludeAgain`n#SingleInstance`n#Warn`nWhile`nLoop`nFor`nIf`nElse`nBreak`nContinue`nReturn`nGosub`nGoto`nlocal`nglobal`nstatic" ;statements that can be found on the beginning of a line
 LexerStatementLiteralList := "#Include`n#IncludeAgain`n#SingleInstance`n#Warn`nBreak`nContinue`nGosub`nGoto`nlocal`nglobal`nstatic" ;statements that accept literals as parameters
 LexerSyntaxElements := "<<=`n>>=`n//=`n . `n*=`n.=`n|=`n&=`n^=`n-=`n+=`n||`n&&`n--`n==`n<>`n!=`n++`n/=`n>=`n<=`n:=`n**`n<<`n>>`n//`n/`n*`n-`n!`n~`n+`n|`n^`n&`n<`n>`n=`n.`n(`n)`n,`n[`n]`n{`n}`n?`n:" ;elements that make up other parts of the syntax (excludes % and `n because they are handled separately by the lexer)

 ;convert statements string list to an object
 Temp1 := LexerStatementList, LexerStatementList := Object()
 Loop, Parse, Temp1, `n
  ObjInsert(LexerStatementList,A_LoopField,"")

 ;convert statements string list to an object
 Temp1 := LexerStatementLiteralList, LexerStatementLiteralList := Object()
 Loop, Parse, Temp1, `n
  ObjInsert(LexerStatementLiteralList,A_LoopField,"")

 ;convert syntax elements string list to an object
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

;lexes AHK code, including all syntax
CodeLex(Code,ByRef Tokens,ByRef Errors,ByRef FileName = "")
{ ;returns 1 on error, nothing otherwise
 global LexerIdentifierChars
 If !IsObject(Tokens)
  Tokens := Object()
 If !IsObject(Errors)
  Errors := Object()
 Position := 1
 Loop
 {
  CurrentChar := SubStr(Code,Position,1)
  If (CurrentChar = "") ;past the end of the string
   Break
  CurrentTwoChar := SubStr(Code,Position,2), Position1 := Position
  If ((InStr("`r`n",CurrentChar) <> 0) || (A_Index = 1)) ;beginning of a line
  {
   ;move past any whitespace
   While, (InStr("`r`n`t ",CurrentChar := SubStr(Code,Position,1)) && (CurrentChar <> ""))
    Position ++
   If (SubStr(Code,Position,1) = ";") ;single line comment
    CodeLexSingleLineComment(Code,Position) ;skip over comment
   Else ;input is a multiline comment or normal line
   {
    If (SubStr(Code,Position,2) = "/*") ;begin multiline comment
    {
     CodeLexMultilineComment(Code,Position) ;skip over the comment block
     ;move past any whitespace, to ensure there are no duplicate lines
     While, (InStr("`r`n",CurrentChar := SubStr(Code,Position,1)) && (CurrentChar <> ""))
      Position ++
    }
    ObjInsert(Tokens,Object("Type","SYNTAX_ELEMENT","Value","`n","Position",(Position - 1),"File",FileName)) ;add the statement end to the token array
    CodeLexLine(Code,Position,Tokens,Errors,FileName) ;parse for statements
   }
  }
  Else If (CurrentChar = """") ;begin literal string
   CodeLexString(Code,Position,Tokens,Errors,Output,FileName)
  Else If (CurrentTwoChar = "/*") ;begin multiline comment
   CodeLexMultilineComment(Code,Position) ;skip over the comment block
  Else If (CurrentTwoChar = "*/") ;end multiline comment
   Position += 2 ;can be skipped over
  Else If (CurrentChar = "%") ;dynamic variable reference or dynamic function call
   CodeLexDynamicReference(Code,Position,Tokens,Errors,Output,FileName)
  Else If !CodeLexSyntaxElement(Code,Position,Tokens,Errors,FileName) ;input is a syntax element
  {
   ;do nothing
  }
  Else If (InStr("1234567890",CurrentChar) && !CodeLexNumber(Code,Position,Output)) ;a number, not an identifier
   ObjInsert(Tokens,Object("Type","LITERAL_NUMBER","Value",Output,"Position",Position1,"File",FileName)) ;add the number literal to the token array
  Else If InStr(LexerIdentifierChars,CurrentChar) ;an identifier
   CodeLexIdentifier(Code,Position,Tokens,FileName)
  Else If InStr("`t ",CurrentChar) ;whitespace
  {
   If (SubStr(Code,Position + 1,1) = ";") ;single line comment
    CodeLexSingleLineComment(Code,Position) ;skip over comment
   Else
    Position ++
  }
  Else ;invalid character
  {
   ObjInsert(Errors,Object("Identifier","INVALID_CHARACTER","Highlight","","Caret",Position)) ;add an error to the error log
   Position ++
  }
 }
 Temp1 := Tokens[ObjMaxIndex(Tokens)] ;get most recent token
 If !(Temp1.Type = "SYNTAX_ELEMENT" && Temp1.Value = "`n") ;token was not a newline
  ObjInsert(Tokens,Object("Type","SYNTAX_ELEMENT","Value","`n","Position",Position,"File",FileName)) ;add the statement end to the token array
 Return, !!ObjMaxIndex(Errors) ;indicate whether or not there were errors
}

;parses a new line, to find control structures, directives, etc.
CodeLexLine(ByRef Code,ByRef Position,ByRef Tokens,ByRef Errors,ByRef FileName)
{ ;returns 1 if the line cannot be parsed as a statement, nothing otherwise
 global LexerIdentifierChars, LexerStatementList, LexerStatementLiteralList

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
  ObjInsert(Tokens,Object("Type","LABEL","Value",Statement,"Position",Position1,"File",FileName)) ;add the label to the token array
  Return
 }

 ;determine whether the line should be parsed as an expression instead of a statement
 If !(InStr("`r`n`t, ",SubStr(Code,Position,1)) && ObjHasKey(LexerStatementList,Statement)) ;not a statement, so must be expression
 {
  Position := Position1 ;move the position back to the beginning of the line, to allow it to be parsed again as an expression
  Return, 1
 }

 ObjInsert(Tokens,Object("Type","STATEMENT","Value",Statement,"Position",Position1,"File",FileName)) ;add the statement to the token array

 ;line is a statement, so skip over whitespace, and up to one comma
 Temp1 := ","
 While, (InStr("`t " . Temp1,CurrentChar := SubStr(Code,Position,1)) && CurrentChar <> "")
  Position ++, (CurrentChar = ",") ? (Temp1 := "") : ""

 If (Statement = "For") ;handle For loops as a special case
  Return, CodeLexForLoop(Code,Position,Tokens,Errors,FileName)

 If ObjHasKey(LexerStatementLiteralList,Statement) ;the current statement accepts the parameters literally
 {
  ;extract statement parameters
  Parameters := "", Position1 := Position
  While, !InStr("`r`n",CurrentChar := SubStr(Code,Position,1))
   Position ++, Parameters .= CurrentChar

  ObjInsert(Tokens,Object("Type","LITERAL_STRING","Value",Parameters,"Position",Position1,"File",FileName)) ;add the statement parameters to the token array
 }
}

;lexes a for loop
CodeLexForLoop(ByRef Code,ByRef Position,ByRef Tokens,ByRef Errors,ByRef FileName)
{
 global LexerIdentifierChars

 ;lex the variable that receives the key, or give an error if it is not valid
 If InStr(LexerIdentifierChars,SubStr(Code,Position,1)) ;valid identifier
  CodeLexIdentifier(Code,Position,Tokens,FileName)
 Else
 {
  ObjInsert(Errors,Object("Identifier","INVALID_IDENTIFIER","Highlight","","Caret",Position)) ;add an error to the error log
  Return, 1
 }

 ;skip over whitespace
 While, (InStr("`t ",CurrentChar := SubStr(Code,Position,1)) && CurrentChar <> "")
  Position ++

 If (SubStr(Code,Position,1) = ",") ;variable that receives the value was given
 {
  Position ++ ;move past the comma

  ;skip over whitespace
  While, (InStr("`t ",CurrentChar := SubStr(Code,Position,1)) && CurrentChar <> "")
   Position ++

  ;lex the variable that receives the value, or give an error if it is not valid
  If InStr(LexerIdentifierChars,SubStr(Code,Position,1)) ;valid identifier
   CodeLexIdentifier(Code,Position,Tokens,FileName)
  Else
  {
   ObjInsert(Errors,Object("Identifier","INVALID_IDENTIFIER","Highlight","","Caret",Position)) ;add an error to the error log
   Return, 1
  }

  ;skip over whitespace
  While, (InStr("`t ",CurrentChar := SubStr(Code,Position,1)) && CurrentChar <> "")
   Position ++
 }

 ;make sure the "In" keyword follows immediately after
 If !(SubStr(Code,Position,2) = "In" && InStr("`t ",CurrentChar := SubStr(Code,Position + 2,1)) && CurrentChar <> "")
 {
  ObjInsert(Errors,Object("Identifier","INVALID_SYNTAX","Highlight","","Caret",Position)) ;add an error to the error log
  Return, 1
 }

 ObjInsert(Tokens,Object("Type","LITERAL_STRING","Value",",","Position",Position,"File",FileName)) ;add a separator to the token array
 Position += 3 ;skip over the "In" keyword

 ;skip over whitespace
 While, (InStr("`t ",CurrentChar := SubStr(Code,Position,1)) && CurrentChar <> "")
  Position ++
}

;lexes a quoted string, handling escaped characters
CodeLexString(ByRef Code,ByRef Position,ByRef Tokens,ByRef Errors,ByRef Output,ByRef FileName) ;input code, current position in code, output to store the detected string in, name of input file
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
   ObjInsert(Errors,Object("Identifier","UNMATCHED_QUOTE","Highlight",Object("Position",Position1,"Length",(Position - Position1)),"Caret",Position)) ;add an error to the error log
   Return, 1
  }
  Else If (CurrentChar = """") ;closing quote mark found
   Break
  Else ;string contents
   Output .= CurrentChar, Position ++ ;append the character to the output
 }
 Position ++ ;move to after the closing quotation mark
 ObjInsert(Tokens,Object("Type","LITERAL_STRING","Value",Output,"Position",Position1,"File",FileName)) ;add the string literal to the token array
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

;parses dynamic variable and function references
CodeLexDynamicReference(ByRef Code,ByRef Position,ByRef Tokens,ByRef Errors,ByRef Output,ByRef FileName)
{ ;returns 1 on error, nothing otherwise
 global LexerIdentifierChars
 Output := "", Position1 := Position
 Loop
 {
  Position ++, CurrentChar := SubStr(Code,Position,1)
  If (CurrentChar = "%") ;found percent sign
   Break
  If (CurrentChar = "" || InStr("`r`n",CurrentChar)) ;past end of string, or found newline before percent sign was matched
  {
   ObjInsert(Errors,Object("Identifier","UNMATCHED_PERCENT_SIGN","Highlight",Object("Position",Position1,"Length",(Position - Position1)),"Caret",Position1)) ;add an error to the error log
   Return, 1
  }
  If !InStr(LexerIdentifierChars,CurrentChar) ;invalid character found
  {
   ObjInsert(Errors,Object("Identifier","INVALID_IDENTIFIER","Highlight",Object("Position",Position1,"Length",(Position - Position1)),"Caret",Position)) ;add an error to the error log
   Return, 1
  }
  Output .= CurrentChar
 }
 Position ++
 ObjInsert(Tokens,Object("Type","SYNTAX_ELEMENT","Value","%","Position",Position1,"File",FileName)) ;add the dereference operator to the token array
 ObjInsert(Tokens,Object("Type","IDENTIFIER","Value",Output,"Position",Position1 + 1,"File",FileName)) ;add the identifier to the token array
}

;parses a number, and if it is not parsable, notify that it may be an identifier
CodeLexNumber(ByRef Code,ByRef Position,ByRef Output)
{ ;returns 1 when parsing failed, nothing otherwise
 global LexerIdentifierChars
 Output := "", Position1 := Position, NumberChars := "1234567890", DecimalUsed := 0
 If (SubStr(Code,Position,2) = "0x") ;hexidecimal number
  DecimalUsed := 1, Position += 2, Output .= "0x", NumberChars .= "abcdefABCDEF" ;prevent the usage of decimals in hex numbers, skip over the identifying characters, append them to the number, and expand the valid number characters set
 Loop
 {
  CurrentChar := SubStr(Code,Position,1)
  If (CurrentChar = "") ;past end of string
   Return
  If InStr(NumberChars,CurrentChar) ;is a valid number character
   Output .= CurrentChar
  Else If (CurrentChar = ".") ;is a decimal point
  {
   If DecimalUsed ;input already had a decimal point, so is probably an identifier
   {
    Position := Position1 ;return the position back to the start of this section, to try to parse it again as an identifier
    Return, 1
   }
   Output .= CurrentChar, DecimalUsed := 1 ;set a flag to show that a decimal point has been used
  }
  Else If InStr(LexerIdentifierChars,CurrentChar) ;notify if the code is a valid identifier char if it cannot be parsed as a number, otherwise end number
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
CodeLexIdentifier(ByRef Code,ByRef Position,ByRef Tokens,ByRef FileName)
{
 global LexerIdentifierChars
 ;MsgBox % Position . "`n""" . SubStr(Code,Position) . "`n`n" . Clipboard := ShowObject(Tokens)
 Output := "", Position1 := Position
 Loop
 {
  CurrentChar := SubStr(Code,Position,1)
  If (CurrentChar = "" || !InStr(LexerIdentifierChars,CurrentChar)) ;past end of string, or found a character that was not part of the identifier
   Break
  Output .= CurrentChar, Position ++
 }
 ObjInsert(Tokens,Object("Type","IDENTIFIER","Value",Output,"Position",Position1,"File",FileName)) ;add the identifier to the token array
}

;parses a syntax token
CodeLexSyntaxElement(ByRef Code,ByRef Position,ByRef Tokens,ByRef Errors,ByRef FileName)
{ ;returns 1 on error, nothing otherwise
 global LexerSyntaxElements
 MaxLength := ObjMaxIndex(LexerSyntaxElements), Temp1 := MaxLength
 Loop, %MaxLength%
 {
  If ObjHasKey(LexerSyntaxElements[Temp1],Output := SubStr(Code,Position,Temp1)) ;check for a match with a syntax element
  {
   ObjInsert(Tokens,Object("Type","SYNTAX_ELEMENT","Value",Output,"Position",Position,"File",FileName)) ;add the found syntax element to the token array
   Position += Temp1
   Return
  }
  Temp1 --
 }
 Return, 1
}
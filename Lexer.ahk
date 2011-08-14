#NoEnv

;initializes resources that the lexer requires
CodeLexInit()
{
 global CodeOperatorTable, CodeLexerConstants, CodeLexerStatementList, CodeLexerStatementLiteralList, CodeLexerOperatorMaxLength
 CodeLexerConstants := Object("ESCAPE","``","SINGLE_LINE_COMMENT",";","MULTILINE_COMMENT_BEGIN","/*","MULTILINE_COMMENT_END","*/","SEPARATOR",",","LABEL",":","IDENTIFIER","abcdefghijklmnopqrstuvwxyz_1234567890#")
 CodeLexerStatementList := Object("#Include",1,"#Define",0,"#Undefine",0,"#If",0,"#Else",1,"#ElseIf",0,"#EndIf",1,"#Error",0,"While",0,"Loop",0,"For",0,"If",0,"Else",0,"Break",0,"Continue",0,"Return",0,"Gosub",0,"Goto",0,"local",0,"global",0,"static",0) ;a list of statements and whether they accept literal parameters

 CodeLexerOperatorMaxLength := 1 ;one is the maximum length of the other syntax elements - commas, parentheses, square brackets, and curly brackets
 For Temp1 In CodeOperatorTable ;get the length of the longest operator
  Temp2 := StrLen(Temp1), (Temp2 > CodeLexerOperatorMaxLength) ? (CodeLexerOperatorMaxLength := Temp2) : ""
}

;lexes plain source code, including all syntax
CodeLex(ByRef Code,ByRef Tokens,ByRef Errors,ByRef FileIndex = 1)
{ ;returns 1 on error, 0 otherwise
 global CodeTokenTypes, CodeLexerConstants
 Tokens := Array(), Position := 1, LexerError := 0 ;initialize variables
 Loop
 {
  CurrentChar := SubStr(Code,Position,1)
  If (CurrentChar = "") ;past the end of the string
   Break
  CurrentTwoChar := SubStr(Code,Position,2)
  If (A_Index = 1) ;first iteration
  {
   CodeLexLine(Code,Position,Tokens,FileIndex) ;move past whitespace and comment lines
   CodeLexStatement(Code,Position,Tokens,FileIndex) ;check for statements
  }
  Else If (CurrentChar = "`r" || CurrentChar = "`n") ;beginning of a line
  {
   Position1 := Position, Position ++ ;store the position, move past the newline character
   CodeLexLine(Code,Position,Tokens,FileIndex) ;move past whitespace and comment lines
   ObjInsert(Tokens,Object("Type",CodeTokenTypes.LINE_END,"Value","","Position",Position1,"File",FileIndex)) ;add the statement end to the token array
   CodeLexStatement(Code,Position,Tokens,FileIndex) ;check for statements
  }
  Else If (CurrentChar = """") ;begin literal string
   LexerError := CodeLexString(Code,Position,Tokens,Errors,FileIndex) || LexerError
  Else If (CurrentTwoChar = CodeLexerConstants.MULTILINE_COMMENT_BEGIN) ;begin multiline comment
   CodeLexMultilineComment(Code,Position) ;skip over the comment block
  Else If (CurrentTwoChar = CodeLexerConstants.MULTILINE_COMMENT_END) ;end multiline comment
   Position += StrLen(CodeLexerConstants.MULTILINE_COMMENT_END) ;move past multiline comment end
  Else If (CurrentChar = "%") ;dynamic variable reference or dynamic function call
   LexerError := CodeLexDynamicReference(Code,Position,Tokens,Errors,FileIndex) || LexerError
  Else If (CurrentChar = ".") ;object access (explicit handling ensures that Var.123.456 will have the purely numerical keys interpreted as identifiers instead of numbers)
  {
   Position1 := Position, Position ++, CurrentChar := SubStr(Code,Position,1) ;move to next char
   If InStr(CodeLexerConstants.IDENTIFIER,CurrentChar) ;object access operator must be followed by an identifier
   {
    ObjInsert(Tokens,Object("Type",CodeTokenTypes.OPERATOR,"Value",".","Position",Position - 1,"File",FileIndex)) ;add a object access token to the token array
    CodeLexIdentifier(Code,Position,Tokens,FileIndex) ;lex identifier
   }
   Else
    CodeRecordError(Errors,"INVALID_OBJECT_ACCESS",3,FileIndex,Position1,1,Array(Object("Position",Position,"Length",1))), LexerError := 1
  }
  Else If (CurrentChar = " " || CurrentChar = "`t") ;whitespace
   LexerError := CodeLexWhitespace(Code,Position,Tokens,Errors,FileIndex) || LexerError
  Else If !CodeLexSyntaxElement(Code,Position,Tokens,FileIndex) ;input is a syntax element
  {
   
  }
  Else If (InStr("1234567890",CurrentChar) && !CodeLexNumber(Code,Position,Tokens,FileIndex)) ;begins with a numerical digit and is not an identifier
  {
   
  }
  Else If InStr(CodeLexerConstants.IDENTIFIER,CurrentChar) ;an identifier
   CodeLexIdentifier(Code,Position,Tokens,FileIndex)
  Else ;invalid character
  {
   CodeRecordError(Errors,"INVALID_CHARACTER",3,FileIndex,Position), LexerError := 1
   Position ++ ;move past the character
  }
 }
 Temp1 := ObjMaxIndex(Tokens) ;get the highest token index
 If (Tokens[Temp1].Type = CodeTokenTypes.LINE_END) ;last token is a newline
  ObjRemove(Tokens,Temp1,"") ;remove the last token
 Return, LexerError
}

;lexes lines with comments or whitespace
CodeLexLine(ByRef Code,ByRef Position,ByRef Tokens,ByRef FileIndex)
{
 global CodeTokenTypes, CodeLexerConstants
 Loop
 {
  If ((CurrentChar := SubStr(Code,Position,1)) = "`r" || CurrentChar = "`n" || CurrentChar = " " || CurrentChar = "`t") ;whitespace character
  {
   Position ++
   While, ((CurrentChar := SubStr(Code,Position,1)) = "`r" || CurrentChar = "`n" || CurrentChar = " " || CurrentChar = "`t") ;move past whitespace characters
    Position ++
  }
  Else If (CurrentChar = CodeLexerConstants.SINGLE_LINE_COMMENT) ;single line comment
   CodeLexSingleLineComment(Code,Position) ;skip over comment
  Else If ((CurrentChar := SubStr(Code,Position,2)) = CodeLexerConstants.MULTILINE_COMMENT_BEGIN) ;multiline comment begin
   CodeLexMultilineComment(Code,Position) ;skip over the comment block
  Else If (CurrentChar = CodeLexerConstants.MULTILINE_COMMENT_END) ;multiline comment end
   Position += StrLen(CodeLexerConstants.MULTILINE_COMMENT_END) ;move past multiline comment end
  Else ;normal line
   Break
 }
}

;lexes a statement to find labels, control structures, and directives
CodeLexStatement(ByRef Code,ByRef Position,ByRef Tokens,ByRef FileIndex)
{ ;returns 1 if the line cannot be lexed as a statement, 0 otherwise
 global CodeTokenTypes, CodeLexerConstants, CodeLexerStatementList

 ;retrieve the candidate statement
 Position1 := Position, Statement := ""
 Loop
 {
  CurrentChar := SubStr(Code,Position,1)
  If (CurrentChar = "" || !InStr(CodeLexerConstants.IDENTIFIER,CurrentChar))
   Break
  Statement .= CurrentChar, Position ++
 }

 ;detect labels
 If (CurrentChar = CodeLexerConstants.LABEL && ((CurrentChar := SubStr(Code,Position + 1,1)) = "`r" || CurrentChar = "`n" || CurrentChar = " " || CurrentChar = "`t" || CurrentChar = "")) ;is a label
 {
  Position += 2 ;move past the colon and the whitespace character after the colon
  While, ((CurrentChar := SubStr(Code,Position,1)) = " " || CurrentChar = "`t") ;move past whitespace
   Position ++
  ObjInsert(Tokens,Object("Type",CodeTokenTypes.LABEL,"Value",Statement,"Position",Position1,"File",FileIndex)) ;add the label to the token array
  Return, 0
 }

 ;determine whether the line should be processed as an expression instead of a statement
 If !(((CurrentChar := SubStr(Code,Position,1)) = CodeLexerConstants.SEPARATOR || CurrentChar = "`r" || CurrentChar = "`n" || CurrentChar = " " || CurrentChar = "`t" || CurrentChar = "") && ObjHasKey(CodeLexerStatementList,Statement)) ;not a statement, so must be expression
 {
  Position := Position1 ;move the position back to the beginning of the line, to allow it to be processed again as an expression
  Return, 1
 }

 ObjInsert(Tokens,Object("Type",CodeTokenTypes.STATEMENT,"Value",Statement,"Position",Position1,"File",FileIndex)) ;add the statement to the token array

 If CodeLexerStatementList[Statement] ;the current statement accepts literal parameters
 {
  ;move past whitespace and a separator character if present
  While, ((CurrentChar := SubStr(Code,Position,1)) = " " || CurrentChar = "`t") ;skip over whitespace
   Position ++
  If (CurrentChar = CodeLexerConstants.SEPARATOR) ;separator found
  {
   Position ++ ;move past the separator
   While, ((CurrentChar := SubStr(Code,Position,1)) = " " || CurrentChar = "`t") ;skip over any remaining whitespace
    Position ++
  }

  ;extract statement parameters
  Position1 := Position, CurrentChar := SubStr(Code,Position - 1,1) ;store the position, get the previous character to check if it was whitespace
  If ((CurrentChar = " " || CurrentChar = "`t") && SubStr(Code,Position,1) = CodeLexerConstants.SINGLE_LINE_COMMENT) ;check if the parameter is a comment
  {
   CodeLexSingleLineComment(Code,Position) ;skip over comment
   ObjInsert(Tokens,Object("Type",CodeTokenTypes.STRING,"Value","","Position",Position1,"File",FileIndex)) ;add the blank statement parameters to the token array
   Return, 0
  }

  Parameters := ""
  While, ((CurrentChar := SubStr(Code,Position,1)) != "`r" && CurrentChar != "`n" && CurrentChar != "") ;move to the end of the line
  {
   CurrentTwoChar := SubStr(Code,Position,2)
   Position ++
   If (CurrentTwoChar = CodeLexerConstants.MULTILINE_COMMENT_BEGIN) ;begin multiline comment
    CodeLexMultilineComment(Code,Position) ;skip over the comment block
   Else If (CurrentTwoChar = CodeLexerConstants.MULTILINE_COMMENT_END) ;end multiline comment
    Position += StrLen(CodeLexerConstants.MULTILINE_COMMENT_END) ;move past multiline comment end
   Else If ((CurrentChar = " " || CurrentChar = "`t") && SubStr(Code,Position,1) = CodeLexerConstants.SINGLE_LINE_COMMENT) ;single line comment
    CodeLexSingleLineComment(Code,Position) ;skip over comment
   Else ;append the text to the parameter
    Parameters .= CurrentChar
  }

  ;trim trailing whitespace from parameters
  Length := Position - Position1
  While, ((CurrentChar := SubStr(Parameters,Length,1)) = " " || CurrentChar = "`t")
   Length --
  Parameters := SubStr(Parameters,1,Length)

  ObjInsert(Tokens,Object("Type",CodeTokenTypes.STRING,"Value",Parameters,"Position",Position1,"File",FileIndex)) ;add the statement parameters to the token array
 }
 Return, 0
}

;lexes whitespace and any constructs that occur after whitespace
CodeLexWhitespace(ByRef Code,ByRef Position,ByRef Tokens,ByRef Errors,ByRef FileIndex)
{ ;returns 1 if the input was invalid, 0 otherwise
 global CodeTokenTypes, CodeLexerConstants
 Position1 := Position, Position ++, CurrentChar := SubStr(Code,Position,1) ;skip over whitespace, retrieve character from updated position
 If (CurrentChar = CodeLexerConstants.SINGLE_LINE_COMMENT) ;single line comment
  CodeLexSingleLineComment(Code,Position) ;skip over comment
 Else If (CurrentChar = ".") ;concatenation operator (dot surrounded by whitespace)
 {
  Position ++, CurrentChar := SubStr(Code,Position,1) ;move to the next character
  If (CurrentChar = " " || CurrentChar = "`t") ;there must be whitespace on both sides of the concatenation operator
   ObjInsert(Tokens,Object("Type",CodeTokenTypes.OPERATOR,"Value"," . ","Position",Position - 1,"File",FileIndex)) ;add a concatenation token to the token array
  Else
  {
   CodeRecordError(Errors,"INVALID_CONCATENATION",3,FileIndex,Position - 1,1,Array(Object("Position",Position1,"Length",1),Object("Position",Position,"Length",1)))
   Return, 1
  }
 }
 Return, 0
}

;lexes a quoted string, handling escaped characters
CodeLexString(ByRef Code,ByRef Position,ByRef Tokens,ByRef Errors,ByRef FileIndex)
{ ;returns 1 if the quotation mark was unmatched, 0 otherwise
 global CodeTokenTypes, CodeLexerConstants
 Position1 := Position, Output := "", Position ++ ;move to after the opening quotation mark
 Loop
 {
  CurrentChar := SubStr(Code,Position,1)
  If (CurrentChar = CodeLexerConstants.ESCAPE) ;next character is escaped
  {
   Position ++, NextChar := SubStr(Code,Position,1) ;get the next character
   ;handle the escaping of the end of a line
   If (NextChar = "`r")
   {
    If (SubStr(Code,Position + 1,1) = "`n")
     Position ++ ;move to the next character
    Output .= CodeLexerConstants.ESCAPE . "n", Position ++ ;always concatenate with the newline character
    Continue
   }
   If (NextChar = "`n")
    NextChar := "n" ;change the escape sequence character to "n"
   Output .= CodeLexerConstants.ESCAPE . NextChar, Position ++ ;append the escape sequence to the output, and move past it
  }
  Else If (CurrentChar = "`r" || CurrentChar = "`n" || CurrentChar = "") ;past end of string, or reached a newline before the open quote has been closed
  {
   CodeRecordError(Errors,"UNMATCHED_QUOTE",3,FileIndex,Position,1,Array(Object("Position",Position1,"Length",Position - Position1)))
   Return, 1
  }
  Else If (CurrentChar = """") ;closing quote mark found
   Break
  Else ;string contents
   Output .= CurrentChar, Position ++ ;append the character to the output
 }
 Position ++ ;move to after the closing quotation mark
 ObjInsert(Tokens,Object("Type",CodeTokenTypes.STRING,"Value",Output,"Position",Position1,"File",FileIndex)) ;add the string literal to the token array
 Return, 0
}

;lexes a single line comment
CodeLexSingleLineComment(ByRef Code,ByRef Position)
{
 Position ++ ;skip over semicolon
 While, ((CurrentChar := SubStr(Code,Position,1)) != "`r" && CurrentChar != "`n" && CurrentChar != "") ;loop until a newline is found or the end of the file is reached
  Position ++
}

;lexes a multiline comment, including any nested comments it may contain
CodeLexMultilineComment(ByRef Code,ByRef Position)
{
 global CodeLexerConstants
 CommentLevel := 1, Position += StrLen(CodeLexerConstants.MULTILINE_COMMENT_BEGIN) ;set the current comment level, move past the multiline comment beginning sequence
 While, (CommentLevel > 0) ;loop until the comment has ended
 {
  CurrentChar := SubStr(Code,Position,1), CurrentTwoChar := SubStr(Code,Position,2)
  If (CurrentChar = "") ;past the end of the string
   Return
  If (CurrentChar = CodeLexerConstants.ESCAPE) ;an escaped character in the comment
   Position += 2 ;skip over the entire esape sequence (allows escaping of comment chars: /* Some `/* Comment */)
  Else If (CurrentTwoChar = CodeLexerConstants.MULTILINE_COMMENT_BEGIN) ;found a nested comment
   CommentLevel ++
  Else If (CurrentTwoChar = CodeLexerConstants.MULTILINE_COMMENT_END) ;found a closing comment
   CommentLevel --
  Position ++
 }
 Position += StrLen(CodeLexerConstants.MULTILINE_COMMENT_END) - 1 ;skip over the closing comment
}

;lexes dynamic variable and function references
CodeLexDynamicReference(ByRef Code,ByRef Position,ByRef Tokens,ByRef Errors,ByRef FileIndex)
{ ;returns 1 on an invalid dynamic reference, 0 otherwise
 global CodeTokenTypes, CodeLexerConstants
 Output := "", Position1 := Position
 Loop
 {
  Position ++, CurrentChar := SubStr(Code,Position,1)
  If (CurrentChar = "%") ;found percent sign
   Break
  If (CurrentChar = "`r" || CurrentChar = "`n" || CurrentChar = "") ;past end of string, or found newline before percent sign was matched
  {
   CodeRecordError(Errors,"UNMATCHED_PERCENT_SIGN",3,FileIndex,Position,1,Array(Object("Position",Position1,"Length",Position - Position1)))
   Return, 1
  }
  If !InStr(CodeLexerConstants.IDENTIFIER,CurrentChar) ;invalid character found
  {
   CodeRecordError(Errors,"INVALID_IDENTIFIER",3,FileIndex,Position,1,Array(Object("Position",Position1,"Length",Position - Position1)))
   Return, 1
  }
  Output .= CurrentChar
 }
 Position ++ ;move past matching percent sign
 ObjInsert(Tokens,Object("Type",CodeTokenTypes.OPERATOR,"Value","%","Position",Position1,"File",FileIndex)) ;add the dereference operator to the token array
 ObjInsert(Tokens,Object("Type",CodeTokenTypes.IDENTIFIER,"Value",Output,"Position",Position1 + 1,"File",FileIndex)) ;add the identifier to the token array
 Return, 0
}

;lexes operators and syntax elements
CodeLexSyntaxElement(ByRef Code,ByRef Position,ByRef Tokens,ByRef FileIndex)
{ ;returns 1 if no syntax element was found, 0 otherwise
 global CodeTokenTypes, CodeOperatorTable, CodeLexerConstants, CodeLexerOperatorMaxLength
 Temp1 := CodeLexerOperatorMaxLength, Position1 := Position
 Loop, %CodeLexerOperatorMaxLength% ;loop until a valid token is found
 {
  Output := SubStr(Code,Position,Temp1), Value := ""
  If (ObjHasKey(CodeOperatorTable,Output) && !(InStr(CodeLexerConstants.IDENTIFIER,SubStr(Output,0)) && (CurrentChar := SubStr(Code,Position + Temp1,1)) != "" && InStr(CodeLexerConstants.IDENTIFIER,CurrentChar))) ;found operator, and if the last charcter is an identifier character, the character after it is not, ensuring the input is an operator instead of an identifier
   TokenType := CodeTokenTypes.OPERATOR, Value := Output
  Else If (Output = CodeLexerConstants.SEPARATOR) ;found separator
   TokenType := CodeTokenTypes.SEPARATOR
  Else If (Output = "(") ;opening parenthesis
   TokenType := CodeTokenTypes.GROUP_BEGIN
  Else If (Output = ")") ;closing parenthesis
   TokenType := CodeTokenTypes.GROUP_END
  Else If (Output = "[") ;opening square bracket
   TokenType := CodeTokenTypes.OBJECT_BEGIN
  Else If (Output = "]") ;closing square bracket
   TokenType := CodeTokenTypes.OBJECT_END
  Else If (Output = "{") ;opening curly bracket
   TokenType := CodeTokenTypes.BLOCK_BEGIN
  Else If (Output = "}") ;closing curly bracket
   TokenType := CodeTokenTypes.BLOCK_END
  Else
  {
   Temp1 -- ;reduce the length of the input to be checked
   Continue
  }
  Position += StrLen(Output) ;move past the syntax element, making sure the position is not past the end of the file
  ObjInsert(Tokens,Object("Type",TokenType,"Value",Value,"Position",Position1,"File",FileIndex)) ;add the found syntax element to the token array
  Return, 0
 }
 Return, 1 ;not a syntax element
}

;lexes a number, and if it is not a valid number, notify that it may be an identifier
CodeLexNumber(ByRef Code,ByRef Position,ByRef Tokens,FileIndex)
{ ;returns 1 if the input could not be lexed as a number, 0 otherwise
 global CodeTokenTypes, CodeLexerConstants
 Output := "", Position1 := Position, NumberChars := "1234567890", DecimalUsed := 0, TokenType := CodeTokenTypes.INTEGER
 If (SubStr(Code,Position,2) = "0x") ;hexidecimal number
  DecimalUsed := 1, Position += 2, Output .= "0x", NumberChars .= "abcdefABCDEF" ;prevent the usage of decimals in hex numbers, skip over the identifying characters, append them to the number, and expand the valid number characters set
 Loop
 {
  CurrentChar := SubStr(Code,Position,1)
  If (CurrentChar = "") ;past end of string
   Break
  If InStr(NumberChars,CurrentChar) ;is a valid number character
   Output .= CurrentChar
  Else If (CurrentChar = ".") ;is a decimal point
  {
   If DecimalUsed ;input already had a decimal point, so is an identifier
   {
    Position := Position1 ;return the position back to the start of this section, to try to process it again as an identifier
    Return, 1
   }
   Output .= CurrentChar, DecimalUsed := 1, TokenType := CodeTokenTypes.DECIMAL ;set a flag to show that a decimal point has been used, change the token type to the decimal type
  }
  Else If InStr(CodeLexerConstants.IDENTIFIER,CurrentChar) ;notify if the code is a valid identifier char if it cannot be processed as a number
  {
   Position := Position1 ;return the position back to the start of this section, to try to parse it again as an identifier
   Return, 1
  }
  Else ;end of number
   Break
  Position ++
 }
 ObjInsert(Tokens,Object("Type",TokenType,"Value",Output,"Position",Position1,"File",FileIndex)) ;add the number literal to the token array
 Return, 0
}

;lexes an identifier
CodeLexIdentifier(ByRef Code,ByRef Position,ByRef Tokens,ByRef FileIndex)
{
 global CodeTokenTypes, CodeLexerConstants
 Output := SubStr(Code,Position,1), Position1 := Position, Position ++
 Loop
 {
  CurrentChar := SubStr(Code,Position,1)
  If (CurrentChar = "" || !InStr(CodeLexerConstants.IDENTIFIER,CurrentChar)) ;past end of string, or found a character that was not part of the identifier
   Break
  Output .= CurrentChar, Position ++
 }
 ObjInsert(Tokens,Object("Type",CodeTokenTypes.IDENTIFIER,"Value",Output,"Position",Position1,"File",FileIndex)) ;add the identifier to the token array
}
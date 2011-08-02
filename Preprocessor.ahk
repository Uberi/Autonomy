#NoEnv

/*
Preprocessor Expressions
------------------------

The preprocessor supports simple expressions in the form:

    #Define SOME_DEFINITION := 3
    #Define ANOTHER_DEFINITION := 2 * (5 + SOME_DEFINITION)
    #Define SOME_DEFINITION := "A String"
    #If SOME_DEFINITION = "A " . "String"
    ;code here would be processed
    #Else
    ;code here would not be processed
    #EndIf

However, there are a few limitations:

* Only the following operators can be used: "||", "&&", "=", "==", "!=", "!==", ">", "<", ">=", "<=", " . ", "&" (binary form), "^", "|", "<<", ">>", "+", "-" (binary and unary forms), "*" (binary form), "/", "//", "!", "~", "**"
* Only parentheses, string or number literals, and other definition identifiers are allowed in the expressions
* Function calls are not allowed
* The definition directive requires all definitions to use the "[Identifier] := [Expression]" form
*/

;initializes resources that the preprocessor requires
CodePreprocessInit(ByRef Files,ByRef CurrentDirectory = "")
{
 global CodePreprocessorIncludeDirectory, CodePreprocessorLibraryPaths

 If (ObjHasKey(Files,1) && (Path := Files.1) != "") ;file path given, set the include directory to the directory of the script
  CodePreprocessorIncludeDirectory := PathSplit(Path).Directory
 Else If (CurrentDirectory != "") ;include directory given explicitly
  CodePreprocessorIncludeDirectory := CurrentDirectory
 Else ;no path given, set the include directory to the directory of this script
  CodePreprocessorIncludeDirectory := A_ScriptDir

 CodePreprocessorLibraryPaths := Array(PathJoin(CodePreprocessorIncludeDirectory,"Lib"),PathJoin(A_MyDocuments,"AutoHotkey","Lib"),PathJoin(A_ScriptDir,"Lib")) ;paths that are searched for libraries
}

;preprocesses a token stream containing preprocessor directives
CodePreprocess(ByRef Tokens,ByRef ProcessedTokens,ByRef Errors,ByRef Files,FileIndex = 1)
{ ;returns 1 on error, 0 otherwise
 global CodeTokenTypes

 ProcessedTokens := Array(), Index := 1, PreprocessError := 0, Definitions := Array()
 While, IsObject(Token := Tokens[Index])
 {
  Index ++ ;move past the statement, or the token if it is not a statement
  If (Token.Type != CodeTokenTypes.STATEMENT) ;skip over any tokens that are not statements
  {
   ObjInsert(ProcessedTokens,Token) ;copy the token to the output stream
   Continue
  }
  Directive := Token.Value
  If (Directive = "#Include") ;script inclusion, duplication ignored
   PreprocessError := CodePreprocessInclusion(Tokens[Index],Index,ProcessedTokens,Errors,Files,FileIndex) || PreprocessError
  Else If (Directive = "#Define") ;identifier macro or function macro definition
   CodePreprocessDefinition(Tokens,Index,ProcessedTokens,Definitions,Errors,FileIndex) ;macro definition
  Else If (Directive = "#Undefine") ;removal of existing macro
   PreprocessError := CodePreprocessRemoveDefinition(Tokens,Index,Definitions,Errors) || PreprocessError
  /*
  Else If (Directive = "#If") ;conditional code checking simple expressions against definitions
   ;wip: process here
  Else If (Directive = "#ElseIf") ;conditional code checking alternative simple expressions against definitions
   ;wip: process here
  Else If (Directive = "#Else") ;conditional code checking alternative
   ;wip: process here
  Else If (Directive = "#EndIf") ;conditional code block end
   ;wip: process here
  */
  Else
   ObjInsert(ProcessedTokens,Token) ;copy the token to the output stream, move past the parameter or line end
  Index ++ ;move to the next token
 }
 Temp1 := ObjMaxIndex(ProcessedTokens) ;get the highest token index
 If (ProcessedTokens[Temp1].Type = CodeTokenTypes.LINE_END) ;token is a newline
  ObjRemove(ProcessedTokens,Temp1,"") ;remove the last token
 Return, PreprocessError
}

;preprocesses an inclusion directive
CodePreprocessInclusion(Token,ByRef TokenIndex,ByRef ProcessedTokens,ByRef Errors,ByRef Files,FileIndex)
{ ;returns 1 on inclusion failure, 0 otherwise
 global CodePreprocessorIncludeDirectory, CodePreprocessorLibraryPaths

 Parameter := Token.Value ;retrieve the next token, the parameters given to the statement

 If (SubStr(Parameter,1,1) = "<") ;library file: #Include <LibraryName>
 {
  Parameter := SubStr(Parameter,2,-1) ;remove surrounding angle brackets
  For Index, Path In CodePreprocessorLibraryPaths ;loop through each folder looking for the file
  {
   Temp1 := PathExpand(Parameter,Path,Attributes)
   If (Attributes != "") ;found script file
   {
    Parameter := Temp1
    Break
   }
  }
 }
 Else
  Parameter := PathExpand(Parameter,CodePreprocessorIncludeDirectory,Attributes)
 If (Attributes = "") ;file not found
 {
  CodeRecordErrorTokens(Errors,"FILE_ERROR",3,0,Array(Token))
  TokenIndex ++ ;skip past extra line end token
  Return, 1
 }
 If InStr(Attributes,"D") ;is a directory
 {
  CodePreprocessorIncludeDirectory := Parameter ;set the current include directory
  TokenIndex ++ ;skip past extra line end token
  Return, 0
 }
 For Index, Temp1 In Files ;check if the file has already been included
 {
  If (Temp1 = Parameter) ;found file already included
  {
   CodeRecordErrorTokens(Errors,"DUPLICATE_INCLUSION",1,0,Array(Token))
   TokenIndex ++ ;skip past extra line end token
   Return, 0
  }
 }

 If (FileRead(Code,Parameter) != 0) ;error reading file
 {
  CodeRecordErrorTokens(Errors,"FILE_ERROR",3,0,Array(Token))
  TokenIndex ++ ;skip past extra line end token
  Return, 1
 }

 ;add file to list of included files, since it has not been included yet
 FileIndex := ObjMaxIndex(Files) + 1 ;get the index to insert the file entry at
 ObjInsert(Files,FileIndex,Parameter) ;add the current script file to the file array

 CodeLex(Code,FileTokens,Errors,FileIndex) ;lex the external file
 CodePreprocess(FileTokens,FileProcessedTokens,Errors,Files,FileIndex) ;preprocess the tokens

 ;copy tokens from included file into the main token stream
 For Index, Token In FileProcessedTokens
  ObjInsert(ProcessedTokens,Token)

 Return, 0
}

;preprocesses a definition directive
CodePreprocessDefinition(ByRef Tokens,ByRef Index,ByRef ProcessedTokens,ByRef Definitions,ByRef Errors,FileIndex)
{ ;returns 1 on invalid definition syntax, 0 otherwise
 global CodeTokenTypes
 Token := Tokens[Index], NextToken := Tokens[Index + 1]
 If (Token.Type != CodeTokenTypes.IDENTIFIER || NextToken.Type != CodeTokenTypes.OPERATOR || NextToken.Value != ":=") ;ensure definition starts with an identifier assignment
 {
  CodeRecordErrorTokens(Errors,"INVALID_DIRECTIVE_SYNTAX",3,0,Array(Token,NextToken))
  TokensLength := ObjMaxIndex(Tokens)
  While, (Index <= TokensLength && Tokens[Index].Type != CodeTokenTypes.LINE_END) ;loop over tokens until the end of the line
   Index ++
  Return, 1
 }
 Identifier := Token.Value, Index += 2 ;retrieve the identifier name, move past the identifier and assignment operator tokens
 If ObjHasKey(Definitions,Identifier)
  CodeRecordErrorTokens(Errors,"DUPLICATE_DEFINITION",2,0,Array(Token))
 If (CodePreprocessEvaluate(Tokens,Index,Result,Definitions,Errors,FileIndex) = 1)
  Return, 1
 ObjInsert(Definitions,Identifier,Result.1)
 MsgBox % ShowObject(Definitions) ;wip: debug
}

;preprocesses a definition removal directive
CodePreprocessRemoveDefinition(ByRef Tokens,Index,ByRef Definitions,Errors)
{ ;returns 1 on invalid definition removal syntax, 0 otherwise
 global CodeTokenTypes

 Token := Tokens[Index]
 If (Token.Type != CodeTokenTypes.IDENTIFIER || Tokens[Index + 1].Type != CodeTokenTypes.LINE_END) ;token is not an identifier or the token after it is not a line end
 {
  CodeRecordErrorTokens(Errors,"INVALID_DIRECTIVE_SYNTAX",3,0,Array(Token))
  Return, 1
 }
 CurrentDefinition := Token.Value
 If ObjHasKey(Definitions,CurrentDefinition) ;remove the key if it exists
  ObjRemove(Definitions,CurrentDefinition)
 Else ;warn that the key does not exist
  CodeRecordErrorTokens(Errors,"UNDEFINED_MACRO",2,0,Array(Token))
 Return, 0
}

;evaluates a simple preprocessor expression ;wip: unary minus not working yet (need to use prevtoken variable)
CodePreprocessEvaluate(ByRef Tokens,ByRef Index,ByRef Result,ByRef Definitions,ByRef Errors,FileIndex)
{ ;returns 1 on evaluation error, 0 otherwise
 global CodeTokenTypes, CodeOperatorTable

 EvaluationError := 0, Result := Array(), Stack := Array(), MaxIndex := 0, TokensLength := ObjMaxIndex(Tokens), StartPosition := Tokens[Index].Position ;initialize variables
 While, (Index <= TokensLength && (Token := Tokens[Index]).Type != CodeTokenTypes.LINE_END) ;loop until the token stream or line ends
 {
  TokenType := Token.Type, TokenValue := Token.Value
  If (TokenType = CodeTokenTypes.LITERAL_NUMBER || TokenType = CodeTokenTypes.LITERAL_STRING) ;a literal token
   ObjInsert(Result,Token)
  Else If (TokenType = CodeTokenTypes.IDENTIFIER) ;an identifier token
  {
   If ObjHasKey(Definitions,TokenValue) ;identifier exists in definitions
    ObjInsert(Result,Definitions[TokenValue]) ;place the token of the definition value onto the result
   Else ;identifier was not defined
    CodeRecordErrorTokens(Errors,"UNDEFINED_MACRO",3,0,Array(Token)), EvaluationError := 1
  }
  Else If (TokenType = CodeTokenTypes.OPERATOR) ;an operator
  {
   While, (MaxIndex > 0 && (StackToken := Stack[MaxIndex]).Type = CodeTokenTypes.OPERATOR) ;loop while the token at the top of the stack is an operator
   {
    Operator := CodeOperatorTable[TokenValue], Precedence := Operator.Precedence, StackOperator := CodeOperatorTable[StackToken.Value], StackPrecedence := StackOperator.Precedence
    If (Operator.Associativity = "L")
    {
     If (Precedence > StackPrecedence) ;operator is left associative and has a higher precedence than the operator on the stack
      Break
    }
    Else If (Precendence >= StackPrecedence) ;operator is right associative and has an equal or higher precedence than the operator on the stack
     Break
    Arity := StackOperator.Arity
    EvaluationError := CodePreprocessEvaluateOperator(Token,Arity,Result,Errors) || EvaluationError
    ObjRemove(StackToken,MaxIndex), MaxIndex -- ;pop the operator at the top of the stack
   }
   ObjInsert(Stack,Token), MaxIndex ++
  }
  Else If (TokenType = CodeTokenTypes.PARENTHESIS)
  {
   If (TokenValue = "(") ;token is a left parenthesis
    ObjInsert(Stack,Token), MaxIndex ++
   Else ;token is a right parenthesis
   {
    While, (MaxIndex > 0 && (StackToken := Stack[MaxIndex]).Type != CodeTokenTypes.PARENTHESIS) ;loop until the token at the top of the stack is a left parenthesis
     ObjInsert(Result,StackToken), ObjRemove(StackToken,MaxIndex), MaxIndex -- ;pop the operator at the top of the stack into the output
    If (MaxIndex = 0) ;parenthesis mismatch
     Position := Token.Position, CodeRecordError(Errors,"PARENTHESIS_MISMATCH",3,FileIndex,Position,Array(Object("Position",StartPosition,"Length",Position - StartPosition))), EvaluationError := 1
    ObjRemove(Stack,MaxIndex), MaxIndex -- ;pop the parenthesis off the stack
   }
  }
  PrevToken := Token, Index ++ ;store the previous token, move to the next token
 }
 If ObjHasKey(Tokens,Index)
  EndPos := Tokens[Index].Position ;get the position of the last line end
 Else
  Token := Tokens[Index - 1], EndPos := Token.Position + StrLen(Token.Value) ;get position of the end of the token stream
 Loop, %MaxIndex% ;wip: incorrect loop syntax
 {
  If ((StackToken := Stack[MaxIndex]).Type = CodeTokenTypes.PARENTHESIS)
   Position := StackToken.Position, CodeRecordError(Errors,"PARENTHESIS_MISMATCH",3,FileIndex,Position,Array(Object("Position",Position,"Length",EndPos - Position))), EvaluationError := 1
  Else
   EvaluationError := CodePreprocessEvaluateOperator(StackToken,CodeOperatorTable[StackToken.Value].Arity,Result,Errors) || EvaluationError
  ObjRemove(Stack,MaxIndex), MaxIndex -- ;pop the operator off the stack
 }
 MaxIndex := ObjMaxIndex(Result) - 1
 If (MaxIndex > 0) ;operators did not consume all the inputs
 {
  Highlight := Array()
  Loop, %MaxIndex% ;wip: incorrect loop syntax
   ObjInsert(Highlight,Result[A_Index])
  CodeRecordErrorTokens(Errors,"EXTRANEOUS_INPUTS",3,0,Highlight)
  Return, 1
 }
 Return, EvaluationError
}

;evaluates the result of a single operator applied to its parameters
CodePreprocessEvaluateOperator(OperatorToken,Arity,ByRef Result,ByRef Errors)
{ ;returns 1 on type or stack error, 0 otherwise
 global CodeTokenTypes

 MaxIndex := ObjMaxIndex(Result)
 If (MaxIndex = 0) ;stack does not contain enough entries
 {
  CodeRecordErrorTokens(Errors,"INVALID_OPERATOR_PARAMETERS",3,0,Array(OperatorToken))
  Return, 1
 }
 Parameter2 := Result[MaxIndex], ObjRemove(Result,MaxIndex), MaxIndex --
 Type2 := Parameter2.Type, Value2 := Parameter2.Value
 If (Arity > 1)
 {
  If (MaxIndex = 0) ;stack does not contain enough entries
  {
   CodeRecordErrorTokens(Errors,"INVALID_OPERATOR_PARAMETERS",3,0,Array(OperatorToken,Parameter2))
   Return, 1
  }
  Parameter1 := Result[MaxIndex], ObjRemove(Result,MaxIndex), MaxIndex --
  Type1 := Parameter1.Type, Value1 := Parameter1.Value
 }
 Operator := OperatorToken.Value

 If (Operator = "||")
  Value := Value2 || Value1, ValidTypes := 1
 Else If (Operator = "&&")
  Value := Value2 && Value1, ValidTypes := 1
 Else If (Operator = "=")
  Value := Value2 = Value1, ValidTypes := 1
 Else If (Operator = "==")
  Value := Value2 == Value1, ValidTypes := 1
 Else If (Operator = "!=")
  Value := Value2 != Value1, ValidTypes := 1
 Else If (Operator = "!==")
  Value := Value2 !== Value1, ValidTypes := 1
 Else If (Operator = ">")
  Value := Value2 > Value1, ValidTypes := 1
 Else If (Operator = "<")
  Value := Value2 < Value1, ValidTypes := 1
 Else If (Operator = ">=")
  Value := Value2 >= Value1, ValidTypes := 1
 Else If (Operator = "<=")
  Value := Value2 <= Value1, ValidTypes := 1
 Else If (Operator = " . ")
  Value := Value2 . Value1, ValidTypes := 1
 Else If (Operator = "&")
  ValidTypes := Type2 = CodeTokenTypes.LITERAL_NUMBER && Type1 = CodeTokenTypes.LITERAL_NUMBER, ValidTypes ? (Value := Value2 & Value1)
 Else If (Operator = "^")
  ValidTypes := Type2 = CodeTokenTypes.LITERAL_NUMBER && Type1 = CodeTokenTypes.LITERAL_NUMBER, ValidTypes ? (Value := Value2 ^ Value1)
 Else If (Operator = "|")
  ValidTypes := Type2 = CodeTokenTypes.LITERAL_NUMBER && Type1 = CodeTokenTypes.LITERAL_NUMBER, ValidTypes ? (Value := Value2 | Value1)
 Else If (Operator = "<<")
  ValidTypes := Type2 = CodeTokenTypes.LITERAL_NUMBER && Type1 = CodeTokenTypes.LITERAL_NUMBER, ValidTypes ? (Value := Value2 << Value1)
 Else If (Operator = ">>")
  ValidTypes := Type2 = CodeTokenTypes.LITERAL_NUMBER && Type1 = CodeTokenTypes.LITERAL_NUMBER, ValidTypes ? (Value := Value2 >> Value1)
 Else If (Operator = "+")
  ValidTypes := Type2 = CodeTokenTypes.LITERAL_NUMBER && Type1 = CodeTokenTypes.LITERAL_NUMBER, ValidTypes ? (Value := Value2 + Value1)
 Else If (Operator = "-")
  ValidTypes := Type2 = CodeTokenTypes.LITERAL_NUMBER && Type1 = CodeTokenTypes.LITERAL_NUMBER, ValidTypes ? (Value := Value2 - Value1)
 Else If (Operator = "*")
  ValidTypes := Type2 = CodeTokenTypes.LITERAL_NUMBER && Type1 = CodeTokenTypes.LITERAL_NUMBER, ValidTypes ? (Value := Value2 * Value1)
 Else If (Operator = "/")
  ValidTypes := Type2 = CodeTokenTypes.LITERAL_NUMBER && Type1 = CodeTokenTypes.LITERAL_NUMBER, ValidTypes ? (Value := Value2 / Value1)
 Else If (Operator = "//")
  ValidTypes := Type2 = CodeTokenTypes.LITERAL_NUMBER && Type1 = CodeTokenTypes.LITERAL_NUMBER, ValidTypes ? (Value := Value2 // Value1)
 Else If (Operator = "!")
  Value := !Value2, ValidTypes := 1
 Else If (Operator = "\-") ;unary minus
  ValidTypes := Type2 = CodeTokenTypes.LITERAL_NUMBER, ValidTypes ? (Value := -Value2)
 Else If (Operator = "~")
  ValidTypes := Type2 = CodeTokenTypes.LITERAL_NUMBER, ValidTypes ? (Value := ~Value2)
 Else If (Operator = "**")
  ValidTypes := Type2 = CodeTokenTypes.LITERAL_NUMBER && Type1 = CodeTokenTypes.LITERAL_NUMBER, ValidTypes ? (Value := Value2 ** Value1)

 If ValidTypes
  ObjInsert(Result,Object("Type",CodeTokenTypes.LITERAL_NUMBER,"Value",Value)) ;wip: give actual types
 Else If (Arity > 1)
  CodeRecordErrorTokens(Errors,"INVALID_OPERATOR_PARAMETERS",3,0,Array(Parameter2,OperatorToken,Parameter1))
 Else
  CodeRecordErrorTokens(Errors,"INVALID_OPERATOR_PARAMETERS",3,0,Array(OperatorToken,Parameter1))

 Return, !ValidTypes
}

/* ;wip: TDOP parser doesn't handle infix yet
CodeExpressionEval(ByRef Tokens,ByRef Errors)
{
 global CodeTokenTypes, FunctionList
 FunctionList := Object(CodeTokenTypes.OPERATOR,Object("Null",Func("DispatchOperatorNull"),"Left",Func("DispatchOperatorLeft"),"BindingPower",),CodeTokenTypes.LITERAL_NUMBER,Object("Null",Func("DispatchLiteralNull")))

 Index := 1
 Return, Expression(Tokens,Index)
}

Expression(ByRef Tokens,ByRef Index,RightBindingPower = 0)
{
 global FunctionList
 t := Tokens[Index], Index ++, Token := Tokens[Index]
 LeftSide := FunctionList[t.Type].Null(Tokens,Index,t)
 While, RightBindingPower < Token.LeftBindingPower
 Return, LeftSide
}

DispatchOperatorLeft(This,ByRef Tokens,ByRef Index,Token,LeftSide)
{
 global CodeTokenTypes
 TokenValue := Token.Value
 If (TokenValue = "+")
  Return, Object("Type",CodeTokenTypes.LITERAL_NUMBER,"Value",Expression(Tokens,Index,10))
}

DispatchOperatorNull(This,ByRef Tokens,ByRef Index,Token)
{
 global CodeTokenTypes
 TokenValue := Token.Value
 If (TokenValue = "-")
 {
  Return, Object("Type",CodeTokenTypes.LITERAL_NUMBER,"Value",-(Expression(Tokens,Index,100).Value))
 }
 Else
  MsgBox % TokenValue
}

DispatchLiteralNull(This,ByRef Tokens,ByRef Index,Token)
{
 Return, Token
}
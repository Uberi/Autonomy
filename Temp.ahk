#NoEnv

#Include Resources\Functions.ahk
#Include Code.ahk
#Include Lexer.ahk

;wip: prefix globals

Code := "4(2+4)*-5"

If CodeInit()
{
 Display("Error initializing code tools.`n") ;display error at standard output
 ExitApp(1) ;fatal error
}

FileName := A_ScriptFullPath
CodeSetScript(FileName,Errors,Files) ;set the current script file

CodeLexInit()
CodeLex(Code,Tokens,Errors)

CodeEvaluateInit()

Index := 1
MsgBox % ShowObject(CodeEvaluate(Tokens,Index,Errors))
ExitApp()

CodeEvaluateInit()
{
 global CodeTokenTypes, Functions, Operators

 Operators := Object("+"
   ,Object("LeftBindingPower",10
   ,"LeftDenotation",Func("OperatorAdd"))
  ,"-"
   ,Object("LeftBindingPower",10
   ,"NullDenotation",Func("OperatorUnarySubtract")
   ,"LeftDenotation",Func("OperatorSubtract"))
  ,"*"
   ,Object("LeftBindingPower",20
   ,"NullDenotation",Func("OperatorDereference")
   ,"LeftDenotation",Func("OperatorMultiply")))
}

CodeEvaluate(ByRef Tokens,ByRef Index,ByRef Errors,RightBindingPower = 0)
{
 global Functions

 TokensLength := ObjMaxIndex(Tokens) ;retrieve the maximum index of the token stream
 If (Index > TokensLength)
  Return, "ERROR: Missing token" ;wip: better error handling
 CurrentToken := Tokens[Index], Index ++ ;retrieve the current token, move to the next token
 LeftSide := CodeEvaluateDispatchNullDenotation(Tokens,Index,Errors,CurrentToken) ;handle the null denotation - the token does not require tokens to its left
 If (Index > TokensLength) ;ensure the index does not go out of bounds
  Return, LeftSide
 NextToken := Tokens[Index] ;retrieve the next token
 While, (RightBindingPower < CodeEvaluateDispatchLeftBindingPower(NextToken)) ;loop while the current right binding power is less than that of the left binding power of the next token
 {
  CurrentToken := NextToken, Index ++ ;store the token and move to the next one
  LeftSide := CodeEvaluateDispatchLeftDenotation(Tokens,Index,Errors,CurrentToken,LeftSide) ;handle the left denotation - the token requires tokens to its left
  If (Index > TokensLength) ;ensure the index does not go out of bounds
   Break
  NextToken := Tokens[Index] ;retrieve the next token
 }
 Return, LeftSide
}

CodeEvaluateDispatchLeftBindingPower(Token)
{
 global CodeTokenTypes, Operators
 TokenType := Token.Type
 If (TokenType = CodeTokenTypes.OPERATOR) ;operator token
  Return, Operators[Token.Value].LeftBindingPower
 If (TokenType = CodeTokenTypes.LITERAL_NUMBER || TokenType = CodeTokenTypes.LITERAL_STRING) ;literal token
  Return, 0
 If (TokenType = CodeTokenTypes.PARENTHESIS) ;parenthesis token
  Return, (Token.Value = "(") ? 100 : 0
}

CodeEvaluateDispatchNullDenotation(ByRef Tokens,ByRef Index,ByRef Errors,Token)
{
 global CodeTokenTypes, Operators
 TokenType := Token.Type
 If (TokenType = CodeTokenTypes.OPERATOR)
  Return, Operators[Token.Value].NullDenotation(Tokens,Index,Errors)
 If (TokenType = CodeTokenTypes.LITERAL_NUMBER || TokenType = CodeTokenTypes.LITERAL_STRING)
  Return, Token
 If (TokenType = CodeTokenTypes.PARENTHESIS)
  Return, DispatchParenthesisNullDenotation(Tokens,Index,Errors,Token)
}

CodeEvaluateDispatchLeftDenotation(ByRef Tokens,ByRef Index,ByRef Errors,Token,LeftSide)
{
 global CodeTokenTypes, Operators
 TokenType := Token.Type
 If (TokenType = CodeTokenTypes.OPERATOR)
  Return, Operators[Token.Value].LeftDenotation(Tokens,Index,Errors,LeftSide)
 If (TokenType = CodeTokenTypes.LITERAL_NUMBER || TokenType = CodeTokenTypes.LITERAL_STRING)
  Return, "ERROR: Missing operator" ;wip: better error handling
 If (TokenType = CodeTokenTypes.PARENTHESIS)
  Return, DispatchParenthesisLeftDenotation(Tokens,Index,Errors,Token,LeftSide)
}

DispatchParenthesisNullDenotation(ByRef Tokens,ByRef Index,ByRef Errors,Token)
{
 global CodeTokenTypes
 If (Token.Value = "(") ;left parenthesis
 {
  Result := CodeEvaluate(Tokens,Index,Errors)
  CurrentToken := Tokens[Index]
  If (CurrentToken.Type = CodeTokenTypes.PARENTHESIS && CurrentToken.Value = ")") ;match a right parenthesis
  {
   Index ++
   Return, Result
  }
 }
 Return, "ERROR: Unmatched parenthesis" ;wip: better error handling
}

DispatchParenthesisLeftDenotation(ByRef Tokens,ByRef Index,ByRef Errors,Token,LeftSide)
{
 global CodeTokenTypes
 If (Token.Value = "(") ;left parenthesis
 {
  Result := CodeEvaluate(Tokens,Index,Errors)
  CurrentToken := Tokens[Index]
  If (CurrentToken.Type = CodeTokenTypes.PARENTHESIS && CurrentToken.Value = ")") ;match a right parenthesis
  {
   Index ++
   Return, Object("Type",LeftSide.Value,"Value",Result)
  }
 }
 Return, "ERROR: Unmatched parenthesis" ;wip: better error handling
}

OperatorAdd(This,ByRef Tokens,ByRef Index,ByRef Errors,LeftSide)
{
 global CodeTokenTypes
 ;Return, Object("Type",CodeTokenTypes.LITERAL_NUMBER,"Value",LeftSide.Value + CodeEvaluate(Tokens,Index,Errors,10).Value)
 Return, Object("Type","ADD","Value",Array(LeftSide,CodeEvaluate(Tokens,Index,Errors,10)))
}

OperatorUnarySubtract(This,ByRef Tokens,ByRef Index,ByRef Errors)
{
 global CodeTokenTypes
 ;Return, Object("Type",CodeTokenTypes.LITERAL_NUMBER,"Value",-CodeEvaluate(Tokens,Index,Errors,100).Value)
 Return, Object("Type","NEGATIVE","Value",Array(CodeEvaluate(Tokens,Index,Errors,100)))
}

OperatorSubtract(This,ByRef Tokens,ByRef Index,ByRef Errors,LeftSide)
{
 global CodeTokenTypes
 ;Return, Object("Type",CodeTokenTypes.LITERAL_NUMBER,"Value",LeftSide.Value - CodeEvaluate(Tokens,Index,Errors,10).Value)
 Return, Object("Type","SUBTRACT","Value",Array(LeftSide,CodeEvaluate(Tokens,Index,Errors,10)))
}

OperatorDereference(This,ByRef Tokens,ByRef Index,ByRef Errors)
{
 global CodeTokenTypes
 ;Return, Object("Type",CodeTokenTypes.LITERAL_NUMBER,"Value",*CodeEvaluate(Tokens,Index,Errors,100).Value)
 Return, Object("Type","DEREFERENCE","Value",Array(CodeEvaluate(Tokens,Index,Errors,100)))
}

OperatorMultiply(This,ByRef Tokens,ByRef Index,ByRef Errors,LeftSide)
{
 global CodeTokenTypes
 ;Return, Object("Type",CodeTokenTypes.LITERAL_NUMBER,"Value",LeftSide.Value * CodeEvaluate(Tokens,Index,Errors,20).Value)
 Return, Object("Type","MULTIPLY","Value",Array(LeftSide,CodeEvaluate(Tokens,Index,Errors,20)))
}
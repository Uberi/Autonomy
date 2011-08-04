#NoEnv

#Include Resources\Functions.ahk
#Include Code.ahk
#Include Lexer.ahk

;wip: prefix globals

Code := "3-(2+4)*-5"

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

 Functions := Object(CodeTokenTypes.OPERATOR,Object("LeftBindingPower",Func("DispatchOperatorLeftBindingPower"),"NullDenotation",Func("DispatchOperatorNullDenotation"),"LeftDenotation",Func("DispatchOperatorLeftDenotation"))
  ,CodeTokenTypes.LITERAL_NUMBER,Object("LeftBindingPower",Func("DispatchLiteralLeftBindingPower"),"NullDenotation",Func("DispatchLiteralNullDenotation"))
  ,CodeTokenTypes.LITERAL_STRING,Object("LeftBindingPower",Func("DispatchLiteralLeftBindingPower"),"NullDenotation",Func("DispatchLiteralNullDenotation"))
  ,CodeTokenTypes.PARENTHESIS,Object("LeftBindingPower",Func("DispatchParenthesisLeftBindingPower"),"NullDenotation",Func("DispatchParenthesisNullDenotation"),"LeftDenotation",Func("DispatchParenthesisLeftDenotation")))

 Operators := Object("+",Object("LeftBindingPower",10,"LeftDenotation",Func("OperatorAdd"))
  ,"-",Object("LeftBindingPower",10,"NullDenotation",Func("OperatorUnarySubtract"),"LeftDenotation",Func("OperatorSubtract"))
  ,"*",Object("LeftBindingPower",20,"NullDenotation",Func("OperatorDereference"),"LeftDenotation",Func("OperatorMultiply")))
}

CodeEvaluate(ByRef Tokens,ByRef Index,ByRef Errors,RightBindingPower = 0)
{
 global Functions

 TokensLength := ObjMaxIndex(Tokens) ;retrieve the maximum index of the token stream
 If (Index > TokensLength)
  Return, "ERROR: Missing token" ;wip: better error handling
 CurrentToken := Tokens[Index], Index ++ ;retrieve the current token, move to the next token
 LeftSide := Functions[CurrentToken.Type].NullDenotation(Tokens,Index,Errors,CurrentToken) ;handle the null denotation - the token does not require tokens to its left
 If (Index > TokensLength) ;ensure the index does not go out of bounds
  Return, LeftSide
 NextToken := Tokens[Index] ;retrieve the next token
 While, (RightBindingPower < Functions[NextToken.Type].LeftBindingPower(NextToken)) ;loop while the current right binding power is less than that of the left binding power of the next token
 {
  CurrentToken := NextToken, Index ++ ;store the token and move to the next one
  LeftSide := Functions[CurrentToken.Type].LeftDenotation(Tokens,Index,Errors,CurrentToken,LeftSide) ;handle the left denotation - the token requires tokens to its left
  If (Index > TokensLength) ;ensure the index does not go out of bounds
   Break
  NextToken := Tokens[Index] ;retrieve the next token
 }
 Return, LeftSide
}

DispatchOperatorLeftBindingPower(This,Token)
{
 global Operators
 Return, Operators[Token.Value].LeftBindingPower
}

DispatchOperatorNullDenotation(This,ByRef Tokens,ByRef Index,ByRef Errors,Token)
{
 global Operators
 Return, Operators[Token.Value].NullDenotation(Tokens,Index,Errors)
}

DispatchOperatorLeftDenotation(This,ByRef Tokens,ByRef Index,ByRef Errors,Token,LeftSide)
{
 global Operators
 Return, Operators[Token.Value].LeftDenotation(Tokens,Index,Errors,LeftSide)
}

DispatchLiteralLeftBindingPower(This,Token)
{
 Return, 0
}

DispatchLiteralNullDenotation(This,ByRef Tokens,ByRef Index,ByRef Errors,Token)
{
 Return, Token
}

DispatchParenthesisLeftBindingPower(This,Token)
{
 If (Token.Value = "(") ;left parenthesis
  Return, 100
 Return, 0 ;right parenthesis
}

DispatchParenthesisNullDenotation(This,ByRef Tokens,ByRef Index,ByRef Errors,Token)
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

DispatchParenthesisLeftDenotation(This,ByRef Tokens,ByRef Index,ByRef Errors,Token,LeftSide)
{
 MsgBox
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
#NoEnv

/*
Copyright 2011 Anthony Zhang <azhang9@gmail.com>

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

;wip: remove Operators global
;wip: check for recursion depth terminating the expression by checking to make sure the token is the last one before returning, otherwise skip over close paren and keep parsing

;/*
#Include Resources\Functions.ahk
#Include Code.ahk
#Include Lexer.ahk

SetBatchLines(-1)

Code := "4-(2+4)*-(((5)))"

If CodeInit()
{
 Display("Error initializing code tools.`n") ;display error at standard output
 ExitApp(1) ;fatal error
}

FileName := A_ScriptFullPath
CodeSetScript(FileName,Errors,Files) ;set the current script file

CodeLexInit()
CodeLex(Code,Tokens,Errors)

CodeParseInit()
TimerBefore := 0, DllCall("QueryPerformanceCounter","Int64*",TimerBefore) ;wip: debug
Result := CodeParse(Tokens,SyntaxTree,Errors)
TimerAfter := 0, DllCall("QueryPerformanceCounter","Int64*",TimerAfter), TickFrequency := 0, DllCall("QueryPerformanceFrequency","Int64*",TickFrequency), TimerAfter := (TimerAfter - TimerBefore) / (TickFrequency / 1000) ;wip: debug

MsgBox % TimerAfter . " ms`n`n" . Result . "`n`n" . ShowObject(SyntaxTree)
ExitApp()
*/

CodeParseInit()
{
 global Operators

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

;parses a token stream
CodeParse(ByRef Tokens,ByRef SyntaxTree,ByRef Errors)
{ ;returns 1 on parsing error, 0 otherwise
 ParserError := 0, Index := 1 ;initialize variables
 SyntaxTree := CodeParseExpression(Tokens,Errors,ParserError,Index)
 If (Index <= ObjMaxIndex(Tokens)) ;did not reach the end of the token stream
 {
  ParserError := 1
  ;wip: better error handling
 }
 Return, ParserError
}

;parses an expression
CodeParseExpression(ByRef Tokens,ByRef Errors,ByRef ParserError,ByRef Index,RightBindingPower = 0)
{
 TokensLength := ObjMaxIndex(Tokens) ;retrieve the maximum index of the token stream
 If (Index > TokensLength)
 {
  ParserError := 1
  Return, "ERROR: Missing token." ;wip: better error handling
 }
 CurrentToken := Tokens[Index], Index ++ ;retrieve the current token, move to the next token
 LeftSide := CodeParseDispatchNullDenotation(Tokens,Errors,ParserError,Index,CurrentToken) ;handle the null denotation - the token does not require tokens to its left
 If (Index > TokensLength) ;ensure the index does not go out of bounds
  Return, LeftSide
 NextToken := Tokens[Index] ;retrieve the next token
 While, (RightBindingPower < CodeParseDispatchLeftBindingPower(NextToken)) ;loop while the current right binding power is less than that of the left binding power of the next token
 {
  CurrentToken := NextToken, Index ++ ;store the token and move to the next one
  LeftSide := CodeParseDispatchLeftDenotation(Tokens,Errors,Index,CurrentToken,LeftSide) ;handle the left denotation - the token requires tokens to its left
  If (Index > TokensLength) ;ensure the index does not go out of bounds
   Break
  NextToken := Tokens[Index] ;retrieve the next token
 }
 Return, LeftSide
}

;dispatches the retrieval of the left binding power of a given token
CodeParseDispatchLeftBindingPower(Token)
{ ;returns the left binding power of the given token
 global CodeTokenTypes, Operators
 TokenType := Token.Type
 If (TokenType = CodeTokenTypes.OPERATOR) ;operator token
  Return, Operators[Token.Value].LeftBindingPower
 If (TokenType = CodeTokenTypes.INTEGER || TokenType = CodeTokenTypes.DECIMAL || TokenType = CodeTokenTypes.STRING) ;literal token
  Return, 0
 If (TokenType = CodeTokenTypes.GROUP_BEGIN) ;parenthesis token
  Return, 100
 If (TokenType = CodeTokenTypes.GROUP_END)
  Return, 0
}

;dispatches the invocation of the null denotation handler of a given token
CodeParseDispatchNullDenotation(ByRef Tokens,ByRef Errors,ByRef ParserError,ByRef Index,Token)
{
 global CodeTokenTypes, Operators
 TokenType := Token.Type
 If (TokenType = CodeTokenTypes.OPERATOR)
  Return, Operators[Token.Value].NullDenotation(Tokens,Errors,ParserError,Index)
 If (TokenType = CodeTokenTypes.INTEGER || TokenType = CodeTokenTypes.DECIMAL || TokenType = CodeTokenTypes.STRING)
  Return, Token
 If (TokenType = CodeTokenTypes.GROUP_BEGIN)
  Return, GroupNullDenotation(Tokens,Errors,ParserError,Index,Token)
 If (TokenType = CodeTokenTypes.GROUP_END)
 {
  ParserError := 1
  Return, "ERROR: Unmatched parenthesis" ;wip: better error handling
 }
}

;dispatches the invocation of the left denotation handler of a given token
CodeParseDispatchLeftDenotation(ByRef Tokens,ByRef Errors,ByRef Index,Token,LeftSide)
{
 global CodeTokenTypes, Operators
 TokenType := Token.Type
 If (TokenType = CodeTokenTypes.OPERATOR)
  Return, Operators[Token.Value].LeftDenotation(Tokens,Errors,Index,LeftSide)
 If (TokenType = CodeTokenTypes.INTEGER || TokenType = CodeTokenTypes.DECIMAL || TokenType = CodeTokenTypes.STRING)
 {
  ParserError := 1
  Return, "ERROR: Missing operator" ;wip: better error handling
 }
 If (TokenType = CodeTokenTypes.GROUP_BEGIN)
  Return, GroupLeftDenotation(Tokens,Errors,Index,Token,LeftSide)
 If (TokenType = CodeTokenTypes.GROUP_END)
 {
  ParserError := 1
  Return, "ERROR: Unmatched parenthesis" ;wip: better error handling
 }
}

GroupNullDenotation(ByRef Tokens,ByRef Errors,ByRef ParserError,ByRef Index,Token)
{
 global CodeTokenTypes
 Result := CodeParseExpression(Tokens,Errors,ParserError,Index,0)
 CurrentToken := Tokens[Index]
 If (CurrentToken.Type = CodeTokenTypes.GROUP_END) ;match a right parenthesis
 {
  Index ++
  Return, Result
 }
 ParserError := 1
 Return, "ERROR: Unmatched parenthesis" ;wip: better error handling
}

GroupLeftDenotation(ByRef Tokens,ByRef Errors,ByRef Index,Token,LeftSide)
{
 global CodeTokenTypes
 Result := CodeParseExpression(Tokens,SyntaxTree,Errors,ParserError,Index)
 CurrentToken := Tokens[Index]
 If (CurrentToken.Type = CodeTokenTypes.GROUP_END) ;match a right parenthesis
 {
  Index ++
  Return, Object("Type",LeftSide.Value,"Value",Result)
 }
 ParserError := 1
 Return, "ERROR: Unmatched parenthesis" ;wip: better error handling
}

OperatorAdd(This,ByRef Tokens,ByRef Errors,ByRef Index,LeftSide)
{
 global CodeTokenTypes
 Return, Object("Type","NODE","Value",Array("ADD",LeftSide,CodeParseExpression(Tokens,Errors,ParserError,Index,10)))
}

OperatorUnarySubtract(This,ByRef Tokens,ByRef Errors,ByRef ParserError,ByRef Index)
{
 global CodeTokenTypes
 Return, Object("Type","NODE","Value",Array("NEGATIVE",CodeParseExpression(Tokens,Errors,ParserError,Index,100)))
}

OperatorSubtract(This,ByRef Tokens,ByRef Errors,ByRef Index,LeftSide)
{
 global CodeTokenTypes
 Return, Object("Type","NODE","Value",Array("SUBTRACT",LeftSide,CodeParseExpression(Tokens,Errors,ParserError,Index,10)))
}

OperatorDereference(This,ByRef Tokens,ByRef Errors,ByRef ParserError,ByRef Index)
{
 global CodeTokenTypes
 Return, Object("Type","NODE","Value",Array("DEREFERENCE",CodeParseExpression(Tokens,Errors,ParserError,Index,100)))
}

OperatorMultiply(This,ByRef Tokens,ByRef Errors,ByRef Index,LeftSide)
{
 global CodeTokenTypes
 Return, Object("Type","NODE","Value",Array("MULTIPLY",LeftSide,CodeParseExpression(Tokens,Errors,ParserError,Index,20)))
}
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

;wip: check for recursion depth terminating the expression by checking to make sure the token is the last one before returning, otherwise skip over close paren and keep parsing
;wip: type verification (possibly implement in type analyser module). need to add type information to operator table
;wip: treat line_end tokens as operators
;wip: do not check for blank parens or other matched operators - just call CodeEvaluateExpression and take the result as-is
;wip: unit test for blocks

;/*
#Warn All
#Warn LocalSameAsGlobal, Off

#Include Resources\Functions.ahk
#Include Resources\Reconstruct.ahk
#Include Resources\Operators.ahk
#Include Code.ahk
#Include Lexer.ahk

SetBatchLines(-1)

Code = 
(
SomeFunc() { Something }
)

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

TimerBefore := 0, DllCall("QueryPerformanceCounter","Int64*",TimerBefore)

Result := CodeParse(Tokens,SyntaxTree,Errors)

TimerAfter := 0, DllCall("QueryPerformanceCounter","Int64*",TimerAfter)
TickFrequency := 0, DllCall("QueryPerformanceFrequency","Int64*",TickFrequency)
TimerAfter := (TimerAfter - TimerBefore) / (TickFrequency / 1000)
MsgBox % TimerAfter . " ms`n`n" . Result . "`n`n" . Clipboard := CodeReconstructShowSyntaxTree(SyntaxTree)
ExitApp()
*/

;initializes resources that the parser requires
CodeParseInit()
{
 
}

;parses a token stream
CodeParse(ByRef Tokens,ByRef SyntaxTree,ByRef Errors)
{ ;returns 1 on parsing error, 0 otherwise
 global CodeTokenTypes, CodeTreeTypes
 ErrorIndex := ObjMaxIndex(Errors)
 TokenIndex := ObjMaxIndex(Tokens)

 SyntaxTree := [CodeTreeTypes.OPERATION,[CodeTreeTypes.IDENTIFIER,"EVALUATE"]]
 If !TokenIndex ;no tokens given
  Return, 0
 Loop ;loop through one subexpression at a time
 {
  ObjInsert(SyntaxTree,CodeParseExpression(Tokens,Errors))
  Try Token := CodeParseToken(Tokens)
  Catch ;end of token stream
   Break
  If (Token.Type = CodeTokenTypes.LINE_END) ;line end token
  {
   ;wip: process line end here
  }
  Else If (Token.Type != CodeTokenTypes.SEPARATOR) ;not a separator token
   Break ;stop parsing subexpressions
 }
 If (ObjMaxIndex(SyntaxTree) = 3) ;there was only one expression
  SyntaxTree := SyntaxTree[3] ;remove the evaluate operation and directly return the result

 If (Index <= ObjMaxIndex(Tokens)) ;did not reach the end of the token stream ;wip
 {
  ;wip: better error handling
 }
 If (ErrorIndex = ObjMaxIndex(Errors)) ;number of error entries unchanged
  Return, 0 ;no errors occurred
 Return, 1 ;errors occurred
}

;parses an expression
CodeParseExpression(ByRef Tokens,ByRef Errors,RightBindingPower = 0)
{
 Try CurrentToken := CodeParseToken(Tokens)
 Catch
 {
  MsgBox
  Return, "ERROR: Missing token." ;wip: better error handling
 }
 LeftSide := CodeParseDispatchNullDenotation(Tokens,Errors,CurrentToken) ;handle the null denotation - the token does not require tokens to its left
 Try NextToken := CodeParseToken(Tokens,0)
 Catch ;end of token stream
  Return, LeftSide
 While, (RightBindingPower < CodeParseDispatchLeftBindingPower(NextToken)) ;loop while the current right binding power is less than that of the left binding power of the next token
 {
  CurrentToken := NextToken, NextToken := CodeParseToken(Tokens) ;store the token and move to the next one
  LeftSide := CodeParseDispatchLeftDenotation(Tokens,Errors,CurrentToken,LeftSide) ;handle the left denotation - the token requires tokens to its left
  Try NextToken := CodeParseToken(Tokens,0) ;retrieve the next token
  Catch
   Break
 }
 Return, LeftSide
}

;dispatches the retrieval of the left binding power of a given token
CodeParseDispatchLeftBindingPower(Token)
{ ;returns the left binding power of the given token
 global CodeTokenTypes
 TokenType := Token.Type
 If (TokenType = CodeTokenTypes.OPERATOR) ;operator token
  Return, CodeParseOperatorLeftBindingPower(Token)
 If (TokenType = CodeTokenTypes.INTEGER ;integer token
    || TokenType = CodeTokenTypes.DECIMAL ;decimal token
    || TokenType = CodeTokenTypes.STRING ;string token
    || TokenType = CodeTokenTypes.IDENTIFIER ;identifier token
    || TokenType = CodeTokenTypes.LINE_END) ;line end token
  Return, 0
 If (TokenType = CodeTokenTypes.SEPARATOR) ;separator token
  Return, 0
}

;dispatches the invocation of the null denotation handler of a given token
CodeParseDispatchNullDenotation(ByRef Tokens,ByRef Errors,Token)
{
 global CodeTokenTypes, CodeTreeTypes
 TokenType := Token.Type
 If (TokenType = CodeTokenTypes.OPERATOR) ;operator token
  Return, CodeParseOperatorNullDenotation(Tokens,Errors,Token) ;parse the operator in null denotation
 If (TokenType = CodeTokenTypes.INTEGER) ;integer token
  Return, [CodeTreeTypes.INTEGER,Token.Value,Token.Position,Token.File] ;create an integer tree node
 If (TokenType = CodeTokenTypes.DECIMAL) ;decimal token
  Return, [CodeTreeTypes.DECIMAL,Token.Value,Token.Position,Token.File] ;create a decimal tree node
 If (TokenType = CodeTokenTypes.STRING) ;string token
  Return, [CodeTreeTypes.STRING,Token.Value,Token.Position,Token.File] ;create a string tree node
 If (TokenType = CodeTokenTypes.IDENTIFIER) ;identifier token
  Return, [CodeTreeTypes.IDENTIFIER,Token.Value,Token.Position,Token.File] ;create an identifier tree node
 If (TokenType = CodeTokenTypes.LINE_END) ;line end token
 {
  Token := CodeParseToken(Tokens) ;retrieve the token after the line end token
  Return, CodeParseDispatchNullDenotation(Tokens,Errors,Token) ;dispatch the null denotation handler of the next token
 }
}

;dispatches the invocation of the left denotation handler of a given token
CodeParseDispatchLeftDenotation(ByRef Tokens,ByRef Errors,Token,LeftSide)
{
 global CodeTokenTypes
 TokenType := Token.Type
 If (TokenType = CodeTokenTypes.OPERATOR) ;operator token
  Return, CodeParseOperatorLeftDenotation(Tokens,Errors,Token,LeftSide)
 If (TokenType = CodeTokenTypes.INTEGER ;integer token
    || TokenType = CodeTokenTypes.DECIMAL ;decimal token
    || TokenType = CodeTokenTypes.STRING ;string token
    || TokenType = CodeTokenTypes.IDENTIFIER ;identifier token
    || TokenType = CodeTokenTypes.LINE_END) ;line end token ;wip: identifiers should allow for the command syntax
 {
  MsgBox
  Return, "ERROR: Missing operator." ;wip: better error handling
 }
}

CodeParseOperatorLeftBindingPower(Token)
{
 global CodeOperatorTable
 If ObjHasKey(CodeOperatorTable.LeftDenotation,Token.Value)
  Return, CodeOperatorTable.LeftDenotation[Token.Value].LeftBindingPower
 Return, CodeOperatorTable.NullDenotation[Token.Value].LeftBindingPower
}

CodeParseOperatorNullDenotation(ByRef Tokens,ByRef Errors,Token)
{
 global CodeTreeTypes, CodeOperatorTable
 If !ObjHasKey(CodeOperatorTable.NullDenotation,Token.Value)
 {
  MsgBox
  Return, "ERROR: Invalid operator usage." ;wip: better error handling
 }
 Operator := CodeOperatorTable.NullDenotation[Token.Value] ;retrieve operator object
 Return, Operator.Handler.(Tokens,Errors,Operator) ;dispatch the null denotation handler for the operator ;wip: function reference call
}

CodeParseOperatorLeftDenotation(ByRef Tokens,ByRef Errors,Token,LeftSide)
{
 global CodeTokenTypes, CodeTreeTypes, CodeOperatorTable
 If !ObjHasKey(CodeOperatorTable.LeftDenotation,Token.Value)
 {
  MsgBox
  Return, "ERROR: Invalid operator usage." ;wip: better error handling
 }
 Operator := CodeOperatorTable.LeftDenotation[Token.Value] ;retrieve operator object
 Return, Operator.Handler.(Tokens,Errors,Operator,LeftSide) ;dispatch the left denotation handler for the operator ;wip: function reference call
}

CodeParseOperatorPrefix(ByRef Tokens,ByRef Errors,Operator)
{
 global CodeTreeTypes
 Return, [CodeTreeTypes.OPERATION
  ,[CodeTreeTypes.IDENTIFIER,Operator.Identifier]
  ,CodeParseExpression(Tokens,Errors,Operator.RightBindingPower)]
}

CodeParseOperatorInfix(ByRef Tokens,ByRef Errors,Operator,LeftSide)
{
 global CodeTreeTypes
 Return, [CodeTreeTypes.OPERATION
  ,[CodeTreeTypes.IDENTIFIER,Operator.Identifier]
  ,LeftSide
  ,CodeParseExpression(Tokens,Errors,Operator.RightBindingPower)]
}

CodeParseOperatorPostfix(ByRef Tokens,ByRef Errors,Operator,LeftSide)
{
 global CodeTreeTypes
 Return, [CodeTreeTypes.OPERATION
  ,[CodeTreeTypes.IDENTIFIER,Operator.Identifier]
  ,LeftSide]
}

;get the next token
CodeParseToken(ByRef Tokens,Offset = 1)
{
 static Index := 1
 If (Offset = "Reset") ;wip
 {
  Index := 1
  Return
 }
 If (Index > ObjMaxIndex(Tokens))
  Throw Exception("Token stream end.",-1)
 Result := Tokens[Index]
 Index += Offset
 Return, Result
}
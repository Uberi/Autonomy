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
;wip: nested ternary not supported

/*
#Include Resources\Functions.ahk
#Include Resources\Reconstruct.ahk
#Include Resources\Operators.ahk
#Include Code.ahk
#Include Lexer.ahk

SetBatchLines(-1)

;Code := "2 + 2 + 2"
;Code := "2 ** 3 ** 4"
;Code := "4 - (2 + 4) * -5"
;Code := "Object.Method(5 + 1,2 * 3) - 4"
;Code := "Length := StrLen(Data) << !!A_IsUnicode"
;Code := "Description := RegExReplace(SubStr(Page,1,InStr(Page,""<br"") - 1),""S)^[ \t]+|[ \t]+$"")"
;Code := "v := 1, (w := 2, (x := 3), y := 4), z := 5"
;Code := "Something ? SomethingDone + 1 : SomethingElse && 5"
Code := "OuterCondition ? InnerCondition ? InnerTrue : InnerFalse : OuterFalse"
;Code := "Something+++++Something1"

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
TimerAfter := 0, DllCall("QueryPerformanceCounter","Int64*",TimerAfter), TickFrequency := 0, DllCall("QueryPerformanceFrequency","Int64*",TickFrequency), TimerAfter := (TimerAfter - TimerBefore) / (TickFrequency / 1000)
MsgBox % TimerAfter . " ms`n`n" . Result . "`n`n" . CodeReconstructShowSyntaxTree(SyntaxTree)
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
 SyntaxTree := [CodeTreeTypes.OPERATION,[CodeTreeTypes.IDENTIFIER,"EVALUATE"]] ;wip: hardcoded string
 Loop ;loop through one subexpression at a time
 {
  ObjInsert(SyntaxTree,CodeParseExpression(Tokens,Errors))
  Try Token := CodeParseToken(Tokens)
  Catch ;end of token stream
   Break
  If (Token.Type != CodeTokenTypes.SEPARATOR)
   Break ;stop parsing subexpressions
 }
 If (ObjMaxIndex(SyntaxTree) = 3) ;there was only one expression
  SyntaxTree := SyntaxTree[3] ;remove the evaluate operation and directly return the result

 If (Index <= ObjMaxIndex(Tokens)) ;did not reach the end of the token stream ;wip
 {
  ;wip: better error handling
 }
 If (ErrorIndex = ObjMaxIndex(Errors))
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
 global CodeTokenTypes, CodeOperatorTable
 TokenType := Token.Type
 If (TokenType = CodeTokenTypes.OPERATOR) ;operator token
  Return, CodeParseOperatorLeftBindingPower(Token)
 If (TokenType = CodeTokenTypes.INTEGER || TokenType = CodeTokenTypes.DECIMAL || TokenType = CodeTokenTypes.STRING || TokenType = CodeTokenTypes.IDENTIFIER) ;literal token
  Return, 0
 If (TokenType = CodeTokenTypes.SEPARATOR) ;separator token
  Return, 0
 If (TokenType = CodeTokenTypes.GROUP_BEGIN) ;parenthesis token
  Return, CodeOperatorTable.LeftDenotation["("].LeftBindingPower ;wip: use identifiers for GROUP_BEGIN/GROUP_END
 If (TokenType = CodeTokenTypes.GROUP_END)
  Return, CodeOperatorTable.NullDenotation[")"].LeftBindingPower
}

;dispatches the invocation of the null denotation handler of a given token
CodeParseDispatchNullDenotation(ByRef Tokens,ByRef Errors,Token)
{
 global CodeTokenTypes, CodeTreeTypes
 TokenType := Token.Type
 If (TokenType = CodeTokenTypes.OPERATOR)
  Return, CodeParseOperatorNullDenotation(Tokens,Errors,Token)
 If (TokenType = CodeTokenTypes.INTEGER)
  Return, [CodeTreeTypes.INTEGER,Token.Value,Token.Position,Token.File]
 If (TokenType = CodeTokenTypes.DECIMAL)
  Return, [CodeTreeTypes.DECIMAL,Token.Value,Token.Position,Token.File]
 If (TokenType = CodeTokenTypes.STRING)
  Return, [CodeTreeTypes.STRING,Token.Value,Token.Position,Token.File]
 If (TokenType = CodeTokenTypes.IDENTIFIER)
  Return, [CodeTreeTypes.IDENTIFIER,Token.Value,Token.Position,Token.File]
 If (TokenType = CodeTokenTypes.GROUP_BEGIN)
  Return, CodeParseGroupNullDenotation(Tokens,Errors,Token)
 If (TokenType = CodeTokenTypes.GROUP_END)
 {
  MsgBox
  Return, "ERROR: Unmatched parenthesis" ;wip: better error handling
 }
}

;dispatches the invocation of the left denotation handler of a given token
CodeParseDispatchLeftDenotation(ByRef Tokens,ByRef Errors,Token,LeftSide)
{
 global CodeTokenTypes
 TokenType := Token.Type
 If (TokenType = CodeTokenTypes.OPERATOR)
  Return, CodeParseOperatorLeftDenotation(Tokens,Errors,Token,LeftSide)
 If (TokenType = CodeTokenTypes.INTEGER || TokenType = CodeTokenTypes.DECIMAL || TokenType = CodeTokenTypes.STRING || TokenType = CodeTokenTypes.IDENTIFIER) ;wip: identifiers should allow for the command syntax
 {
  MsgBox
  Return, "ERROR: Missing operator" ;wip: better error handling
 }
 If (TokenType = CodeTokenTypes.GROUP_BEGIN)
  Return, CodeParseGroupLeftDenotation(Tokens,Errors,Token,LeftSide)
 If (TokenType = CodeTokenTypes.GROUP_END)
 {
  MsgBox
  Return, "ERROR: Unmatched parenthesis" ;wip: better error handling
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
 Operator := CodeOperatorTable.NullDenotation[Token.Value]
 Return, [CodeTreeTypes.OPERATION
  ,[CodeTreeTypes.IDENTIFIER,Operator.Identifier]
  ,CodeParseExpression(Tokens,Errors,Operator.RightBindingPower)]
}

CodeParseOperatorLeftDenotation(ByRef Tokens,ByRef Errors,Token,LeftSide)
{
 global CodeTokenTypes, CodeTreeTypes, CodeOperatorTable
 Operator := CodeOperatorTable.LeftDenotation[Token.Value]

 If (Operator.Identifier = "TERNARY_IF") ;wip: literal string
 {
  FirstBranch := CodeParseExpression(Tokens,Errors,Operator.RightBindingPower) ;parse the first branch
  Token := CodeParseToken(Tokens,0)
  If !(Token.Type = CodeTokenTypes.OPERATOR && CodeOperatorTable.LeftDenotation[Token.Value].Identifier = "TERNARY_ELSE")
  {
   MsgBox
   Return, "ERROR: Ternary operator missing ELSE branch" ;wip: better error handling
  }
  CodeParseToken(Tokens)
  SecondBranch := CodeParseExpression(Tokens,Errors,Operator.RightBindingPower) ;parse the second branch
  Return, [CodeTreeTypes.OPERATION
   ,[CodeTreeTypes.IDENTIFIER,Operator.IDENTIFIER]
   ,LeftSide
   ,FirstBranch
   ,SecondBranch]
 }

 ;postfix operator
 If (Operator.RightBindingPower = -1)
  Return, [CodeTreeTypes.OPERATION
  ,[CodeTreeTypes.IDENTIFIER,Operator.Identifier]
  ,LeftSide]

 ;infix operator
 Return, [CodeTreeTypes.OPERATION
  ,[CodeTreeTypes.IDENTIFIER,Operator.Identifier]
  ,LeftSide
  ,CodeParseExpression(Tokens,Errors,Operator.RightBindingPower)]
}

CodeParseGroupNullDenotation(ByRef Tokens,ByRef Errors,Token)
{
 global CodeTokenTypes, CodeTreeTypes
 Result := [CodeTreeTypes.OPERATION,[CodeTreeTypes.IDENTIFIER,"EVALUATE"]] ;wip: hardcoded string
 Loop ;loop through one subexpression at a time
 {
  ObjInsert(Result,CodeParseExpression(Tokens,Errors))
  Try Token := CodeParseToken(Tokens) ;move past the separator token
  Catch ;end of token stream
   Break
  If (Token.Type != CodeTokenTypes.SEPARATOR)
   Break ;stop parsing subexpressions
 }
 If (ObjMaxIndex(Result) = 3) ;there was only one expression inside the parentheses
  Result := Result.3 ;remove the evaluate operation and directly return the result
 If (Token.Type != CodeTokenTypes.GROUP_END) ;mismatched parentheses
 {
  MsgBox
  Return, "ERROR: Unmatched parenthesis" ;wip: better error handling
 }
 Return, Result
}

CodeParseGroupLeftDenotation(ByRef Tokens,ByRef Errors,Token,LeftSide)
{
 global CodeTreeTypes, CodeTokenTypes
 Result := [CodeTreeTypes.OPERATION,LeftSide]
 Loop ;loop through one argument at a time
 {
  ObjInsert(Result,CodeParseExpression(Tokens,Errors)) ;parse the argument
  Try Token := CodeParseToken(Tokens)
  Catch ;end of token stream
   Break
  If (Token.Type != CodeTokenTypes.SEPARATOR) ;break the loop if there is no argument separator present
   Break ;stop parsing parameters
 }
 If (Token.Type != CodeTokenTypes.GROUP_END) ;mismatched parentheses
 {
  MsgBox
  Return, "ERROR: Unmatched parenthesis" ;wip: better error handling
 }
 Return, Result
}

;get the next token
CodeParseToken(ByRef Tokens,Offset = 1)
{
 static Index := 1
 If (Index > ObjMaxIndex(Tokens))
  Throw Exception("Token stream end.",-1)
 Result := Tokens[Index]
 Index += Offset
 Return, Result
}
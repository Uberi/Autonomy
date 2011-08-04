#NoEnv

/*
Syntax Tree Format
------------------

* _[Index]_:         the index of the tree node                                       _[Object]_
    * 1:             the operation to perform                                         _[String]_
    * _[1 + Index]_: the parameter or parameters of the operation                     _[Object]_
        * Type:      the type of the parameter (Object, String, Float, Integer, etc.) _[Identifier]_
        * Value:     the value of the parameter                                       _[String]_

Example
-------

(2 * 3) + 8 -> (+ (* 2 3) 8)

    1:
        Type: NODE ;type information
        Value: ;node value
            1:
                Type: OPERATOR
                Value: +
            2:
                Type: NODE
                Value: ;subnode
                    1:
                        Type: OPERATOR
                        Value: *
                    2:
                        Type: LITERAL_NUMBER
                        Value: 2
                    3:
                        Type: LITERAL_NUMBER
                        Value: 3
            3:
                Type: LITERAL_NUMBER
                Value: 8

Syntax Tree Types Enumeration
-----------------------------

* NODE:           0
* BLOCK:          1
* OPERATION:      2
* LITERAL_NUMBER: 3
* LITERAL_STRING: 4
*/

;wip: prefix globals
;wip: treat parentheses like an operator for the left binding power

;/*
#Include Resources\Functions.ahk
#Include Code.ahk
#Include Lexer.ahk

Code := "4-(2+4)*-5"

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

MsgBox % CodeParse(Tokens,SyntaxTree,Errors)
MsgBox % ShowObject(SyntaxTree)
*/

CodeParseInit()
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

;parses a token stream
CodeParse(ByRef Tokens,ByRef SyntaxTree,ByRef Errors)
{ ;returns 1 on parsing error, 0 otherwise
 ParserError := 0, Index := 1 ;initialize variables
 SyntaxTree := CodeParseExpression(Tokens,Errors,ParserError,Index)
 Return, ParserError
}

;parses an expression
CodeParseExpression(ByRef Tokens,ByRef Errors,ByRef ParserError,ByRef Index,RightBindingPower = 0)
{
 global Functions

 TokensLength := ObjMaxIndex(Tokens) ;retrieve the maximum index of the token stream
 If (Index > TokensLength)
  Return, "ERROR: Missing token." ;wip: better error handling
 CurrentToken := Tokens[Index], Index ++ ;retrieve the current token, move to the next token
 LeftSide := CodeParseDispatchNullDenotation(Tokens,Errors,Index,CurrentToken) ;handle the null denotation - the token does not require tokens to its left
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

;dispatches the invocation of the null denotation handler of a given token
CodeParseDispatchNullDenotation(ByRef Tokens,ByRef Errors,ByRef Index,Token)
{
 global CodeTokenTypes, Operators
 TokenType := Token.Type
 If (TokenType = CodeTokenTypes.OPERATOR)
  Return, Operators[Token.Value].NullDenotation(Tokens,Errors,Index)
 If (TokenType = CodeTokenTypes.LITERAL_NUMBER || TokenType = CodeTokenTypes.LITERAL_STRING)
  Return, Token
 If (TokenType = CodeTokenTypes.PARENTHESIS)
  Return, DispatchParenthesisNullDenotation(Tokens,Errors,Index,Token)
}

;dispatches the invocation of the left denotation handler of a given token
CodeParseDispatchLeftDenotation(ByRef Tokens,ByRef Errors,ByRef Index,Token,LeftSide)
{
 global CodeTokenTypes, Operators
 TokenType := Token.Type
 If (TokenType = CodeTokenTypes.OPERATOR)
  Return, Operators[Token.Value].LeftDenotation(Tokens,Errors,Index,LeftSide)
 If (TokenType = CodeTokenTypes.LITERAL_NUMBER || TokenType = CodeTokenTypes.LITERAL_STRING)
  Return, "ERROR: Missing operator" ;wip: better error handling
 If (TokenType = CodeTokenTypes.PARENTHESIS)
  Return, DispatchParenthesisLeftDenotation(Tokens,Errors,Index,Token,LeftSide)
}

DispatchParenthesisNullDenotation(ByRef Tokens,ByRef Errors,ByRef Index,Token)
{
 global CodeTokenTypes
 If (Token.Value = "(") ;left parenthesis
 {
  Result := CodeParseExpression(Tokens,Errors,ParserError,Index,0)
  CurrentToken := Tokens[Index]
  If (CurrentToken.Type = CodeTokenTypes.PARENTHESIS && CurrentToken.Value = ")") ;match a right parenthesis
  {
   Index ++
   Return, Result
  }
 }
 Return, "ERROR: Unmatched parenthesis" ;wip: better error handling
}

DispatchParenthesisLeftDenotation(ByRef Tokens,ByRef Errors,ByRef Index,Token,LeftSide)
{
 global CodeTokenTypes
 If (Token.Value = "(") ;left parenthesis
 {
  Result := CodeParseExpression(Tokens,SyntaxTree,Errors,ParserError,Index)
  CurrentToken := Tokens[Index]
  If (CurrentToken.Type = CodeTokenTypes.PARENTHESIS && CurrentToken.Value = ")") ;match a right parenthesis
  {
   Index ++
   Return, Object("Type",LeftSide.Value,"Value",Result)
  }
 }
 Return, "ERROR: Unmatched parenthesis" ;wip: better error handling
}

OperatorAdd(This,ByRef Tokens,ByRef Errors,ByRef Index,LeftSide)
{
 global CodeTokenTypes
 Return, Object("Type","ADD","Value",Array(LeftSide,CodeParseExpression(Tokens,Errors,ParserError,Index,10)))
}

OperatorUnarySubtract(This,ByRef Tokens,ByRef Errors,ByRef Index)
{
 global CodeTokenTypes
 Return, Object("Type","NEGATIVE","Value",Array(CodeParseExpression(Tokens,Errors,ParserError,Index,100)))
}

OperatorSubtract(This,ByRef Tokens,ByRef Errors,ByRef Index,LeftSide)
{
 global CodeTokenTypes
 Return, Object("Type","SUBTRACT","Value",Array(LeftSide,CodeParseExpression(Tokens,Errors,ParserError,Index,10)))
}

OperatorDereference(This,ByRef Tokens,ByRef Errors,ByRef Index)
{
 global CodeTokenTypes
 Return, Object("Type","DEREFERENCE","Value",Array(CodeParseExpression(Tokens,Errors,ParserError,Index,100)))
}

OperatorMultiply(This,ByRef Tokens,ByRef Errors,ByRef Index,LeftSide)
{
 global CodeTokenTypes
 Return, Object("Type","MULTIPLY","Value",Array(LeftSide,CodeParseExpression(Tokens,Errors,ParserError,Index,20)))
}
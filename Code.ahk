#NoEnv

/*
Basic AHK Grammar (EBNF as defined by [Wikipedia])
-----------------

    (* basic nonterminals *)
    Whitespace  = " " | "\t"

    (* fundemental types *)
    Digit       = '0' | '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9' ;
    DigitNumber = Digit , { Digit } ;
    HexDigit    = 'a' | 'b' | 'c' | 'd' | 'e' | 'f' | 'A' | 'B' | 'C' | 'D' | 'E' | 'F' | Digit ;
    Integer     = [ '+' | '-' ] , ( DigitNumber | ( '0x' , HexDigit , { HexDigit } ) ) ;
    Decimal     = [ '+' | '-' ] , ( ( Digit , { Digit } , '.' , { Digit } ) | ( '.' , Digit , { Digit } ) ) ;
    String      = '"' , { '""' | ? any character ? } , '"' ;
    AlNum       = 'a' | 'b' | 'c' | 'd' | 'e' | 'f' | 'g' | 'h' | 'i' | 'j' | 'k' | 'l' | 'm' | 'n' | 'o' | 'p' | 'q' | 'r' | 's' | 't' | 'u' | 'v' | 'w' | 'x' | 'y' | 'z' | 'A' | 'B' | 'C' | 'D' | 'E' | 'F' | 'G' | 'H' | 'I' | 'J' | 'K' | 'L' | 'M' | 'N' | 'O' | 'P' | 'Q' | 'R' | 'S' | 'T' | 'U' | 'V' | 'W' | 'X' | 'Y' | 'Z' | Digit | '_' ;
    Identifier  = AlNum , { AlNum } ;
    Operand     = Integer | Decimal | String | Identifier

    (* operators *)
    Prefix      = "!" | "~" | "&" | "*" | "++" | "--" ;
    Infix       = "||" | "&&" | "==" | "=" | "!=" | ">" | "<" | ">=" | "<=" | ( Whitespace , "." , Whitespace ) | "&" | "^" | "|" | "<<" | ">>" | "+" | "-" | "*" | "/" | "//" | "." | ":=" | "+=" | "-=" | "*=" | "/=" | "//=" | ".=" | "|=" | "&=" | "^=" | "<<=" | ">>=" | "**" ;
    Postfix     = "++" | "--"
    Dynamic     = [ Identifier ] , "%" , Identifier , "%" , [ Identifier ] , { "%" , Identifier , "%" , [ Identifier ] } ;

    (* expression components *)
    Padding     = [ { Whitespace } ]
    Operation   = ( Prefix , Padding , Operand ) | ( Operand , Padding , Infix , Padding , Operand ) | ( Operand , Padding , Postfix ) ;
    Expression  = Padding , Operation , Padding , { Operation , Padding }

Operator Table Format
---------------------

* _[Symbol]_:        the symbol representing the operator     _[Object]_
    * Precedence:    the operator's precendence               _[Integer]_
    * Associativity: the associativity of the operator        _[String: "L" or "R"]_
    * Arity:         the number of operands the operator uses _[Integer]_

Token Stream Format
-------------------

* _[Index]_:    the index of the token                         _[Object]_
    * Type:     the enumerated type of the token               _[Integer]_
    * Value:    the value of the token                         _[String]_
    * Position: position of token within the file              _[Integer]_
    * File:     the file index the current token is located in _[Integer]_

Example Token Stream
--------------------

    2:
        Type: 9
        Value: SomeVariable
        Position: 15
        File: 3

Token Types Enumeration
-----------

* OPERATOR:       0
* LITERAL_NUMBER: 1
* LITERAL_STRING: 2
* SEPARATOR:      3
* PARENTHESIS:    4
* OBJECT_BRACE:   5
* BLOCK_BRACE:    6
* LABEL:          7
* STATEMENT:      8
* IDENTIFIER:     9
* LINE_END:       10

[Wikipedia]: http://en.wikipedia.org/wiki/Extended_Backus-Naur_Form
*/

;initializes resources that will be required by other modules
CodeInit(ResourcesPath = "Resources")
{ ;returns 1 on failure, 0 otherwise
 global CodeOperatorTable, CodeErrorMessages, CodeTokenTypes
 If FileRead(Temp1,PathJoin(ResourcesPath,"OperatorTable.txt")) ;error reading file
  Return, 1

 ;parse operators table file into object
 CodeOperatorTable := Object()
 Loop, Parse, Temp1, `n, `r
  Line := StringSplit(A_LoopField,"`t"), ObjInsert(CodeOperatorTable,Line.1,Object("Precedence",Line.2,"Associativity",Line.3,"Arity",Line.4))

 If FileRead(Temp1,PathJoin(ResourcesPath,"Errors.txt")) ;error reading file
  Return, 1

 ;parse error message file into object, and enumerate error identifiers
 CodeErrorMessages := Object()
 Loop, Parse, Temp1, `n, `r
  Line := StringSplit(A_LoopField,"`t"), ObjInsert(CodeErrorMessages,Line.1,Line.2)

 ;set up token type enumeration
 CodeTokenTypes := Object("OPERATOR",0,"LITERAL_NUMBER",1,"LITERAL_STRING",2,"SEPARATOR",3,"PARENTHESIS",4,"OBJECT_BRACE",5,"BLOCK_BRACE",6,"LABEL",7,"STATEMENT",8,"IDENTIFIER",9,"LINE_END",10)

 Return, 0
}

;initializes or resets resources that are needed by other modules each time they work on a different input
CodeSetScript(ByRef Path = "",ByRef Errors = "",ByRef Files = "")
{
 If (Path != "")
  Files := Array(PathExpand(Path)) ;create an array to store the path of each script
 Errors := Array()
}

;records an error containing information about the nature, severity, and location of the issue
CodeRecordError(ByRef Errors,Identifier,Level,File,Caret = 0,CaretLength = 1,Highlight = 0)
{ ;wip: process caret length
 ErrorRecord := Object("Identifier",Identifier,"Level",Level,"Highlight",Highlight,"Caret",Object("Position",Caret,"Length",CaretLength),"File",File)
 ObjInsert(Errors,ErrorRecord) ;add an error to the error log
}

;an alternative, convenient way to record errors by passing tokens to the function instead of positions and lengths
CodeRecordErrorTokens(ByRef Errors,Identifier,Level,Caret = 0,Highlight = 0)
{
 If (Highlight != 0)
 {
  File := Highlight.1.File, ProcessedHighlight := Array()
  For Index, Token In Highlight
   ObjInsert(ProcessedHighlight,Object("Position",Token.Position,"Length",StrLen(Token.Value)))
 }
 Else
  ProcessedHighlight := 0
 If IsObject(Caret)
  File := Caret.File, Position := Caret.Position, Length := StrLen(Caret.Value)
 Else
  Position := 0, Length := 1
 CodeRecordError(Errors,Identifier,Level,File,Position,Length,ProcessedHighlight)
}
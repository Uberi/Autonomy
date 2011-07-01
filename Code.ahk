#NoEnv

/*
Syntax Element Table Format
---------------------------

[Operator]: [Object]
	- Precedence:    the operator's precendence               [Integer]
	- Associativity: the associativity of the operator        [String: "L" or "R"]
	- Arity:         the number of operands the operator uses [Integer]

Token Types Enumeration
-----------

- OPERATOR:       0
- LITERAL_NUMBER: 1
- LITERAL_STRING: 2
- SEPARATOR:      3
- PARENTHESIS:    4
- OBJECT_BRACE:   5
- BLOCK_BRACE:    6
- LABEL:          7
- STATEMENT:      8
- IDENTIFIER:     9
- LINE_END:       10
*/

;initializes resources that will be required by the code tools
CodeInit(ResourcesPath = "Resources")
{ ;returns 1 on failure, nothing otherwise
 global CodeOperatorTable, CodeErrorMessages, CodeTokenTypes

 ;ensure the path ends with a directory separator ;wip: not cross-platform
 If (SubStr(ResourcesPath,0) <> "\")
  ResourcesPath .= "\"

 If (FileRead(Temp1,ResourcesPath . "OperatorTable.txt") <> 0) ;error reading file
  Return, 1

 ;parse operators table file into object
 CodeOperatorTable := Object()
 Loop, Parse, Temp1, `n, `r
  Line := StringSplit(A_LoopField,"`t"), ObjInsert(CodeOperatorTable,Line.1,Object("Precedence",Line.2,"Associativity",Line.3,"Arity",Line.4))

 If (FileRead(Temp1,ResourcesPath . "Errors.txt") <> 0) ;error reading file
  Return, 1

 ;parse error message file into object, and enumerate error identifiers
 CodeErrorMessages := Object()
 Loop, Parse, Temp1, `n, `r
  Line := StringSplit(A_LoopField,"`t"), ObjInsert(CodeErrorMessages,Line.1,Line.2)

 ;set up token type enumeration
 Temp1 := "OPERATOR|LITERAL_NUMBER|LITERAL_STRING|SEPARATOR|PARENTHESIS|OBJECT_BRACE|BLOCK_BRACE|LABEL|STATEMENT|IDENTIFIER|LINE_END"
 CodeTokenTypes := Object(), Index := 0
 Loop, Parse, Temp1, |
  ObjInsert(CodeTokenTypes,A_LoopField,Index), Index ++
}
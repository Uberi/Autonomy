#NoEnv

#Include Resources\Functions.ahk

/*
Syntax Element Table Format
---------------------------

For Each Operator:
	- Operator Symbol
	- Precendence
	- Associativity
	- Arity
*/

;initializes resources that will be required by the code tools
CodeInit(ResourcesPath = "Resources")
{ ;returns 1 on failure, nothing otherwise
 global CodeOperatorTable, CodeErrorMessages

 ;ensure the path ends with a directory separator
 If (SubStr(ResourcesPath,0) <> "\")
  ResourcesPath .= "\"

 If (FileRead(Temp1,ResourcesPath . "OperatorTable.txt") <> 0) ;error reading file
  Return, 1

 ;parse file into object
 CodeOperatorTable := Object()
 Loop, Parse, Temp1, `n, `r
  Line := StringSplit(A_LoopField,"`t"), ObjInsert(CodeOperatorTable,Line.1,Object("Precedence",Line.2,"Associativity",Line.3,"Arity",Line.4))

 If (FileRead(Temp1,ResourcesPath . "Errors.txt") <> 0) ;error reading file
  Return, 1

 ;parse file into object
 CodeErrorMessages := Object()
 Loop, Parse, Temp1, `n, `r
  Line := StringSplit(A_LoopField,"`t"), ObjInsert(CodeErrorMessages,Line.1,Line.2)
}
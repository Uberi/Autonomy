#NoEnv

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
CodeInit(OperatorTableFile = "Resources\OperatorTable.txt")
{
 global CodeOperatorTable

 If (FileRead(Temp1,OperatorTableFile) <> 0) ;error reading file
  Return, 1

 CodeOperatorTable := Object()
 Loop, Parse, Temp1, `n, `r
  Line := StringSplit(A_LoopField,"`t"), ObjInsert(CodeOperatorTable,Line.1,Object("Precedence",Line.2,"Associativity",Line.3,"Arity",Line.4))
}
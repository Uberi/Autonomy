#NoEnv

;initializes resources that will be required by the code tools
CodeInit()
{
 global OperatorTable

 OperatorTableFile := "OperatorTable.txt"

 If (FileRead(Temp1,OperatorTableFile) <> 0) ;error reading file
  Return, 1

 OperatorTable := Object()
 Loop, Parse, Temp1, `n
  Line := StringSplit(A_LoopField,"\"), ObjInsert(OperatorTable,Line.1,Object("Precedence",Line.2,"Associativity",Line.3,"ArgumentCount",Line.4))
 MsgBox % ShowObject(OperatorTable)
}
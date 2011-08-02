#NoEnv

;wip: see if dynamic labels can be faster

;initializes resources that the interpreter requires
CodeInterpretInit()
{
 global CodeInterpreterJumpTable, CodeInterpreterNamespace
 Index := 0, CodeInterpreterJumpTable := Array()
 Loop, 255
  ObjInsert(CodeInterpreterJumpTable,Index,Func("CodeInterpretInstruction" . Index)), Index ++ ;store a function reference for each instruction

 CodeInterpreterNamespace := Object() ;namespace to store variables in
}

;interprets bytecode given as input
CodeInterpret(ByRef Bytecode,Length)
{
 global CodeInterpreterJumpTable
 Index := 0
 While, (Index < Length)
 {
  ;Instruction := NumGet(Bytecode,Index,"UChar"), Index ++ ;retrieve and move past the bytecode instruction
  Instruction := *(&Bytecode + Index), Index ++ ;retrieve and move past the bytecode instruction
  CodeInterpreterJumpTable[Instruction]() ;call the function reference stored for the current instruction
 }
}

CodeInterpretInstruction0()
{
 MsgBox 0
}

CodeInterpretInstruction1()
{
 MsgBox 1
}

CodeInterpretInstruction2()
{
 MsgBox 2
}

CodeInterpretInstruction3()
{
 MsgBox 3
}

CodeInterpretInstruction4()
{
 MsgBox 4
}
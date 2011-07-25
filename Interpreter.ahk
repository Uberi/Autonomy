#NoEnv

;initializes resources that the interpreter requires
CodeInterpretInit()
{
 global InterpreterJumpTable, InterpreterNamespace
 Index := 0, InterpreterJumpTable := Array()
 Loop, 255
  ObjInsert(InterpreterJumpTable,Index,Func("CodeInterpretInstruction" . Index)), Index ++ ;store a function reference for each instruction

 InterpreterNamespace := Object() ;namespace to store variables in
}

;interprets bytecode given as input
CodeInterpret(ByRef Bytecode,Length)
{
 global InterpreterJumpTable
 Index := 0
 While, (Index < Length)
 {
  ;Instruction := NumGet(Bytecode,Index,"UChar"), Index ++ ;retrieve and move past the bytecode instruction
  Instruction := *(&Bytecode + Index), Index ++ ;retrieve and move past the bytecode instruction
  InterpreterJumpTable[Instruction]() ;call the function reference stored for the current instruction ;wip: function reference call is AHK_L only - not available in the self hosting version
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
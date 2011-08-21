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

;wip: see if dynamic labels can be faster

;initializes resources that the interpreter requires
CodeInterpretInit()
{
 global CodeInterpreterJumpTable
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
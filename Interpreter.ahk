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

;initializes resources that the interpreter requires
CodeInterpretInit()
{
 global CodeInterpreterJumpTable, CodeInterpreterStack
 Index := 0, CodeInterpreterJumpTable := []
 CodeInterpreterJumpTable := [Func("CodeInterpretPush")
                             ,Func("CodeInterpretPop")
                             ,Func("CodeInterpretCall")
                             ,Func("CodeInterpretStackReturn")
                             ,Func("CodeInterpretJump")
                             ,Func("CodeInterpretConditional")]

 CodeInterpreterStack := []
}

;interprets bytecode given as input
CodeInterpret(ByRef Bytecode,Length)
{
 global CodeInterpreterJumpTable
 pBytecode := &Bytecode
 While, (Index < Length)
 {
  Instruction := NumGet(pBytecode + 0,0,"UChar"), pBytecode ++ ;retrieve and move past the bytecode instruction
  CodeInterpreterJumpTable[Instruction]() ;call the function reference stored for the current instruction
 }
}

;stack push
CodeInterpretPush(Value)
{
 global CodeInterpreterStack
 ObjInsert(CodeInterpreterStack,Value)
}

;stack pop
CodeInterpretPop()
{
 global CodeInterpreterStack
 ObjRemove(CodeInterpreterStack)
}

;subroutine call
CodeInterpretCall()
{
 MsgBox Call
}

;subroutine return
CodeInterpretReturn()
{
 
}

;unconditional jump
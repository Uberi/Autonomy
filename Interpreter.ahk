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

/*
#Include Resources/Functions.ahk

Code =
(
1
2
3
4
)
Bytecode := "", Length := 0
Loop, Parse, Code, `n
    Bytecode .= Chr(A_LoopField), Length ++
CodeInterpretInit()
CodeInterpret(Bytecode,Length)
*/

;initializes resources that the interpreter requires
CodeInterpretInit()
{
    global CodeInterpreterJumpTable
    Index := 0, CodeInterpreterJumpTable := []
    CodeInterpreterJumpTable := [Func("CodeInterpretPush")
                                ,Func("CodeInterpretPop")
                                ,Func("CodeInterpretCall")
                                ,Func("CodeInterpretStackReturn")
                                ,Func("CodeInterpretJump")
                                ,Func("CodeInterpretConditional")]
}

;interprets bytecode given as input
CodeInterpret(ByRef Bytecode,Length)
{
    global CodeInterpreterJumpTable
    Stack := [] ;initialize the stack
    Index := 0
    While, (Index < Length)
    {
        Instruction := NumGet(Bytecode,Index,"UChar"), Index ++ ;retrieve and move past the bytecode instruction
        CodeInterpreterJumpTable[Instruction](Stack,Index) ;call the function reference stored for the current instruction
    }
}

;stack push
CodeInterpretPush(This,Stack,ByRef Index,Value)
{
    ObjInsert(Stack,Value)
}

;stack pop
CodeInterpretPop(This,Stack,ByRef Index)
{
    ObjRemove(Stack)
}

;subroutine call
CodeInterpretCall(This,Stack,ByRef Index)
{
    JumpTarget := ObjRemove(Stack) ;pop the jump target off of the stack and store it it
    ObjInsert(Stack,StackBase) ;push the stack base onto the stack ;wip: stack base variable
    ObjInsert(Stack,Index) ;push the instruction index onto the stack
    Index := JumpTarget ;jump to the stored jump target
}

;subroutine return
CodeInterpretReturn(This,Stack,ByRef Index)
{
    ReturnValue := ObjRemove(Stack) ;pop the return value off of the stack and store it
    Loop, % ObjRemove(Stack) ;pop the parameter count off of the stack and iterate the correct number of times
        ObjRemove(Stack) ;remove a parameter from the stack
    Index := ObjRemove(Stack) ;pop the jump target off of the stack and jump to it
    StackBase := ObjRemove(Stack) ;pop the stack base off of the stack and restore it ;wip: stack base variable
    ObjInsert(Stack,ReturnValue) ;push the return value back onto the stack
}

;unconditional jump
CodeInterpretJump(This,Stack,ByRef Index)
{
    Index := ObjRemove(Stack) ;pop the jump target off of the stack and jump to it
}

;conditional jump
CodeInterpretConditional(This,Stack,ByRef Index)
{
    If ObjRemove(Stack) ;pop the test condition off of the stack and test it
        Index := ObjRemove(Stack) ;pop the jump target off of the stack and store it
    Else
        ObjRemove(Stack) ;pop the jump target off of the stack
}
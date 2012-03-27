#NoEnv

#Include Code.ahk

/*
Copyright 2011-2012 Anthony Zhang <azhang9@gmail.com>

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

;/*
#Include Resources\Reconstruct.ahk
#Include Lexer.ahk
#Include Parser.ahk
#Include Bytecode.ahk

SetBatchLines, -1

Code := "2*{3}*4"

If CodeInit()
{
    Display("Error initializing code tools.`n") ;display error at standard output
    ExitApp ;fatal error
}

FileName := A_ScriptFullPath
CodeSetScript(FileName,Errors,Files) ;set the current script file

CodeTreeInit()

CodeLexInit()
Tokens := CodeLex(Code,Errors)

SyntaxTree := CodeParse(Tokens,Errors)

CodeBytecodeInit()
Bytecode := CodeBytecode(SyntaxTree)

FlowGraph := CodeFlow(Bytecode,Errors)
MsgBox % Bytecode . "`n" . ShowObject(FlowGraph)
ExitApp
*/

CodeFlow(ByRef Bytecode,ByRef Errors)
{
    SymbolTable := Object() ;wip: not sure if this is needed
    FlowGraph := [], Index := 0, CurrentBlock := ""
    Loop, Parse, Bytecode, `n, %A_Space%%A_Tab%
    {
        ;parse bytecode line
        If SubStr(A_LoopField,1,1) = ":" ;line is a label definition
        {
            Index ++, ObjInsert(FlowGraph,Index,CurrentBlock)
            CurrentBlock := ""
        }
        Else ;line is an instruction
        {
            Temp1 := InStr(A_LoopField," ")
            If Temp1
                Instruction := SubStr(A_LoopField,1,Temp1 - 1), Parameter := SubStr(A_LoopField,Temp1 + 1)
            Else
                Instruction := A_LoopField, Parameter := ""

            CurrentBlock .= A_LoopField . "`n"
        }
    }
    Index ++, ObjInsert(FlowGraph,Index,CurrentBlock)
    Return, FlowGraph
}
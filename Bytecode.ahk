#NoEnv

#Include Code.ahk

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
Bytecode format
---------------

;wip: when processing different types, preconvert the smaller type to the common-denominator type at compile time. for example, if a variable was originally detected to be in a Short range, but was then added to a Long, declare the variable as a long instead of a short to avoid conversion
;wip: static tail call detection
;wip: distinct Array type using contiguous memory, faster than Object hash table implementation
;wip: dead/unreachable code elimination
*/

;/*
#Include Resources\Reconstruct.ahk
#Include Lexer.ahk
#Include Parser.ahk

SetBatchLines, -1

Code = 
(
1+2*3 . "hello"
)

If CodeInit()
{
 Display("Error initializing code tools.`n") ;display error at standard output
 ExitApp ;fatal error
}

FileName := A_ScriptFullPath
CodeSetScript(FileName,Errors,Files) ;set the current script file

CodeLexInit()
CodeLex(Code,Tokens,Errors)

CodeParseInit()
Result := CodeParse(Tokens,SyntaxTree,Errors)

CodeBytecodeInit()
MsgBox % Clipboard := CodeBytecode(SyntaxTree)
ExitApp
*/

CodeBytecodeInit()
{
 global FreeRegisters, UsedRegisters
 ;FreeRegisters := ["%edi","%esi","%edx","%ecx","%ebx"] ;wip: debug
 FreeRegisters := []
 UsedRegisters := []
}

CodeBytecode(SyntaxTree)
{
 global CodeTreeTypes
 NodeType := SyntaxTree[1]
 If (NodeType = CodeTreeTypes.OPERATION)
  Return, CodeBytecodeOperation(SyntaxTree)
 Else If (NodeType = CodeTreeTypes.NUMBER)
  Return, CodeBytecodeStackPush(SyntaxTree[2])
 Else If (NodeType = CodeTreeTypes.STRING)
  Return, CodeBytecodeStackPush("'" . SyntaxTree[2] . "'")
 Else If (NodeType = CodeTreeTypes.IDENTIFIER)
  Return, CodeBytecodeStackPush("IDENTIFIER:" . SyntaxTree[2])
 Else If (NodeType = CodeTreeTypes.BLOCK)
 {
  Index := ObjMaxIndex(SyntaxTree)
  Result := CodeBytecodeStackPush("BLOCK()")
  While, Index > 1
  {
   Result .= CodeBytecode(SyntaxTree[Index])
   Index --
  }
  Result .= CodeBytecodeStackPop()
  Result .= CodeBytecode(SyntaxTree[2])
  Return, Result . CodeBytecodeStackCall("%eax")
 }
}

CodeBytecodeOperation(SyntaxTree)
{
 Index := ObjMaxIndex(SyntaxTree)
 Result := ""
 While, Index > 1
 {
  Result .= CodeBytecode(SyntaxTree[Index])
  Index --
 }
 Result .= CodeBytecodeStackCall("%eax")
 Index := ObjMaxIndex(SyntaxTree)
 Result .= "add %esp " . ((Index - 1) * 4) . "`n" ;size of all parameters ;wip: does not work with register allocator
 While, Index > 1
 {
  CodeBytecodeStackPop()
  Index --
 }
 Return, Result . CodeBytecodeStackPush("%eax")
}

CodeBytecodeStackPush(Value)
{
 global FreeRegisters, UsedRegisters
 Index := ObjMaxIndex(FreeRegisters)
 If (Index = "")
  Return, "push " . Value . "`n"
 Register := ObjRemove(FreeRegisters,Index)
 ObjInsert(UsedRegisters,Register) ;move the register into the used register list
 Return, "mov " . Register . "," . Value . "`n"
}

CodeBytecodeStackPop(Register = "")
{
 global FreeRegisters, UsedRegisters
 Index := ObjMaxIndex(UsedRegisters)
 If (Index = "")
  Return, "pop " . Register . "`n"
 SourceRegister := ObjRemove(UsedRegisters,Index)
 ObjInsert(FreeRegisters,SourceRegister) ;move the register into the free register list
 If (Register = "")
  Return, "xor " . SourceRegister . "," . SourceRegister . "`n"
 Return, "mov " . Register . "," . SourceRegister . "`n"
}

CodeBytecodeStackCall(Register)
{
 global FreeRegisters, UsedRegisters
 Index := ObjMaxIndex(UsedRegisters)
 If (Index = "")
  Return, "call [%esp]`n"
 Return, "call [" . UsedRegisters[Index] . "]`n"
}

CodeBytecodeSymbol(Prefix)
{
 static UsedSymbols := Object()
 If !ObjHasKey(UsedSymbols,Prefix)
  UsedSymbols[Prefix] := 0
 UsedSymbols[Prefix] ++
 Return, Prefix . UsedSymbols[Prefix]
}

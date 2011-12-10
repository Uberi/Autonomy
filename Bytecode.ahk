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

Stack based virtual machine implementing a few simple instructions

push value                     pushes a value onto the stack.

pop                            pops a value off of the stack.

call                           pops and stores the jump target.
                               pushes the current stack base onto the stack.
                               pushes the current instruction pointer onto the stack.
                               jumps to the stored jump target.

return                         pops and stores the return value.
                               pops the parameter count off of the stack.
                               pops the correct number of parameters off of the stack.
                               pushes the return value back onto the stack.
                               pops and jumps to the instruction pointer.
                               pops and restores the stack base.

jump                           pops and jumps to the jump target.

conditional                    pops a value off of the stack.
                               pops and stores the potential jump target.
                               jumps to the provided identifier if the value is truthy.

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
 
}

CodeBytecode(SyntaxTree)
{
 global CodeTreeTypes
 NodeType := SyntaxTree[1]
 If (NodeType = CodeTreeTypes.OPERATION)
  Return, CodeBytecodeOperation(SyntaxTree)
 Else If (NodeType = CodeTreeTypes.NUMBER)
  Return, "push #" . SyntaxTree[2] . "`n"
 Else If (NodeType = CodeTreeTypes.STRING)
  Return, "push '" . SyntaxTree[2] . "'`n"
 Else If (NodeType = CodeTreeTypes.IDENTIFIER)
  Return, "push :" . SyntaxTree[2] . "`n"
 Else If (NodeType = CodeTreeTypes.BLOCK)
 {
  Index := ObjMaxIndex(SyntaxTree)
  Result := "push BLOCK()`n"
  While, Index > 1
  {
   Result .= CodeBytecode(SyntaxTree[Index])
   Index --
  }
  Result .= CodeBytecode(SyntaxTree[2])
  Return, Result . "call`n"
 }
}

CodeBytecodeOperation(SyntaxTree)
{
 Index := ObjMaxIndex(SyntaxTree)
 Result := ""
 While, Index > 1
  Result .= CodeBytecode(SyntaxTree[Index]), Index --
 Result .= "call`n"
 Return, Result
}
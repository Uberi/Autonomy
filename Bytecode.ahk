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
Bytecode format
---------------

;wip: when processing different types, preconvert the smaller type to the common-denominator type at compile time. for example, if a variable was originally detected to be in a Short range, but was then added to a Long, declare the variable as a long instead of a short to avoid conversion
;wip: static tail call detection
;wip: distinct Array type using contiguous memory, faster than Object hash table implementation
;wip: http://www.llvm.org/docs/LangRef.html
*/

#Include Resources\Functions.ahk
#Include Resources\Reconstruct.ahk
#Include Resources\Operators.ahk
#Include Code.ahk
#Include Lexer.ahk
#Include Parser.ahk

SetBatchLines(-1)

Code = 
(
Something + 1
)

If CodeInit()
{
 Display("Error initializing code tools.`n") ;display error at standard output
 ExitApp(1) ;fatal error
}

FileName := A_ScriptFullPath
CodeSetScript(FileName,Errors,Files) ;set the current script file

CodeLexInit()
CodeLex(Code,Tokens,Errors)

CodeParseInit()
Result := CodeParse(Tokens,SyntaxTree,Errors)

MsgBox % Clipboard := CodeBytecode(SyntaxTree)
ExitApp()

CodeBytecode(SyntaxTree)
{
 global CodeTreeTypes
 NodeType := SyntaxTree[1]
 If (NodeType = CodeTreeTypes.OPERATION)
 {
  Index := ObjMaxIndex(SyntaxTree), Result := ""
  Loop, %Index%
  {
   Result .= CodeBytecode(SyntaxTree[Index])
   Index --
  }
  Return, Result . "POP REGISTER`nCALL REGISTER`n"
 }
 Else If (NodeType = CodeTreeTypes.INTEGER)
  Return, "PUSH INTEGER(" . SyntaxTree[2] . ")`n"
 Else If (NodeType = CodeTreeTypes.DECIMAL)
  Return, "PUSH DECIMAL(" . SyntaxTree[2] . ")`n"
 Else If (NodeType = CodeTreeTypes.STRING)
  Return, "PUSH STRING(" . SyntaxTree[2] . ")`n"
 Else If (NodeType = CodeTreeTypes.IDENTIFIER)
  Return, "PUSH IDENTIFIER(" . SyntaxTree[2] . ")`n"
}
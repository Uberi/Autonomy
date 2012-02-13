#NoEnv

#Include Code.ahk
#Include Resources\Syntax Tree.ahk

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

Stack based virtual machine implementing a few simple instructions:

push value                      pushes a value onto the stack.

call paramcount                 pops and stores the jump target.
                                pushes the parameter count onto the stack.
                                pushes the current stack base onto the stack.
                                pushes the current instruction index onto the stack.
                                jumps to the stored jump target.

return                          pops the return value off of the stack and stores it.
                                pops the intruction index off of the stack and stores it.
                                pops the stack base off of the stack and stores it.
                                pops the parameter count off of the stack.
                                pops the parameters off of the stack.
                                jumps to the stored instruction index.
                                sets the stack base to the stored stack base.
                                pushes the return value back onto the stack.

jump                            pops the jump target off of the stack.
                                jumps to the stored jump target.

conditional                     pops the value off of the stack and stores it.
                                pops the potential jump target off of the stack and stores it.
                                jumps to the stored potential jump target if the stored value is truthy.

;wip: generated identifiers are not always unique
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
MsgBox % Clipboard := CodeBytecode(SyntaxTree)
ExitApp
*/

CodeBytecodeInit()
{
    
}

CodeBytecode(SyntaxTree,Padding = "")
{
    global CodeTreeTypes
    NodeType := SyntaxTree[1]
    If (NodeType = CodeTreeTypes.OPERATION)
        Return, CodeBytecodeOperation(SyntaxTree,Padding)
    Else If (NodeType = CodeTreeTypes.NUMBER)
        Return, Padding . "push #" . SyntaxTree[2] . "`n"
    Else If (NodeType = CodeTreeTypes.STRING)
    {
        Result := SyntaxTree[2]
        StringReplace, Result, Result, ``, ````, All
        StringReplace, Result, Result, ', ``', All
        Return, Padding . "push '" . Result . "'`n"
    }
    Else If (NodeType = CodeTreeTypes.IDENTIFIER)
        Return, Padding . "push $" . SyntaxTree[2] . "`n"
    Else If (NodeType = CodeTreeTypes.BLOCK)
        Return, CodeBytecodeBlock(SyntaxTree,Padding)
}

CodeBytecodeOperation(SyntaxTree,Padding)
{
    MaxIndex := ObjMaxIndex(SyntaxTree), Index := MaxIndex
    Result := ""
    While, Index > 1
        Result .= CodeBytecode(SyntaxTree[Index],Padding . "`t"), Index --
    Result .= Padding . "call " . (MaxIndex - 2) . "`n"
    Return, Result
}

CodeBytecodeBlock(SyntaxTree,Padding)
{
    Index := ObjMaxIndex(SyntaxTree)
    Symbol1 := ":label" . StrLen(Padding) . "_1"
    Symbol2 := ":label" . StrLen(Padding) . "_2"
    Result := Padding . "push " . Symbol2 . "`n" . Padding . "jump`n" . Padding . Symbol1 . "`n"
    While, Index > 1
    {
        Result .= CodeBytecode(SyntaxTree[Index],Padding . "`t")
        Index --
    }
    Return, Result . Padding . Symbol2 . "`n"
}
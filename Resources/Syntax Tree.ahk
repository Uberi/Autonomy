#NoEnv

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

CodeTreeInit()
{
    global CodeTreeTypes
    ;set up syntax tree type enumeration
    CodeTreeTypes := Object("OPERATION",  0
                           ,"IDENTIFIER", 1
                           ,"NUMBER",     2
                           ,"STRING",     3
                           ,"BLOCK",      4)
}

CodeTreeOperation(Operation,Operands = "",Position = 0,File = 0) ;wip: position/file info
{
    global CodeTreeTypes
    Result := [CodeTreeTypes.OPERATION,Operation]
    If (Operands = "") ;wip: should just directly use dynamic default value
        Return, Result
    For Index, Operand In Operands
        ObjInsert(Result,Operand)
    Return, Result
}

CodeTreeGroup(Operands,Position = 0,File = 0)
{
    Return, CodeTreeOperation(CodeTreeIdentifier("EVALUATE"),Operands,Position,File)
}

CodeTreeIdentifier(Value,Position = 0,File = 0)
{
    global CodeTreeTypes
    Return, [CodeTreeTypes.IDENTIFIER,Value,Position,File]
}

CodeTreeNumber(Value,Position = 0,File = 0)
{
    global CodeTreeTypes
    Return, [CodeTreeTypes.NUMBER,Value,Position,File]
}

CodeTreeString(Value,Position = 0,File = 0)
{
    global CodeTreeTypes
    Return, [CodeTreeTypes.STRING,Value,Position,File]
}

CodeTreeBlock(Values = "",Position = 0,File = 0) ;wip: position/file info
{
    global CodeTreeTypes
    Result := [CodeTreeTypes.BLOCK]
    If (Values = "") ;wip: should just directly use dynamic default value
        Return, Result
    For Index, Value In Values
        ObjInsert(Result,Value)
    Return, Result
}
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
Operator Table Format
---------------------

* _[Symbol]_:            symbol representing the operator _[Object]_
    * LeftBindingPower:  left token binding power         _[Integer]_
    * RightBindingPower: right token binding power        _[String: "L" or "R"]_
    * Identifier:        identifier of the operator       _[Integer]_

Token Stream Format
-------------------

* _[Index]_:    index of the token                         _[Object]_
    * Type:     enumerated type of the token               _[Integer]_
    * Value:    value of the token                         _[String]_
    * Position: position of token within the file          _[Integer]_
    * File:     file index the current token is located in _[Integer]_

Example Token Stream
--------------------

    2:
        Type: 9
        Value: SomeVariable
        Position: 15
        File: 3

Syntax Tree Format
------------------

* _[Index]_:            index of the tree node                                       _[Object]_
    * 1:                type of the tree node                                        _[Integer]_
    * 2:                the operation to perform, if applicable                      _[Object]_
        * _[Subtree]_:  a subtree resulting in an operation identifer                _[Object]_
    * _[2 + Index]_:    parameter or parameters of the operation                     _[Object]_
        * 1:            type of the parameter                                        _[Integer]_
        * 2:            value of the parameter                                       _[Object or String]_

Example
-------

(2 * 3.1) + 8 -> (+ (* 2 3) 8)

    1: 2
    2:
        1: 6
        2: +
    3:
        1: 2
        2: 
            1: 6
            2: *
        3:
            1: 3
            2: 2
        4:
            1: 4
            2: 3.1
    4:
        1: 3
        2: 8

[Wikipedia]: http://en.wikipedia.org/wiki/Extended_Backus-Naur_Form
*/

;initializes resources that will be required by other modules
CodeInit(ResourcesPath = "Resources")
{ ;returns 1 on failure, 0 otherwise
 global CodeOperatorTable, CodeErrorMessages, CodeTokenTypes, CodeTreeTypes
 If FileRead(Temp1,PathJoin(ResourcesPath,"OperatorTable.txt")) ;error reading file
  Return, 1

 ;parse operators table file into object
 CodeOperatorTable := Object("NullDenotation",Object(),"LeftDenotation",Object())
 Loop, Parse, Temp1, `n, `r
 {
  Line := StringSplit(A_LoopField,"`t")
  CodeOperatorTable[(Line.2 = 0) ? "NullDenotation" : "LeftDenotation"][Line.1] := Object("LeftBindingPower",Line.2,"RightBindingPower",Line.3,"Identifier",Line.4)
 }

 If FileRead(Temp1,PathJoin(ResourcesPath,"Errors.txt")) ;error reading file
  Return, 1

 ;parse error message file into object, and enumerate error identifiers
 CodeErrorMessages := Object()
 Loop, Parse, Temp1, `n, `r
  Line := StringSplit(A_LoopField,"`t"), ObjInsert(CodeErrorMessages,Line.1,Line.2)

 ;set up token stream type enumeration
 CodeTokenTypes := Object("OPERATOR",0
  ,"INTEGER",1
  ,"DECIMAL",2
  ,"STRING",3
  ,"IDENTIFIER",4
  ,"SEPARATOR",5
  ,"GROUP_BEGIN",6
  ,"GROUP_END",7
  ,"OBJECT_BEGIN",8
  ,"OBJECT_END",9
  ,"BLOCK_BEGIN",10
  ,"BLOCK_END",11
  ,"STATEMENT",12
  ,"LABEL",13
  ,"LINE_END",14)

 ;set up syntax tree type enumeration
 CodeTreeTypes := Object("OPERATION",0
  ,"INTEGER",1
  ,"DECIMAL",2
  ,"STRING",3
  ,"IDENTIFIER",4
  ,"BLOCK",5
  ,"LABEL",6)

 Return, 0
}

;initializes or resets resources that are needed by other modules each time they work on a different input
CodeSetScript(ByRef Path = "",ByRef Errors = "",ByRef Files = "")
{
 If (Path != "")
  Files := Array(PathExpand(Path)) ;create an array to store the path of each script
 Errors := Array()
}

;records an error containing information about the nature, severity, and location of the issue
CodeRecordError(ByRef Errors,Identifier,Level,File,Caret = 0,CaretLength = 1,Highlight = 0)
{
 ErrorRecord := Object("Identifier",Identifier,"Level",Level,"Highlight",Highlight,"Caret",Object("Position",Caret,"Length",CaretLength),"File",File)
 ObjInsert(Errors,ErrorRecord) ;add an error to the error log
}

;an alternative, convenient way to record errors by passing tokens to the function instead of positions and lengths
CodeRecordErrorTokens(ByRef Errors,Identifier,Level,Caret = 0,Highlight = 0)
{
 If (Highlight != 0)
 {
  File := Highlight.1.File, ProcessedHighlight := Array()
  For Index, Token In Highlight
   ObjInsert(ProcessedHighlight,Object("Position",Token.Position,"Length",StrLen(Token.Value)))
 }
 Else
  ProcessedHighlight := 0
 If IsObject(Caret)
  File := Caret.File, Position := Caret.Position, Length := StrLen(Caret.Value)
 Else
  Position := 0, Length := 1
 CodeRecordError(Errors,Identifier,Level,File,Position,Length,ProcessedHighlight)
}
#NoEnv

#Include Resources/Functions.ahk

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

class Code
{
    static Operators := Code.CreateOperatorTable()

    __New(Text)
    {
        this.Lexer := new Code.Lexer(Text) ;wip: text could potentially be quite large
        this.Parser := new Code.Parser(this.Lexer)
    }

    #Include Lexer.ahk
    #Include Parser.ahk

    #Include Resources/Operators.ahk
}

MsgBox % ShowObject(Code)
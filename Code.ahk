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

* _[Symbol]_:            symbol representing the operator _[String]_
    * LeftBindingPower:  left token binding power         _[Integer]_
    * RightBindingPower: right token binding power        _[Integer]_
    * Identifier:        identifier of the operator       _[String]_

Token Stream Format
-------------------

* _[Index]_:    index of the token                    _[Integer]_
    * Type:     enumerated type of the token          _[String]_
    * Value:    value of the token                    _[String or Object]_
    * Position: position of the token within the file _[Integer]_
    * Length:   length of the token                   _[Integer]_

Example Token Stream
--------------------

    2:
        Type: "Identifier"
        Value: SomeVariable
        Position: 15
        Length: 12

Syntax Tree Format
------------------

* _[Index]_:            index of the tree node                        _[Object]_
    * 1:                type of the tree node                         _[String]_
    * 2:                the operation to perform, if applicable       _[Object]_
        * _[Subtree]_:  a subtree resulting in an operation identifer _[Object]_
    * _[2 + Index]_:    parameter or parameters of the operation      _[Object]_
        * 1:            type of the parameter                         _[String]_
        * 2:            value of the parameter                        _[Object or String]_

Example
-------

(2 * 3.1) + 8 -> (+ (* 2 3) 8)

    ["Operation",
        ["Identifier", "+"],
        ["Operation",
            ["Identifier", "*"],
            ["Number", 2],
            ["Number", 3.1]],
        ["Number", 8]]

[Wikipedia]: http://en.wikipedia.org/wiki/Extended_Backus-Naur_Form
*/

class Code
{
    #Include Lexer.ahk
    #Include Parser.ahk

    #Include Resources/Operators.ahk
}
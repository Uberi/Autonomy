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

#Warn All
#Warn LocalSameAsGlobal, Off

SetBatchLines, -1

/*
TODO
----

Short term tasks:

* make unit tests for the new lexer escape behavior
* consider using , to denote an array and [] to denote an object: x := 1, 2, 3
    * still need a good way to represent empty or single element arrays, or make it transparent like MATLAB
* Unit tests for error handler
* Error tolerance for parser by ignoring an operation like want.to.autocomplete.%INVALID% by simply returning the valid operands in the operator parser.

Long term tasks:

* implement all control flow and exceptions using continuations, continuation passing style is the norm with implicit continuations parameter, sort of like the "this" param in other languages
    * have "self" and $ available at all times, which represent the object instance and the passed continuations object/scope object
    * $.return(x), $.continue(), $.parent.break()
    * http://matt.might.net/articles/by-example-continuation-passing-style/
* async "promise" and green thread system with async exceptions
* use OBJECT KEY for prototype/metatable: "base" object: obj[base]._get, etc. scope objects will always have the "base" property set to the "base" property of the enclosing scope, in order to give enclosing code access to the base of objects. inheritance is obj[base]._get := fn('key) { PARENT_OBJECT[key] }
* do something about the enumerability of object bases; they should not be enumerable, maybe special case in the enumerator
* "userdata"/"bytes" type like in lua/python: custom user-defined blocks of memory that have literals and having two variants: GC managed or explicitly managed
* make a code formatter that can infer style settings from a code sample
* destructured assignment: [a, b, c] := [c, b, a] and [x, y] += [1, 2]
* static tail recursion elimination (make sure cases like $.return a ? b() : c() are handled by checking if the following bytecode instruction after the call is either a return or one or more unconditional jumps that leads to a return)
* have the .each method return the result: squares := [1, 2, 3].each (fn ('x) { x ** 2 })
* % operator can format strings, .= can append to array
* FFI with libffi for DllCall-like functionality
* multiple catch clauses in exception handler, and each accepting a condition for catching: try {} catch e: e Is KeyboardInterrupt {}
* to make an object, use ClassName()
* named parameter "key" for functions such as [].max(), [].min(), [].sort(), etc. that allows the user to specify a function that specifies the key to use in place of the actual key, together with a custom comparison function with named parameter "compare"
* "with" statement that sets an object as a scope (needs internal support, or use $ := something), or possibly use binding to rebind this: {some code here}.bind(scope_object)
* refinement pattern: matcher := with Patterns, { ["hello", "hi"]..[" ", "`t"][1:Infinity].."world!" }) and: date := with Time, { next.friday + weeks * 2 }
* "ensure" or "assert" statements allow code to be statically verified
* macro { some compile-time related code } syntax and compile time defined type system
* "is" operator that checks current class and recursively checks base classes
* "in" operator that checks for membership
* Function objects should have an call() method that applies a given array as the arguments, and allows specifying the "this" object, possibly as a named parameter
* for-loops and try-catch-else-finally should have an Else clause that executes if the loop did not break or an exception was not thrown
*/

FileName := A_ScriptFullPath ;set the file name of the current file

;Value = abc param1, param2`ndef param1 + sin 45`n!ghi + 5 * jkl 123, 456
;Value = Something a, b, c`n4+5`nTest 1, 2, 3
;Value = a ? b : c`nd && e || f
;Value = 1 + sin x, y
;Value = sin x + 1, y
;Value = x !y
;Value = 1 - 2 * 3 + 5 ** 3
;Value = 1 - 2 * (3 + 6e3) ** 3
;Value = a.b[c].d.e[f]
;Value = a(b)(c,d)(e)
;Value = a ? b := 2 : c := 3
;Value = {}()
;Value = x := 'name
;Value = x.y.z
;Value = 1 + {2}
;Value = f(x,,,,,,,,y)
;Value = a[1] + a[1 :   2  ] + a[1:2:3]
;Value = f x,, y: 'abc, z
;Value = 1 - 2 * 3
;Value = [a, f: g, b, 4, d: e,, c]
;Value = 1`n `n `n `n `n `n2`n    `n   `r
Value = x < y > z`nx < y

/* ;lexer testing
l := new Code.Lexer(Value)
Tokens := []
While, Token := l.Next()
    Tokens.Insert(Token)
MsgBox % Clipboard := Reconstruct.Tokens(Tokens)
ExitApp
*/

;/* ;parser testing
l := new Code.Lexer(Value)
p := new Code.Parser(l)
SyntaxTree := p.Parse()
MsgBox % Clipboard := Reconstruct.Tree(SyntaxTree)
;MsgBox % Clipboard := ShowObject(SyntaxTree)
ExitApp
*/

/* ;simplifier testing
l := new Code.Lexer(Value)
p := new Code.Parser(l)
SyntaxTree := p.Parse()
SimplifiedSyntaxTree := CodeSimplify(SyntaxTree)
MsgBox % Clipboard := Reconstruct.Tree(SimplifiedSyntaxTree)
ExitApp
*/

/* ;bytecoder testing
l := new Code.Lexer(Value)
p := new Code.Parser(l)
SyntaxTree := p.Parse()
Bytecoder := new Code.Bytecoder
Bytecode := Bytecoder.Convert(SyntaxTree)
MsgBox % Clipboard := Reconstruct.Bytecode(Bytecode)
ExitApp
*/

#Include Resources\Error Format.ahk
#Include Resources\Reconstruct.ahk

#Include Code.ahk
;#Include Simplifier.ahk
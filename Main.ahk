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

* consider using => to do named parameters and array key-value mappings, and reassign :'s status back as an operator
* invalid numbers like 123abc should give a lexer error rather than lexing as a number token and an identifier token, make sure it works after decimal points too (1.2abc) and add unit tests for it
* consider removing separator entirely from language?
* consider using , to denote an array and [] to denote an object
* Comparisons can be chained arbitrarily, e.g., x < y <= z is equivalent to x < y and y <= z, except that y is evaluated only once (but in both cases z is not evaluated at all when x < y is found to be false). Formally, if a, b, c, ..., y, z are expressions and op1, op2, ..., opN are comparison operators, then a op1 b op2 c ... y opN z is equivalent to a op1 b and b op2 c and ... y opN z, except that each expression is evaluated at most once.
* Allow backticks inline in code to represent literal versions of themselves in the code
* Unit tests for error handler
* Error tolerance for parser by ignoring an operation like want.to.autocomplete.@ by simply returning the valid operands in the operator parser.

Long term tasks:

* async "promise" and green thread system with async exceptions
* use OBJECT KEY for prototype/metatable: "base" object: obj[base]._get, etc. scope objects will always have the "base" property set to the "base" property of the enclosing scope, in order to give enclosing code access to the base of objects. inheritance is obj[base].get := fn ('key) { PARENT_OBJECT[key] }
* do something about the enumerability of object bases; they should not be enumerable
* "userdata"/"bytes" type like in lua/python: custom user-defined blocks of memory that have literals and having two variants: GC managed or explicitly managed
* make a code formatter that can infer style settings from a code sample
* destructured assignment: [a, b, c] := [c, b, a]
* static tail recursion elimination (make sure cases like return a ? b() : c() are handled by checking if the following bytecode instruction after the call is either a return or one or more jumps that leads to a return)
* have the .each method return the result: squares := [1, 2, 3].each (fn ('x) { x ** 2 })
* array slicing: a[start:end:step]
* fn function definition should allow multiple param lists bodies and patterns to match for each body: guard statements choose the correct function to call
* FFI with libffi for DllCall-like functionality
* have "self" and $ available at all times, which represent the object instance and the current object
* multiple catch clauses in exception handler, and each accepting a condition for catching: try {} catch e: e Is KeyboardInterrupt {}
* return, break, continue, etc. should be methods of "this", and "this" should be a continuation
* implement all control flow and exceptions using continuations
* to make an object, use ClassName.new() or just ClassName.new or ClassName()
* named parameter "key" for functions such as [].max(), [].min(), [].sort(), etc. that allows the user to specify a function that specifies the key to use in place of the actual key, together with a custon comparison function
* named parameter "compare" for the same purposes above, that allow things like custom sorting functions
* "with" statement that sets an object as a scope (needs internal support), or possibly use "this" binding to rebind this: {}.bind(scope_object)
* refinement pattern: matcher := with Patterns, { ["hello", "hi"]..[" ", "`t"][1:Infinity].."world!" }) and: date := with Time, { next.friday + weeks * 2 }
* "ensure" or "assert" statements allow code to be statically verified
* Dynamic default values for optional function parameters: SomeFunction(Param: 2 * 8 + VarInParentScope) { Function body here }
* macro { some compile-time related code } syntax and compile time defined type system
* "is" operator that checks current class and recursively checks base classes
* "in" operator that checks for membership
* Function objects should have an call() method that applies a given array as the arguments, and allows specifying the "this" object, possibly as a named parameter
* .= operator to append to an array
* for-loops and try-catch-else-finally should have an Else clause that executes if the loop did not break or an exception was not thrown
* Library in bytecode format; allows libraries to avoid recompilation each time by using a linker
*/

FileName := A_ScriptFullPath ;set the file name of the current file

Code = 
(
#Define SOME_DEFINITION := 1 + 2 * 3
Var := Something
#Define ANOTHER_DEFINITION := SOME_DEFINITION + 1
Return,, 1 + 1
)
Code =
(
abc param1, param2
def param1 + sin 45
!ghi + 5 * jkl 123, 456
)

;l := new Code.Lexer(Code)
l := new Lexer(Code)
Tokens := []
While, Token := l.Next()
    Tokens.Insert(Token)
Result := ""
For Index, Token In Tokens
    Result .= Reconstruct.Token(Token) . "`n"
MsgBox % Clipboard := Result

;p := new Code.Parser(l)
p := new Parser(l)
SyntaxTree := p.Parse()
MsgBox % Clipboard := Reconstruct.Tree(SyntaxTree)

/*
SimplifiedSyntaxTree := CodeSimplify(SyntaxTree)
MsgBox % Clipboard := Reconstruct.Tree(SimplifiedSyntaxTree)

Bytecode := CodeBytecode(SimplifiedSyntaxTree)
MsgBox % Clipboard := Bytecode
*/

ExitApp

#Include Resources\Error Format.ahk
#Include Resources\Reconstruct.ahk

;#Include Code.ahk
#Include Lexer.ahk
#Include Parser.ahk
;#Include Simplifier.ahk
;#Include Bytecode.ahk
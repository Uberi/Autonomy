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

* make subscript_identifier parse the right hand side as a symbol rather than an identifier
* consider using => to do named parameters and array key-value mappings, and reassign :'s status back as an operator
* invalid numbers like 123abc should give a lexer error rather than lexing as a number token and an identifier token, make sure it works after decimal points too and add unit tests for it
* consider removing separator entirely from language?
* Comparisons can be chained arbitrarily, e.g., x < y <= z is equivalent to x < y and y <= z, except that y is evaluated only once (but in both cases z is not evaluated at all when x < y is found to be false). Formally, if a, b, c, ..., y, z are expressions and op1, op2, ..., opN are comparison operators, then a op1 b op2 c ... y opN z is equivalent to a op1 b and b op2 c and ... y opN z, except that each expression is evaluated at most once.
* Allow backticks inline in code to represent literal versions of themselves in the code
* Unit tests for error handler

Long term tasks:

* static tail recursion elimination (make sure cases like return a ? b() : c() are handled by checking if the following bytecode instruction after the call is either a return or one or more jumps that leads to a return)
* have the .each method return the result: squares := [1, 2, 3].each(fn ('n) { n ** 2 })
* create 3 address code IR instead of stack based to allow things like register based VM or LLVM support
* array slicing: a[start:end:step]
* fn function definition should allow multiple param lists bodies and patterns to match for each body: guard statements choose the correct function to call
* have "this" and $ available at all times, which represent the object instance and the current object
* multiple catch clauses in exception handler, and each accepting a condition for catching: try {} catch e: e Is KeyboardInterrupt {}
* return, break, continue, etc. should be methods of "this", and "this" should be a continuation
* implement exceptions using this.caller
* to make an object, use Object.new() or ClassName.new() or just ClassName.new
* named parameter "key" for functions such as [].max(), [].min(), [].sort(), etc. that allows the user to specify a function that specifies the key to use in place of the actual key, together with a custon comparison function
* named parameter "compare" for the same purposes above, that allow things like custom sorting functions
* "with" statement that sets an object as a scope (needs internal support), or possibly use "this" binding to rebind this: {}.bind(scope_object)
* refinement pattern: matcher := with Patterns, { ["hello", "hi"] &[" ", "`t"] "world!" }) and: date := with Time, { next Friday + weeks * 2 }
* quasi-literals: literals in source code that have their own parsers, allowing things like date or regex literals
* "ensure" or "assert" statements allow code to be statically verified
* Dynamic default values for optional function parameters: SomeFunction(Param: 2 * 8 + VarInParentScope) { Function body here }
* macro { some compile-time related code } syntax and compile time defined type system
* Base object should not be enumerable or findable by ObjHasKey()
* "is" operator that checks current class and recursively checks base classes
* Primitive type methods through augmentation: String.Trim := Trim OR "".base.Trim := Trim ... "  test  ".Trim()
* Function objects should have an call() method that applies a given array as the arguments, and allows specifying the "this" object, possibly as a named parameter
* .= operator to append to an array
* Error messages should provide quick fixes for common causes of the issue
* for-loops and try-catch-else-finally should have an Else clause that executes if the loop did not break or an exception was not thrown
* Library in bytecode format; allows libraries to avoid recompilation each time by using a linker
* Incremental parser and lexer for IDE use, have object mapping line numbers to token indexes, have parser save state at intervals, lex changed lines only, restore parser state to the saved state right before the token index of the changed token, keep parsing to the end of the file
* Lua-like this.locals[] mechanism to replace dynamic variables, parent scope can be accessed as this.caller.locals[]
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
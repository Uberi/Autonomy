Autonomy
========
A programming language inspired by AutoHotkey.

Progress
--------

<table>
    <th>Module</th><th>Status</th>

    <tr><td>Lexer</td>         <td><em>Working</em></td></tr>
    <tr><td>Preprocessor</td>  <td><em>Almost working</em></td></tr>
    <tr><td>Parser</td>        <td><em>In Progress</em></td></tr>
    <tr><td>Simplifier</td>    <td><em>Pending</em></td></tr>
    <tr><td>Bytecode</td>      <td><em>Pending</em></td></tr>
    <tr><td>Interpreter</td>   <td><em>Pending</em></td></tr>
    <tr><td>Error Handler</td> <td><em>Working</em></td></tr>
</table>

Currently running on top of AutoHotkey until the implementation is self hosting.


Goal
----

To create a set of basic tools for the AutoHotkey language that will enable the creation of code-modifying tools. Examples of these include code minifiers, code tidying and reformatting tools, translators to other languages, and eventually, a self hosting compiler.


Modules
-------

### Code.ahk

Implements general initialization routines. Depends on Resources/Errors.txt and Resources/OperatorTable.txt. Requires filesystem access.

### Lexer.ahk

Implements tokenization of plain source code given as input and outputs a token array. Depends on Code.ahk.

### Preprocessor.ahk

Implements processing of preprocessor directives within a token array given as input. Depends on Lexer.ahk and Code.ahk. Requires filesystem access.

### Parser.ahk

Implements parsing of a token array given as input and outputs an abstract syntax tree. Depends on Code.ahk.

### Simplifier.ahk

Implements simplification of a syntax tree given as input.

### Bytecode.ahk

Implements the conversion of an abstract syntax tree given as input to a bytecode format suitable for interpretation or compilation.

### Interpreter.ahk

Implements a runtime execution environment for bytecode given as input.

### Resources/Get Error.ahk

Formats error records into a human readable form. Can display line and column information, as well as underline and point out incorrect code. Depends on Code.ahk.

### Resources/Functions.ahk

Utility functions bridging compatibility differences between AutoHotkey and Autonomy. Required for development until the compiler is fully self hosting, will most likely be removed afterwards.

### Resources/Reconstruct.ahk

Routines for the reconstruction of code from the various stages of compilation, such as from a token stream or syntax tree. Used for debugging purposes, but also has applications outside of this. Depends on Code.ahk.
AHK Code Tools
==============
A lexer, parser, and interpreter for the AutoHotkey scripting language.

Progress
--------

<table>
    <th>Module</th><th>Status</th>

    <tr><td>Lexer</td>         <td><em>Working (prone to changes)</em></td></tr>
    <tr><td>Preprocessor</td>  <td><em>Partially working</em></td></tr>
    <tr><td>Parser</td>        <td><em>Temporarily broken (soon undergoing rewrite)</em></td></tr>
    <tr><td>Simplifier</td>    <td><em>Pending</em></td></tr>
    <tr><td>Bytecode</td>      <td><em>Pending</em></td></tr>
    <tr><td>Interpreter</td>   <td><em>Pending</em></td></tr>
    <tr><td>Error Handler</td> <td><em>Working</em></td></tr>
</table>

Goal
----

To create a set of basic tools for the AutoHotkey language that will enable the creation of code-modifying tools. Examples of these include code minifiers, code tidying and reformatting tools, translators to other languages, and eventually, a self hosting compiler.


Modules
-------

### Code.ahk

Implements initialization routines. Accesses the filesystem.

### Lexer.ahk

Implements a tokenizer for raw source code given as input. Outputs a token array.

### Preprocessor.ahk

Implements preprocessor directive handling within a token array given as input. Depends on Lexer.ahk. Accesses the filesystem.

### Parser.ahk

Implements parsing of a token array given as input and output an abstract syntax tree.

### Simplify.ahk

Implements simplification of a syntax tree given as input.

### Bytecode.ahk

Implements the conversion of an abstract syntax tree given as input to a bytecode format suitable for interpretation or compilation.

### Interpreter.ahk

Implements a runtime execution environment for bytecode given as input.

### Resources/Get Error.ahk

Formats error records into a human readable form. Can display line and column information, as well as underline and point out incorrect code.

### Resources/Functions.ahk

Utility functions bridging compatibility differences between the original version of AutoHotkey and the "AHK Code Tools" dialect. Required for use until the compiler is fully self hosting, will be removed afterwards.

### Resources/Reconstruct.ahk

Routines for the reconstruction of code from the various stages of compilation, such as a token stream, or a syntax tree. Used for debugging purposes, but also has applications outside of this.
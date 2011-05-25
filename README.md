AHK Code Tools
==============
A lexer, parser, and interpreter for the AutoHotkey scripting language.

Progress
--------

<table>
    <th>Module</th><th>Status</th>

    <tr><td>Error Handler</td> <td><em>Working</em></td></tr>
    <tr><td>Lexer</td>         <td><em>Working</em></td></tr>
    <tr><td>Parser</td>        <td><em>In Progress</em></td></tr>
    <tr><td>Optimiser</td>        <td><em>Pending</em></td></tr>
    <tr><td>Bytecode</td>      <td><em>Pending</em></td></tr>
    <tr><td>Interpreter</td>   <td><em>Pending</em></td></tr>
</table>

Goal
----

To create a set of basic tools for the AutoHotkey language that will enable the creation of code-modifying tools. 

Examples of these include code minifiers, code tidying and reformatting tools, translators to other languages, and 

eventually, a self hosting compiler.


Modules
-------

### Get Error.ahk

Implements error formatting. Can display line and column information, underline code causing the error, and point 

out a specific character.

### Lexer.ahk

Implements a tokenizer for raw source code given as input. Outputs a token array.

### Parser.ahk

Not yet implemented. Will parse a token array given as input and output an abstract syntax tree. Uses modified and extended shunting yard algorithm.

### Optimise.ahk

Not yet implemented. Will perform optimisations and transformations to a syntax tree given as input.

### Bytecode.ahk

Not yet implemented. Will accept an abstract syntax tree given as input and output a bytecode format suitable for 

interpretation or compilation.

### Interpreter.ahk

Not yet implemented. Will execute bytecode given as input.
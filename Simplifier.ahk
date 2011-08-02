#NoEnv

/*
Possible Simplifications
------------------------

http://en.wikipedia.org/wiki/Category:Compiler_optimizations
http://en.wikipedia.org/wiki/Compiler_optimization
http://en.wikipedia.org/wiki/Constant_folding

- constant folding:                                  (3 + 4) * Sin(5) -> [Value of (3 + 4) * Sin(5)]
- common subexpression elimination:                  http://en.wikipedia.org/wiki/Common_subexpression_elimination
- integer bit shift left equivelance:                Integer1 * [Power of 2: Integer2] -> Integer1 << [Log2(Integer2)]
- integer bit shift right equivelance:               Integer1 // [Power of 2: Integer2] -> Integer1 >> [Log2(Integer2)]
- floor divide:                                      Floor(Number1 / Number2) -> Number1 // Number2
- multiply by one:                                   [Evaluates to integer 1] * Number, Number * [Evaluates to integer 1] -> Number
- divide by one:                                     Integer / [Evaluates to 1] -> Integer
- zero product property:                             Number * [Evaluates to 0] -> 0 ;if the multiplicand that evaluates to zero was a float, then the number type should be converted to a float as well
- bitwise modulo:                                    Mod(Integer1,[Power of 2: Integer2]) -> Integer1 & [Integer2 - 1]
- logical transforms:                                (!Something && !SomethingElse) -> !(Something || SomethingElse) ;many other different types of logical transforms too
...
*/

;simplifies a syntax tree given as input
CodeSimplify(ByRef SyntaxTree)
{
 
}
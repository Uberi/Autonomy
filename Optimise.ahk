#NoEnv

/*
Possible optimisations

http://en.wikipedia.org/wiki/Category:Compiler_optimizations
http://en.wikipedia.org/wiki/Compiler_optimization

- (3 + 4) * Sin(5) -> [Value of (3 + 4) * Sin(5)] ;substitute constant expressions with their values
- Common subexpression elimination (http://en.wikipedia.org/wiki/Common_subexpression_elimination)
- Something * [Power of 2: SomethingElse] -> Something << [Log2(SomethingElse)] ;or multiplied by anything that will evaluate to a power of two
- Something // (2 ** SomethingElse) -> Something >> SomethingElse ;or multiplied by anything that will evaluate to a power of two
- Floor(Something / SomethingElse) -> Something // SomethingElse
- [Evaluates to 1] * Something, Something * [Evaluates to 1] -> Something
...
*/

;optimises a syntax tree given as input
CodeOptimise(ByRef SyntaxTree)
{
 
}
#NoEnv

CodePreprocessInit()
{
 
}

CodePreprocess(Tokens,Errors)
{
 global CodeFiles
 For Index, Token In Tokens
 {
  If (Token.Type <> "STATEMENT") ;skip over any tokens that are not statements
   Continue
  
 }
}
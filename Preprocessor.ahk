#NoEnv

CodePreprocess(ByRef Tokens,ByRef Errors,FileIndex = 1)
{ ;returns 1 on error, nothing otherwise
 global CodeTokenTypes
 For Index, Token In Tokens
 {
  If (Token.Type <> CodeTokenTypes.STATEMENT) ;skip over any tokens that are not statements
   Continue
  Statement := Token.Value
  ;#Include #IncludeAgain #Define #Undefine #IfDefined #IfNotDefined #ElseIfDefined #ElseIfNotDefined
  If (Statement = "#Include") ;script inclusion, duplication ignored
   PreprocessError := CodePreprocessInclusion(Index,Tokens,Errors,0,FileIndex)
  Else If (Statement = "#IncludeAgain") ;script inclusion, duplication allowed
   PreprocessError := CodePreprocessInclusion(Index,Tokens,Errors,1,FileIndex)
 }
 Return, PreprocessError
}

CodePreprocessInclusion(Index,ByRef Tokens,ByRef Errors,AllowDuplicates,FileIndex)
{ ;returns 1 on inclusion failure, nothing otherwise
 global CodeFiles
 static CurrentIncludeDirectory
 Token := Tokens[Index + 1], Parameters := Token.Value ;retrieve the next token, the parameters given to the statement
 If (SubStr(Parameters,1,1) = "<") ;library file: #Include <LibraryName>
 {
  Parameters := SubStr(Parameters,2,-1)
  ;wip: some library path stuff here
 }
 Attributes := FileExist(Parameters)
 If (Attributes = "") ;file not found
 {
  ObjInsert(Errors,Object("Identifier","FILE_ERROR","Level","Error","Highlight","","Caret",Position,"File",FileIndex)) ;add an error to the error log
  Return, 1
 }
 If InStr(Attributes,"D") ;is a directory
  CurrentIncludeDirectory := CodePreprocessExpandPath(Parameter,1) ;set the current include directory
 Else ;is a file to include
 {
  Parameter := 
 }
}

CodePreprocessExpandPath(ByRef Path,IsDirectory)
{
 Loop, %Path%, % IsDirectory ? 2 : 0
  Return, A_LoopFileLongPath
}
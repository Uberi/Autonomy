#NoEnv

CodePreprocessInit()
{
 global CodeFiles, PreprocessorLibraryPaths

 PreprocessorLibraryPaths := Object(1,SplitPath(CodeFiles.1).Directory . "\Lib\",2,A_MyDocuments . "\AutoHotkey\Lib\",3,A_ScriptDir . "\Lib\") ;wip: not cross-platform
}

CodePreprocess(ByRef Tokens,ByRef ProcessedTokens,ByRef Errors,FileIndex = 1)
{ ;returns 1 on error, nothing otherwise
 global CodeTokenTypes
 ProcessedTokens := Object(), Index := 1, PreprocessError := 0
 While, IsObject(Token := Tokens[Index])
 {
  Index ++
  If (Token.Type <> CodeTokenTypes.STATEMENT) ;skip over any tokens that are not statements
  {
   ObjInsert(ProcessedTokens,Token) ;copy the token to the output stream
   Continue
  }
  Statement := Token.Value
  ;#Include #IncludeAgain #Define #Undefine #IfDefined #IfNotDefined #ElseIfDefined #ElseIfNotDefined
  If (Statement = "#Include") ;script inclusion, duplication ignored
   PreprocessError := CodePreprocessInclusion(Tokens[Index],ProcessedTokens,Errors,0,FileIndex) || PreprocessError
  Else If (Statement = "#IncludeAgain") ;script inclusion, duplication allowed
   PreprocessError := CodePreprocessInclusion(Tokens[Index],ProcessedTokens,Errors,1,FileIndex) || PreprocessError
  Else
   ObjInsert(ProcessedTokens,Token) ;copy the token to the output stream
  Index += 2 ;move past the parameter string and line ending
 }
 Return, PreprocessError
}

CodePreprocessInclusion(Token,ByRef ProcessedTokens,ByRef Errors,AllowDuplicates,FileIndex)
{ ;returns 1 on inclusion failure, nothing otherwise
 global CodeFiles, PreprocessorLibraryPaths
 static CurrentIncludeDirectory := ""
 Parameter := Token.Value, Length := StrLen(Parameter) ;retrieve the next token, the parameters given to the statement

 If (SubStr(Parameter,1,1) = "<") ;library file: #Include <LibraryName>
 {
  Parameter := SubStr(Parameter,2,-1) ;remove surrounding angle brackets
  For Index, Path In PreprocessorLibraryPaths ;loop through each folder looking for the file
  {
   Temp1 := Parameter
   Attributes := CodePreprocessExpandPath(Temp1,Path)
   If (Attributes <> "") ;found script file
   {
    Parameter := Temp1
    Break
   }
  }
 }
 Else
  Attributes := CodePreprocessExpandPath(Parameter,CurrentIncludeDirectory)
 If (Attributes = "") ;file not found
 {
  ObjInsert(Errors,Object("Identifier","FILE_ERROR","Level","Error","Highlight",Object("Position",Token.Position,"Length",Length),"Caret","","File",FileIndex)) ;add an error to the error log
  Return, 1
 }
 If InStr(Attributes,"D") ;is a directory
 {
  CurrentIncludeDirectory := Parameter ;set the current include directory
  Return
 }
 Found := 0
 For Index, Temp1 In CodeFiles ;check if the file has already been included
 {
  If (Temp1 = Parameter) ;found file already included
  {
   If (AllowDuplicates = 0)
   {
    ObjInsert(Errors,Object("Identifier","DUPLICATE_INCLUSION","Level","Notice","Highlight",Object("Position",Token.Position,"Length",Length),"Caret","","File",FileIndex)) ;notify that there was an inclusion duplicate
    Return
   }
   Found := 1
   Break
  }
 }

 ;add file to list of included files if it has not been included yet
 If (Found = 0)
 {
  FileIndex := ObjMaxIndex(CodeFiles) + 1 ;get the index to insert the file entry at
  ObjInsert(CodeFiles,FileIndex,Parameter) ;add the current script file to the file array
 }

 If (FileRead(Code,Parameter) <> 0) ;error reading file
 {
  ObjInsert(Errors,Object("Identifier","FILE_ERROR","Level","Error","Highlight",Object("Position",Token.Position,"Length",Length),"Caret","","File",FileIndex)) ;add an error to the error log
  Return, 1
 }
 If CodeLex(Code,FileTokens,Errors,FileIndex) ;errors while lexing file
  Return, 1
 If CodePreprocess(FileTokens,FileProcessedTokens,Errors,FileIndex) ;errors while preprocessing file
  Return, 1

 ;copy tokens from included file into the main token stream
 Index := 2
 Loop, % ObjMaxIndex(FileProcessedTokens) - 1 ;loop through all tokens except the first, which is a LINE_END type
  ObjInsert(ProcessedTokens,FileProcessedTokens[Index]), Index ++
}

CodePreprocessExpandPath(ByRef Path,CurrentDirectory = "")
{
 If (CurrentDirectory <> "")
 {
  WorkingDirectory := A_WorkingDir
  SetWorkingDir(CurrentDirectory)
 }
 Temp1 := Path, Path := ""
 If (SubStr(Temp1,0) = "\") ;remove trailing slash if present
  Temp1 := SubStr(Temp1,1,-1)
 Loop, %Temp1%, 1
 {
  Path := A_LoopFileLongPath
  Break
 }
 If (CurrentDirectory <> "")
  SetWorkingDir(WorkingDirectory)
 Return, FileExist(Path)
}
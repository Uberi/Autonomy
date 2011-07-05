#NoEnv

CodePreprocessInit()
{
 global CodeFiles, PreprocessorLibraryPaths, PreprocessorRecursionDepth, PreprocessorRecursionWarning
 PreprocessorLibraryPaths := Object(1,SplitPath(CodeFiles.1).Directory . "\Lib\",2,A_MyDocuments . "\AutoHotkey\Lib\",3,A_ScriptDir . "\Lib\") ;wip: not cross-platform
 PreprocessorRecursionDepth := 0
 PreprocessorRecursionWarning := 8 ;level at which to warn about the high level of recursion
}

CodePreprocess(ByRef Tokens,ByRef ProcessedTokens,ByRef Errors,FileIndex = 1)
{ ;returns 1 on error, nothing otherwise
 global CodeTokenTypes
 ProcessedTokens := Object(), Index := 1, PreprocessError := 0
 While, IsObject(Token := Tokens[Index])
 {
  Index ++ ;move past the statement, or the token if it is not a statement
  If (Token.Type <> CodeTokenTypes.STATEMENT) ;skip over any tokens that are not statements
  {
   ObjInsert(ProcessedTokens,Token) ;copy the token to the output stream
   Continue
  }
  Statement := Token.Value
  ;wip: add all these extra directives to the lexer
  If (Statement = "#Include") ;script inclusion, duplication ignored
   PreprocessError := CodePreprocessInclusion(Tokens[Index],ProcessedTokens,Errors,0,FileIndex) || PreprocessError, Index += 2
  Else If (Statement = "#IncludeAgain") ;script inclusion, duplication allowed
   PreprocessError := CodePreprocessInclusion(Tokens[Index],ProcessedTokens,Errors,1,FileIndex) || PreprocessError, Index += 2
  Else If (Statement = "#Define") ;identifier macro or function macro definition
   Index += 2 ;wip: process here
  Else If (Statement = "#Undefine") ;removal of existing macro
   Index += 2 ;wip: process here
  Else If (Statement = "#IfDefinition") ;conditional code checking definition truthiness
   Index += 2 ;wip: process here
  Else If (Statement = "#IfNotDefinition") ;conditional code checking definition falsiness
   Index += 2 ;wip: process here
  Else If (Statement = "#Else") ;conditional code checking alternative
   Index += 2 ;wip: process here
  Else If (Statement = "#ElseIfDefinition") ;conditional code checking alternative definition truthiness
   Index += 2 ;wip: process here
  Else If (Statement = "#ElseIfNotDefinition") ;conditional code checking alternative definition falsiness
   Index += 2 ;wip: process here
  Else If (Statement = "#EndIf") ;conditional code block end
   Index += 2 ;wip: process here
  Else
   ObjInsert(ProcessedTokens,Token), Index ++ ;copy the token to the output stream, move past the parameter if present, or the line end
 }
 Return, PreprocessError
}

CodePreprocessInclusion(Token,ByRef ProcessedTokens,ByRef Errors,AllowDuplicates,FileIndex)
{ ;returns 1 on inclusion failure, nothing otherwise
 global CodeFiles, PreprocessorLibraryPaths, PreprocessorRecursionDepth, PreprocessorRecursionWarning
 static CurrentIncludeDirectory := ""
 Parameter := Token.Value, Length := StrLen(Parameter) ;retrieve the next token, the parameters given to the statement

 If (SubStr(Parameter,1,1) = "<") ;library file: #Include <LibraryName>
 {
  Parameter := SubStr(Parameter,2,-1) ;remove surrounding angle brackets
  For Index, Path In PreprocessorLibraryPaths ;loop through each folder looking for the file
  {
   Temp1 := Parameter, Attributes := ExpandPath(Temp1,Path)
   If (Attributes <> "") ;found script file
   {
    Parameter := Temp1
    Break
   }
  }
 }
 Else
  Attributes := ExpandPath(Parameter,CurrentIncludeDirectory)
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
 PreprocessorRecursionDepth ++ ;increase the recursion depth counter
 If (PreprocessorRecursionDepth = PreprocessorRecursionWarning) ;at recursion warning level, give warning
  ObjInsert(Errors,Object("Identifier","RECURSION_WARNING","Level","Warning","Highlight",Object("Position",Token.Position,"Length",Length),"Caret","","File",FileIndex)) ;add an error to the error log
 Temp1 := CodePreprocess(FileTokens,FileProcessedTokens,Errors,FileIndex)
 PreprocessorRecursionDepth -- ;decrease the recursion depth counter
 If Temp1 ;errors while preprocessing file
  Return, 1

 ;copy tokens from included file into the main token stream
 Index := 2 ;start at the second token to skip past the first one
 Loop, % ObjMaxIndex(FileProcessedTokens) - 1 ;loop through all tokens except the first, which is a LINE_END type
  ObjInsert(ProcessedTokens,FileProcessedTokens[Index]), Index ++
}
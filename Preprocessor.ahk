#NoEnv

;initializes resources that the preprocessor requires
CodePreprocessInit(ByRef Files,ByRef CurrentDirectory = "")
{
 global PreprocessorIncludeDirectory, PreprocessorLibraryPaths, PreprocessorRecursionDepth, PreprocessorRecursionWarning

 If (ObjHasKey(Files,1) = 1 && (Path := Files.1) <> "") ;file path given, set the include directory to the directory of the script
  PreprocessorIncludeDirectory := PathSplit(Path).Directory
 Else If (CurrentDirectory <> "") ;include directory given explicitly
  PreprocessorIncludeDirectory := CurrentDirectory
 Else ;no path given, set the include directory to the directory of this script
  PreprocessorIncludeDirectory := A_ScriptDir

 PreprocessorLibraryPaths := Array(PathJoin(PreprocessorIncludeDirectory,"Lib"),PathJoin(A_MyDocuments,"AutoHotkey","Lib"),PathJoin(A_ScriptDir,"Lib")) ;paths that are searched for libraries
 PreprocessorRecursionDepth := 0
 PreprocessorRecursionWarning := 8 ;level at which to give a warning about the recursion depth
}

;preprocesses a token stream containing preprocessor directives
CodePreprocess(ByRef Tokens,ByRef ProcessedTokens,ByRef Errors,ByRef Files,FileIndex = 1)
{ ;returns 1 on error, 0 otherwise
 global CodeTokenTypes

 ProcessedTokens := Array(), Index := 1, PreprocessError := 0, Definitions := Array()
 While, IsObject(Token := Tokens[Index])
 {
  Index ++ ;move past the statement, or the token if it is not a statement
  If (Token.Type != CodeTokenTypes.STATEMENT) ;skip over any tokens that are not statements
  {
   ObjInsert(ProcessedTokens,Token) ;copy the token to the output stream
   Continue
  }
  Directive := Token.Value
  If (Directive = "#Include") ;script inclusion, duplication ignored
   PreprocessError := CodePreprocessInclusion(Tokens[Index],Index,ProcessedTokens,Errors,Files,FileIndex) || PreprocessError, Index ++
  Else If (Directive = "#Define") ;identifier macro or function macro definition
   CodePreprocessDefinition(Tokens,Index,ProcessedTokens,Definitions,Errors), Index ++ ;macro definition
  Else If (Directive = "#Undefine") ;removal of existing macro
   PreprocessError := CodePreprocessRemoveDefinition(Tokens,Index,Definitions,Errors) || PreprocessError, Index += 2
  Else If (Directive = "#If") ;conditional code checking simple expressions against definitions
   Index += 2 ;wip: process here
  Else If (Directive = "#ElseIf") ;conditional code checking alternative simple expressions against definitions
   Index += 2 ;wip: process here
  Else If (Directive = "#Else") ;conditional code checking alternative
   Index += 2 ;wip: process here
  Else If (Directive = "#EndIf") ;conditional code block end
   Index += 2 ;wip: process here
  Else
   ObjInsert(ProcessedTokens,Token), Index ++ ;copy the token to the output stream, move past the parameter or line end
 }
 Temp1 := ObjMaxIndex(ProcessedTokens) ;get the highest token index
 If (ProcessedTokens[Temp1].Type = CodeTokenTypes.LINE_END) ;token is a newline
  ObjRemove(ProcessedTokens,Temp1,"") ;remove the last token
 Return, PreprocessError
}

;preprocesses inclusion of files external to the script
CodePreprocessInclusion(Token,ByRef TokenIndex,ByRef ProcessedTokens,ByRef Errors,ByRef Files,FileIndex)
{ ;returns 1 on inclusion failure, 0 otherwise
 global PreprocessorIncludeDirectory, PreprocessorLibraryPaths, PreprocessorRecursionDepth, PreprocessorRecursionWarning

 Parameter := Token.Value, Length := StrLen(Parameter) ;retrieve the next token, the parameters given to the statement

 If (SubStr(Parameter,1,1) = "<") ;library file: #Include <LibraryName>
 {
  Parameter := SubStr(Parameter,2,-1) ;remove surrounding angle brackets
  For Index, Path In PreprocessorLibraryPaths ;loop through each folder looking for the file
  {
   Temp1 := PathExpand(Parameter,Path,Attributes)
   If (Attributes != "") ;found script file
   {
    Parameter := Temp1
    Break
   }
  }
 }
 Else
  Parameter := PathExpand(Parameter,PreprocessorIncludeDirectory,Attributes)
 If (Attributes = "") ;file not found
 {
  ObjInsert(Errors,Object("Identifier","FILE_ERROR","Level","Error","Highlight",Array(Object("Position",Token.Position,"Length",Length)),"Caret","","File",FileIndex)) ;add an error to the error log
  TokenIndex ++ ;skip past extra line end token
  Return, 1
 }
 If InStr(Attributes,"D") ;is a directory
 {
  PreprocessorIncludeDirectory := Parameter ;set the current include directory
  TokenIndex ++ ;skip past extra line end token
  Return, 0
 }
 For Index, Temp1 In Files ;check if the file has already been included
 {
  If (Temp1 = Parameter) ;found file already included
  {
   ObjInsert(Errors,Object("Identifier","DUPLICATE_INCLUSION","Level","Notice","Highlight",Array(Object("Position",Token.Position,"Length",Length)),"Caret","","File",FileIndex)) ;notify that there was an inclusion duplicate
   TokenIndex ++ ;skip past extra line end token
   Return, 0
  }
 }

 If (FileRead(Code,Parameter) != 0) ;error reading file
 {
  ObjInsert(Errors,Object("Identifier","FILE_ERROR","Level","Error","Highlight",Array(Object("Position",Token.Position,"Length",Length)),"Caret","","File",FileIndex)) ;add an error to the error log
  TokenIndex ++ ;skip past extra line end token
  Return, 1
 }

 ;add file to list of included files, since it has not been included yet
 FileIndex := ObjMaxIndex(Files) + 1 ;get the index to insert the file entry at
 ObjInsert(Files,FileIndex,Parameter) ;add the current script file to the file array

 CodeLex(Code,FileTokens,Errors,FileIndex) ;lex the external file
 PreprocessorRecursionDepth ++ ;increase the recursion depth counter
 If (PreprocessorRecursionDepth = PreprocessorRecursionWarning) ;at recursion warning level, give warning
  ObjInsert(Errors,Object("Identifier","RECURSION_WARNING","Level","Warning","Highlight",Array(Object("Position",Token.Position,"Length",Length)),"Caret","","File",FileIndex)) ;add an error to the error log
 CodePreprocess(FileTokens,FileProcessedTokens,Errors,Files,FileIndex) ;preprocess the tokens
 PreprocessorRecursionDepth -- ;decrease the recursion depth counter

 ;copy tokens from included file into the main token stream
 For Index, Token In FileProcessedTokens
  ObjInsert(ProcessedTokens,Token)

 Return, 0
}

CodePreprocessDefinition(ByRef Tokens,ByRef Index,ByRef ProcessedTokens,ByRef Definitions,ByRef Errors)
{ ;returns 1 on invalid syntax, 0 otherwise
 
}


CodePreprocessRemoveDefinition(ByRef Tokens,Index,ByRef Definitions,Errors)
{ ;returns 1 on invalid syntax, 0 otherwise
 global CodeTokenTypes

 Token := Tokens[Index]
 If !(Token.Type = CodeTokenTypes.IDENTIFIER && Tokens[Index + 1].Type = CodeTokenTypes.LINE_END) ;token is not an identifier or the token after it is not a line end
 {
  ObjInsert(Errors,Object("Identifier","INVALID_DIRECTIVE_SYNTAX","Level","Error","Highlight",Array(Object("Position",Token.Position,"Length",StrLen(Token.Value))),"Caret","","File",FileIndex)) ;add an error to the error log
  Return, 1
 }
 CurrentDefinition := Token.Value
 If ObjHasKey(Definitions,CurrentDefinition) ;remove the key if it exists
  ObjRemove(Definitions,CurrentDefinition)
 Else ;warn that the key does not exist
  ObjInsert(Errors,Object("Identifier","UNDEFINED_MACRO","Level","Warning","Highlight",Array(Object("Position",Token.Position,"Length",StrLen(CurrentDefinition))),"Caret","","File",FileIndex)) ;add an error to the error log
 Return, 0
}
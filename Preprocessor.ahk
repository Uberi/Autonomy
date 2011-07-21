#NoEnv

;dependant on Lexer.ahk for lexing capabilities

CodePreprocessInit()
{
 global CodeFiles, PreprocessorLibraryPaths, PreprocessorRecursionDepth, PreprocessorRecursionWarning
 PreprocessorLibraryPaths := Array(PathJoin(SplitPath(CodeFiles.1).Directory,"Lib"),PathJoin(A_MyDocuments,"AutoHotkey","Lib"),PathJoin(A_ScriptDir,"Lib"))
 PreprocessorRecursionDepth := 0
 PreprocessorRecursionWarning := 8 ;level at which to warn about the high level of recursion
}

CodePreprocess(ByRef Tokens,ByRef ProcessedTokens,ByRef Errors,FileIndex = 1)
{ ;returns 1 on error, 0 otherwise
 global CodeTokenTypes

 ProcessedTokens := Array(), Index := 1, PreprocessError := 0, Definitions := Array()
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
   PreprocessError := CodePreprocessInclusion(Tokens[Index],Index,ProcessedTokens,Errors,FileIndex) || PreprocessError, Index ++
  Else If (Statement = "#Define") ;identifier macro or function macro definition
   CodePreprocessDefinition(Tokens[Index],ProcessedTokens,Definitions,Errors), Index += 2 ;definition
  Else If (Statement = "#Undefine") ;removal of existing macro
   Index += 2 ;wip: process here
  Else If (Statement = "#If") ;conditional code checking simple expressions against definitions
   Index += 2 ;wip: process here
  Else If (Statement = "#Else") ;conditional code checking alternative
   Index += 2 ;wip: process here
  Else If (Statement = "#ElseIf") ;conditional code checking alternative simple expressions against definitions
   Index += 2 ;wip: process here
  Else If (Statement = "#EndIf") ;conditional code block end
   Index += 2 ;wip: process here
  Else
   ObjInsert(ProcessedTokens,Token) ;copy the token to the output stream, move past the parameter if present, or the line end
 }
 Temp1 := ObjMaxIndex(ProcessedTokens) ;get the highest token index
 If (ProcessedTokens[Temp1].Type = CodeTokenTypes.LINE_END) ;token is a newline
  ObjRemove(ProcessedTokens,Temp1,"") ;remove the last token
 Return, PreprocessError
}

CodePreprocessInclusion(Token,ByRef TokenIndex,ByRef ProcessedTokens,ByRef Errors,FileIndex)
{ ;returns 1 on inclusion failure, 0 otherwise
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
  TokenIndex ++ ;skip past extra line end token
  Return, 1
 }
 If InStr(Attributes,"D") ;is a directory
 {
  CurrentIncludeDirectory := Parameter ;set the current include directory
  TokenIndex ++ ;skip past extra line end token
  Return, 0
 }
 For Index, Temp1 In CodeFiles ;check if the file has already been included
 {
  If (Temp1 = Parameter) ;found file already included
  {
   ObjInsert(Errors,Object("Identifier","DUPLICATE_INCLUSION","Level","Notice","Highlight",Object("Position",Token.Position,"Length",Length),"Caret","","File",FileIndex)) ;notify that there was an inclusion duplicate
   TokenIndex ++ ;skip past extra line end token
   Return, 0
  }
 }

 If (FileRead(Code,Parameter) <> 0) ;error reading file
 {
  ObjInsert(Errors,Object("Identifier","FILE_ERROR","Level","Error","Highlight",Object("Position",Token.Position,"Length",Length),"Caret","","File",FileIndex)) ;add an error to the error log
  TokenIndex ++ ;skip past extra line end token
  Return, 1
 }

 ;add file to list of included files, since it has not been included yet
 FileIndex := ObjMaxIndex(CodeFiles) + 1 ;get the index to insert the file entry at
 ObjInsert(CodeFiles,FileIndex,Parameter) ;add the current script file to the file array

 CodeLex(Code,FileTokens,Errors,FileIndex) ;lex the external file
 PreprocessorRecursionDepth ++ ;increase the recursion depth counter
 If (PreprocessorRecursionDepth = PreprocessorRecursionWarning) ;at recursion warning level, give warning
  ObjInsert(Errors,Object("Identifier","RECURSION_WARNING","Level","Warning","Highlight",Object("Position",Token.Position,"Length",Length),"Caret","","File",FileIndex)) ;add an error to the error log
 CodePreprocess(FileTokens,FileProcessedTokens,Errors,FileIndex) ;preprocess the tokens
 PreprocessorRecursionDepth -- ;decrease the recursion depth counter

 ;copy tokens from included file into the main token stream
 For Index, Token In FileProcessedTokens
  ObjInsert(ProcessedTokens,Token)

 Return, 0
}

CodePreprocessDefinition(Token,ByRef ProcessedTokens,ByRef Definitions,ByRef Errors)
{
 
}
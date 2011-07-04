#NoEnv

DisplayObject(DisplayObject,ParentID = 0)
{
 ListLines, Off
 If (ParentID = 0)
 {
  Gui, Add, Text, x10 y0 w300 h30 Center, Object Contents
  Gui, Add, TreeView, x10 y30 w300 h230
 }
 For Key, Value In DisplayObject
  IsObject(Value) ? DisplayObject(Value,TV_Add(Key,ParentID,"Bold Expand")) : TV_Add(Key . ": " . Value,ParentID)
 If (ParentID = 0)
 {
  Gui, +ToolWindow +AlwaysOnTop +LastFound
  WindowID := WinExist()
  Gui, Show, w320 h270
  While, WinExist("ahk_id " . WindowID)
   Sleep, 100
  Gui, Destroy
  ListLines, On
  Return
 }
}

SetBatchLines(Amount)
{
 SetBatchLines, %Amount%
}

FileRead(ByRef OutputVar,Filename)
{
 FileRead, OutputVar, %Filename%
 Return, ErrorLevel
}

Display(DisplayText)
{
 FileAppend, %DisplayText%, *
 Return, ErrorLevel
}

ExitApp(ExitCode = 0)
{
 ExitApp, %ExitCode%
}

StringSplit(InputVar,Delimiters = "",OmitChars = "")
{
 StringSplit, Array, InputVar, %Delimiters%, %OmitChars%
 Result := Object()
 Loop, %Array0%
  ObjInsert(Result,A_Index,Array%A_Index%)
 Return, Result
}

SplitPath(InputVar)
{
 SplitPath, InputVar, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
 Return, Object("FileName",OutFileName,"Directory",OutDir,"Extension",OutExtension,"FileNameNoExtension",OutNameNoExt,"Drive",OutDrive)
}

SetWorkingDir(DirName)
{
 SetWorkingDir, %DirName%
}
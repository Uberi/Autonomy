#NoEnv

ShowObject(ShowObject,Padding = "")
{
 ListLines, Off
 If !IsObject(ShowObject)
 {
  ListLines, On
  Return, ShowObject
 }
 ObjectContents := ""
 For Key, Value In ShowObject
 {
  If IsObject(Value)
   Value := "`n" . ShowObject(Value,Padding . A_Tab)
  ObjectContents .= Padding . Key . ": " . Value . "`n"
 }
 ObjectContents := SubStr(ObjectContents,1,-1)
 If (Padding = "")
  ListLines, On
 Return, ObjectContents
}

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

ExpandPath(ByRef Path,CurrentDirectory = "")
{ ;returns blank if there was a filesystem error, the attributes otherwise
 ListLines, Off
 If (CurrentDirectory <> "")
 {
  WorkingDirectory := A_WorkingDir
  SetWorkingDir, %CurrentDirectory%
 }
 Temp1 := Path, Path := "", Attributes := ""
 If (SubStr(Temp1,0) = "\") ;remove trailing slash if present
  Temp1 := SubStr(Temp1,1,-1)
 Loop, %Temp1%, 1
 {
  Path := A_LoopFileLongPath, Attributes := A_LoopFileAttrib
  Break
 }
 If (CurrentDirectory <> "")
  SetWorkingDir, %WorkingDirectory%
 ListLines, On
 Return, Attributes
}

PathJoin(Path1,Path2 = "",Path3 = "",Path4 = "",Path5 = "",Path6 = "")
{
 /*
 #Define HOST_OS = "WINDOWS"
 #If HOST_OS = "WINDOWS"
  Separator := "\"
 #ElseIf HOST_OS = "LINUX"
  Separator := "/"
 #EndIf
 */
 HOST_OS := "WINDOWS"
 If (HOST_OS = "WINDOWS")
  Separator := "\"
 Else If (HOST_OS = "LINUX")
  Separator := "/"

 ;remove any leading separator characters if present
 If (SubStr(Path1,1,1) = Separator)
  Path1 := SubStr(Path1,2)
 If (SubStr(Path2,1,1) = Separator)
  Path2 := SubStr(Path2,2)
 If (SubStr(Path3,1,1) = Separator)
  Path3 := SubStr(Path3,2)
 If (SubStr(Path4,1,1) = Separator)
  Path4 := SubStr(Path4,2)
 If (SubStr(Path5,1,1) = Separator)
  Path5 := SubStr(Path5,2)
 If (SubStr(Path6,1,1) = Separator)
  Path6 := SubStr(Path6,2)

 ;append a separator character if the path element does not end in one, and is not blank
 If (Path1 <> "" && SubStr(Path1,0) <> Separator)
  Path1 .= Separator
 If (Path2 <> "" && SubStr(Path2,0) <> Separator)
  Path2 .= Separator
 If (Path3 <> "" && SubStr(Path3,0) <> Separator)
  Path3 .= Separator
 If (Path4 <> "" && SubStr(Path4,0) <> Separator)
  Path4 .= Separator
 If (Path5 <> "" && SubStr(Path5,0) <> Separator)
  Path5 .= Separator
 If (Path6 <> "" && SubStr(Path6,0) <> Separator)
  Path6 .= Separator

 Return, SubStr(Path1 . Path2 . Path3 . Path4 . Path5 . Path6,1,-1)
}
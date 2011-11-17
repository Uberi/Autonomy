#NoEnv

/*
Copyright 2011 Anthony Zhang <azhang9@gmail.com>

This file is part of Autonomy. Source code is available at <https://github.com/Uberi/Autonomy>.

Autonomy is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

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

StringSplit(InputVar,Delimiters = "",OmitChars = "")
{
 StringSplit, Array, InputVar, %Delimiters%, %OmitChars%
 Result := Object()
 Loop, %Array0%
  ObjInsert(Result,A_Index,Array%A_Index%)
 Return, Result
}

PathSplit(InputVar)
{
 SplitPath, InputVar, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
 Return, Object("FileName",OutFileName,"Directory",OutDir,"Extension",OutExtension,"FileNameNoExtension",OutNameNoExt,"Drive",OutDrive)
}

PathExpand(Path,CurrentDirectory = "",ByRef Attributes = "")
{ ;returns blank if there was a filesystem error, the attributes otherwise
 ListLines, Off
 If (CurrentDirectory != "")
 {
  WorkingDirectory := A_WorkingDir
  SetWorkingDir, %CurrentDirectory%
 }
 ExpandedPath := "", Attributes := ""
 If (SubStr(Path,0) = "\") ;remove trailing slash if present
  Path := SubStr(Path,1,-1)
 Loop, %Path%, 1
 {
  ExpandedPath := A_LoopFileLongPath, Attributes := A_LoopFileAttrib
  Break
 }
 If (CurrentDirectory != "")
  SetWorkingDir, %WorkingDirectory%
 ListLines, On
 Return, ExpandedPath
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
 If (Path1 != "" && SubStr(Path1,0) != Separator)
  Path1 .= Separator
 If (Path2 != "" && SubStr(Path2,0) != Separator)
  Path2 .= Separator
 If (Path3 != "" && SubStr(Path3,0) != Separator)
  Path3 .= Separator
 If (Path4 != "" && SubStr(Path4,0) != Separator)
  Path4 .= Separator
 If (Path5 != "" && SubStr(Path5,0) != Separator)
  Path5 .= Separator
 If (Path6 != "" && SubStr(Path6,0) != Separator)
  Path6 .= Separator

 Return, SubStr(Path1 . Path2 . Path3 . Path4 . Path5 . Path6,1,0 - StrLen(Separator))
}
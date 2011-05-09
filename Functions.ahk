#NoEnv

GetArgs()
{
 global
 local Args
 Args := Object()
 Loop, %0%
  ObjInsert(Args,%A_Index%)
 Return, Args
}

ShowObject(ShowObject,Padding = "")
{
 ListLines, Off
 If !IsObject(ShowObject)
 {
  ListLines, On
  Return, Padding . ShowObject
 }
 ObjectContents := ""
 For Key, Value In ShowObject
 {
  If IsObject(Value)
   Value := "`n" . ShowObject(Value,Padding . A_Tab)
  ObjectContents .= Padding . Key . ": " . Value . "`n"
 }
 If (Padding = "")
 {
  ObjectContents := SubStr(ObjectContents,1,-1)
  ListLines, On
 }
 Return, ObjectContents
}

SetBatchLines(Amount)
{
 SetBatchLines, %Amount%
}

FileRead(ByRef OutputVar,Filename)
{
 FileRead, OutputVar, %Filename%
}

FileAppend(Text,Filename)
{
 FileAppend, %Text%, %Filename%
}

MsgBox(Text = "")
{
 If (Text = "")
  MsgBox
 Else
  MsgBox, %Text%
}

ExitApp(ExitCode = 0)
{
 ExitApp, %ExitCode%
}

StringSplit(ByRef InputVar,Delimiters = "",OmitChars = "")
{
 StringSplit, Output, InputVar, %Delimiters%, %OmitChars%
 OutputArray := Object()
 Loop, %Output0%
  ObjInsert(OutputArray,Output%A_Index%)
 Return, OutputArray
}
#NoEnv

ShowObject(ShowObject,Padding = "")
{
 ListLines, Off
 If !IsObject(ShowObject)
 {
  ListLines, On
  Return, Padding . ShowObject
 }
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
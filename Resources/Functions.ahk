#NoEnv

DisplayObject(DisplayObject,ParentID = 0)
{
 ;ListLines, Off
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

ParseObject(ObjectDescription)
{
 ListLines, Off
 PreviousIndentLevel := 1, PreviousKey := "", Result := Object(), ObjectPath := Object(), TempObject := Result ;initialize values
 Loop, Parse, ObjectDescription, `n, `r ;loop over each line of the object description
 {
  IndentLevel := 1
  While, (SubStr(A_LoopField,A_Index,1) = "`t")
   IndentLevel ++
  MaxIndex := ObjMaxIndex(ObjectPath)
  Temp1 := InStr(A_LoopField,":",0,IndentLevel)
  If !Temp1 ;not a key-value pair, treat as a continuation of the value of the previous pair
  {
   TempObject[PreviousKey] .= "`n" . A_LoopField
   Continue
  }
  Key := SubStr(A_LoopField,IndentLevel,Temp1 - IndentLevel), Value := SubStr(A_LoopField,Temp1 + 2)
  If (IndentLevel = PreviousIndentLevel) ;sibling object
   TempObject[Key] := Value
  Else If (IndentLevel > PreviousIndentLevel) ;nested object
   TempObject[PreviousKey] := Object(Key,Value), TempObject := TempObject[PreviousKey], ObjInsert(ObjectPath,PreviousKey) ;
  Else ;(IndentLevel < PreviousIndentLevel) ;parent object
  {
   Temp1 := PreviousIndentLevel - IndentLevel, ObjRemove(ObjectPath,MaxIndex - Temp1,MaxIndex), MaxIndex -= Temp1 ;update object path

   ;get parent object
   TempObject := Result
   Loop, %MaxIndex%
    TempObject := TempObject[ObjectPath[A_Index]]
   TempObject[Key] := Value
  }
  PreviousIndentLevel := IndentLevel, PreviousKey := Key
 }
 ListLines, On
 Return, Result
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
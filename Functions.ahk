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
}

FileAppend(Text,Filename)
{
 FileAppend, %Text%, %Filename%
}

ExitApp(ExitCode = 0)
{
 ExitApp, %ExitCode%
}
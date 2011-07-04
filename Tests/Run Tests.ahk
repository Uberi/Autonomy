#NoEnv

#Include ..\Resources\Functions.ahk

#Include ..\Code.ahk
#Include ..\Lexer.ahk
#Include ..\Preprocessor.ahk
#Include ..\Parser.ahk

#Warn All

/*
Unit Test Format
----------------

If a fields is blank, an empty line is to be left in its place

* Input:     the input to be given to the module being tested
* Separator: the literal string "---" on its own line
* Errors:    errors that are expected to be given, if any
* Separator: the literal string "---" on its own line
* Output:    expected output that is to be received from the module being tested

Example Unit Test
-----------------

Lexer unit test:

    MsgBox("Hello, World!)
    ---
    1: 
        Caret: 23
        File: 1
        Highlight: 
            Length: 15
            Position: 8
        Identifier: UNMATCHED_QUOTE
        Level: Error
    ---
    1: 
        File: 1
        Position: 0
        Type: 10
        Value: 
    2: 
        File: 1
        Position: 1
        Type: 9
        Value: MsgBox
    3: 
        File: 1
        Position: 7
        Type: 4
        Value: (
    4: 
        File: 1
        Position: 23
        Type: 10
        Value: 
*/

Gui, Font, s12 Bold, Arial
Gui, Add, Text, x2 y0 w510 h20 +Center, Unit Test Results:
Gui, Font, s8 Norm
Gui, Add, ListView, x2 y20 w510 h320, Index|Test Name|Result|Additional Info
Gui, Font, s10
Gui, Add, Button, x2 y350 w260 h30 gCopyReport Default, Copy To Clipboard
Gui, Add, Button, x262 y350 w250 h30 gSaveReport, Save To File
GuiControl, Focus, Button1

If CodeInit("..\Resources")
{
 MsgBox, Error: Could not initialize code tools.
 ExitApp
}

CodeFiles.1 := A_ScriptDir . "\Script.ahk" ;set the file name of the current file

TestIndex := 1
Gosub, TestLexer
Gosub, TestPreprocessor
Gosub, TestParser
Gosub, TestBytecode
Gosub, TestInterpreter

Loop, 4
 LV_ModifyCol(A_Index,"AutoHdr")
Gui, Show, w515 h385, Unit Test
Return

TestLexer:
CodeLexInit()
Loop, %A_ScriptDir%\Lexer\*.txt
{
 FileRead(FileContents,A_LoopFileLongPath)
 If RegExMatch(FileContents,"sS)^(?P<Code>.*?)\r?\n---\r?\n(?P<ErrorOutput>.*?)\r?\n---\r?\n(?P<TokenOutput>.*)$",Test)
 {
  StringReplace, TestErrorOutput, TestErrorOutput, `r,, All
  StringReplace, TestTokenOutput, TestTokenOutput, `r,, All
  Errors := Object()
  CodeLex(TestCode,Tokens,Errors)
  If (ShowObject(Errors) <> TestErrorOutput)
   ExtraInfo := "Generated errors do not match expected errors.", TestStatus := "Fail"
  Else If (ShowObject(Tokens) <> TestTokenOutput)
   ExtraInfo := "Output does not match expected output.", TestStatus := "Fail"
  Else
   ExtraInfo := "None", TestStatus := "Pass"
 }
 Else
  ExtraInfo := "Invalid test.", TestStatus := "Fail"
 LV_Add("",TestIndex,"Lexer - " . A_LoopFileName,TestStatus,ExtraInfo), TestIndex ++
}
Return

TestPreprocessor:
CodeFiles1 := CodeFiles.1
CodeFiles.1 := A_ScriptDir . "\Preprocessor\Script.ahk" ;temporarily change the test directory to the directory the tests are located

CodePreprocessInit()
Loop, %A_ScriptDir%\Preprocessor\*.txt
{
 FileRead(FileContents,A_LoopFileLongPath)
 If RegExMatch(FileContents,"sS)^(?P<Tokens>.*?)\r?\n---\r?\n(?P<ErrorOutput>.*?)\r?\n---\r?\n(?P<TokenOutput>.*)$",Test)
 {
  TestTokens := ParseObject(TestTokens)
  StringReplace, TestErrorOutput, TestErrorOutput, `r,, All
  StringReplace, TestTokenOutput, TestTokenOutput, `r,, All
  Errors := Object()
  CodePreprocess(TestTokens,ProcessedTokens,Errors)
  If (ShowObject(Errors) <> TestErrorOutput)
  {
   ExtraInfo := "Generated errors do not match expected errors.", TestStatus := "Fail"
   MsgBox % Clipboard := ShowObject(Errors)
  }
  Else If (ShowObject(ProcessedTokens) <> TestTokenOutput)
   ExtraInfo := "Output does not match expected output.", TestStatus := "Fail"
  Else
   ExtraInfo := "None", TestStatus := "Pass"
  ObjRemove(CodeFiles) ;clean up files list
 }
 Else
  ExtraInfo := "Invalid test.", TestStatus := "Fail"
 LV_Add("",TestIndex,"Preprocessor - " . A_LoopFileName,TestStatus,ExtraInfo), TestIndex ++
}
CodeFiles.1 := CodeFiles1
Return

TestParser:
Loop, %A_ScriptDir%\Parser\*.txt
{
 FileRead(FileContents,A_LoopFileLongPath)
 If RegExMatch(FileContents,"sS)^(?P<Tokens>.*?)\r?\n---\r?\n(?P<ErrorOutput>.*?)\r?\n---\r?\n(?P<TreeOutput>.*)$",Test)
 {
  TestTokens := ParseObject(TestTokens)
  StringReplace, TestErrorOutput, TestErrorOutput, `r,, All
  StringReplace, TestTokenOutput, TestTokenOutput, `r,, All
  Errors := Object()
  CodeParse(TestTokens,SyntaxTree,Errors)
  If (ShowObject(Errors) <> TestErrorOutput)
   ExtraInfo := "Generated errors do not match expected errors.", TestStatus := "Fail"
  Else If (ShowObject(SyntaxTree) <> TestTreeOutput)
   ExtraInfo := "Output does not match expected output.", TestStatus := "Fail"
  Else
   ExtraInfo := "None", TestStatus := "Pass"
 }
 Else
  ExtraInfo := "Invalid test.", TestStatus := "Fail"
 LV_Add("",TestIndex,"Parser - " . A_LoopFileName,TestStatus,ExtraInfo), TestIndex ++
}
Return

TestBytecode:

Return

TestInterpreter:

Return

GuiEscape:
GuiClose:
ExitApp

CopyReport:
GenerateReport(TestReport)
Gui, Destroy
Clipboard := TestReport
MsgBox, 64, Copied, Report has been copied to the clipboard.
ExitApp

SaveReport:
Gui, Hide
GenerateReport(TestReport)
FileSelectFile, FileName, S18, Report.txt, Please Select A Path To Save The Report To:, *.txt
FileDelete, %FileName%
FileAppend, %TestReport%, %FileName%
MsgBox, 64, Saved, Report has been saved to the following file:`n`n"%FileName%"
ExitApp

GenerateReport(ByRef TestReport)
{
 TestReport := "", PassAmount := 0, FailAmount := 0
 Index := LV_GetCount(), PassList := "", FailList := ""
 Loop, %Index%
 {
  LV_GetText(Temp1,A_Index,2)
  LV_GetText(Temp2,A_Index,3)
  LV_GetText(Temp3,A_Index,4)
  If (Temp2 = "Pass")
   PassList .= "`r`n" . Temp1, PassAmount ++
  Else
   FailList .= "`r`n" . Temp1, FailAmount ++
  TestReport .= "`r`n" . Temp1 . A_Tab . A_Tab . A_Tab . Temp2 . ((Temp3 <> "None") ? " (" . Temp3 . ")" : "")
 }
 TestReport := "Tested with " . Index . " test(s):`r`n" . TestReport . "`r`n`r`n" . FailAmount . " test(s) failed:`r`n" . FailList . "`r`n`r`n" . PassAmount . " test(s) passed:`r`n" . PassList
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
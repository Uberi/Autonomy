#NoEnv

#Include %A_ScriptDir%\..\Functions.ahk
#Include %A_ScriptDir%\..\Lexer.ahk
#Include %A_ScriptDir%\..\Get Error.ahk

Gui, Font, s12 Bold, Arial
Gui, Add, Text, x2 y0 w510 h20 +Center, Unit Test Results:
Gui, Font, s8 Norm
Gui, Add, ListView, x2 y20 w510 h320, Index|Test Name|Result|Additional Info
Gui, Font, s10
Gui, Add, Button, x2 y350 w260 h30 gCopyReport Default, Copy To Clipboard
Gui, Add, Button, x262 y350 w250 h30 gSaveReport, Save To File
GuiControl, Focus, Button1

Gosub, TestLexer
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
  CodeLex(TestCode,Tokens,Errors)
  If (ShowObject(Errors) <> TestErrorOutput)
   ExtraInfo := "Generated errors do not match expected errors.", TestStatus := "Fail"
  Else If (ShowObject(Tokens) <> TestTokenOutput)
   ExtraInfo := "Tokenized output does not match expected output.", TestStatus := "Fail"
  Else
   ExtraInfo := "None", TestStatus := "Pass"
 }
 Else
  ExtraInfo := "Invalid test.", TestStatus := "Fail"
 LV_Add("",A_Index,"Lexer - " . A_LoopFileName,TestStatus,ExtraInfo)
}
Return

TestParser:

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
 Index := LV_GetCount()
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
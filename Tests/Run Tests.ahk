#NoEnv

/*
Copyright 2011-2012 Anthony Zhang <azhang9@gmail.com>

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

SetBatchLines, -1
Process, Priority,, RealTime

/*
#Warn All
#Warn LocalSameAsGlobal, Off
*/

Debug := 0 ;whether or not to copy and display unexpected output

/*
Test Format
-----------

If a fields is blank, an empty line is to be left in its place

* Input:     the input to be given to the module being tested
* Separator: the literal string "---" on its own line
* Errors:    errors that are expected to be given, if any
* Separator: the literal string "---" on its own line
* Output:    expected output that is to be received from the module being tested

Example Test
------------

Lexer test:

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
    File 1: IDENTIFIER  (1):  'MsgBox'
    File 1: GROUP_BEGIN (7):  ''
*/

Gui, Font, s12 Bold, Arial
Gui, Add, Text, x0 y5 h25 vTitle Center, Test Results:
Gui, Font, s8 Norm
Gui, Add, ListView, x2 y30 vResults, Index|Test Name|Result|Additional Info
Gui, Font, s10
Gui, Add, Button, x2 w150 h30 vCopyReport gCopyReport Default, Copy To Clipboard
Gui, Add, Button, w150 h30 vSaveReport gSaveReport, Save To File
Gui, Font, s8
Gui, Add, StatusBar
GuiControl, Focus, Button1
Gui, +Resize +MinSize320x200
Gosub, GuiSize

If CodeInit("..\Resources")
{
    MsgBox, Error: Could not initialize code tools.
    ExitApp
}

CodeTreeInit()

FileName := PathJoin(A_ScriptDir,"Run Tests.ahk") ;set the file name of the current file

;take a quick control benchmark
ControlTimer := StartTimer()
ControlTimer := StopTimer(ControlTimer)

TestIndex := 1
Gosub, TestLexer
Gosub, TestParser
Gosub, TestBytecode
Gosub, TestInterpreter

Index := LV_GetCount(), PassAmount := 0
Loop, %Index%
    LV_GetText(Temp1,A_Index,3), (Temp1 = "Pass") ? (PassAmount ++)
SB_SetText("`t`t" . PassAmount . " of " . Index . " tests passed.",1)

Gosub, GuiSize

Gui, Show, w515 h600, Tests
Return

#Include ..\
#Include Resources\Reconstruct.ahk
#Include Resources\Syntax Tree.ahk

#Include Code.ahk
#Include Lexer.ahk
#Include Parser.ahk

ShowOutput(TestName,OutputType,ByRef OutputText)
{
    Clipboard := OutputText
    OutputType := (OutputType = 0) ? "errors" : "output"
    MsgBox, Unexpected %OutputType% in %TestName%:`n`n%OutputText%
    ExitApp
}

TestLexer:
CodeSetScript(FileName,Errors,Files)
CodeLexInit()
Loop, %A_ScriptDir%\Lexer\*.txt
{
    TestName := "Lexer - " . A_LoopFileName
    FileRead(FileContents,A_LoopFileLongPath)
    If RegExMatch(FileContents,"sS)^(?P<Code>.*?)\r?\n---\r?\n(?P<ErrorOutput>.*?)\r?\n---\r?\n(?P<TokenOutput>.*)$",Test)
    {
        StringReplace, TestErrorOutput, TestErrorOutput, `r,, All
        StringReplace, TestTokenOutput, TestTokenOutput, `r,, All
        Errors := []
        Temp1 := StartTimer()
        Tokens := CodeLex(TestCode,Errors)
        Temp1 := StopTimer(Temp1) - ControlTimer
        If ((Output := ShowObject(Errors)) != TestErrorOutput)
        {
            ExtraInfo := "Generated errors do not match expected errors.", TestStatus := "Fail"
            If Debug
                ShowOutput(TestName,0,Output)
        }
        Else If ((Output := CodeReconstructShowTokens(Tokens)) != TestTokenOutput)
        {
            ExtraInfo := "Output does not match expected output.", TestStatus := "Fail"
            If Debug
                ShowOutput(TestName,1,Output)
        }
        Else
            ExtraInfo := "Executed in " . Temp1 . " milliseconds.", TestStatus := "Pass"
    }
    Else
        ExtraInfo := "Invalid test.", TestStatus := "Fail"
    LV_Add("",TestIndex,TestName,TestStatus,ExtraInfo), TestIndex ++
}
Return

TestParser:
CodeSetScript(FileName)
Loop, %A_ScriptDir%\Parser\*.txt
{
    TestName := "Parser - " . A_LoopFileName
    FileRead(FileContents,A_LoopFileLongPath)
    If RegExMatch(FileContents,"sS)^(?P<Tokens>.*?)\r?\n---\r?\n(?P<ErrorOutput>.*?)\r?\n---\r?\n(?P<TreeOutput>.*)$",Test)
    {
        TestTokens := ParseTokenDescription(TestTokens)
        StringReplace, TestErrorOutput, TestErrorOutput, `r,, All
        StringReplace, TestTreeOutput, TestTreeOutput, `r,, All
        Errors := [], SyntaxTree := ""
        Temp1 := StartTimer()
        SyntaxTree := CodeParse(TestTokens,Errors)
        Temp1 := StopTimer(Temp1) - ControlTimer
        If ((Output := ShowObject(Errors)) != TestErrorOutput)
        {
            ExtraInfo := "Generated errors do not match expected errors.", TestStatus := "Fail"
            If Debug
                ShowOutput(TestName,0,Output)
        }
        Else If ((Output := CodeReconstructShowSyntaxTree(SyntaxTree)) != TestTreeOutput)
        {
            ExtraInfo := "Output does not match expected output.", TestStatus := "Fail"
            If Debug
                ShowOutput(TestName,1,Output)
        }
        Else
            ExtraInfo := "Executed in " . Temp1 . " milliseconds.", TestStatus := "Pass"
    }
    Else
        ExtraInfo := "Invalid test.", TestStatus := "Fail"
    LV_Add("",TestIndex,TestName,TestStatus,ExtraInfo), TestIndex ++
}
Return

TestBytecode:
CodeSetScript(FileName)

Return

TestInterpreter:
CodeSetScript(FileName)

Return

GuiSize:
GuiControl, MoveDraw, Title, w%A_GuiWidth%
GuiControl, Move, Results, % "w" . (A_GuiWidth - 4) . " h" . (A_GuiHeight - 105)
GuiControl, Move, CopyReport, % "y" . (A_GuiHeight - 65)
GuiControl, MoveDraw, SaveReport, % "x" . (A_GuiWidth - 152) . " y" . (A_GuiHeight - 65)
Loop, 4
    LV_ModifyCol(A_Index,"AutoHdr")
Return

GuiEscape:
GuiClose:
ExitApp

CopyReport:
GenerateReport(TestReport)
Gui, Destroy
Clipboard := TestReport
MsgBox, 64, Copied, Report has been copied to the clipboard.
Return

SaveReport:
Gui, Hide
GenerateReport(TestReport)
FileSelectFile, FileName, S18, Report.txt, Please Select A Path To Save The Report To:, *.txt
If FileExist(FileName)
    FileDelete, %FileName%
FileAppend, %TestReport%, %FileName%
MsgBox, 64, Saved, Report has been saved to the following file:`n`n"%FileName%"
Return

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
        TestReport .= "`r`n" . Temp1 . A_Tab . A_Tab . A_Tab . Temp2 . ((Temp3 != "") ? " (" . Temp3 . ")" : "")
    }
    TestReport := "Tested with " . Index . " test(s):`r`n" . TestReport . "`r`n`r`n" . FailAmount . " test(s) failed:`r`n" . FailList . "`r`n`r`n" . PassAmount . " test(s) passed:`r`n" . PassList
}

StartTimer()
{
    TimerBefore := 0, DllCall("QueryPerformanceCounter","Int64*",TimerBefore)
    Return, TimerBefore
}

StopTimer(ByRef TimerBefore)
{
    TimerAfter := 0, DllCall("QueryPerformanceCounter","Int64*",TimerAfter), TickFrequency := 0, DllCall("QueryPerformanceFrequency","Int64*",TickFrequency)
    Return, (TimerAfter - TimerBefore) / (TickFrequency / 1000)
}

ParseTokenDescription(TokenDescription)
{
    global CodeTokenTypes
    StringReplace, TokenDescription, TokenDescription, %A_Tab%, %A_Space%, All
    StringReplace, TokenDescription, TokenDescription, `r,, All
    TokenDescription := Trim(TokenDescription,"`n"), Result := []
    Loop, Parse, TokenDescription, `n, %A_Space%
    {
        RegExMatch(A_LoopField,"iS)^File *(\d+) *: *(\w+) *\( *(\d+) *\) *: *'(.*)'$",Field)
        ObjInsert(Result,Object("File",Field1,"Type",CodeTokenTypes[Field2],"Position",Field3,"Value",Field4))
    }
    Return, Result
}
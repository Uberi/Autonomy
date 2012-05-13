#NoEnv

;wip: text based reports to stdout, clipboard, and file

class UnitTest
{
    Initialize()
    {
        global UnitTestTitle, UnitTestEntries
        Gui, UnitTest:Default
        Gui, Font, s16, Arial
        Gui, Add, Text, x0 y0 h30 vUnitTestTitle Center, Test Results:

        hImageList := IL_Create()
        IL_Add(hImageList,"imageres.dll",101) ;red shield with cross sign icon
        IL_Add(hImageList,"imageres.dll",102) ;green shield with checkmark icon
        IL_Add(hImageList,"imageres.dll",189) ;document icon
        Gui, Font, s10
        Gui, Add, TreeView, x10 y30 vUnitTestEntries ImageList%hImageList%

        Gui, Font, s8
        Gui, Add, StatusBar
        Gui, +Resize +MinSize320x200
        Gui, Show, w500 h400, Unit Test
        Gui, +LastFound
        Return

        UnitTestGuiSize:
        Gui, UnitTest:Default
        GuiControl, Move, UnitTestTitle, w%A_GuiWidth%
        GuiControl, Move, UnitTestEntries, % "w" . (A_GuiWidth - 20) . " h" . (A_GuiHeight - 60)
        Gui, +LastFound
        WinSet, Redraw
        Return

        UnitTestGuiClose:
        ExitApp
    }

    Test(Tests,hNode = 0,State = "")
    {
        static TestPrefix := "Test_"
        static CategoryPrefix := "Category_"

        If !IsObject(State)
        {
            State := Object()
            State.Passed := 0
            State.Failed := 0
        }

        CurrentStatus := True
        For Key, Value In Tests
        {
            If IsFunc(Value)
            {
                If RegExMatch(Key,"iS)" . TestPrefix . "\K[\w_]+",TestName)
                {
                    Result := True
                    ;try TestResult := Value() ;wip
                    try TestResult := Object("Value",Value).Value()
                    catch e
                        Result := False
                    If Result
                    {
                        State.Passed ++
                        hChildNode := TV_Add(TestName,hNode,"Icon2 Sort")
                        If (TestResult != "")
                            TV_Add(TestResult,hChildNode,"Icon3")
                    }
                    Else
                    {
                        CurrentStatus := False
                        State.Failed ++
                        hChildNode := TV_Add(TestName,hNode,"Icon1 Sort")
                        If (e != "")
                            TV_Add(e,hChildNode,"Icon3")
                    }
                }
            }
            Else If IsObject(Value)
            {
                If RegExMatch(Key,"iS)" . CategoryPrefix . "\K[\w_]+",CategoryName)
                {
                    hChildNode := TV_Add(CategoryName,hNode,"Icon2 Expand Bold Sort")
                    If !UnitTest.Test(Value,hChildNode,State) ;test category
                    {
                        CurrentStatus := False
                        TV_Modify(hChildNode,"Icon1")
                    }
                }
            }
            Else
                Continue

            ;update the status bar
            If State.Failed ;tests failed
                SB_SetIcon("imageres.dll",101) ;red shield with cross sign
            Else ;all tests in the category passed
                SB_SetIcon("imageres.dll",102) ;green shield with checkmark
            SB_SetText(State.Passed . " of " . (State.Passed + State.Failed) . " tests passed.")
        }

        Return, CurrentStatus
    }
}
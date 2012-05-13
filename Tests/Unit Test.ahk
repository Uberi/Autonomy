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

    Test(Tests,hNode = 0)
    {
        TestPrefix := "Test_"
        CategoryPrefix := "Category_"

        Passed := 0
        Failed := 0
        Total := 0

        For Key, Value In Tests
        {
            If IsFunc(Value)
            {
                If !RegExMatch(Key,"iS)" . TestPrefix . "\K[\w_]+",TestName)
                    Continue
    
                Total ++
                ;try TestResult := Value() ;wip
                try TestResult := Object("Value",Value).Value()
                catch e
                {
                    Failed ++
                    hChildNode := TV_Add(TestName,hNode,"Icon1 Sort")
                    If (e != "")
                        TV_Add(e,hChildNode,"Icon3")
                    Continue
                }
                Passed ++
                hChildNode := TV_Add(TestName,hNode,"Icon2 Sort")
                If (TestResult != "")
                    TV_Add(TestResult,hChildNode,"Icon3")
            }
            Else If IsObject(Value)
            {
                If !RegExMatch(Key,"iS)" . CategoryPrefix . "\K[\w_]+",CategoryName)
                    Continue

                hChildNode := TV_Add(CategoryName,hNode,"Icon2 Expand Bold Sort")

                CategoryResult := UnitTest.Test(Value,hChildNode) ;test category

                Passed += CategoryResult.Passed
                Failed += CategoryResult.Failed
                Total += CategoryResult.Total

                If CategoryResult.Failed ;tests in the category failed
                    TV_Modify(hChildNode,"Icon1")
            }
        }

        If hNode = 0 ;root node
        {
            If Failed ;tests failed
                SB_SetIcon("imageres.dll",101) ;red shield with cross sign
            Else ;all tests in the category passed
                SB_SetIcon("imageres.dll",102) ;green shield with checkmark
            SB_SetText(Passed . " of " . Total . " tests passed.")
        }

        Result := Object()
        Result.Passed := Passed
        Result.Failed := Failed
        Result.Total := Total
        Return, Result
    }
}
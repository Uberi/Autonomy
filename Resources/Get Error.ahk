#NoEnv

;#Include Functions.ahk

/*
Error Array Format

[Index]: [Object]
	Level: the class of the error ["Error", "Warning", or "Info"]
	Identifier: the name of the error [Word]
	Caret: exact location of error [Number]
	Highlight: [Object or Blank]
		Length: length of the highlighted section [Number]
		Position: position of hightlighted section [Number]

Example

4:
	Level: Error
	Identifier: INVALID_SYNTAX
	Caret: 17
	Highlight:
		Length: 3
		Position: 13
*/

;creates a formatted summary of errors
CodeGetError(ByRef Code,ByRef Errors)
{
 global CodeErrorMessages

 DisplayLength := 15 ;amount of characters to display on either side of the code

 ErrorReport := ""
 For ErrorIndex, CurrentError In Errors
 {
  CodeGetErrorBounds(CurrentError,ErrorStart,ErrorEnd)

  ;move back one character if there is a newline at the end
  Temp1 := SubStr(Code,ErrorEnd,1)
  If ((Temp1 <> "") && InStr("`r`n",Temp1)) ;not past the end of the input, and newline found at the end of the error
   ErrorEnd --

  ;ensure there is enough padding for the highlights and caret
  ErrorDisplay := ""
  Loop, % ErrorEnd - ErrorStart
   ErrorDisplay .= " "

  ;iterate over the error highlights to highlight the incorrect code
  For Index, Highlight In CurrentError.Highlight
  {
   Position := (Highlight.Position - ErrorStart) + 1, Length := Highlight.Length
   If (Position < 1)
    Position := 1
   Temp1 := SubStr(ErrorDisplay,1,Position - 1)
   Loop, %Length%
    Temp1 .= "-"
   ErrorDisplay := Temp1 . SubStr(ErrorDisplay,Position + Length)
  }

  ;insert the caret to show the exact location of the error
  Caret := CurrentError.Caret
  If (Caret <> "")
  {
   Position := (Caret - ErrorStart) + 1, Pad := ""
   If (Position < 1)
   Position := 1
   ErrorDisplay := SubStr(ErrorDisplay,1,Position - 1) . "^" . SubStr(ErrorDisplay,Position + 1)
  }

  CodeGetErrorShowBefore(Code,ErrorSection,ErrorDisplay,ErrorStart,DisplayLength)
  ErrorSection .= SubStr(Code,ErrorStart,ErrorEnd - ErrorStart) ;show the code that is causing the error
  CodeGetErrorShowAfter(Code,ErrorSection,ErrorEnd,DisplayLength)
  CodeGetErrorPosition(Code,Caret,Line,Column)
  Message := CodeErrorMessages[CurrentError.Identifier] ;get the error message
  ErrorReport .= CurrentError.Level . " in " . CurrentError.File . " (Line " . Line . ", Column " . Column . "): " . Message . "`nSpecifically: " . ErrorSection . "`n              " . ErrorDisplay . "`n`n"
 }
 Return, ErrorReport
}

;retrieves the boundaries of the error
CodeGetErrorBounds(CurrentError,ByRef ErrorStart,ByRef ErrorEnd)
{
 ErrorStart := "", ErrorEnd := ""
 For Index, Highlight In CurrentError.Highlight
 {
  Temp1 := Highlight.Position, Temp2 := Temp1 + Highlight.Length
  If (A_Index = 1)
   ErrorStart := Temp1, ErrorEnd := Temp2
  Else
  {
   If (Temp1 < ErrorStart)
    ErrorStart := Temp1
   If (Temp2 > ErrorEnd)
    ErrorEnd := Temp2
  }
 }
 Temp1 := CurrentError.Caret
 If (Temp1 <> "")
 {
  Temp2 := Temp1 + 1
  If ((Temp1 < ErrorStart) || (ErrorStart = ""))
   ErrorStart := Temp1
  If ((Temp2 > ErrorEnd) || (ErrorEnd = ""))
   ErrorEnd := Temp2
 }
}

;show some of the code in the current line, before the error, and pad the error display accordingly
CodeGetErrorShowBefore(ByRef Code,ByRef ErrorSection,ByRef ErrorDisplay,ErrorStart,DisplayLength)
{
 ;get the beginning of the line containing the error
 Temp2 := (ErrorStart - 1) - StrLen(Code)
 Temp1 := InStr(Code,"`r",1,Temp2), Temp2 := InStr(Code,"`n",1,Temp2)
 Temp2 := ((Temp1 > Temp2) ? Temp1 : Temp2) + 1

 ;retrieve the code and pad the error display
 Temp1 := ErrorStart - DisplayLength
 Temp2 := (Temp1 < Temp2) ? Temp2 : Temp1 ;get start of the section to display
 Temp1 := ErrorStart - Temp2
 ErrorSection := SubStr(Code,Temp2,Temp1), Pad := ""
 Loop, %Temp1%
  Pad .= " "
 ErrorDisplay := Pad . ErrorDisplay
}

;show some of the code in the current line, after the error
CodeGetErrorShowAfter(ByRef Code,ByRef ErrorSection,ErrorEnd,DisplayLength)
{
 ;get the end of the line containing the error
 Temp1 := InStr(Code,"`r",1,ErrorEnd), Temp2 := InStr(Code,"`n",1,ErrorEnd)
 If (Temp2 = 0)
  Temp2 := Temp1
 Else If (Temp1 <> 0)
  Temp2 := (Temp1 < Temp2) ? Temp1 : Temp2

 ;retrieve the code
 DisplayLength += ErrorEnd
 If (DisplayLength > Temp2)
  DisplayLength := Temp2
 ErrorSection .= SubStr(Code,ErrorEnd,DisplayLength - ErrorEnd)
}

;finds the line and column the error occurred on
CodeGetErrorPosition(ByRef Code,Caret,ByRef Line,ByRef Column)
{
 Temp1 := SubStr(Code,1,Caret - 1)
 StringReplace, Temp1, Temp1, `r`n, `n, All
 StringReplace, Temp1, Temp1, `r, `n, All
 StringReplace, Temp1, Temp1, `n, `n, UseErrorLevel
 Line := ErrorLevel + 1
 Temp1 := "`n" . Temp1, Column := StrLen(SubStr(Temp1,InStr(Temp1,"`n",1,0) + 1)) + 1
}
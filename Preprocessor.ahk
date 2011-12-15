#NoEnv

#Include Code.ahk
#Include Lexer.ahk
#Include Resources/Functions.ahk

/*
Copyright 2011 Anthony Zhang <azhang9@gmail.com>

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

/*
Preprocessor Expressions
------------------------

The preprocessor supports simple expressions in the form:

    #Define SOME_DEFINITION := 3
    #Define ANOTHER_DEFINITION := 2 * (5 + SOME_DEFINITION)
    #Define SOME_DEFINITION := "A String"
    #If SOME_DEFINITION = "A " . "String"
    ;...
    #ElseIf SOME_DEFINITION = "Something else"
    ;...
    #Else
    #Error 1, "Unsupported platform."
    #EndIf

However, there are a few limitations:

* Only the following operators can be used: "||", "&&", "=", "==", "!=", "!==", ">", "<", ">=", "<=", " . ", "&" (binary form), "^", "|", "<<", ">>", "+", "-" (binary and unary forms), "*" (binary form), "/", "//", "!", "~", "**"
* Only parentheses, string or number literals, and other definition identifiers are allowed in the expressions
* Function calls are not allowed
* The definition directive requires all definitions to use the "[Identifier] := [Expression]" form
*/

;initializes resources that the preprocessor requires
CodePreprocessInit(ByRef Files,ByRef CurrentDirectory = "")
{
    global CodePreprocessorIncludeDirectory, CodePreprocessorLibraryPaths

    If (ObjHasKey(Files,1) && (Path := Files.1) != "") ;file path given, set the include directory to the directory of the script
        CodePreprocessorIncludeDirectory := PathSplit(Path).Directory
    Else If (CurrentDirectory != "") ;include directory given explicitly
        CodePreprocessorIncludeDirectory := CurrentDirectory
    Else ;no path given, set the include directory to the directory of this script
        CodePreprocessorIncludeDirectory := A_ScriptDir

    CodePreprocessorLibraryPaths := [PathJoin(CodePreprocessorIncludeDirectory,"Lib"),PathJoin(A_MyDocuments,"AutoHotkey","Lib"),PathJoin(A_ScriptDir,"Lib")] ;paths that are searched for libraries
}

;preprocesses a token stream containing preprocessor directives
CodePreprocess(ByRef Tokens,ByRef ProcessedTokens,ByRef Errors,ByRef Files,FileIndex = 1)
{ ;returns 1 on error, 0 otherwise
    global CodeTokenTypes

    ProcessedTokens := [], Index := 1, PreprocessError := 0, Definitions := []
    While, IsObject(Token := Tokens[Index])
    {
        Index ++ ;move past the statement, or the token if it is not a statement
        If (Token.Type != CodeTokenTypes.STATEMENT) ;skip over any tokens that are not statements
        {
            ObjInsert(ProcessedTokens,Token) ;copy the token to the output stream
            Continue
        }
        Directive := Token.Value
        If (Directive = "#Include") ;script inclusion
            PreprocessError := CodePreprocessInclusion(Tokens[Index],Index,ProcessedTokens,Errors,Files,FileIndex) || PreprocessError
        Else If (Directive = "#Define") ;identifier macro or function macro definition
            PreprocessError := CodePreprocessDefinition(Tokens,Index,ProcessedTokens,Definitions,Errors,FileIndex) || PreprocessError ;macro definition
        Else If (Directive = "#Undefine") ;removal of existing macro
            PreprocessError := CodePreprocessRemoveDefinition(Tokens,Index,Definitions,Errors) || PreprocessError
        /*
        Else If (Directive = "#If") ;conditional code checking simple expressions against definitions
            ;wip: process here
        Else If (Directive = "#ElseIf") ;conditional code checking alternative simple expressions against definitions
            ;wip: process here
        Else If (Directive = "#Else") ;conditional code checking alternative
            ;wip: process here
        Else If (Directive = "#EndIf") ;conditional code block end
            ;wip: process here
        Else If (Directive = "#Error") ;compilation error raising
            ;wip: process here
        */
        Else
            ObjInsert(ProcessedTokens,Token) ;copy the token to the output stream, move past the parameter or line end
        Index ++ ;move to the next token
    }
    Temp1 := ObjMaxIndex(ProcessedTokens) ;get the highest token index
    If (ProcessedTokens[Temp1].Type = CodeTokenTypes.LINE_END) ;token is a newline
        ObjRemove(ProcessedTokens,Temp1,"") ;remove the last token
    Return, PreprocessError
}

;preprocesses an inclusion directive
CodePreprocessInclusion(Token,ByRef TokenIndex,ByRef ProcessedTokens,ByRef Errors,ByRef Files,FileIndex)
{ ;returns 1 on inclusion failure, 0 otherwise
    global CodePreprocessorIncludeDirectory, CodePreprocessorLibraryPaths

    Parameter := Token.Value ;retrieve the next token, the parameters given to the statement

    If (SubStr(Parameter,1,1) = "<") ;library file: #Include <LibraryName>
    {
        Parameter := SubStr(Parameter,2,-1) ;remove surrounding angle brackets
        For Index, Path In CodePreprocessorLibraryPaths ;loop through each folder looking for the file
        {
            Temp1 := PathExpand(Parameter,Path,Attributes)
            If (Attributes != "") ;found script file
            {
                Parameter := Temp1
                Break
            }
        }
    }
    Else
        Parameter := PathExpand(Parameter,CodePreprocessorIncludeDirectory,Attributes)
    If (Attributes = "") ;file not found
    {
        CodeRecordErrorTokens(Errors,"FILE_ERROR",3,Token)
        TokenIndex ++ ;skip past extra line end token
        Return, 1
    }
    If InStr(Attributes,"D") ;is a directory
    {
        CodePreprocessorIncludeDirectory := Parameter ;set the current include directory
        TokenIndex ++ ;skip past extra line end token
        Return, 0
    }
    For Index, Temp1 In Files ;check if the file has already been included
    {
        If (Temp1 = Parameter) ;found file already included
        {
            CodeRecordErrorTokens(Errors,"DUPLICATE_INCLUSION",1,Token)
            TokenIndex ++ ;skip past extra line end token
            Return, 0
        }
    }

    If (FileRead(Code,Parameter) != 0) ;error reading file
    {
        CodeRecordErrorTokens(Errors,"FILE_ERROR",3,Token)
        TokenIndex ++ ;skip past extra line end token
        Return, 1
    }

    ;add file to list of included files, since it has not been included yet
    FileIndex := ObjMaxIndex(Files) + 1 ;get the index to insert the file entry at
    ObjInsert(Files,FileIndex,Parameter) ;add the current script file to the file array

    FileTokens := CodeLex(Code,Errors,FileIndex) ;lex the external file
    CodePreprocess(FileTokens,FileProcessedTokens,Errors,Files,FileIndex) ;preprocess the tokens

    ;copy tokens from included file into the main token stream
    For Index, Token In FileProcessedTokens
        ObjInsert(ProcessedTokens,Token)

    Return, 0
}

;preprocesses a definition directive
CodePreprocessDefinition(ByRef Tokens,ByRef Index,ByRef ProcessedTokens,ByRef Definitions,ByRef Errors,FileIndex)
{ ;returns 1 on invalid definition syntax, 0 otherwise
    global CodeTokenTypes
    Token := Tokens[Index], NextToken := Tokens[Index + 1]
    If (Token.Type = CodeTokenTypes.IDENTIFIER) ;token is an identifier
    {
        If (NextToken.Type = CodeTokenTypes.OPERATOR && NextToken.Value = ":=") ;identifier is followed by literal assignment ;wip: remove literal ":=" for an identifier
        {
            Identifier := Token.Value, Index += 2 ;retrieve the identifier name, move past the identifier and assignment operator tokens
            If ObjHasKey(Definitions,Identifier)
                CodeRecordErrorTokens(Errors,"DUPLICATE_DEFINITION",2,0,[Token])
            If CodePreprocessEvaluate(Tokens,Index,Result,Definitions,Errors,FileIndex)
                Return, 1
            ObjInsert(Definitions,Identifier,Result.1)
            MsgBox % ShowObject(Definitions) ;wip: debug
            Return, 0
        }
        Else
            CodeRecordErrorTokens(Errors,"INVALID_DIRECTIVE_SYNTAX",3,NextToken,[Token])
    }
    Else
        CodeRecordErrorTokens(Errors,"INVALID_DIRECTIVE_SYNTAX",3,Token,[NextToken])
    TokensLength := ObjMaxIndex(Tokens)
    While, (Index <= TokensLength && Tokens[Index].Type != CodeTokenTypes.LINE_END) ;loop over tokens until the end of the line
        Index ++
    Return, 1
}

;preprocesses a definition removal directive
CodePreprocessRemoveDefinition(ByRef Tokens,Index,ByRef Definitions,Errors)
{ ;returns 1 on invalid definition removal syntax, 0 otherwise
    global CodeTokenTypes

    Token := Tokens[Index]
    If (Token.Type != CodeTokenTypes.IDENTIFIER || Tokens[Index + 1].Type != CodeTokenTypes.LINE_END) ;token is not an identifier or the token after it is not a line end
    {
        CodeRecordErrorTokens(Errors,"INVALID_DIRECTIVE_SYNTAX",3,Token)
        Return, 1
    }
    CurrentDefinition := Token.Value
    If ObjHasKey(Definitions,CurrentDefinition) ;remove the key if it exists
        ObjRemove(Definitions,CurrentDefinition)
    Else ;warn that the key does not exist
        CodeRecordErrorTokens(Errors,"UNDEFINED_MACRO",2,Token)
    Return, 0
}

;evaluates a simple preprocessor expression ;wip: replace with TDOP evaluator
CodePreprocessEvaluate(ByRef Tokens,ByRef Index,ByRef Result,ByRef Definitions,ByRef Errors,FileIndex)
{ ;returns 1 on evaluation error, 0 otherwise
    global CodeTokenTypes, CodeOperatorTable

    ;wip: use parser for evaluating expressions
    Return, EvaluationError
}
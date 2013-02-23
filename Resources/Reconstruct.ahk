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

class Reconstruct
{
    Tokens(Value)
    {
        Result := ""
        For Index, Token In Value
        {
            If Token.Type = "OperatorNull"
                Result .= Token.Position . ":" . Token.Length . "`t" . Token.Type . "`t" . Token.Value . "`n"
            If Token.Type = "OperatorLeft"
                Result .= Token.Position . ":" . Token.Length . "`t" . Token.Type . "`t" . Token.Value . "`n"
            If Token.Type = "Line"
                Result .= Token.Position . ":" . Token.Length . "`t" . Token.Type . "`n"
            If Token.Type = "Separator"
                Result .= Token.Position . ":" . Token.Length . "`t" . Token.Type . "`n"
            If Token.Type = "Map"
                Result .= Token.Position . ":" . Token.Length . "`t" . Token.Type . "`n"
            If Token.Type = "String"
                Result .= Token.Position . ":" . Token.Length . "`t" . Token.Type . "`t""" . Token.Value . """`n"
            If Token.Type = "Identifier"
                Result .= Token.Position . ":" . Token.Length . "`t" . Token.Type . "`t" . Token.Value . "`n"
            If Token.Type = "Number"
                Result .= Token.Position . ":" . Token.Length . "`t" . Token.Type . "`t" . Token.Value . "`n"
            If Token.Type = "Comment"
                Result .= Token.Position . ":" . Token.Length . "`t" . Token.Type . "`t""" . Token.Value . """`n"
        }
        Return, SubStr(Result,1,-1)
    }

    Tree(Value)
    {
        If Value.Type = "Operation"
        {
            Result := "(" . this.Tree(Value.Value)
            For Index, Parameter In Value.Parameters
                Result .= " " . this.Tree(Parameter)
            Return, Result . ")"
        }
        If Value.Type = "Block"
        {
            Result := ""
            For Index, Content In Value.Contents
                Result .= this.Tree(Content) . " "
            Return, "{" . SubStr(Result,1,-1) . "}"
        }
        If Value.Type = "Symbol"
            Return, "'" . Value.Value
        If Value.Type = "String"
            Return, """" . Value.Value . """"
        If Value.Type = "Identifier"
            Return, Value.Value
        If Value.Type = "Number"
            Return, Value.Value
        Return, "UNKNOWN_VALUE"
    }

    Bytecode(Value)
    {
        Result := ""
        For Index, Code In Value
            Result .= Code . "`n"
        Return, SubStr(Result,1,-1)
    }
}

CodeRecontructSyntaxTree(SyntaxTree) ;wip
{
    global CodeTokenTypes
    If (SyntaxTree.1.Type = CodeTokenTypes.OPERATOR)
        Operator := SyntaxTree.1.Value, ObjRemove(SyntaxTree,1,1)
    For Index, Node In SyntaxTree
    {
        NodeType := Node.Type, NodeValue := Node.Value
        If (NodeType = CodeTokenTypes.NODE)
            Code .= CodeRecontructSyntaxTree(NodeValue)
        Else If (NodeType = CodeTokenTypes.LITERAL_STRING)
            Code .= """" . NodeValue . """"
        Else If (NodeType = CodeTokenTypes.STATEMENT)
            Code .= NodeValue . " "
        Else
            Code .= NodeValue
        Code .= ","
    }
    Return, Operator . "(" . SubStr(Code,1,-1) . ")"
}

SearchObject(InputObject,SearchValue) ;wip: remove the need for this function with ObjFind()
{
    For Key, Value In InputObject
    {
        If (Value = SearchValue)
            Return, Key
    }
}

Pad(Length,Character = " ")
{
    Result := ""
    Loop, %Length%
        Result .= Character
    Return, Result
}
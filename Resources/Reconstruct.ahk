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
                Result .= Token.Position . ":" . Token.Length . "`t" . Token.Type . "`t" . Token.Value.Identifier . "`n"
            Else If Token.Type = "OperatorLeft"
                Result .= Token.Position . ":" . Token.Length . "`t" . Token.Type . "`t" . Token.Value.Identifier . "`n"
            Else If Token.Type = "Line"
                Result .= Token.Position . ":" . Token.Length . "`t" . Token.Type . "`n"
            Else If Token.Type = "Separator"
                Result .= Token.Position . ":" . Token.Length . "`t" . Token.Type . "`n"
            Else If Token.Type = "Map"
                Result .= Token.Position . ":" . Token.Length . "`t" . Token.Type . "`n"
            Else If Token.Type = "Symbol"
                Result .= Token.Position . ":" . Token.Length . "`t" . Token.Type . "`t" . Token.Value . "`n"
            Else If Token.Type = "String"
                Result .= Token.Position . ":" . Token.Length . "`t" . Token.Type . "`t""" . Token.Value . """`n"
            Else If Token.Type = "Identifier"
                Result .= Token.Position . ":" . Token.Length . "`t" . Token.Type . "`t" . Token.Value . "`n"
            Else If Token.Type = "Number"
                Result .= Token.Position . ":" . Token.Length . "`t" . Token.Type . "`t" . Token.Value . "`n"
            Else If Token.Type = "Comment"
                Result .= Token.Position . ":" . Token.Length . "`t" . Token.Type . "`t""" . Token.Value . """`n"
        }
        Return, SubStr(Result,1,-1)
    }

    Tree(Value)
    {
        static OperatorUnary := {_address: "&"
                                ,_bit_not: "~"
                                ,_invert:  "-"
                                ,_not:     "!"}
        static OperatorBinary := {_exponentiate:          "**"
                                 ,_modulo:                "%%"
                                 ,_remainder:             "%"
                                 ,_divide_floor:          "//"
                                 ,_divide:                "/"
                                 ,_multiply:              "*"
                                 ,_subtract:              "-"
                                 ,_add:                   "+"
                                 ,_shift_right_unsigned:  ">>>"
                                 ,_shift_right:           ">>"
                                 ,_shift_left:            "<<"
                                 ,_bit_and:               "&"
                                 ,_bit_exclusive_or:      "^"
                                 ,_bit_or:                "|"
                                 ,_concatenate:           ".."
                                 ,_less_than_or_equal:    "<="
                                 ,_greater_than_or_equal: ">="
                                 ,_less_than:             "<"
                                 ,_greater_than:          ">"
                                 ,_not_equals_strict:     "!=="
                                 ,_not_equals:            "!="
                                 ,_equals_strict:         "=="
                                 ,_equals:                "="}
        If Value.Type = "Operation"
        {
            Callable := Value.Value
            Parameters := Value.Parameters
            If Callable.Type = "Identifier"
            {
                If Callable.Value = "_subscript"
                {
                    If Parameters[2].Type = "Symbol"
                        Return, "(" . this.Tree(Parameters[1]) . "." . Parameters[2].Value . ")"
                    Return, this.Tree(Parameters[1]) . "[" . this.Tree(Parameters[2]) . "]"
                }
                If Callable.Value = "_slice"
                {
                    If Parameters.HasKey(4)
                        Return, this.Tree(Parameters[1]) . "[" . this.Tree(Parameters[2]) . ":" . this.Tree(Parameters[3]) . ":" . this.Tree(Parameters[4]) . "]"
                    Return, this.Tree(Parameters[1]) . "[" . this.Tree(Parameters[2]) . ":" . this.Tree(Parameters[3]) . "]"
                }
                If Callable.Value = "_compare"
                {
                    Result := "(" . this.Tree(Parameters[1])
                    Index := 2
                    Loop, % Parameters.MaxIndex() // 2
                    {
                        Result .= " " . OperatorBinary[Parameters[Index].Value]
                        Index ++
                        Result .= " " . this.Tree(Parameters[Index])
                        Index ++
                    }
                    Return, Result . ")"
                }
                If Callable.Value = "_array"
                {
                    Result := "["
                    ParameterValue := []
                    Loop, % Parameters.MaxIndex()
                        ParameterValue.Insert(Parameters.HasKey(A_Index) ? this.Tree(Parameters[A_Index]) : "")
                    For Key, Parameter In Parameters
                    {
                        If IsObject(Key)
                            ParameterValue.Insert(this.Tree(Key) . ": " . this.Tree(Parameter))
                    }
                    For Index, Value In ParameterValue
                    {
                        If Index != 1
                            Result .= "," . (Value = "" ? "" : " ")
                        Result .= Value
                    }
                    Return, Result . "]"
                }
                If Callable.Value = "_evaluate"
                {
                    Result := "("
                    For Index, Parameter In Parameters
                        Result .= this.Tree(Parameter) . "`n"
                    Return, SubStr(Result,1,-1) . ")"
                }
                If Callable.Value = "_and"
                    Return, "(" . this.Tree(Parameters[1]) . " && " . this.Tree(Parameters[2].Contents[1]) . ")"
                If Callable.Value = "_or"
                    Return, "(" . this.Tree(Parameters[1]) . " || " . this.Tree(Parameters[2].Contents[1]) . ")"
                If Callable.Value = "_if"
                    Return, "(" . this.Tree(Parameters[1]) . " ? " . this.Tree(Parameters[2].Contents[1]) . " : " . this.Tree(Parameters[3].Contents[1]) . ")"
                If OperatorUnary.HasKey(Callable.Value)
                    Return, "(" . OperatorUnary[Callable.Value] . this.Tree(Parameters[1]) . ")"
                If OperatorBinary.HasKey(Callable.Value)
                    Return, "(" . this.Tree(Parameters[1]) . " " . OperatorBinary[Callable.Value] . " " . this.Tree(Parameters[2]) . ")"
            }
            Result := this.Tree(Value.Value) . "("
            ParameterValue := []
            Loop, % Parameters.MaxIndex()
                ParameterValue.Insert(Parameters.HasKey(A_Index) ? this.Tree(Parameters[A_Index]) : "")
            For Key, Parameter In Parameters
            {
                If IsObject(Key)
                    ParameterValue.Insert(this.Tree(Key) . ": " . this.Tree(Parameter))
            }
            For Index, Value In ParameterValue
            {
                If Index != 1
                    Result .= "," . (Value = "" ? "" : " ")
                Result .= Value
            }
            Return, Result . ")"
        }
        If Value.Type = "Block"
        {
            Result := ""
            For Index, Content In Value.Contents
                Result .= this.Tree(Content) . "`n"
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
        Return, "(UNKNOWN_VALUE)"
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
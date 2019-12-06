%{
    /* definition */
    #include <stdio.h>
    #include <termio.h>
    #include <ctype.h>
    #include <cmath>
    #include <iostream>
    #include <iomanip>
    #include <map>
    #include <string>
    #include <vector>
    #include <algorithm>
    #include "minipy-lab.h"
    using namespace std;
    /*
        符号表 Symbol Table
        variableName(string) -> Value(not Variable)
    */
    map<string, struct value> Symbol;
    typedef struct value
    {
        Type type;
        int integerValue;               /* value for int type */
        double realValue;               /* value for real type */
        string stringValue;             /* value for string type */
        vector<struct value> listValue; /* value for list type */
        string variableName;            /* name of the Variable */
        string attributeName;           /* name of the attribute */
        bool transparent;               /* display(false) or not */
        // slice or item of List
        vector<struct value>::iterator begin; // slice 起始位置 或 item 坐标
        vector<struct value>::iterator end;
        int step;

        // Overload the operator
        bool operator==(const value that) const
        {
            struct value A, B;
            if (this->type == Variable)
                A = Symbol.at(this->variableName);
            else if (this->type == ListItem)
                A = *(this->begin);
            else
                A = *this;
            if (that.type == Variable)
                B = Symbol.at(that.variableName);
            else if (that.type == ListItem)
                B = *(that.begin);
            else
                B = that;
            switch (A.type)
            {
                case Integer:
                    return (A.type == B.type && A.integerValue == B.integerValue);
                case Real:
                    return (A.type == B.type && A.realValue == B.realValue);
                case String:
                    return (A.type == B.type && A.stringValue == B.stringValue);
                case List:
                case ListSlice:
                    return ((B.type == List || B.type == ListSlice) && (A.listValue == B.listValue));
                default:
                    return false;
            }
        }
    } Value;



    #define YYSTYPE Value
    #include "lex.yy.c"
    void yyerror(string);
    // extern yy_buffer_state * yy_scan_string(char *);
    // extern void yy_delete_buffer(yy_buffer_state * Buffer);

    // 变量值的输出函数
    void Print(Value);

    // 返回变量类型的字符串
    string TypeString(Value);

    // 返回可迭代实体的长度
    int Length(Value);
%}

%token ID INT REAL STRING_LITERAL
%token DIV
%left  '+' '-'
%left  '*' '/' '%' DIV
%right UMINUS

%%
Start:
    Lines
;

Lines:
    Lines stat
    {
        Value temp;
        if ($2.type != None)
        {
            if ($2.transparent == false)
            {
                if ($2.type == Variable) /* 单独的变量 */
                    Print(Symbol.at($2.variableName));
                else
                    Print($2);
                cout << endl;
            }
        }
    } |
    /* empty production */ |
    error '\n' { yyerrok; }
;


stat:
	assignExpr
;

assignExpr:
    atom_expr '=' assignExpr
    {
        Value temp;
        if ($3.type == Variable)
            temp = Symbol.at($3.variableName);
        else
            temp = $3;

        switch ($1.type)
        {
            case Variable:
                Symbol[$1.variableName] = temp; /* 加入符号表或重新赋值 */
                break;
            case ListItem:
                *$1.begin = temp;
                break;
            case ListSlice:
                switch (temp.type)
                {
                    case List:
                        if ($1.step == 1) // 默认步长
                        {
                            Symbol[$1.variableName].listValue.erase($1.begin, $1.end);
                            Symbol[$1.variableName].listValue.insert($1.begin, temp.listValue.begin(), temp.listValue.end()); // 插入
                        }
                        else
                        {
                            if ($1.listValue.size() == temp.listValue.size()) // 长度对等
                            {
                                for (vector<struct value>::iterator i = $1.begin, j = temp.listValue.begin(); j < temp.listValue.end(); i += $1.step, j++)
                                    *i = *j;
                                $1.listValue = temp.listValue;
                            }
                            else
                            {
                                yyerror("ValueError: attempt to assign sequence of size " + to_string(temp.listValue.size()) + " to extended slice of size " + to_string($1.listValue.size()));
                                YYERROR;
                            }
                        }
                        break;
                    case ListSlice:
                        if ($1.step == 1) // 默认步长
                        {
                            Symbol[$1.variableName].listValue.erase($1.begin, $1.end);
                            Symbol[$1.variableName].listValue.insert($1.begin, temp.listValue.begin(), temp.listValue.end()); // 插入
                        }
                        else
                        {
                            if ($1.listValue.size() == temp.listValue.size()) // 长度对等
                            {
                                for (vector<struct value>::iterator i = $1.begin, j = temp.listValue.begin(); j < temp.listValue.end(); i += $1.step, j++)
                                    *i = *j;
                                $1.listValue = temp.listValue;
                            }
                            else
                            {
                                yyerror("ValueError: attempt to assign sequence of size " + to_string(temp.listValue.size()) + " to extended slice of size " + to_string($1.listValue.size()));
                                YYERROR;
                            }
                        }
                        break;
                    case String:
                    {
                        vector<struct value> tempString = vector<struct value>();
                        Value tempChar; // 拆分字符串
                        tempChar.type = String;
                        for (int i = 0; i < temp.stringValue.length(); i++)
                        {
                            tempChar.stringValue = temp.stringValue[i];
                            tempString.push_back(tempChar);
                        }

                        if ($1.step == 1) // 默认步长
                        {
                            Symbol[$1.variableName].listValue.erase($1.begin, $1.end);
                            Symbol[$1.variableName].listValue.insert($1.begin, tempString.begin(), tempString.end()); // 插入
                        }
                        else
                        {
                            if ($1.listValue.size() == tempString.size()) // 长度对等
                            {
                                for (vector<struct value>::iterator i = $1.begin, j = tempString.begin(); j < tempString.end(); i += $1.step, j++)
                                    *i = *j;
                            }
                            else
                            {
                                yyerror("ValueError: attempt to assign sequence of size " + to_string(tempString.size()) + " to extended slice of size " + to_string($1.listValue.size()));
                                YYERROR;
                            }
                        }
                        break;
                    }
                    default:
                        yyerror("TypeError: can only assign an iterable");
                        YYERROR;
                }
                break;
            default:
                yyerror("SyntaxError: can't assign to literal");
                YYERROR;
        }
        $$ = $1;
        $$.transparent = true;
    } |
    add_expr
;

number:
    INT |
    REAL
;

factor:
    '+' factor
    {
        $$.type = $2.type;
        if ($2.type == Integer)
            $$.integerValue = $2.integerValue;
        else if ($2.type == Real)
            $$.realValue = $2.realValue;
        else
        {
            yyerror("TypeError: bad operand type for unary +: '"+ TypeString($2) + "\'");
            YYERROR;
        }
    } |
    '-' factor %prec UMINUS
    {
        $$.type = $2.type;
        if ($2.type == Integer)
            $$.integerValue = -$2.integerValue;
        else if ($2.type == Real)
            $$.realValue = -$2.realValue;
        else
        {
            yyerror("TypeError: bad operand type for unary -: '"+ TypeString($2) + "\'");
            YYERROR;
        }
    } |
    atom_expr
    {
        switch ($1.type)
        {
            case Integer:
            case Real:
            case String:
            case List:
                $$ = $1;
                break;
            case ListSlice:
                $$.type = List;
                $$.listValue = $1.listValue;
                break;
            case ListItem:
                $$ = *$1.begin;
                break;
            case Variable:
                if (Symbol.count($1.variableName) == 1) // 已在变量表内
                    $$ = Symbol.at($1.variableName); // 取变量内容，使用下标检查
                else
                {
                    yyerror("NameError: name '"+ $1.variableName +"' is not defined");
                    YYERROR;
                }
                break;
            // default:
            //     yyerror("TypeError: not supported type");
            //     YYERROR;
        }
    }
;

atom:
    ID |
    STRING_LITERAL |
    List |
    number
;

slice_op:
    /* empty production */ { $$.type = None; } |
    ':' { $$.type = None; } |
    ':' add_expr
    {
        $$.type = Integer;
        if ($2.type == Integer)
            $$.integerValue = $2.integerValue;
        else
        {
            yyerror("TypeError: slice indices must be integers or None");
            YYERROR;
        }
    }
;

sub_expr:
    /* empty production */ { $$.type = None; } |
    add_expr
;

atom_expr:
    atom |
    atom_expr  '[' sub_expr  ':' sub_expr  slice_op ']'
    {
        int begin, end;

        if ($6.type == None) // 默认步长
            $$.step = 1;
        else if ($6.type == Integer)
            $$.step = $6.integerValue;
        else
        {
            yyerror("TypeError: slice indices must be integers or None");
            YYERROR;
        }
        switch ($1.type)
        {
            case String:
                $$.type = String;
                $$.stringValue = "";

                if ($$.step > 0)
                {
                    if ($3.type == None) // 默认起始
                        begin = 0;
                    else if ($3.type == Integer)
                    {
                        begin = $3.integerValue;
                        if (begin < 0)
                            begin += $1.stringValue.length();
                        if (begin < 0)
                            begin = 0;
                        else if (begin >= $1.stringValue.length())
                            begin = $1.stringValue.length();
                    }
                    else
                    {
                        yyerror("TypeError: slice indices must be integers or None");
                        YYERROR;
                    }

                    if ($5.type == None) // 默认结束
                        end = $1.stringValue.length();
                    else if ($5.type == Integer)
                    {
                        end = $5.integerValue;
                        if (end < 0)
                            end += $1.stringValue.length();
                        if (end < 0)
                            end = 0;
                        else if (end >= $1.stringValue.length())
                            end = $1.stringValue.length();
                    }
                    else
                    {
                        yyerror("TypeError: slice indices must be integers or None");
                        YYERROR;
                    }
                    for (int i = begin; i < end; i += $$.step)
                        $$.stringValue += $1.stringValue[i]; // 逐个取子串
                }
                else if ($$.step < 0) // 负步长
                {
                    if ($3.type == None) // 默认起始
                        begin = $1.stringValue.length() - 1;
                    else if ($3.type == Integer)
                    {
                        begin = $3.integerValue;
                        if (begin < 0)
                            begin += $1.stringValue.length();
                        if (begin < 0)
                            begin = 0;
                        else if (begin >= $1.stringValue.length())
                            begin = $1.stringValue.length() - 1;
                    }
                    else
                    {
                        yyerror("TypeError: slice indices must be integers or None");
                        YYERROR;
                    }

                    if ($5.type == None) // 默认结束
                        end = -1;
                    else if ($5.type == Integer)
                    {
                        end = $5.integerValue;
                        if (end < 0)
                            end += $1.stringValue.length();
                        if (end < 0)
                            end = -1;
                        else if (end >= $1.stringValue.length())
                            end = $1.stringValue.length();
                    }
                    else
                    {
                        yyerror("TypeError: slice indices must be integers or None");
                        YYERROR;
                    }

                    for (int i = begin; i > end; i += $$.step)
                        $$.stringValue += $1.stringValue[i]; // 逐个取子串
                }
                break;
            case List:
                $$.type = List; // 实体列表的切片不作为切片类型处理
                $$.listValue = vector<struct value>();
                if ($$.step > 0)
                {
                    if ($3.type == None) // 默认起始
                        begin = 0;
                    else if ($3.type == Integer)
                    {
                        begin = $3.integerValue;
                        if (begin < 0)
                            begin += $1.listValue.size();
                        if (begin < 0)
                            begin = 0;
                        else if (begin >= $1.listValue.size())
                            begin = $1.listValue.size();
                    }
                    else
                    {
                        yyerror("TypeError: slice indices must be integers or None");
                        YYERROR;
                    }

                    if ($5.type == None) // 默认结束
                        end = $1.listValue.size();
                    else if ($5.type == Integer)
                    {
                        end = $5.integerValue;
                        if (end < 0)
                            end += $1.listValue.size();
                        if (end < 0)
                            end = 0;
                        else if (end >= $1.listValue.size())
                            end = $1.listValue.size();
                    }
                    else
                    {
                        yyerror("TypeError: slice indices must be integers or None");
                        YYERROR;
                    }

                    for (vector<struct value>::iterator i = $1.listValue.begin() + begin; i < $1.listValue.begin() + end; i += $$.step)
                        $$.listValue.push_back(*i); // 逐个取元素
                }
                else if ($$.step < 0)
                {
                    if ($3.type == None) // 默认起始
                        begin = $1.listValue.size() - 1;
                    else if ($3.type == Integer)
                    {
                        begin = $3.integerValue;
                        if (begin < 0)
                            begin += $1.listValue.size();
                        if (begin < 0)
                            begin = 0;
                        else if (begin >= $1.listValue.size())
                            begin = $1.listValue.size() - 1;
                    }
                    else
                    {
                        yyerror("TypeError: slice indices must be integers or None");
                        YYERROR;
                    }

                    if ($5.type == None) // 默认结束
                        end = -1;
                    else if ($5.type == Integer)
                    {
                        end = $5.integerValue;
                        if (end < 0)
                            end += $1.listValue.size();
                        if (end < 0)
                            end = -1;
                        else if (end >= $1.listValue.size())
                            end = $1.listValue.size();
                    }
                    else
                    {
                        yyerror("TypeError: slice indices must be integers or None");
                        YYERROR;
                    }

                    for (vector<struct value>::iterator i = $1.listValue.begin() + begin; i > $1.listValue.begin() + end; i += $$.step)
                        $$.listValue.push_back(*i); // 逐个取元素
                }
                break;
            case ListSlice:
                $$.type = ListSlice; // 列表元素类型
                $$.variableName = $1.variableName;
                $$.listValue = vector<struct value>();
                if ($$.step > 0)
                {
                    if ($3.type == None) // 默认起始
                        $$.begin = $1.begin;
                    else if ($3.type == Integer)
                    {
                        begin = $3.integerValue;
                        if (begin < 0)
                            begin += $1.listValue.size();
                        if (begin < 0)
                            begin = 0;
                        else if (begin > $1.listValue.size())
                            begin = $1.listValue.size();
                        $$.begin = $1.begin + begin;
                    }
                    else
                    {
                        yyerror("TypeError: slice indices must be integers or None");
                        YYERROR;
                    }

                    if ($5.type == None) // 默认结束
                        $$.end = $1.end;
                    else if ($5.type == Integer)
                    {
                        end = $5.integerValue;
                        if (end < 0)
                            end += $1.listValue.size();
                        if (end < 0)
                            end = 0;
                        else if (end > $1.listValue.size())
                            end = $1.listValue.size();
                        $$.end = $1.begin + end;
                    }
                    else
                    {
                        yyerror("TypeError: slice indices must be integers or None");
                        YYERROR;
                    }

                    for (vector<struct value>::iterator i = $$.begin; i < $$.end; i += $$.step)
                        $$.listValue.push_back(*i); // 逐个取子串

                }
                else if ($$.step < 0)
                {
                    if ($3.type == None) // 默认起始
                        $$.begin = $1.end - 1;
                    else if ($3.type == Integer)
                    {
                        begin = $3.integerValue;
                        if (begin < 0)
                            begin += $1.listValue.size();
                        if (begin < 0)
                            begin = 0;
                        else if (begin > $1.listValue.size())
                            begin = $1.listValue.size() - 1;
                        $$.begin = $1.begin + begin;
                    }
                    else
                    {
                        yyerror("TypeError: slice indices must be integers or None");
                        YYERROR;
                    }

                    if ($5.type == None) // 默认结束
                        $$.end = $1.begin - 1;
                    else if ($5.type == Integer)
                    {
                        end = $5.integerValue;
                        if (end < 0)
                            end += $1.listValue.size();
                        if (end < 0)
                            end = -1;
                        else if (end > $1.listValue.size())
                            end = $1.listValue.size();
                        $$.end = $1.begin + end;
                    }
                    else
                    {
                        yyerror("TypeError: slice indices must be integers or None");
                        YYERROR;
                    }

                    for (vector<struct value>::iterator i = $$.begin; i > $$.end; i += $$.step)
                        $$.listValue.push_back(*i); // 逐个取子串
                }
                break;
            case ListItem:
                switch ((*$1.begin).type)
                {
                    case String:
                        $$.type = String;
                        $$.stringValue = "";

                        if ($$.step > 0)
                        {
                            if ($3.type == None) // 默认起始
                                begin = 0;
                            else if ($3.type == Integer)
                            {
                                begin = $3.integerValue;
                                if (begin < 0)
                                    begin += (*$1.begin).stringValue.length();
                                if (begin < 0)
                                    begin = 0;
                                else if (begin >= (*$1.begin).stringValue.length())
                                    begin = (*$1.begin).stringValue.length();
                            }
                            else
                            {
                                yyerror("TypeError: slice indices must be integers or None");
                                YYERROR;
                            }

                            if ($5.type == None) // 默认结束
                                end = (*$1.begin).stringValue.length();
                            else if ($5.type == Integer)
                            {
                                end = $5.integerValue;
                                if (end < 0)
                                    end += (*$1.begin).stringValue.length();
                                if (end < 0)
                                    end = 0;
                                else if (end >= (*$1.begin).stringValue.length())
                                    end = (*$1.begin).stringValue.length();
                            }
                            else
                            {
                                yyerror("TypeError: slice indices must be integers or None");
                                YYERROR;
                            }
                            for (int i = begin; i < end; i += $$.step)
                                $$.stringValue += (*$1.begin).stringValue[i]; // 逐个取子串
                        }
                        else if ($$.step < 0) // 负步长
                        {
                            if ($3.type == None) // 默认起始
                                begin = (*$1.begin).stringValue.length() - 1;
                            else if ($3.type == Integer)
                            {
                                begin = $3.integerValue;
                                if (begin < 0)
                                    begin += (*$1.begin).stringValue.length();
                                if (begin < 0)
                                    begin = 0;
                                else if (begin >= (*$1.begin).stringValue.length())
                                    begin = (*$1.begin).stringValue.length() - 1;
                            }
                            else
                            {
                                yyerror("TypeError: slice indices must be integers or None");
                                YYERROR;
                            }

                            if ($5.type == None) // 默认结束
                                end = -1;
                            else if ($5.type == Integer)
                            {
                                end = $5.integerValue;
                                if (end < 0)
                                    end += (*$1.begin).stringValue.length();
                                if (end < 0)
                                    end = -1;
                                else if (end >= (*$1.begin).stringValue.length())
                                    end = (*$1.begin).stringValue.length();
                            }
                            else
                            {
                                yyerror("TypeError: slice indices must be integers or None");
                                YYERROR;
                            }

                            for (int i = begin; i > end; i += $$.step)
                                $$.stringValue += (*$1.begin).stringValue[i]; // 逐个取子串
                        }
                        break;
                    case List:
                        $$.type = ListSlice; // 列表元素类型
                        $$.variableName = $1.variableName;
                        $$.listValue = vector<struct value>();
                        if ($$.step > 0)
                        {
                            if ($3.type == None) // 默认起始
                                $$.begin = (*$1.begin).begin;
                            else if ($3.type == Integer)
                            {
                                begin = $3.integerValue;
                                if (begin < 0)
                                    begin += (*$1.begin).listValue.size();
                                if (begin < 0)
                                    begin = 0;
                                else if (begin > (*$1.begin).listValue.size())
                                    begin = (*$1.begin).listValue.size();
                                $$.begin = (*$1.begin).begin + begin;
                            }
                            else
                            {
                                yyerror("TypeError: slice indices must be integers or None");
                                YYERROR;
                            }

                            if ($5.type == None) // 默认结束
                                $$.end = (*$1.begin).end;
                            else if ($5.type == Integer)
                            {
                                end = $5.integerValue;
                                if (end < 0)
                                    end += (*$1.begin).listValue.size();
                                if (end < 0)
                                    end = 0;
                                else if (end > (*$1.begin).listValue.size())
                                    end = (*$1.begin).listValue.size();
                                $$.end = (*$1.begin).begin + end;
                            }
                            else
                            {
                                yyerror("TypeError: slice indices must be integers or None");
                                YYERROR;
                            }

                            for (vector<struct value>::iterator i = $$.begin; i < $$.end; i += $$.step)
                                $$.listValue.push_back(*i); // 逐个取子串

                        }
                        else if ($$.step < 0)
                        {
                            if ($3.type == None) // 默认起始
                                $$.begin = (*$1.begin).end - 1;
                            else if ($3.type == Integer)
                            {
                                begin = $3.integerValue;
                                if (begin < 0)
                                    begin += (*$1.begin).listValue.size();
                                if (begin < 0)
                                    begin = 0;
                                else if (begin > (*$1.begin).listValue.size())
                                    begin = (*$1.begin).listValue.size() - 1;
                                $$.begin = (*$1.begin).begin + begin;
                            }
                            else
                            {
                                yyerror("TypeError: slice indices must be integers or None");
                                YYERROR;
                            }

                            if ($5.type == None) // 默认结束
                                $$.end = (*$1.begin).begin - 1;
                            else if ($5.type == Integer)
                            {
                                end = $5.integerValue;
                                if (end < 0)
                                    end += (*$1.begin).listValue.size();
                                if (end < 0)
                                    end = -1;
                                else if (end > (*$1.begin).listValue.size())
                                    end = (*$1.begin).listValue.size();
                                $$.end = (*$1.begin).begin + end;
                            }
                            else
                            {
                                yyerror("TypeError: slice indices must be integers or None");
                                YYERROR;
                            }

                            for (vector<struct value>::iterator i = $$.begin; i > $$.end; i += $$.step)
                                $$.listValue.push_back(*i); // 逐个取子串
                        }
                        break;
                    default:
                        yyerror("TypeError: '"+ TypeString((*$1.begin)) +"' object is not subscriptable");
                        YYERROR;
                }
                break;
            case Variable:
                if ((Symbol.count($1.variableName) == 1)) // 已在变量表内
                {
                    switch (Symbol.at($1.variableName).type)
                    {
                        case String:
                            $$.type = String;
                            $$.stringValue = "";

                            if ($$.step > 0)
                            {
                                if ($3.type == None) // 默认起始
                                    begin = 0;
                                else if ($3.type == Integer)
                                {
                                    begin = $3.integerValue;
                                    if (begin < 0)
                                        begin += Symbol.at($1.variableName).stringValue.length();
                                    if (begin < 0)
                                        begin = 0;
                                    else if (begin >= Symbol.at($1.variableName).stringValue.length())
                                        begin = Symbol.at($1.variableName).stringValue.length();
                                }
                                else
                                {
                                    yyerror("TypeError: slice indices must be integers or None");
                                    YYERROR;
                                }

                                if ($5.type == None) // 默认结束
                                    end = Symbol.at($1.variableName).stringValue.length();
                                else if ($5.type == Integer)
                                {
                                    end = $5.integerValue;
                                    if (end < 0)
                                        end += Symbol.at($1.variableName).stringValue.length();
                                    if (end < 0)
                                        end = 0;
                                    else if (end >= Symbol.at($1.variableName).stringValue.length())
                                        end = Symbol.at($1.variableName).stringValue.length();
                                }
                                else
                                {
                                    yyerror("TypeError: slice indices must be integers or None");
                                    YYERROR;
                                }
                                for (int i = begin; i < end; i += $$.step)
                                    $$.stringValue += Symbol.at($1.variableName).stringValue[i]; // 逐个取子串
                            }
                            else if ($$.step < 0) // 负步长
                            {
                                if ($3.type == None) // 默认起始
                                    begin = Symbol.at($1.variableName).stringValue.length() - 1;
                                else if ($3.type == Integer)
                                {
                                    begin = $3.integerValue;
                                    if (begin < 0)
                                        begin += Symbol.at($1.variableName).stringValue.length();
                                    if (begin < 0)
                                        begin = 0;
                                    else if (begin >= Symbol.at($1.variableName).stringValue.length())
                                        begin = Symbol.at($1.variableName).stringValue.length() - 1;
                                }
                                else
                                {
                                    yyerror("TypeError: slice indices must be integers or None");
                                    YYERROR;
                                }

                                if ($5.type == None) // 默认结束
                                    end = -1;
                                else if ($5.type == Integer)
                                {
                                    end = $5.integerValue;
                                    if (end < 0)
                                        end += Symbol.at($1.variableName).stringValue.length();
                                    if (end < 0)
                                        end = -1;
                                    else if (end >= Symbol.at($1.variableName).stringValue.length())
                                        end = Symbol.at($1.variableName).stringValue.length();
                                }
                                else
                                {
                                    yyerror("TypeError: slice indices must be integers or None");
                                    YYERROR;
                                }

                                for (int i = begin; i > end; i += $$.step)
                                    $$.stringValue += Symbol.at($1.variableName).stringValue[i]; // 逐个取子串
                            }
                            break;
                        case List:
                            $$.type = ListSlice; // 列表元素类型
                            $$.variableName = $1.variableName;
                            $$.listValue = vector<struct value>();
                            if ($$.step > 0)
                            {
                                if ($3.type == None) // 默认起始
                                    $$.begin = Symbol.at($1.variableName).listValue.begin();
                                else if ($3.type == Integer)
                                {
                                    begin = $3.integerValue;
                                    if (begin < 0)
                                        begin += Symbol.at($1.variableName).listValue.size();
                                    if (begin < 0)
                                        begin = 0;
                                    else if (begin > Symbol.at($1.variableName).listValue.size())
                                        begin = Symbol.at($1.variableName).listValue.size();
                                    $$.begin = Symbol.at($1.variableName).listValue.begin() + begin;
                                }
                                else
                                {
                                    yyerror("TypeError: slice indices must be integers or None");
                                    YYERROR;
                                }

                                if ($5.type == None) // 默认结束
                                    $$.end = Symbol.at($1.variableName).listValue.end();
                                else if ($5.type == Integer)
                                {
                                    end = $5.integerValue;
                                    if (end < 0)
                                        end += Symbol.at($1.variableName).listValue.size();
                                    if (end < 0)
                                        end = 0;
                                    else if (end > Symbol.at($1.variableName).listValue.size())
                                        end = Symbol.at($1.variableName).listValue.size();
                                    $$.end = Symbol.at($1.variableName).listValue.begin() + end;
                                }
                                else
                                {
                                    yyerror("TypeError: slice indices must be integers or None");
                                    YYERROR;
                                }

                                for (vector<struct value>::iterator i = $$.begin; i < $$.end; i += $$.step)
                                    $$.listValue.push_back(*i); // 逐个取子串

                            }
                            else if ($$.step < 0)
                            {
                                if ($3.type == None) // 默认起始
                                    $$.begin = Symbol.at($1.variableName).listValue.end() - 1;
                                else if ($3.type == Integer)
                                {
                                    begin = $3.integerValue;
                                    if (begin < 0)
                                        begin += Symbol.at($1.variableName).listValue.size();
                                    if (begin < 0)
                                        begin = 0;
                                    else if (begin > Symbol.at($1.variableName).listValue.size())
                                        begin = Symbol.at($1.variableName).listValue.size() - 1;
                                    $$.begin = Symbol.at($1.variableName).listValue.begin() + begin;
                                }
                                else
                                {
                                    yyerror("TypeError: slice indices must be integers or None");
                                    YYERROR;
                                }

                                if ($5.type == None) // 默认结束
                                    $$.end = Symbol.at($1.variableName).listValue.begin() - 1;
                                else if ($5.type == Integer)
                                {
                                    end = $5.integerValue;
                                    if (end < 0)
                                        end += Symbol.at($1.variableName).listValue.size();
                                    if (end < 0)
                                        end = -1;
                                    else if (end > Symbol.at($1.variableName).listValue.size())
                                        end = Symbol.at($1.variableName).listValue.size();
                                    $$.end = Symbol.at($1.variableName).listValue.begin() + end;
                                }
                                else
                                {
                                    yyerror("TypeError: slice indices must be integers or None");
                                    YYERROR;
                                }

                                for (vector<struct value>::iterator i = $$.begin; i > $$.end; i += $$.step)
                                    $$.listValue.push_back(*i); // 逐个取子串
                            }
                            break;
                        default:
                            yyerror("TypeError: '"+ TypeString(Symbol.at($1.variableName)) +"' object is not subscriptable");
                            YYERROR;
                    }
                }
                else
                {
                    yyerror("NameError: name '" + $1.variableName + "' is not defined");
                    YYERROR;
                }
                break;
            default:
                yyerror("TypeError: '" + TypeString($1) + "' object is not subscriptable");
                YYERROR;
        }
    } |
    atom_expr  '[' add_expr ']'
    {
        switch ($1.type)
        {
            case String:
                if ($3.type == Integer)
                {
                    int index = $3.integerValue;
                    if (index < 0)
                        index += $1.stringValue.length();
                    if (index >= $1.stringValue.length() || index < 0)
                    {
                        yyerror("IndexError: string index out of range");
                        YYERROR;
                    }
                    else
                    {
                        $$.type = String;
                        $$.stringValue = $1.stringValue[index]; // 字符和字符串同等
                    }
                }
                else
                {
                    yyerror("TypeError: string indices must be integers");
                    YYERROR;
                }
                break;
            case List:
                if ($3.type == Integer)
                {
                    int index = $3.integerValue;
                    if (index < 0)
                        index += $1.listValue.size();
                    if (index >= $1.listValue.size() || index < 0)
                    {
                        yyerror("IndexError: list index out of range");
                        YYERROR;
                    }
                    else
                    {
                        $$.type = ListItem; // 列表元素类型
                        $$.begin = $1.listValue.begin() + index; // 取列表元素地址
                    }
                }
                else
                {
                    yyerror("TypeError: list indices must be integers or slices, not " + TypeString($3));
                    YYERROR;
                }
                break;
            case ListSlice:
                if ($3.type == Integer)
                {
                    int index = $3.integerValue;
                    if (index < 0)
                        index += $1.listValue.size();
                    if (index >= $1.listValue.size() || index < 0)
                    {
                        yyerror("IndexError: list index out of range");
                        YYERROR;
                    }
                    else
                    {
                        $$.type = ListItem; // 列表元素类型
                        $$.begin = $1.begin + index; // 取列表元素地址
                        // $$.begin = $1.listValue.begin() + index; // 取列表元素地址
                    }
                }
                else
                {
                    yyerror("TypeError: list indices must be integers or slices, not " + TypeString($3));
                    YYERROR;
                }
                break;
            case ListItem:
                switch ((*$1.begin).type)
                {
                    case String:
                        if ($3.type == Integer)
                        {
                            int index = $3.integerValue;
                            if (index < 0)
                                index += (*$1.begin).stringValue.length();
                            if (index >= (*$1.begin).stringValue.length() || index < 0)
                            {
                                yyerror("IndexError: string index out of range");
                                YYERROR;
                            }
                            else
                            {
                                $$.type = String;
                                $$.stringValue = (*$1.begin).stringValue[index]; // 字符和字符串同等
                            }
                        }
                        else
                        {
                            yyerror("TypeError: string indices must be integers");
                            YYERROR;
                        }
                        break;
                    case List:
                        if ($3.type == Integer)
                        {
                            int index = $3.integerValue;
                            if (index < 0)
                                index += (*$1.begin).listValue.size();
                            if (index > (*$1.begin).listValue.size() || index < 0)
                            {
                                yyerror("IndexError: list index out of range");
                                YYERROR;
                            }
                            else
                            {
                                $$.type = ListItem; // 列表元素类型
                                $$.begin = (*$1.begin).listValue.begin() + index; // 取列表元素地址
                            }
                        }
                        else
                        {
                            yyerror("TypeError: list indices must be integers or slices, not " + TypeString($3));
                            YYERROR;
                        }
                        break;
                    default:
                        yyerror("TypeError: '"+ TypeString((*$1.begin)) +"' object is not subscriptable");
                        YYERROR;
                }
                break;
            case Variable:
                if ($3.type == Integer)
                {
                    int index = $3.integerValue;
                    if ((Symbol.count($1.variableName) == 1)) // 已在变量表内
                    {
                        switch (Symbol.at($1.variableName).type)
                        {
                            case String:
                                if (index < 0)
                                    index += Symbol.at($1.variableName).stringValue.length();
                                if (index >= Symbol.at($1.variableName).stringValue.length() || index < 0)
                                {
                                    yyerror("IndexError: string index out of range");
                                    YYERROR;
                                }
                                else
                                {
                                    $$.type = String;
                                    $$.stringValue = Symbol.at($1.variableName).stringValue[index]; // 字符和字符串同等
                                }
                                break;
                            case List:
                                if (index < 0)
                                    index += Symbol.at($1.variableName).listValue.size();
                                if (index >= Symbol.at($1.variableName).listValue.size() || index < 0)
                                {
                                    yyerror("IndexError: list index out of range");
                                    YYERROR;
                                }
                                else
                                {
                                    $$.type = ListItem; // 列表元素类型
                                    $$.begin = Symbol.at($1.variableName).listValue.begin() + index; // 取列表元素地址
                                }
                                break;
                            default:
                                yyerror("TypeError: '"+ TypeString(Symbol.at($1.variableName)) +"' object is not subscriptable");
                                YYERROR;
                        }
                    }
                    else
                    {
                        yyerror("NameError: name '" + $1.variableName + "' is not defined");
                        YYERROR;
                    }
                }
                else
                {
                    yyerror("TypeError: list indices must be integers or slices, not " + TypeString($3));
                    YYERROR;
                }
                break;
            default:
                yyerror("TypeError: '"+ TypeString($1) +"' object is not subscriptable");
                YYERROR;
        }

    } |
    atom_expr '.' ID
    {
        $$.type = $1.type;

        $$.variableName = $1.variableName; // 变量名
        $$.attributeName = $3.variableName; // 属性或方法名
    } |
    atom_expr '(' arglist opt_comma ')'
    {
        if ($1.attributeName == "append") // append方法
        {
            $$.type = None;
            $$.transparent = true;
            switch ($1.type)
            {
                case List:
                case ListSlice:
                    if ($3.listValue.size() == 1) // append 有且仅有1个参数
                    {
                        $1.listValue.push_back(*$3.listValue.begin()); // 这里的意义不是很大
                    }
                    else
                    {
                        yyerror("TypeError: append() takes exactly one argument ("+ to_string($3.listValue.size()) +" given)");
                        YYERROR;
                    }
                    break;
                case ListItem:
                    if ((*$1.begin).type == List)
                    {
                        if ($3.listValue.size() == 1) // append 有且仅有1个参数
                        {
                            (*$1.begin).listValue.push_back(*$3.listValue.begin());
                        }
                        else
                        {
                            yyerror("TypeError: append() takes exactly one argument ("+ to_string($3.listValue.size()) +" given)");
                            YYERROR;
                        }
                    }
                    else
                    {
                        yyerror("AttributeError: '" + TypeString(*$1.begin) + "' object has no attribute 'append'");
                        YYERROR;
                    }
                    break;
                case Variable:
                    if (Symbol.at($1.variableName).type == List)
                    {
                        if ($3.listValue.size() == 1) // append 有且仅有1个参数
                        {
                            Symbol.at($1.variableName).listValue.push_back(*$3.listValue.begin());
                        }
                        else
                        {
                            yyerror("TypeError: append() takes exactly one argument ("+ to_string($3.listValue.size()) +" given)");
                            YYERROR;
                        }
                    }
                    else
                    {
                        yyerror("AttributeError: '" + TypeString(Symbol.at($1.variableName)) + "' object has no attribute 'append'");
                        YYERROR;
                    }
                    break;
                default:
                    yyerror("AttributeError: '" + TypeString($1) + "' object has no attribute 'append'");
                    YYERROR;
            }
        }
        else if ($1.attributeName == "count") // count方法
        {
            switch ($1.type)
            {
                case String:
                    if ($3.listValue.size() == 1) // count 有且仅有1个参数
                    {
                        if ((*$3.listValue.begin()).type == String)
                        {
                            $$.type = Integer;
                            $$.integerValue = 0;
                            size_t len = (*$3.listValue.begin()).stringValue.length();
                            if (len == 0)
                                len = 1; // 空子串调用
                            for (size_t i = 0; (i = $1.stringValue.find((*$3.listValue.begin()).stringValue,i)) != $1.stringValue.npos; $$.integerValue++, i+=len);
                        }
                        else
                        {
                            yyerror("TypeError: must be str, not " + TypeString(*$3.listValue.begin()));
                            YYERROR;
                        }
                    }
                    else
                    {
                        yyerror("TypeError: count() takes exactly one argument ("+ to_string($3.listValue.size()) +" given)");
                        YYERROR;
                    }
                    break;
                case List:
                case ListSlice:
                    if ($3.listValue.size() == 1) // count 有且仅有1个参数
                    {
                        $$.type = Integer;
                        $$.integerValue = count($1.listValue.begin(), $1.listValue.end(), *$3.listValue.begin()); // 调用algorithm中的count
                    }
                    else
                    {
                        yyerror("TypeError: count() takes exactly one argument ("+ to_string($3.listValue.size()) +" given)");
                        YYERROR;
                    }
                    break;
                case ListItem:
                    switch ((*$1.begin).type)
                    {
                        case String:
                            if ($3.listValue.size() == 1) // count 有且仅有1个参数
                            {
                                if ((*$3.listValue.begin()).type == String)
                                {
                                    $$.type = Integer;
                                    $$.integerValue = 0;
                                    size_t len = (*$3.listValue.begin()).stringValue.length();
                                    if (len == 0)
                                        len = 1; // 空子串调用
                                    for (size_t i = 0; (i = (*$1.begin).stringValue.find((*$3.listValue.begin()).stringValue,i)) != (*$1.begin).stringValue.npos; $$.integerValue++, i+=len);
                                }
                                else
                                {
                                    yyerror("TypeError: must be str, not " + TypeString(*$3.listValue.begin()));
                                    YYERROR;
                                }
                            }
                            else
                            {
                                yyerror("TypeError: count() takes exactly one argument ("+ to_string($3.listValue.size()) +" given)");
                                YYERROR;
                            }
                            break;
                        case List:
                            if ($3.listValue.size() == 1) // count 有且仅有1个参数
                            {
                                $$.type = Integer;
                                $$.integerValue = count((*$1.begin).listValue.begin(), (*$1.begin).listValue.end(), *$3.listValue.begin()); // 调用algorithm中的count
                            }

                            else
                            {
                                yyerror("TypeError: count() takes exactly one argument ("+ to_string($3.listValue.size()) +" given)");
                                YYERROR;
                            }
                            break;
                        default:
                            yyerror("AttributeError: '" + TypeString(*$1.begin) + "' object has no attribute 'count'");
                            YYERROR;
                    }
                    break;
                case Variable:
                    switch (Symbol.at($1.variableName).type)
                    {
                        case String:
                            if ($3.listValue.size() == 1) // count 有且仅有1个参数
                            {
                                if ((*$3.listValue.begin()).type == String)
                                {
                                    $$.type = Integer;
                                    $$.integerValue = 0;
                                    size_t len = (*$3.listValue.begin()).stringValue.length();
                                    if (len == 0)
                                        len = 1; // 空子串调用
                                    for (size_t i = 0; (i = Symbol.at($1.variableName).stringValue.find((*$3.listValue.begin()).stringValue,i)) != Symbol.at($1.variableName).stringValue.npos; $$.integerValue++, i+=len); // 不计算重复
                                }
                                else
                                {
                                    yyerror("TypeError: must be str, not " + TypeString(*$3.listValue.begin()));
                                    YYERROR;
                                }
                            }
                            else
                            {
                                yyerror("TypeError: count() takes exactly one argument ("+ to_string($3.listValue.size()) +" given)");
                                YYERROR;
                            }
                            break;
                        case List:
                            if ($3.listValue.size() == 1) // count 有且仅有1个参数
                            {
                                $$.type = Integer;
                                $$.integerValue = count(Symbol.at($1.variableName).listValue.begin(), Symbol.at($1.variableName).listValue.end(), *$3.listValue.begin()); // 调用algorithm中的count
                            }
                            else
                            {
                                yyerror("TypeError: count() takes exactly one argument ("+ to_string($3.listValue.size()) +" given)");
                                YYERROR;
                            }
                            break;
                        default:
                            yyerror("AttributeError: '" + TypeString(Symbol.at($1.variableName)) + "' object has no attribute 'count'");
                            YYERROR;
                    }
                    break;
                default:
                    yyerror("AttributeError: '" + TypeString($1) + "' object has no attribute 'count'");
                    YYERROR;
            }
        }
        else if ($1.attributeName == "extend") // extend方法
        {
            $$.type = None;
            $$.transparent = true;
            switch ($1.type)
            {
                case List:
                case ListSlice:
                    if ($3.listValue.size() == 1) // append 有且仅有1个参数
                    {
                        // 这里的代码没有什么意义
                    }
                    else
                    {
                        yyerror("TypeError: append() takes exactly one argument ("+ to_string($3.listValue.size()) +" given)");
                        YYERROR;
                    }
                    break;
                case ListItem:
                    if ((*$1.begin).type == List)
                    {
                        if ($3.listValue.size() == 1) // list 有且仅有1个参数
                        {
                            Value temp;
                            Value temp_2; // 拆分字符串

                            if ((*$3.listValue.begin()).type == Variable) // 变量替换为实体
                            {
                                if (Symbol.count((*$3.listValue.begin()).variableName) == 1) // 已在变量表中
                                    temp = Symbol.at((*$3.listValue.begin()).variableName);
                                else
                                {
                                    yyerror("NameError: name '" + (*$3.listValue.begin()).variableName + "' is not defined");
                                    YYERROR;
                                }
                            }
                            else
                                temp = (*$3.listValue.begin());

                            switch (temp.type)
                            {
                                case String:
                                    temp_2.type = String;
                                    for (int i = 0; i < temp.stringValue.length(); i++)
                                    {
                                        temp_2.stringValue = temp.stringValue[i];
                                        (*$1.begin).listValue.push_back(temp_2);
                                    }
                                    break;
                                case List:
                                    (*$1.begin).listValue.insert((*$1.begin).listValue.end(), temp.listValue.begin(), temp.listValue.end());
                                    break;
                                default:
                                {
                                    yyerror("TypeError: '"+TypeString(temp)+"' object is not iterable");
                                    YYERROR;
                                }
                            }
                        }
                        else
                        {
                            yyerror("TypeError: extend() takes exactly one argument ("+ to_string($3.listValue.size()) +" given)");
                            YYERROR;
                        }
                    }
                    else
                    {
                        yyerror("AttributeError: '" + TypeString(*$1.begin) + "' object has no attribute 'append'");
                        YYERROR;
                    }
                    break;
                case Variable:
                    if (Symbol.at($1.variableName).type == List)
                    {
                        if ($3.listValue.size() == 1) // list 有且仅有1个参数
                        {
                            Value temp;
                            Value temp_2; // 拆分字符串

                            if ((*$3.listValue.begin()).type == Variable) // 变量替换为实体
                            {
                                if (Symbol.count((*$3.listValue.begin()).variableName) == 1) // 已在变量表中
                                    temp = Symbol.at((*$3.listValue.begin()).variableName);
                                else
                                {
                                    yyerror("NameError: name '" + (*$3.listValue.begin()).variableName + "' is not defined");
                                    YYERROR;
                                }
                            }
                            else
                                temp = (*$3.listValue.begin());

                            switch (temp.type)
                            {
                                case String:
                                    temp_2.type = String;
                                    for (int i = 0; i < temp.stringValue.length(); i++)
                                    {
                                        temp_2.stringValue = temp.stringValue[i];
                                        Symbol.at($1.variableName).listValue.push_back(temp_2);
                                    }
                                    break;
                                case List:
                                    Symbol.at($1.variableName).listValue.insert(Symbol.at($1.variableName).listValue.end(), temp.listValue.begin(), temp.listValue.end());
                                    break;
                                default:
                                {
                                    yyerror("TypeError: '"+TypeString(temp)+"' object is not iterable");
                                    YYERROR;
                                }
                            }
                        }
                        else
                        {
                            yyerror("TypeError: extend() takes exactly one argument ("+ to_string($3.listValue.size()) +" given)");
                            YYERROR;
                        }
                    }
                    else
                    {
                        yyerror("AttributeError: '" + TypeString(Symbol.at($1.variableName)) + "' object has no attribute 'extend'");
                        YYERROR;
                    }
                    break;
                default:
                    yyerror("AttributeError: '" + TypeString($1) + "' object has no attribute 'append'");
                    YYERROR;
            }
        }
        else if ($1.attributeName == "index") // index方法
        {
            Value object = $3.listValue[0];
            switch ($1.type)
            {
                case String:
                    if ($3.listValue.size() > 3)
                    {
                        yyerror("TypeError: index() expected at most 3 arguments, got " + to_string($3.listValue.size()));
                        YYERROR;
                    }
                    else
                    {
                        if (object.type == String)
                        {
                            int begin;
                            string temp;

                            if ($3.listValue.size() == 1) // 默认起始
                                begin = 0;
                            else if ($3.listValue.size() == 2 || $3.listValue.size() == 3)
                                begin = $3.listValue[1].integerValue; // 第二个参数

                            if ($3.listValue.size() == 1 || $3.listValue.size() == 2) // 默认结尾
                                temp = $1.stringValue;
                            else if ($3.listValue.size() == 3)
                                temp = $1.stringValue.substr(0, $3.listValue[2].integerValue); // 第三个参数

                            int pos = temp.find(object.stringValue, begin); // 使用string的find
                            if (pos == temp.npos)
                            {
                                yyerror("ValueError: substring not found");
                                YYERROR;
                            }
                            else
                            {
                                $$.type = Integer;
                                $$.integerValue = pos;
                            }
                        }
                        else
                        {
                            yyerror("TypeError: must be str, not " + TypeString(object));
                            YYERROR;
                        }
                    }
                    break;
                case List:
                case ListSlice:
                {
                    vector<struct value>::iterator begin, end;
                    if ($3.listValue.size() == 1) // 默认起始
                        begin = $1.listValue.begin();
                    else if ($3.listValue.size() == 2 || $3.listValue.size() == 3)
                        begin = $1.listValue.begin() + $3.listValue[1].integerValue; // 第二个参数

                    if ($3.listValue.size() == 1 || $3.listValue.size() == 2) // 默认结尾
                        end = $1.listValue.end();
                    else if ($3.listValue.size() == 3)
                        end = $1.listValue.begin() + $3.listValue[2].integerValue; // 第三个参数

                    vector<struct value>::iterator pos = find(begin, end, object); // 使用algorithm 中的find
                    if (pos == end)
                    {
                        cout << "ValueError: "; // 这里的错误信息处理的不太好
                        Print(object);
                        yyerror(" is not in list");
                        YYERROR;
                    }
                    else
                    {
                        $$.type = Integer;
                        $$.integerValue = distance($1.listValue.begin(), pos); // 使用algorithm中的distance
                    }
                    break;
                }
                case ListItem:
                    switch ((*$1.begin).type)
                    {
                        case String:
                            if ($3.listValue.size() > 3)
                            {
                                yyerror("TypeError: index() expected at most 3 arguments, got " + to_string($3.listValue.size()));
                                YYERROR;
                            }
                            else
                            {
                                if (object.type == String)
                                {
                                    int begin;
                                    string temp;

                                    if ($3.listValue.size() == 1) // 默认起始
                                        begin = 0;
                                    else if ($3.listValue.size() == 2 || $3.listValue.size() == 3)
                                        begin = $3.listValue[1].integerValue; // 第二个参数

                                    if ($3.listValue.size() == 1 || $3.listValue.size() == 2) // 默认结尾
                                        temp = (*$1.begin).stringValue;
                                    else if ($3.listValue.size() == 3)
                                        temp = (*$1.begin).stringValue.substr(0, $3.listValue[2].integerValue); // 第三个参数

                                    int pos = temp.find(object.stringValue, begin); // 使用string的find
                                    if (pos == temp.npos)
                                    {
                                        yyerror("ValueError: substring not found");
                                        YYERROR;
                                    }
                                    else
                                    {
                                        $$.type = Integer;
                                        $$.integerValue = pos;
                                    }
                                }
                                else
                                {
                                    yyerror("TypeError: must be str, not " + TypeString(object));
                                    YYERROR;
                                }
                            }
                            break;
                        case List:
                        {
                            vector<struct value>::iterator begin, end;
                            if ($3.listValue.size() == 1) // 默认起始
                                begin = $1.listValue.begin();
                            else if ($3.listValue.size() == 2 || $3.listValue.size() == 3)
                                begin = $1.listValue.begin() + $3.listValue[1].integerValue; // 第二个参数

                            if ($3.listValue.size() == 1 || $3.listValue.size() == 2) // 默认结尾
                                end = (*$1.begin).listValue.end();
                            else if ($3.listValue.size() == 3)
                                end = (*$1.begin).listValue.begin() + $3.listValue[2].integerValue; // 第三个参数

                            vector<struct value>::iterator pos = find(begin, end, object); // 使用algorithm 中的find
                            if (pos == end)
                            {
                                cout << "ValueError: "; // 这里的错误信息处理的不太好
                                Print(object);
                                yyerror(" is not in list");
                                YYERROR;
                            }
                            else
                            {
                                $$.type = Integer;
                                $$.integerValue = distance((*$1.begin).listValue.begin(), pos); // 使用algorithm中的distance
                            }
                            break;
                        }
                        default:
                            yyerror("AttributeError: '" + TypeString(*$1.begin) + "' object has no attribute 'count'");
                            YYERROR;
                    }
                    break;
                case Variable:
                    switch (Symbol.at($1.variableName).type)
                    {
                        case String:
                            if ($3.listValue.size() > 3)
                            {
                                yyerror("TypeError: range expected at most 3 arguments, got " + to_string($3.listValue.size()));
                                YYERROR;
                            }
                            else
                            {
                                if (object.type == String)
                                {
                                    int begin;
                                    string temp;

                                    if ($3.listValue.size() == 1) // 默认起始
                                        begin = 0;
                                    else if ($3.listValue.size() == 2 || $3.listValue.size() == 3)
                                        begin = $3.listValue[1].integerValue; // 第二个参数

                                    if ($3.listValue.size() == 1 || $3.listValue.size() == 2) // 默认结尾
                                        temp = Symbol.at($1.variableName).stringValue;
                                    else if ($3.listValue.size() == 3)
                                        temp = Symbol.at($1.variableName).stringValue.substr(0, $3.listValue[2].integerValue); // 第三个参数

                                    int pos = temp.find(object.stringValue, begin); // 使用string的find
                                    if (pos == temp.npos)
                                    {
                                        yyerror("ValueError: substring not found");
                                        YYERROR;
                                    }
                                    else
                                    {
                                        $$.type = Integer;
                                        $$.integerValue = pos;
                                    }
                                }
                                else
                                {
                                    yyerror("TypeError: must be str, not " + TypeString(object));
                                    YYERROR;
                                }
                            }
                            break;
                        case List:
                        {
                            if ($3.listValue.size() > 3)
                            {
                                yyerror("TypeError: index() expected at most 3 arguments, got " + to_string($3.listValue.size()));
                                YYERROR;
                            }
                            else
                            {
                                vector<struct value>::iterator begin, end;
                                if ($3.listValue.size() == 1) // 默认起始
                                    begin = Symbol.at($1.variableName).listValue.begin();
                                else if ($3.listValue.size() == 2 || $3.listValue.size() == 3)
                                    begin = Symbol.at($1.variableName).listValue.begin() + $3.listValue[1].integerValue; // 第二个参数

                                if ($3.listValue.size() == 1 || $3.listValue.size() == 2) // 默认结尾
                                    end = Symbol.at($1.variableName).listValue.end();
                                else if ($3.listValue.size() == 3)
                                    end = Symbol.at($1.variableName).listValue.begin() + $3.listValue[2].integerValue; // 第三个参数

                                vector<struct value>::iterator pos = find(begin, end, object); // 使用algorithm 中的find
                                if (pos == end)
                                {
                                    cout << "ValueError: "; // 这里的错误信息处理的不太好
                                    Print(object);
                                    yyerror(" is not in list");
                                    YYERROR;
                                }
                                else
                                {
                                    $$.type = Integer;
                                    $$.integerValue = distance(Symbol.at($1.variableName).listValue.begin(), pos); // 使用algorithm中的distance
                                }
                            }
                            break;
                        }

                        default:
                            yyerror("AttributeError: '" + TypeString(Symbol.at($1.variableName)) + "' object has no attribute 'index'");
                            YYERROR;
                    }
                    break;
                default:
                    yyerror("AttributeError: '" + TypeString($1) + "' object has no attribute 'index'");
                    YYERROR;
            }
        }
        else if ($1.attributeName == "insert") // insert方法
        {
            $$.type = None;
            switch ($1.type)
            {
                case List:
                case ListSlice:
                    if ($3.listValue.size() == 2) // insert 有且仅有2个参数
                    {
                        int index = $3.listValue[0].integerValue;
                        if (index < 0)
                            index += Length($1);
                        if (index < 0)
                            index = 0;
                        else if (index > Length($1))
                            index = Length($1);
                        $1.listValue.insert($1.listValue.begin() + index, $3.listValue[1]); // 这里的意义不是很大
                    }
                    else
                    {
                        yyerror("TypeError: insert() takes exactly 2 arguments ("+ to_string($3.listValue.size()) +" given)");
                        YYERROR;
                    }
                    break;
                case ListItem:
                    if ((*$1.begin).type == List)
                    {
                        if ($3.listValue.size() == 2) // insert 有且仅有2个参数
                        {
                            int index = $3.listValue[0].integerValue;
                            if (index < 0)
                                index += Length(*$1.begin);
                            if (index < 0)
                                index = 0;
                            else if (index > Length(*$1.begin))
                                index = Length(*$1.begin);
                            (*$1.begin).listValue.insert((*$1.begin).listValue.begin() + index, $3.listValue[1]);
                        }
                        else
                        {
                            yyerror("TypeError: insert() takes exactly 2 arguments ("+ to_string($3.listValue.size()) +" given)");
                            YYERROR;
                        }
                    }
                    else
                    {
                        yyerror("AttributeError: '" + TypeString(*$1.begin) + "' object has no attribute 'insert'");
                        YYERROR;
                    }
                    break;
                case Variable:
                    if (Symbol.at($1.variableName).type == List)
                    {
                        if ($3.listValue.size() == 2) // insert 有且仅有2个参数
                        {
                            int index = $3.listValue[0].integerValue;
                            if (index < 0)
                                index += Length(Symbol.at($1.variableName));
                            if (index < 0)
                                index = 0;
                            else if (index > Length(Symbol.at($1.variableName)))
                                index = Length(Symbol.at($1.variableName));
                            Symbol.at($1.variableName).listValue.insert(Symbol.at($1.variableName).listValue.begin() + index, $3.listValue[1]);
                        }
                        else
                        {
                            yyerror("TypeError: insert() takes exactly 2 arguments ("+ to_string($3.listValue.size()) +" given)");
                            YYERROR;
                        }
                    }
                    else
                    {
                        yyerror("AttributeError: '" + TypeString(Symbol.at($1.variableName)) + "' object has no attribute 'insert'");
                        YYERROR;
                    }
                    break;
                default:
                    yyerror("AttributeError: '" + TypeString($1) + "' object has no attribute 'insert'");
                    YYERROR;
            }
        }
        else if ($1.attributeName == "pop") // pop方法
        {
            switch ($1.type)
            {
                case List:
                case ListSlice:
                    if ($3.listValue.size() == 1) // pop 有1个参数
                    {
                        int index = $3.listValue[0].integerValue;
                        if (index < 0)
                            index += Length($1);
                        if (index >= $1.listValue.size() || index < 0)
                        {
                            yyerror("IndexError: pop index out of range");
                            YYERROR;
                        }
                        else
                        {
                            $$ = $1.listValue[index];
                            $1.listValue.erase($1.listValue.begin() + index);
                        }
                    }
                    else
                    {
                        yyerror("TypeError: pop() takes at most 1 argument ("+ to_string($3.listValue.size()) +" given)");
                        YYERROR;
                    }
                    break;
                case ListItem:
                    if ((*$1.begin).type == List)
                    {
                        if ($3.listValue.size() == 1) // pop 有1个参数
                        {
                            int index = $3.listValue[0].integerValue;
                            if (index < 0)
                                index += Length((*$1.begin));
                            if (index >= (*$1.begin).listValue.size() || index < 0)
                            {
                                yyerror("IndexError: pop index out of range");
                                YYERROR;
                            }
                            else
                            {
                                $$ = (*$1.begin).listValue[index];
                                (*$1.begin).listValue.erase((*$1.begin).listValue.begin() + index);
                            }
                        }
                        else
                        {
                            yyerror("TypeError: pop() takes at most 1 argument ("+ to_string($3.listValue.size()) +" given)");
                            YYERROR;
                        }
                    }
                    else
                    {
                        yyerror("AttributeError: '" + TypeString(*$1.begin) + "' object has no attribute 'pop'");
                        YYERROR;
                    }
                    break;
                case Variable:
                    if (Symbol.at($1.variableName).type == List)
                    {
                        if ($3.listValue.size() == 1) // pop 有1个参数
                        {
                            int index = $3.listValue[0].integerValue;
                            if (index < 0)
                                index += Length(Symbol.at($1.variableName));
                            if (index >= Symbol.at($1.variableName).listValue.size() || index < 0)
                            {
                                yyerror("IndexError: pop index out of range");
                                YYERROR;
                            }
                            else
                            {
                                $$ = Symbol.at($1.variableName).listValue[index];
                                Symbol.at($1.variableName).listValue.erase(Symbol.at($1.variableName).listValue.begin() + index);
                            }
                        }
                        else
                        {
                            yyerror("TypeError: pop() takes at most 1 argument ("+ to_string($3.listValue.size()) +" given)");
                            YYERROR;
                        }
                    }
                    else
                    {
                        yyerror("AttributeError: '" + TypeString(Symbol.at($1.variableName)) + "' object has no attribute 'pop'");
                        YYERROR;
                    }
                    break;
                default:
                    yyerror("AttributeError: '" + TypeString($1) + "' object has no attribute 'pop'");
                    YYERROR;
            }
        }
        else if ($1.attributeName == "remove") // remove方法
        {
            $$.type = None;
            vector<struct value>::iterator pos;
            switch ($1.type)
            {
                case List:
                case ListSlice:
                    if ($3.listValue.size() == 1) // remove 有且仅有1个参数
                    {
                        pos = find($1.listValue.begin(), $1.listValue.end(), *$3.listValue.begin());
                        if (pos == $1.listValue.end())
                            yyerror("ValueError: list.remove(x): x not in list ");
                        else
                            $1.listValue.erase(pos);
                    }
                    else
                    {
                        yyerror("TypeError: remove() takes exactly one argument ("+ to_string($3.listValue.size()) +" given)");
                        YYERROR;
                    }
                    break;
                case ListItem:
                    switch ((*$1.begin).type)
                    {
                        case List:
                            if ($3.listValue.size() == 1) // remove 有且仅有1个参数
                            {
                                pos = find((*$1.begin).listValue.begin(), (*$1.begin).listValue.end(), *$3.listValue.begin());
                                if (pos == (*$1.begin).listValue.end())
                                    yyerror("ValueError: list.remove(x): x not in list ");
                                else
                                    (*$1.begin).listValue.erase(pos);
                            }

                            else
                            {
                                yyerror("TypeError: remove() takes exactly one argument ("+ to_string($3.listValue.size()) +" given)");
                                YYERROR;
                            }
                            break;
                        default:
                            yyerror("AttributeError: '" + TypeString(*$1.begin) + "' object has no attribute 'remove'");
                            YYERROR;
                    }
                    break;
                case Variable:
                    switch (Symbol.at($1.variableName).type)
                    {
                        case List:
                            if ($3.listValue.size() == 1) // remove 有且仅有1个参数
                            {
                                pos = find(Symbol.at($1.variableName).listValue.begin(), Symbol.at($1.variableName).listValue.end(), *$3.listValue.begin());
                                if (pos == Symbol.at($1.variableName).listValue.end())
                                    yyerror("ValueError: list.remove(x): x not in list ");
                                else
                                    Symbol.at($1.variableName).listValue.erase(pos);
                            }
                            else
                            {
                                yyerror("TypeError: remove() takes exactly one argument ("+ to_string($3.listValue.size()) +" given)");
                                YYERROR;
                            }
                            break;
                        default:
                            yyerror("AttributeError: '" + TypeString(Symbol.at($1.variableName)) + "' object has no attribute 'remove'");
                            YYERROR;
                    }
                    break;
                default:
                    yyerror("AttributeError: '" + TypeString($1) + "' object has no attribute 'remove'");
                    YYERROR;
            }
        }
        else if ($1.attributeName == "reverse")
        {
            switch ($1.type)
            {
                case List:
                case ListSlice:
                    yyerror("TypeError: reverse() takes no arguments ("+ to_string($3.listValue.size()) +" given)");
                        YYERROR;
                    break;
                case ListItem:
                    if ((*$1.begin).type == List)
                    {
                        yyerror("TypeError: reverse() takes no arguments ("+ to_string($3.listValue.size()) +" given)");
                        YYERROR;
                    }
                    else
                    {
                        yyerror("AttributeError: '" + TypeString(*$1.begin) + "' object has no attribute 'reverse'");
                        YYERROR;
                    }
                    break;
                case Variable:
                    if (Symbol.at($1.variableName).type == List)
                    {
                        yyerror("TypeError: reverse() takes no arguments ("+ to_string($3.listValue.size()) +" given)");
                        YYERROR;
                    }
                    else
                    {
                        yyerror("AttributeError: '" + TypeString(Symbol.at($1.variableName)) + "' object has no attribute 'reverse'");
                        YYERROR;
                    }
                    break;
                default:
                    yyerror("AttributeError: '" + TypeString($1) + "' object has no attribute 'reverse'");
                    YYERROR;
            }
        }
        else if ($1.variableName == "print") // print函数
        {
            $$.type = None;
            $$.transparent = true;
            for (vector<struct value>::iterator i = $3.listValue.begin(); i != $3.listValue.end(); i++)
            {
                if ((*i).type == None)
                    cout << "None";
                else
                    Print(*i);
                if (i != $3.listValue.end() - 1)
                    cout << ' ';
            }
            cout << endl;
        }
        else if ($1.variableName == "range") // range函数
        {
            $$.type = List;
            $$.listValue = vector<struct value>();
            Value temp;
            temp.type = Integer; // 整数列表

            int begin, end, step;

            if ($3.listValue.size() == 1 || $3.listValue.size() == 2) // 默认步长
                step = 1;
            else if ($3.listValue.size() == 3)
                step = $3.listValue[2].integerValue; // 第三个参数
            else if ($3.listValue.size() > 3)
            {
                yyerror("TypeError: range expected at most 3 arguments, got " + to_string($3.listValue.size()));
                YYERROR;
            }

            if (step > 0)
            {
                if ($3.listValue.size() == 1) // 仅一个参数：从0到参数
                {
                    begin = 0;
                    end = $3.listValue[0].integerValue;
                }
                else if ($3.listValue.size() == 2 || $3.listValue.size() == 3)
                {
                    begin = $3.listValue[0].integerValue;
                    end = $3.listValue[1].integerValue;
                }
                for (temp.integerValue = begin; temp.integerValue < end; temp.integerValue+=step)
                    $$.listValue.push_back(temp);
            }
            else if (step < 0) // 一定有3个参数
            {
                begin = $3.listValue[0].integerValue;
                end = $3.listValue[1].integerValue;
                for (temp.integerValue = begin; temp.integerValue > end; temp.integerValue+=step)
                    $$.listValue.push_back(temp);
            }
            else
            {
                yyerror("ValueError: range() arg 3 must not be zero");
                YYERROR;
            }
        }
        else if ($1.variableName == "list") // list函数
        {
            $$.type = List;

            if ($3.listValue.size() == 1) // list 有1个参数
            {
                Value temp;
                Value temp_2; // 拆分字符串

                if ((*$3.listValue.begin()).type == Variable) // 变量替换为实体
                {
                    if (Symbol.count((*$3.listValue.begin()).variableName) == 1) // 已在变量表中
                        temp = Symbol.at((*$3.listValue.begin()).variableName);
                    else
                    {
                        yyerror("NameError: name '" + (*$3.listValue.begin()).variableName + "' is not defined");
                        YYERROR;
                    }
                }
                else
                    temp = (*$3.listValue.begin());

                switch (temp.type)
                {
                    case String:
                        $$.listValue = vector<struct value>();
                        temp_2.type = String;
                        for (int i = 0; i < temp.stringValue.length(); i++)
                        {
                            temp_2.stringValue = temp.stringValue[i];
                            $$.listValue.push_back(temp_2);
                        }
                        break;
                    case List:
                        $$.listValue = vector<struct value>(temp.listValue);
                        break;
                    default:
                    {
                        yyerror("TypeError: '"+TypeString(temp)+"' object is not iterable");
                        YYERROR;
                    }
                }
            }
            else
            {
                yyerror("TypeError: list expected at most 1 arguments, got " + to_string($3.listValue.size()));
                YYERROR;
            }
        }
        else if ($1.variableName == "type") // type函数
        {
            $$.type = None;
            $$.transparent = true;
            if ($3.listValue.size() == 1 || $3.listValue.size() == 3)
            {
                if ($3.listValue.size() == 1)
                {
                    cout << "<type '" + TypeString(*$3.listValue.begin()) + "'>" << endl;
                }
                else
                {
                    yyerror("SyntaxError: not supported syntax of 3 arguments");
                    YYERROR;
                }
            }
            else
            {
                yyerror("TypeError: type() takes 1 or 3 arguments");
                YYERROR;
            }
        }
        else if ($1.variableName == "len") // len函数
        {
            if ($3.listValue.size() == 1) // list 有1个参数
            {
                switch((*$3.listValue.begin()).type)
                {
                    case String:
                    case List:
                    case ListSlice:
                    case ListItem:
                    case Variable:
                        $$.type = Integer;
                        $$.integerValue = Length(*$3.listValue.begin());
                        break;
                    default:
                        yyerror("TypeError: object of type '"+ TypeString(*$3.listValue.begin()) +"' has no len()");
                        YYERROR;
                }
            }
            else
            {
                yyerror("TypeError: len() takes exactly one argument (" + to_string($3.listValue.size()) + " given)");
                YYERROR;
            }
        }
        else
        {
            yyerror("AttributeError: '" + TypeString($1) + "' object has no attribute '"+ $1.attributeName +"\'");
            YYERROR;
        }

    } |
    atom_expr  '('  ')'
    {
        if ($1.variableName == "quit") // quit函数
            exit(0);
        else if ($1.attributeName == "append")
        {
            $$.type = None;
            $$.transparent = true;
            switch ($1.type)
            {
                case List:
                case ListSlice:
                    yyerror("TypeError: append() takes exactly one argument (0 given)");
                    YYERROR;
                    break;
                case ListItem:
                    if ((*$1.begin).type == List)
                    {
                        yyerror("TypeError: append() takes exactly one argument (0 given)");
                        YYERROR;
                    }
                    else
                    {
                        yyerror("AttributeError: '" + TypeString(*$1.begin) + "' object has no attribute 'append'");
                        YYERROR;
                    }
                    break;
                case Variable:
                    if (Symbol.at($1.variableName).type == List)
                    {
                        yyerror("TypeError: append() takes exactly one argument (0 given)");
                        YYERROR;
                    }
                    else
                    {
                        yyerror("AttributeError: '" + TypeString(Symbol.at($1.variableName)) + "' object has no attribute 'append'");
                        YYERROR;
                    }
                    break;
                default:
                    yyerror("AttributeError: '" + TypeString($1) + "' object has no attribute 'append'");
                    YYERROR;
            }
        }
        else if ($1.attributeName == "count")
        {
            $$.type = None;
            $$.transparent = true;
            switch ($1.type)
            {
                case String:
                case List:
                case ListSlice:
                    yyerror("TypeError: count() takes exactly one argument (0 given)");
                    YYERROR;
                    break;
                case ListItem:
                    if ((*$1.begin).type == List || (*$1.begin).type == String)
                    {
                        yyerror("TypeError: count() takes exactly one argument (0 given)");
                        YYERROR;
                    }
                    else
                    {
                        yyerror("AttributeError: '" + TypeString(*$1.begin) + "' object has no attribute 'count'");
                        YYERROR;
                    }
                    break;
                case Variable:
                    if (Symbol.at($1.variableName).type == List || Symbol.at($1.variableName).type == String)
                    {
                        yyerror("TypeError: count() takes exactly one argument (0 given)");
                        YYERROR;
                    }
                    else
                    {
                        yyerror("AttributeError: '" + TypeString(Symbol.at($1.variableName)) + "' object has no attribute 'count'");
                        YYERROR;
                    }
                    break;
                default:
                    yyerror("AttributeError: '" + TypeString($1) + "' object has no attribute 'count'");
                    YYERROR;
            }
        }
        else if ($1.attributeName == "extend")
        {
            $$.type = None;
            $$.transparent = true;
            switch ($1.type)
            {
                case List:
                case ListSlice:
                    yyerror("TypeError: extend() takes exactly one argument (0 given)");
                    YYERROR;
                    break;
                case ListItem:
                    if ((*$1.begin).type == List)
                    {
                        yyerror("TypeError: extend() takes exactly one argument (0 given)");
                        YYERROR;
                    }
                    else
                    {
                        yyerror("AttributeError: '" + TypeString(*$1.begin) + "' object has no attribute 'extend'");
                        YYERROR;
                    }
                    break;
                case Variable:
                    if (Symbol.at($1.variableName).type == List)
                    {
                        yyerror("TypeError: extend() takes exactly one argument (0 given)");
                        YYERROR;
                    }
                    else
                    {
                        yyerror("AttributeError: '" + TypeString(Symbol.at($1.variableName)) + "' object has no attribute 'extend'");
                        YYERROR;
                    }
                    break;
                default:
                    yyerror("AttributeError: '" + TypeString($1) + "' object has no attribute 'extend'");
                    YYERROR;
            }
        }
        else if ($1.attributeName == "index")
        {
            $$.type = None;
            $$.transparent = true;
            switch ($1.type)
            {
                case String:
                case List:
                case ListSlice:
                    yyerror("TypeError: index() takes at least 1 argument (0 given)");
                    YYERROR;
                    break;
                case ListItem:
                    if ((*$1.begin).type == List || (*$1.begin).type == String)
                    {
                        yyerror("TypeError: index() takes at least 1 argument (0 given)");
                        YYERROR;
                    }
                    else
                    {
                        yyerror("AttributeError: '" + TypeString(*$1.begin) + "' object has no attribute 'index'");
                        YYERROR;
                    }
                    break;
                case Variable:
                    if (Symbol.at($1.variableName).type == List || Symbol.at($1.variableName).type == String)
                    {
                        yyerror("TypeError: index() takes at least 1 argument (0 given)");
                        YYERROR;
                    }
                    else
                    {
                        yyerror("AttributeError: '" + TypeString(Symbol.at($1.variableName)) + "' object has no attribute 'index'");
                        YYERROR;
                    }
                    break;
                default:
                    yyerror("AttributeError: '" + TypeString($1) + "' object has no attribute 'index'");
                    YYERROR;
            }
        }
        else if ($1.attributeName == "insert")
        {
            $$.type = None;
            $$.transparent = true;
            switch ($1.type)
            {
                case List:
                case ListSlice:
                    yyerror("TypeError: insert() takes exactly 2 arguments (0 given)");
                    YYERROR;
                    break;
                case ListItem:
                    if ((*$1.begin).type == List)
                    {
                        yyerror("TypeError: insert() takes exactly 2 arguments (0 given)");
                        YYERROR;
                    }
                    else
                    {
                        yyerror("AttributeError: '" + TypeString(*$1.begin) + "' object has no attribute 'insert'");
                        YYERROR;
                    }
                    break;
                case Variable:
                    if (Symbol.at($1.variableName).type == List)
                    {
                        yyerror("TypeError: insert() takes exactly 2 arguments (0 given)");
                        YYERROR;
                    }
                    else
                    {
                        yyerror("AttributeError: '" + TypeString(Symbol.at($1.variableName)) + "' object has no attribute 'insert'");
                        YYERROR;
                    }
                    break;
                default:
                    yyerror("AttributeError: '" + TypeString($1) + "' object has no attribute 'insert'");
                    YYERROR;
            }
        }
        else if ($1.attributeName == "pop") // pop方法
        {
            switch ($1.type)
            {
                case List:
                case ListSlice:
                    if ($1.listValue.empty()) // 空列表
                    {
                        yyerror("IndexError: pop from empty list");
                        YYERROR;
                    }
                    else
                    {
                        $$ = $1.listValue.back();
                        $1.listValue.pop_back();
                    }
                    break;
                case ListItem:
                    if ((*$1.begin).type == List)
                    {
                        if ((*$1.begin).listValue.empty()) // 空列表
                        {
                            yyerror("IndexError: pop from empty list");
                            YYERROR;
                        }
                        else
                        {
                            $$ = (*$1.begin).listValue.back();
                            (*$1.begin).listValue.pop_back();
                        }
                    }
                    else
                    {
                        yyerror("AttributeError: '" + TypeString(*$1.begin) + "' object has no attribute 'pop'");
                        YYERROR;
                    }
                    break;
                case Variable:
                    if (Symbol.at($1.variableName).type == List)
                    {
                        if (Symbol.at($1.variableName).listValue.empty()) // 空列表
                        {
                            yyerror("IndexError: pop from empty list");
                            YYERROR;
                        }
                        else
                        {
                            $$ = Symbol.at($1.variableName).listValue.back();
                            Symbol.at($1.variableName).listValue.pop_back();
                        }
                    }
                    else
                    {
                        yyerror("AttributeError: '" + TypeString(Symbol.at($1.variableName)) + "' object has no attribute 'pop'");
                        YYERROR;
                    }
                    break;
                default:
                    yyerror("AttributeError: '" + TypeString($1) + "' object has no attribute 'pop'");
                    YYERROR;
            }
        }
        else if ($1.attributeName == "remove")
        {
            $$.type = None;
            $$.transparent = true;
            switch ($1.type)
            {
                case List:
                case ListSlice:
                    yyerror("TypeError: remove() takes exactly one argument (0 given)");
                    YYERROR;
                    break;
                case ListItem:
                    if ((*$1.begin).type == List)
                    {
                        yyerror("TypeError: remove() takes exactly one argument (0 given)");
                        YYERROR;
                    }
                    else
                    {
                        yyerror("AttributeError: '" + TypeString(*$1.begin) + "' object has no attribute 'remove'");
                        YYERROR;
                    }
                    break;
                case Variable:
                    if (Symbol.at($1.variableName).type == List)
                    {
                        yyerror("TypeError: remove() takes exactly one argument (0 given)");
                        YYERROR;
                    }
                    else
                    {
                        yyerror("AttributeError: '" + TypeString(Symbol.at($1.variableName)) + "' object has no attribute 'remove'");
                        YYERROR;
                    }
                    break;
                default:
                    yyerror("AttributeError: '" + TypeString($1) + "' object has no attribute 'remove'");
                    YYERROR;
            }
        }
        else if ($1.attributeName == "reverse") // reverse方法
        {
            $$.type = None;
            $$.transparent = true;
            switch ($1.type)
            {
                case List:
                case ListSlice:
                    reverse($1.listValue.begin(), $1.listValue.end()); // 没有意义
                    break;
                case ListItem:
                    if ((*$1.begin).type == List)
                    {
                        reverse((*$1.begin).listValue.begin(), (*$1.begin).listValue.end()); // 调用algorithm中的reverse
                    }
                    else
                    {
                        yyerror("AttributeError: '" + TypeString(*$1.begin) + "' object has no attribute 'reverse'");
                        YYERROR;
                    }
                    break;
                case Variable:
                    if (Symbol.at($1.variableName).type == List)
                    {
                        reverse(Symbol.at($1.variableName).listValue.begin(), Symbol.at($1.variableName).listValue.end()); // 调用algorithm中的reverse
                    }
                    else
                    {
                        yyerror("AttributeError: '" + TypeString(Symbol.at($1.variableName)) + "' object has no attribute 'reverse'");
                        YYERROR;
                    }
                    break;
                default:
                    yyerror("AttributeError: '" + TypeString($1) + "' object has no attribute 'reverse'");
                    YYERROR;
            }
        }
        else if ($1.variableName == "print") // print函数
        {
            $$.type = None;
            $$.transparent = true;
            cout << endl;
        }
        else if ($1.variableName == "range")
        {
            yyerror("TypeError: range expected 1 arguments, got 0");
            YYERROR;
        }
        else if ($1.variableName == "list") // list函数
        {
            $$.type = List;
            $$.listValue = vector<struct value>();
        }
        else if ($1.variableName == "type")
        {
            yyerror("TypeError: type() takes 1 or 3 arguments");
            YYERROR;
        }
        else if ($1.variableName == "len")
        {
            yyerror("TypeError: len() takes exactly one argument (0 given)");
            YYERROR;
        }
        else
        {
            yyerror("AttributeError: '" + TypeString($1) + "' object has no attribute '"+ $1.attributeName +"\'");
            YYERROR;
        }
    }
;

arglist:
    add_expr
    {
        $$.type = List;
        $$.listValue = vector<struct value>(1, $1); // 用列表“框柱”参数
    }|
    arglist ',' add_expr
    {
        $$.type = List;
        $1.listValue.push_back($3);
        $$.listValue = vector<struct value>($1.listValue);
    }
;

List:
    '[' ']'
    {
        $$.type = List;
        $$.listValue = vector<struct value>();
    } |
    '[' List_items opt_comma ']' /* 注意 [1, 2, 3, ] == [1, 2, 3] */
    {
        $$.type = List;
        $$.listValue = vector<struct value>($2.listValue);
    }
;

opt_comma:
    /* empty production */ |
    ','
;

List_items:
    add_expr
    {
        $$.type = List;
        $$.listValue = vector<struct value>(1, $1); // 用列表“框柱”变量
    } |
    List_items ',' add_expr
    {
        $$.type = List;
        $1.listValue.push_back($3);
        $$.listValue = vector<struct value>($1.listValue);
    }
;

add_expr:
    add_expr '+' mul_expr
    {
        switch($1.type)
        {
            case Integer:
                switch($3.type)
                {
                    case Integer:
                        $$.type = Integer;
                        $$.integerValue = $1.integerValue + $3.integerValue;
                        break;
                    case Real:
                        $$.type = Real;
                        $1.realValue = (double) $1.integerValue;
                        $$.realValue = $1.realValue + $3.realValue;
                        break;
                    // case List:
                    //     $$.type = List;
                    //     $$.listValue = vector<struct value>($3.listValue);
                    //     $$.listValue.insert($$.listValue.begin(), $1); // 在头部插入
                    //     break;
                    default:
                        yyerror("TypeError: unsupported operand type(s) for +: 'int' and '" + TypeString($3) + "\'");
                        YYERROR;
                }
                break;
            case Real:
                switch($3.type)
                {
                    case Integer:
                        $$.type = Real;
                        $3.realValue = (double) $3.integerValue;
                        $$.realValue = $1.realValue + $3.realValue;
                        break;
                    case Real:
                        $$.type = Real;
                        $$.realValue = $1.realValue + $3.realValue;
                        break;
                    // case List:
                    //     $$.type = List;
                    //     $$.listValue = vector<struct value>($3.listValue);
                    //     $$.listValue.insert($$.listValue.begin(), $1); // 在头部插入
                    //     break;
                    default:
                        yyerror("TypeError: unsupported operand type(s) for +: 'float' and '" + TypeString($3) + "\'");
                        YYERROR;
                }
                break;
            case String:
                switch($3.type)
                {
                    case String:
                        $$.type = String;
                        $$.stringValue = $1.stringValue + $3.stringValue;
                        break;
                    // case List:
                    //     $$.type = List;
                    //     $$.listValue = vector<struct value>($3.listValue);
                    //     $$.listValue.insert($$.listValue.begin(), $1); // 在头部插入
                    //     break;
                    default:
                        yyerror("TypeError: can only concatenate str (not \"" + TypeString($3) + "\") to str");
                        YYERROR;
                }
                break;
            case List:
                $$.type = List;
                $$.listValue = vector<struct value>($1.listValue);
                switch($3.type)
                {
                    // case Integer:
                    //     $$.listValue.insert($$.listValue.end(), $3); // 在尾部插入
                    //     break;
                    // case Real:
                    //     $$.listValue.insert($$.listValue.end(), $3); // 在尾部插入
                    //     break;
                    // case String:
                    //     $$.listValue.insert($$.listValue.end(), $3); // 在尾部插入
                    //     break;
                    case List:
                        $$.listValue.insert($$.listValue.end(), $3.listValue.begin(), $3.listValue.end()); // 在尾部插入
                        break;
                    default:
                        yyerror("TypeError: can only concatenate list (not \"" + TypeString($3) + "\") to list");
                        YYERROR;
                }
                break;
            default:
                yyerror("TypeError: not supported type");
                YYERROR;
        }
    } |
    add_expr '-' mul_expr
    {
        switch($1.type)
        {
            case Integer:
                switch($3.type)
                {
                    case Integer:
                        $$.type = Integer;
                        $$.integerValue = $1.integerValue - $3.integerValue;
                        break;
                    case Real:
                        $$.type = Real;
                        $1.realValue = (double) $1.integerValue;
                        $$.realValue = $1.realValue - $3.realValue;
                        break;
                    default:
                        yyerror("TypeError: unsupported operand type(s) for +: 'int' and '" + TypeString($3) + "\'");
                        YYERROR;
                }
                break;
            case Real:
                switch($3.type)
                {
                    case Integer:
                        $$.type = Real;
                        $3.realValue = (double) $3.integerValue;
                        $$.realValue = $1.realValue - $3.realValue;
                        break;
                    case Real:
                        $$.type = Real;
                        $$.realValue = $1.realValue - $3.realValue;
                        break;
                    default:
                        yyerror("TypeError: unsupported operand type(s) for +: 'int' and '" + TypeString($3) + "\'");
                        YYERROR;
                }
                break;
            default:
                yyerror("TypeError: unsupported operand type(s) for +: '"+ TypeString($1) +"' and '" + TypeString($3) + "\'");
                YYERROR;
        }
    } |
    mul_expr
;

mul_expr:
    mul_expr '*' mul_expr
    {
        switch($1.type)
        {
            case Integer:
                switch($3.type)
                {
                    case Integer:
                        $$.type = Integer;
                        $$.integerValue = $1.integerValue * $3.integerValue;
                        break;
                    case Real:
                        $$.type = Real;
                        $1.realValue = (double) $1.integerValue;
                        $$.realValue = $1.realValue * $3.realValue;
                        break;
                    case List:
                        $$.type = List;
                        $$.listValue = vector<struct value>($3.listValue);
                        for (int i = 1; i < $1.integerValue; i++)
                            $$.listValue.insert($$.listValue.end(), $3.listValue.begin(), $3.listValue.end()); // 循环插入
                        break;
                    default:
                        yyerror("TypeError: not supported type");
                        YYERROR;
                }
                break;
            case Real:
                switch($3.type)
                {
                    case Integer:
                        $$.type = Real;
                        $3.realValue = (double) $3.integerValue;
                        $$.realValue = $1.realValue * $3.realValue;
                        break;
                    case Real:
                        $$.type = Real;
                        $$.realValue = $1.realValue * $3.realValue;
                        break;
                    case String:
                    case List:
                        yyerror("TypeError: can't multiply sequence by non-int of type 'float'");
                        YYERROR;
                        break;
                    default:
                        yyerror("TypeError: not supported type");
                        YYERROR;
                }
                break;
            case String:
                switch($3.type)
                {
                    case Integer:
                        $$.type = String;
                        $$.stringValue = $1.stringValue;
                        for (int i = 1; i < $3.integerValue; i++)
                            $$.stringValue += $1.stringValue;
                        break;
                    default:
                        yyerror("TypeError: can't multiply sequence by non-int of type '" + TypeString($3) + "\'");
                        YYERROR;
                }
                break;
            case List:
                switch($3.type)
                {
                    case Integer:
                        $$.type = List;
                        $$.listValue = vector<struct value>($1.listValue);
                        for (int i = 1; i < $3.integerValue; i++)
                            $$.listValue.insert($$.listValue.end(), $1.listValue.begin(), $1.listValue.end()); // 循环插入
                        break;
                    default:
                        yyerror("TypeError: can't multiply sequence by non-int of type '" + TypeString($3) + "\'");
                        YYERROR;
                }
            default:
                yyerror("TypeError: not supported type");
                YYERROR;
        }
    } |
    mul_expr '/' mul_expr
    {
        $$.type = Real;
        if (($1.type == Integer || $1.type == Real) && ($3.type == Integer || $3.type == Real))
        {
            if ( $1.type == Integer )
                $1.realValue = (double) $1.integerValue;
            if ( $3.type == Integer )
                $3.realValue = (double) $3.integerValue;
            $$.realValue = $1.realValue / $3.realValue;
        }
        else
        {
            yyerror("TypeError: unsupported operand type(s) for /: '"+ TypeString($1) +"' and '" + TypeString($3) + "\'");
            YYERROR;
        }
    } |
    mul_expr DIV mul_expr
    {
        // 整除
        $$.type = Integer;
        if (($1.type == Integer || $1.type == Real) && ($3.type == Integer || $3.type == Real))
        {
            if ( $1.type == Real )
                $1.integerValue = round($1.realValue);
            if ( $3.type == Real )
                $3.integerValue = round($3.realValue);
            $$.integerValue = $1.integerValue / $3.integerValue;
        }
        else
        {
            yyerror("TypeError: unsupported operand type(s) for //: '"+ TypeString($1) +"' and '" + TypeString($3) + "\'");
            YYERROR;
        }

    } |
    mul_expr '%' mul_expr
    {
        if (($1.type == Integer || $1.type == Real) && ($3.type == Integer || $3.type == Real))
        {
            if (($1.type == Integer) && ( $3.type == Integer ))
            {
                $$.type = Integer;
                $$.integerValue = $1.integerValue % $3.integerValue;
                if ($1.integerValue * $3.integerValue < 0) // 取余的符号问题
                    $$.integerValue += $3.integerValue;
            }
            else
            {
                $$.type = Real;
                if ( $1.type == Integer )
                    $1.realValue = (double) $1.integerValue;
                if ( $3.type == Integer )
                    $3.realValue = (double) $3.integerValue;
                int temp = (int)($1.realValue / $3.realValue); // 手动实现实数取余
                $$.realValue = $1.realValue - ($3.realValue * temp);
                if ($1.realValue * $3.realValue < 0)
                    $$.realValue += $3.realValue;
            }
        }
        else
        {
            yyerror("TypeError: unsupported operand type(s) for %: '"+ TypeString($1) +"' and '" + TypeString($3) + "\'");
            YYERROR;
        }
    } |
    '(' add_expr ')' { $$ = $2; } |
    '(' mul_expr ')' { $$ = $2; } |
    factor
;

%%

int main()
{
    string KeyBoardStream;
    vector<string> History;
    int historyIndex; // 自下向上地存放输入历史位置
    int cursor = 0; // 光标位置
    yy_buffer_state * Buffer;
    while (true)
    {
        int c;
        printf("%c[2K", 27);
        printf("\33[2K\r"); // 清除本行
        cout << "miniPy> " << KeyBoardStream;
        for (int i = KeyBoardStream.length() ;i > cursor; i--)
            printf("\b"); // 移动光标
        switch(c = getch())
        {
            case 27:
                switch(c = getch())
                {
                    case 91:
                        switch(c = getch())
                        {
                            case 65: // Up
                                historyIndex++;
                                if (historyIndex > History.size())
                                    historyIndex = History.size();
                                else
                                    KeyBoardStream = *(History.rbegin() + historyIndex - 1);
                                if (cursor > KeyBoardStream.length())
                                    cursor = KeyBoardStream.length(); // 防止光标溢出
                                break;
                            case 66: // Down
                                historyIndex--;
                                if (historyIndex <= 0)
                                {
                                    historyIndex = 0;
                                    KeyBoardStream = "";
                                }
                                else
                                    KeyBoardStream = *(History.rbegin() + historyIndex - 1);
                                if (cursor > KeyBoardStream.length())
                                    cursor = KeyBoardStream.length(); // 防止光标溢出
                                break;
                            case 67: // Right
                                cursor++;
                                if (cursor > KeyBoardStream.length())
                                    cursor = KeyBoardStream.length();
                                printf("\033[1C");
                                break;
                            case 68: // Left
                                cursor--;
                                if (cursor < 0)
                                    cursor = 0;
                                printf("\033[1D");
                                break;
                            default:
                                break;
                        }
                        break;
                    default:
                        break;
                }
                break;
            case 3: // Ctrl + C
                // yy_flush_buffer(Buffer); // 清空缓冲区
                KeyBoardStream = ""; // 清空流
                cursor = 0;
                cout << endl << "KeyboardInterrupt" << endl;
                break;
            case 9: // Tab
                cout << "\t" << endl;
                break;
            case 13: // Enter
                putchar('\n');

                // KeyBoardStream += "\n";
                Buffer = yy_scan_string(KeyBoardStream.c_str()); // 设置parse缓冲
                yyparse();
                yy_flush_buffer(Buffer); // 清空parse缓冲

                History.push_back(KeyBoardStream); // 历史入栈
                historyIndex = 0; // 刷新栈顶

                KeyBoardStream = "";
                cursor = 0;
                break;
            case 127: // Backspace
                cursor--;
                if (cursor < 0)
                    cursor = 0;
                else
                    KeyBoardStream.erase(cursor, 1); // 删除流中字符
                break;
            default:
                KeyBoardStream.insert(cursor++, 1, (char)(c)); // 插入字符
        }
    }
    yy_delete_buffer(Buffer);

    return 0;
}

void yyerror(string s)
{
	cout << s << endl;
}

int yywrap()
{
	return 1;
}

void Print(Value x)
{
    switch(x.type)
    {
        case None:
            cout << "None";
            break;
        case Integer:
            cout << x.integerValue;
            break;
        case Real:
            if (x.realValue - floor(x.realValue) == 0)
                cout << x.realValue <<".0";
            else
                cout << setprecision(15) << x.realValue;
            break;
        case String:
            cout << '\'' << x.stringValue << '\'';
            break;
        case List:
        case ListSlice: // Slice 的 listValue 也存储相应值
            cout << "[";
            for (vector<struct value>::iterator i = x.listValue.begin(); i != x.listValue.end(); i++)
            {
                Print(*i);
                if (i != x.listValue.end() - 1)
                    cout << ", ";
            }
            cout << "]";
            break;
        case ListItem:
            Print(*x.begin); // 输出元素
            break;
        case Variable:
            Print(Symbol.at(x.variableName));
            break;
    }
}

string TypeString(Value x) // 将枚举类型返回字符串类型，用于错误信息
{
    switch (x.type)
    {
        case None:       // 赋值语句、列表方法等在python里没有输出
            return "NoneType";
        case Integer:    // 整型
            return "int";
        case Real:       // 浮点型
            return "float";
        case String:     // 字符和字符串
            return "str";
        case List:       // 列表
            return "list";
        case Variable:   // 变量
            return TypeString(Symbol.at(x.variableName));
        case ListSlice:  // 列表切片
            return "list";
        case ListItem:   // 列表元素
            return TypeString(*x.begin);
        default:
            return "NoneType";
    }
}

int Length(Value x) // 将枚举类型返回实体长度，用于len(), insert(), []
{
    switch(x.type)
    {
        case String:
            return(x.stringValue.length());
            break;
        case List:
        case ListSlice:
            return(x.listValue.size());
            break;
        case ListItem:
            return(Length(*x.begin));
        case Variable:   // 变量
            return(Length(Symbol.at(x.variableName)));
            break;
    }
}


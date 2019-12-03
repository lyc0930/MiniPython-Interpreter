%{
    /* definition */
    #include <stdio.h>
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
        string stringValue;             /* value for string type 或 方法 函数名称*/
        vector<struct value> listValue; /* value for list type */
        string variableName;            /* name of the Variable */

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

    // 变量值的输出函数
    void Print(Value);

    // 返回变量类型的字符串
    string TypeString(Value);
%}

%token ID INT REAL STRING_LITERAL
%token DIV
%left  '+' '-'
%left  '*' '/' '%' DIV
%right UMINUS

%%
Start:
    prompt Lines
;

Lines:
    Lines stat '\n'
        {
            Value temp;
            if ($2.type != None)
            {
                if ($2.type == Variable) /* 单独的变量 */
                    Print(Symbol.at($2.variableName));
                else
                    Print($2);
                cout << endl;
            }
        }
    prompt |
    Lines '\n' prompt |
    /*  empty production */ |
    error '\n' { yyerrok; }
;

prompt:
	{ cout << "miniPy> "; }
;

stat:
	assignExpr
;

assignExpr:
    atom_expr '=' assignExpr
        {
            $$.type = None;
            Value temp;
            if ($3.type == Variable)
                temp = Symbol.at($3.variableName);
            else
                temp = $3;
            vector<struct value> temp_for_string = vector<struct value>();
            Value temp_for_string_2; // 拆分字符串
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
                            Symbol[$1.variableName].listValue.erase($1.begin, $1.end);
                            Symbol[$1.variableName].listValue.insert($1.begin, temp.listValue.begin(), temp.listValue.end()); // 插入
                            break;
                        case ListSlice:
                            Symbol[$1.variableName].listValue.erase($1.begin, $1.end);
                            Symbol[$1.variableName].listValue.insert($1.begin, temp.begin, temp.end); // 插入
                            break;
                        case String:
                            temp_for_string_2.type = String;
                            for (int i = 0; i < temp.stringValue.length(); i++)
                            {
                                temp_for_string_2.stringValue = temp.stringValue[i];
                                temp_for_string.push_back(temp_for_string_2);
                            }
                            Symbol[$1.variableName].listValue.erase($1.begin, $1.end);
                            Symbol[$1.variableName].listValue.insert($1.begin, temp_for_string.begin(), temp_for_string.end()); // 插入
                            break;
                        default:
                            yyerror("TypeError: can only assign an iterable");
                            YYERROR;
                    }
                    break;
                default:
                    yyerror("SyntaxError: can't assign to literal");
                    YYERROR;
            }
        }|
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
    /*  empty production */
        {
            $$.type = None;
        }|
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
    /*  empty production */
        {
            $$.type = None;
        }|
    add_expr
;

atom_expr:
    atom |
    atom_expr  '[' sub_expr  ':' sub_expr  slice_op ']'
        {
            int begin, end, step;

            if ($6.type == None) // 默认步长
                step = 1;
            else if ($6.type == Integer)
                step = $6.integerValue;
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

                    if (step > 0)
                    {
                        if ($3.type == None) // 默认起始
                            begin = 0;
                        else if ($3.type == Integer)
                            begin = $3.integerValue;
                        else
                        {
                            yyerror("TypeError: slice indices must be integers or None");
                            YYERROR;
                        }

                        if ($5.type == None) // 默认结束
                            end = $1.stringValue.length();
                        else if ($5.type == Integer)
                            end = $5.integerValue;
                        else
                        {
                            yyerror("TypeError: slice indices must be integers or None");
                            YYERROR;
                        }

                        for (int i = begin; i < end; i += step)
                            $$.stringValue += $1.stringValue[i]; // 逐个取子串
                    }
                    else if (step < 0) // 负步长
                    {
                        if ($3.type == None) // 默认起始
                            begin = $1.stringValue.length() - 1;
                        else if ($3.type == Integer)
                            begin = $3.integerValue;
                        else
                        {
                            yyerror("TypeError: slice indices must be integers or None");
                            YYERROR;
                        }

                        if ($5.type == None) // 默认结束
                            end = -1;
                        else if ($5.type == Integer)
                            end = $5.integerValue;
                        else
                        {
                            yyerror("TypeError: slice indices must be integers or None");
                            YYERROR;
                        }

                        for (int i = begin; i > end; i += step)
                            $$.stringValue += $1.stringValue[i]; // 逐个取子串
                    }
                    break;
                case List:
                    $$.type = List; // 列表元素类型
                    $$.listValue = vector<struct value>();
                    if (step > 0)
                    {
                        if ($3.type == None) // 默认起始
                            begin = 0;
                        else if ($3.type == Integer)
                            begin = $3.integerValue;
                        else
                        {
                            yyerror("TypeError: slice indices must be integers or None");
                            YYERROR;
                        }

                        if ($5.type == None) // 默认结束
                            end = $1.listValue.size();
                        else if ($5.type == Integer)
                            end = $5.integerValue;
                        else
                        {
                            yyerror("TypeError: slice indices must be integers or None");
                            YYERROR;
                        }

                        for (vector<struct value>::iterator i = $1.listValue.begin() + begin; i != $1.listValue.begin() + end; i += step)
                            $$.listValue.push_back(*i); // 逐个取元素
                    }
                    else if (step < 0)
                    {
                        if ($3.type == None) // 默认起始
                            begin = $1.listValue.size() - 1;
                        else if ($3.type == Integer)
                            begin = $3.integerValue;
                        else
                        {
                            yyerror("TypeError: slice indices must be integers or None");
                            YYERROR;
                        }

                        if ($5.type == None) // 默认结束
                            end = -1;
                        else if ($5.type == Integer)
                            end = $5.integerValue;
                        else
                        {
                            yyerror("TypeError: slice indices must be integers or None");
                            YYERROR;
                        }

                        for (vector<struct value>::iterator i = $1.listValue.begin() + begin; i != $1.listValue.begin() + end; i += step)
                            $$.listValue.push_back(*i); // 逐个取元素
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

                                if (step > 0)
                                {
                                    if ($3.type == None) // 默认起始
                                        begin = 0;
                                    else if ($3.type == Integer)
                                        begin = $3.integerValue;
                                    else
                                    {
                                        yyerror("TypeError: slice indices must be integers or None");
                                        YYERROR;
                                    }

                                    if ($5.type == None) // 默认结束
                                        end = Symbol.at($1.variableName).stringValue.length();
                                    else if ($5.type == Integer)
                                        end = $5.integerValue;
                                    else
                                    {
                                        yyerror("TypeError: slice indices must be integers or None");
                                        YYERROR;
                                    }
                                    for (int i = begin; i < end; i += step)
                                        $$.stringValue += Symbol.at($1.variableName).stringValue[i]; // 逐个取子串
                                }
                                else if (step < 0) // 负步长
                                {
                                    if ($3.type == None) // 默认起始
                                        begin = Symbol.at($1.variableName).stringValue.length() - 1;
                                    else if ($3.type == Integer)
                                        begin = $3.integerValue;
                                    else
                                    {
                                        yyerror("TypeError: slice indices must be integers or None");
                                        YYERROR;
                                    }

                                    if ($5.type == None) // 默认结束
                                        end = -1;
                                    else if ($5.type == Integer)
                                        end = $5.integerValue;
                                    else
                                    {
                                        yyerror("TypeError: slice indices must be integers or None");
                                        YYERROR;
                                    }

                                    for (int i = begin; i > end; i += step)
                                        $$.stringValue += Symbol.at($1.variableName).stringValue[i]; // 逐个取子串
                                }
                                break;
                            case List:
                                $$.type = ListSlice; // 列表元素类型
                                $$.variableName = $1.variableName;
                                $$.listValue = vector<struct value>();
                                if (step > 0)
                                {
                                    if ($3.type == None) // 默认起始
                                        $$.begin = Symbol.at($1.variableName).listValue.begin();
                                    else if ($3.type == Integer)
                                        $$.begin = Symbol.at($1.variableName).listValue.begin() + $3.integerValue;
                                    else
                                    {
                                        yyerror("TypeError: slice indices must be integers or None");
                                        YYERROR;
                                    }

                                    if ($5.type == None) // 默认结束
                                        $$.end = Symbol.at($1.variableName).listValue.end();
                                    else if ($5.type == Integer)
                                        $$.end = Symbol.at($1.variableName).listValue.begin() + $5.integerValue;
                                    else
                                    {
                                        yyerror("TypeError: slice indices must be integers or None");
                                        YYERROR;
                                    }

                                    for (vector<struct value>::iterator i = $$.begin; i != $$.end; i += step)
                                        $$.listValue.push_back(*i); // 逐个取子串

                                }
                                else if (step < 0)
                                {
                                    if ($3.type == None) // 默认起始
                                        $$.begin = Symbol.at($1.variableName).listValue.end() - 1;
                                    else if ($3.type == Integer)
                                        $$.begin = Symbol.at($1.variableName).listValue.begin() + $3.integerValue;
                                    else
                                    {
                                        yyerror("TypeError: slice indices must be integers or None");
                                        YYERROR;
                                    }

                                    if ($5.type == None) // 默认结束
                                        $$.end = Symbol.at($1.variableName).listValue.begin() - 1;
                                    else if ($5.type == Integer)
                                        $$.end = Symbol.at($1.variableName).listValue.begin() + $5.integerValue;
                                    else
                                    {
                                        yyerror("TypeError: slice indices must be integers or None");
                                        YYERROR;
                                    }

                                    for (vector<struct value>::iterator i = $$.begin; i != $$.end; i += step)
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
                    yyerror("TypeError: '"+ TypeString($1) +"' object is not subscriptable");
                    YYERROR;
            }
        }|
    atom_expr  '[' add_expr ']'
        {
            if ($3.type == Integer)
            {
                switch ($1.type)
                {
                    case String:
                        $$.type = String;
                        $$.stringValue = $1.stringValue[$3.integerValue]; // 字符和字符串同等
                        break;
                    case List:
                        $$.type = ListItem; // 列表元素类型
                        $$.begin = $1.listValue.begin() + $3.integerValue; // 取列表元素地址
                        break;
                    case Variable:
                        if ((Symbol.count($1.variableName) == 1)) // 已在变量表内
                        {
                            switch (Symbol.at($1.variableName).type)
                            {
                                case String:
                                    $$.type = String;
                                    $$.stringValue = Symbol.at($1.variableName).stringValue[$3.integerValue]; // 字符和字符串同等
                                    break;
                                case List:
                                    $$.type = ListItem; // 列表元素类型
                                    $$.begin = Symbol.at($1.variableName).listValue.begin() + $3.integerValue; // 取列表元素地址
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
                        yyerror("TypeError: '"+ TypeString($1) +"' object is not subscriptable");
                        YYERROR;
                }
            }
            else
            {
                yyerror("TypeError: list indices must be integers or slices, not " + TypeString($3));
                YYERROR;
            }
        }|
    atom_expr '(' arglist opt_comma ')'
        {
            if ($1.stringValue == "append") // append方法
            {
                $$.type = None;
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

            }
            else if ($1.stringValue == "count") // count方法
            {
                $$.type = Integer;
                if (Symbol.at($1.variableName).type == List)
                {
                    if ($3.listValue.size() == 1)
                    {
                        if (Symbol.at($1.variableName).type == List)
                        {
                            if ($3.listValue.size() == 1) // count 有且仅有1个参数
                            {
                                $$.integerValue = count(Symbol.at($1.variableName).listValue.begin(), Symbol.at($1.variableName).listValue.end(), *$3.listValue.begin()); // 调用algorithm中的count
                            }
                        }
                    }
                    else
                    {
                        yyerror("TypeError: count() takes exactly one argument ("+ to_string($3.listValue.size()) +" given)");
                        YYERROR;
                    }
                }
                else
                {
                    yyerror("AttributeError: '" + TypeString(Symbol.at($1.variableName)) + "' object has no attribute 'count'");
                    YYERROR;
                }
            }
            else if ($1.stringValue == "extend") // extend方法
            {
                $$.type = None;
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
            }
            else if ($1.stringValue == "index")
            {
                if ((Symbol.at($1.variableName).type == List) || (Symbol.at($1.variableName).type == String))
                {
                    if ($3.listValue.size() > 3)
                    {
                        yyerror("TypeError: range expected at most 3 arguments, got " + to_string($3.listValue.size()));
                        YYERROR;
                    }
                    else
                    {
                        Value object = $3.listValue[0];

                        if (Symbol.at($1.variableName).type == List)
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
                        else if (Symbol.at($1.variableName).type == String)
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
                    }
                }
                else
                {
                    yyerror("AttributeError: '" + TypeString(Symbol.at($1.variableName)) + "' object has no attribute 'index'");
                    YYERROR;
                }
            }
            else if ($1.stringValue == "reverse")
            {
                if (Symbol.at($1.variableName).type == List)
                {
                    yyerror("TypeError: append() takes no arguments ("+ to_string($3.listValue.size()) +" given)");
                    YYERROR;
                }
                else
                {
                    yyerror("AttributeError: '" + TypeString(Symbol.at($1.variableName)) + "' object has no attribute 'reverse'");
                    YYERROR;
                }
            }
            else if ($1.variableName == "print") // print函数
            {
                $$.type = None;
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
            }
            else if ($1.variableName == "list") // list函数
            {
                $$.type = List;

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

        } |
    atom_expr '.' ID
        {
            $$.type = None;
            $$.variableName = $1.variableName; // 变量名
            $$.stringValue = $3.variableName; // 属性或方法名
        } |
    atom_expr  '('  ')'
        {
            if ($1.variableName == "quit") // quit函数
                exit(0);
            else if ($1.stringValue == "append")
            {
                $$.type = None;
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
            }
            else if ($1.stringValue == "count")
            {
                $$.type = None;
                if (Symbol.at($1.variableName).type == List)
                {
                    yyerror("TypeError: append() takes exactly one argument (0 given)");
                    YYERROR;
                }
                else
                {
                    yyerror("AttributeError: '" + TypeString(Symbol.at($1.variableName)) + "' object has no attribute 'count'");
                    YYERROR;
                }
            }
            else if ($1.stringValue == "extend")
            {
                $$.type = None;
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
            }
            else if ($1.stringValue == "index")
            {
                $$.type = None;
                if ((Symbol.at($1.variableName).type == List) || (Symbol.at($1.variableName).type == String))
                {
                    yyerror("TypeError: index() takes at least 1 argument (0 given)");
                    YYERROR;
                }
                else
                {
                    yyerror("AttributeError: '" + TypeString(Symbol.at($1.variableName)) + "' object has no attribute 'index'");
                    YYERROR;
                }
            }
            else if ($1.stringValue == "reverse") // reverse方法
            {
                $$.type = None;
                if (Symbol.at($1.variableName).type == List)
                {
                    reverse(Symbol.at($1.variableName).listValue.begin(), Symbol.at($1.variableName).listValue.end()); // 调用algorithm中的reverse
                }
                else
                {
                    yyerror("AttributeError: '" + TypeString(Symbol.at($1.variableName)) + "' object has no attribute 'reverse'");
                    YYERROR;
                }
            }
            else if ($1.variableName == "print") // print函数
            {
                $$.type = None;
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
    }|
    '[' List_items opt_comma ']' /* 注意 [1, 2, 3, ] == [1, 2, 3] */
    {
        $$.type = List;
        $$.listValue = vector<struct value>($2.listValue);
    }
;

opt_comma:
    /*  empty production */ |
    ','
;

List_items:
    add_expr
    {
        $$.type = List;
        $$.listValue = vector<struct value>(1, $1); // 用列表“框柱”变量
    }|
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
                        case Integer:
                            $$.listValue.insert($$.listValue.end(), $3); // 在尾部插入
                            break;
                        case Real:
                            $$.listValue.insert($$.listValue.end(), $3); // 在尾部插入
                            break;
                        case String:
                            $$.listValue.insert($$.listValue.end(), $3); // 在尾部插入
                            break;
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
        }|
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
        }|
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
        }|
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
        }|
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

        }|
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
        }|
    '(' add_expr ')' { $$ = $2; } |
    '(' mul_expr ')' { $$ = $2; } |
    factor
;

%%

int main()
{
	return yyparse();
}

void yyerror(string s)
{
	cout << s << endl << "miniPy> ";
}

int yywrap()
{
	return 1;
}

void Print(Value x)
{
    switch(x.type)
    {
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
    }
}

string TypeString(Value x) // 将枚举类型返回字符串类型，用于错误信息
{
    switch (x.type)
    {
        case None:       // 赋值语句、列表方法等在python里没有输出
            return "None";
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
            return "None";
    }
}
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
    #include "minipy-lab.h"
    using namespace std;
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
    } Value;

    /*
        符号表 Symbol Table
        variableName(string) -> Value(not Variable)
    */
    map<string, Value> Symbol;

    #define YYSTYPE Value
    #include "lex.yy.c"
    void yyerror(string);

    // 变量值的输出函数
    void Print(Value);

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
                    Print(Symbol[$2.variableName]);
                else
                    Print($2);
                cout << endl;
            }
        }
    prompt |
    Lines '\n' prompt |
    /*  empty production */ |
    error '\n'
        { yyerrok; }
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
            switch ($1.type)
            {
                case Variable:
                    Symbol[$1.variableName] = $3; /* 加入符号表或重新赋值 */
                    break;
                case ListItem:
                    *$1.begin = $3;
                    break;
                case ListSlice:
                    switch ($3.type)
                    {
                        case List:
                            Symbol[$1.variableName].listValue.erase($1.begin, $1.end);
                            Symbol[$1.variableName].listValue.insert($1.begin + 1, $3.listValue.begin(), $3.listValue.end()); // 插入
                            break;
                        case ListSlice:
                            Symbol[$1.variableName].listValue.erase($1.begin, $1.end);
                            Symbol[$1.variableName].listValue.insert($1.begin + 1, $3.begin, $3.end); // 插入
                            break;
                        // default: yyerror(); // TODO @NXH ，只能给切片赋切片或者列表
                    }
                    break;
                // default: yyerror(); // TODO @NXH ， only subscriptable type here
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
        { $$ = $2; } |
    '-' factor %prec UMINUS
        {
            $$.type = $2.type;
            if ($2.type == Integer)
                $$.integerValue = -$2.integerValue;
            else if ($2.type == Real)
                $$.realValue = -$2.realValue;
        } |
    atom_expr
        {
            switch ($1.type)
            {
                case Integer:
                case Real:
                case String:
                    $$ = $1;
                    break;
                case Variable:
                    if (Symbol.count($1.variableName) == 1) // 已在变量表内
                        $$ = Symbol.at($1.variableName); // 取变量内容，使用下标检查
                    else
                    {
                        $$.type = None; // 不输出变量内容，也确实没有可以输出的
                        // TODO @NXH 把这里的错误信息处理好
                        // yyerror("Traceback (most recent call last):\n\tFile \"<stdin>\", line 1, in <module>\nNameError: name "+ $1.variableName +" is not defined  ");
                    }
                    break;
                case ListItem:
                    $$ = *$1.begin;
                    break;
                // default: yyerror(); // TODO @NXH ， only subscriptable type here
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
            // yyerror(); // TODO @NXH ， int
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
                // yyerror(); // TODO @NXH ， int or none
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
                            // yyerror(); // TODO @NXH ， int or none
                        }

                        if ($5.type == None) // 默认结束
                            end = $1.stringValue.length();
                        else if ($5.type == Integer)
                            end = $5.integerValue;
                        else
                        {
                            // yyerror(); // TODO @NXH ， int or none
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
                            // yyerror(); // TODO @NXH ， int or none
                        }

                        if ($5.type == None) // 默认结束
                            end = -1;
                        else if ($5.type == Integer)
                            end = $5.integerValue;
                        else
                        {
                            // yyerror(); // TODO @NXH ， int or none
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
                            // yyerror(); // TODO @NXH ， int or none
                        }

                        if ($5.type == None) // 默认结束
                            end = $1.listValue.size();
                        else if ($5.type == Integer)
                            end = $5.integerValue;
                        else
                        {
                            // yyerror(); // TODO @NXH ， int or none
                        }

                        for (vector<struct value>::iterator i = $1.listValue.begin() + begin; i != $1.listValue.begin() + end; i += step)
                            $$.listValue.push_back(*i); // 逐个取子串
                    }
                    else if (step < 0)
                    {
                        if ($3.type == None) // 默认起始
                            begin = $1.listValue.size() - 1;
                        else if ($3.type == Integer)
                            begin = $3.integerValue;
                        else
                        {
                            // yyerror(); // TODO @NXH ， int or none
                        }

                        if ($5.type == None) // 默认结束
                            end = -1;
                        else if ($5.type == Integer)
                            end = $5.integerValue;
                        else
                        {
                            // yyerror(); // TODO @NXH ， int or none
                        }

                        for (vector<struct value>::iterator i = $1.listValue.begin() + begin; i != $1.listValue.begin() + end; i += step)
                            $$.listValue.push_back(*i); // 逐个取子串
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
                                        // yyerror(); // TODO @NXH ， int or none
                                    }

                                    if ($5.type == None) // 默认结束
                                        end = Symbol.at($1.variableName).stringValue.length();
                                    else if ($5.type == Integer)
                                        end = $5.integerValue;
                                    else
                                    {
                                        // yyerror(); // TODO @NXH ， int or none
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
                                        // yyerror(); // TODO @NXH ， int or none
                                    }

                                    if ($5.type == None) // 默认结束
                                        end = -1;
                                    else if ($5.type == Integer)
                                        end = $5.integerValue;
                                    else
                                    {
                                        // yyerror(); // TODO @NXH ， int or none
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
                                        // yyerror(); // TODO @NXH ， int or none
                                    }

                                    if ($5.type == None) // 默认结束
                                        $$.end = Symbol.at($1.variableName).listValue.end();
                                    else if ($5.type == Integer)
                                        $$.end = Symbol.at($1.variableName).listValue.begin() + $5.integerValue;
                                    else
                                    {
                                        // yyerror(); // TODO @NXH ， int or none
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
                                        // yyerror(); // TODO @NXH ， int or none
                                    }

                                    if ($5.type == None) // 默认结束
                                        $$.end = Symbol.at($1.variableName).listValue.begin() - 1;
                                    else if ($5.type == Integer)
                                        $$.end = Symbol.at($1.variableName).listValue.begin() + $5.integerValue;
                                    else
                                    {
                                        // yyerror(); // TODO @NXH ， int or none
                                    }

                                    for (vector<struct value>::iterator i = $$.begin; i != $$.end; i += step)
                                        $$.listValue.push_back(*i); // 逐个取子串
                                }
                                break;
                            // default: yyerror(); // TODO @NXH ， only subscriptable type here
                        }
                    }
                    else
                    {
                        // yyerror(); // TODO @NXH ， only subscriptable type here
                    }
                    break;
                // default: yyerror(); // TODO @NXH ， only subscriptable type here
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
                                // default: yyerror(); // TODO @NXH ， only subscriptable type here
                            }
                        }
                        else
                        {
                            // yyerror(); // TODO @NXH ， only subscriptable type here
                        }
                        break;
                    // default: yyerror(); // TODO @NXH ， only subscriptable type here
                }
            }
            else
            {
                // yyerror(); // TODO @NXH , indices must be integers or slices
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
                else
                {
                    // yyerror(); // TODO @NXH ， 2 或 3 个参数
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
        } |
    atom_expr '.' ID
        {
            $$.type = None;
            $$.variableName = $1.variableName; // 变量名
            $$.stringValue = $3.variableName; // 属性或方法名
        } |
    atom_expr  '('  ')'
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
                        case List:
                            $$.type = List;
                            $$.listValue = vector<struct value>($3.listValue);
                            $$.listValue.insert($$.listValue.begin(), $1); // 在头部插入
                            break;
                        // default: yyerror(); // TODO @NXH
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
                        case List:
                            $$.type = List;
                            $$.listValue = vector<struct value>($3.listValue);
                            $$.listValue.insert($$.listValue.begin(), $1); // 在头部插入
                            break;
                        // default: yyerror(); // TODO @NXH
                    }
                    break;
                case String:
                    switch($3.type)
                    {
                        case String:
                            $$.type = String;
                            $$.stringValue = $1.stringValue + $3.stringValue;
                            break;
                        case List:
                            $$.type = List;
                            $$.listValue = vector<struct value>($3.listValue);
                            $$.listValue.insert($$.listValue.begin(), $1); // 在头部插入
                            break;
                        // default: yyerror(); // TODO @NXH
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
                        // default: yyerror(); // TODO @NXH
                    }
                // default: yyerror(); // TODO @NXH
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
                        // default: yyerror(); // TODO @NXH
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
                        // default: yyerror(); // TODO @NXH
                    }
                    break;
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
                        // default: yyerror(); // TODO @NXH
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
                        // default: yyerror(); // TODO @NXH
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
                        // default: yyerror(); // TODO @NXH
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
                        // default: yyerror(); // TODO @NXH
                    }
                // default: yyerror(); // TODO @NXH
            }
        }|
    mul_expr '/' mul_expr
        {
            $$.type = Real;
            if ( $1.type == Integer )
                $1.realValue = (double) $1.integerValue;
            if ( $3.type == Integer )
                $3.realValue = (double) $3.integerValue;
            $$.realValue = $1.realValue / $3.realValue;
            // default: yyerror(); // TODO @NXH
        }|
    mul_expr DIV mul_expr
        {
            // 整除
            if ( $1.type == Real )
                $1.integerValue = round($1.realValue);
            if ( $3.type == Real )
                $3.integerValue = round($3.realValue);
            $$.type = Integer;
            $$.integerValue = $1.integerValue / $3.integerValue;
            // default: yyerror(); // TODO @NXH
        }|
    mul_expr '%' mul_expr
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
            // default: yyerror(); // TODO @NXH
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
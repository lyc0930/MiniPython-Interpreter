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
        string stringValue;             /* value for string type */
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
    void yyerror(char*);

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
            // default: yyerror(); // TODO @NXH ， only subscriptable type here
        }
    }|
    add_expr
;

number:
    INT { $$ = $1;} |
    REAL { $$ = $1;}
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
                        // TODO @NXH 把这里的错误信息处理好，注意string到char*的转换
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
    /*  empty production */ |
    ':' add_expr
;

sub_expr:
    /*  empty production */ |
    add_expr
;

atom_expr:
    atom |
    atom_expr  '[' sub_expr  ':' sub_expr  slice_op ']'
    {
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
    atom_expr  '.' ID |
    atom_expr  '(' arglist opt_comma ')' |
    atom_expr  '('  ')'
;

arglist:
    add_expr |
    arglist ',' add_expr
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

void yyerror(char *s)
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
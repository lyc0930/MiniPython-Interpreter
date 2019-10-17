%{
    /* definition */
    #include <stdio.h>
    #include <ctype.h>
    #include <cmath>
    #include <iostream>
    #include <string>
    #include <map>
    #include "minipy-lab.h"
    typedef struct
    {
        int type;
        union
        {
            int i;    /* value for int type */
            double d; /* value for float type */
        };
    } Val;
    #define YYSTYPE Val
    #include "lex.yy.c"
    using namespace std;
    void yyerror(char*);
    // int yylex(void);
%}

%token ID INT REAL STRING_LITERAL
%token DIV
%left  '+' '-'
%left  '*' '/'
%right UMINUS

%%
Start:
    prompt Lines
;

Lines:
    Lines stat '\n'
        {
            if ($2.type == INTEGER)
                cout << $2.i << endl;
            else if ($2.type == DOUBLE)
                cout << $2.d << endl;
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
        { $$ = $1; }
;

assignExpr:
    atom_expr '=' assignExpr
        { $$ = $1; } |
    add_expr
        { $$ = $1; }
;

number:
    INT { $$ = $1; cout <<"INT!"<<endl;} |
    REAL { $$ = $1; cout <<"REAL!"<<endl;}
;

factor:
    '+' factor
        { $$ = $2; } |
    '-' factor %prec UMINUS
        {
            $$.type = $2.type;
            if ($2.type == INTEGER)
                $$.i = -$2.i;
            else if ($2.type == DOUBLE)
                $$.d = -$2.d;
        } |
    atom_expr
        { $$ = $1; }
;

atom:
    ID |
    STRING_LITERAL |
    List |
    number { $$ = $1;}
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
    atom { $$ = $1; } |
    atom_expr  '[' sub_expr  ':' sub_expr  slice_op ']' |
    atom_expr  '[' add_expr ']' |
    atom_expr  '.' ID |
    atom_expr  '(' arglist opt_comma ')' |
    atom_expr  '('  ')'
;

arglist:
    add_expr |
    arglist ',' add_expr
;

List:
    '[' ']' |
    '[' List_items opt_comma ']' /* [1, 2, 3, ] == [1, 2, 3] */
;

opt_comma:
    /*  empty production */ |
    ','
;

List_items:
    add_expr |
    List_items ',' add_expr
;

add_expr:
    add_expr '+' mul_expr
        {
            if (($1.type == INTEGER) && ( $3.type == INTEGER ))
            {
			    $$.type = INTEGER;
                $$.i = $1.i + $3.i;
            }
            else
            {
		        $$.type = DOUBLE;
                if ( $1.type == INTEGER )
                    $1.d = (double) $1.i;
                if ( $3.type == INTEGER )
                    $3.d = (double) $3.i;
                $$.d = $1.d + $3.d;
            }
        }|
    add_expr '-' mul_expr
        {
            if (($1.type == INTEGER) && ( $3.type == INTEGER ))
            {
			    $$.type = INTEGER;
                $$.i = $1.i - $3.i;
            }
            else
            {
		        $$.type = DOUBLE;
                if ( $1.type == INTEGER )
                    $1.d = (double) $1.i;
                if ( $3.type == INTEGER )
                    $3.d = (double) $3.i;
                $$.d = $1.d - $3.d;
            }
        }|
    mul_expr { $$ = $1; }
;

mul_expr:
    mul_expr '*' factor
        {
            if (($1.type == INTEGER) && ( $3.type == INTEGER ))
            {
			    $$.type = INTEGER;
                $$.i = $1.i * $3.i;
            }
            else
            {
		        $$.type = DOUBLE;
                if ( $1.type == INTEGER )
                    $1.d = (double) $1.i;
                if ( $3.type == INTEGER )
                    $3.d = (double) $3.i;
                $$.d = $1.d * $3.d;
            }
        }|
    mul_expr '/' factor
        {
            $$.type = DOUBLE;
            if ( $1.type == INTEGER )
                $1.d = (double) $1.i;
            if ( $3.type == INTEGER )
                $3.d = (double) $3.i;
            $$.d = $1.d / $3.d;
        }|
    mul_expr DIV factor
        {
            // 整除
            if ( $1.type == DOUBLE )
                $1.i = round($1.d);
            if ( $3.type == DOUBLE )
                $3.i = round($3.d);
            $$.type = INTEGER;
            $$.i = $1.i / $3.i;
        }|
    mul_expr '%' factor
        {
            if (($1.type == INTEGER) && ( $3.type == INTEGER ))
            {
			    $$.type = INTEGER;
                $$.i = $1.i % $3.i;
                if ($1.i * $3.i < 0)
                    $$.i += $3.i;
            }
            else
            {
		        $$.type = DOUBLE;
                if ( $1.type == INTEGER )
                    $1.d = (double) $1.i;
                if ( $3.type == INTEGER )
                    $3.d = (double) $3.i;
                int temp = (int)($1.d / $3.d);
                $$.d = $1.d - ($3.d * temp);
                if ($1.d * $3.d < 0)
                    $$.d += $3.d;
            }
        }|
    factor { $$ = $1; }
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

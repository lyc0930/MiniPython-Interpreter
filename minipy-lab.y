%{
    /* definition */
	#include <stdio.h>
	#include <ctype.h>
	#include <iostream>
	#include <string>
	#include <map>

	#include "lex.yy.c"

	using namespace std;
	void yyerror(char *s);
%}

%token ID INT REAL STRING_LITERAL

%%
Start:
    prompt Lines
;

Lines:
    Lines  stat '\n' { cout << $2 << endl; } prompt |
    Lines  '\n' prompt |
    /*  empty production */ |
    error '\n'
        { yyerrok; }
;

prompt:
	{ cout << "miniPy> "; }
;

stat:
	assignExpr { $$ = $1; }
;

assignExpr:
    atom_expr '=' assignExpr |
    add_expr { $$ = $1; }
;

number:
    INT |
    REAL
;

factor:
    '+' factor |
    '-' factor |
    atom_expr
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
    add_expr '+' mul_expr { $$ = $1 + $3; }|
    add_expr '-' mul_expr { $$ = $1 - $3; }|
    mul_expr { $$ = $1; }
;

mul_expr:
    mul_expr '*' factor |
    mul_expr '/' factor |
    mul_expr '%' factor |
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

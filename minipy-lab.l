%{
#include <stdlib.h>
#include <stdio.h>
#include <iostream>
#include "minipy-lab.h"
using namespace std;
void yyerror(char*);
#include "y.tab.h"

/*  any C declaration  */
%}

letter    [a-zA-Z]

digit     [0-9]

number   {digit}+

id       {letter}({letter}|{digit})*

real     {number}'.'{number}?|{number}?'.'{number}

%%
[ \t]+              { /*do nothing , just skip */ }
{number}            {
                        yylval.type = INTEGER;
                        yylval.i = atoi( yytext );
	                    return INT;
                    }
{real}              {
                        yylval.type = DOUBLE;
                        yylval.d = atof( yytext );
                        return REAL;
                    }
{id}                { return ID; }
\"(\\.|[^\\"])*\"   { return STRING_LITERAL; }
.|\n                {
                        yylval.type = INT;
                        return yylval.i = yytext[0];
                    }
%%

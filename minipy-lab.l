%{
#include <stdlib.h>
#include <stdio.h>
#include <iostream>
// #include "minipy-lab.h"
using namespace std;
// void yyerror(char*);
#include "y.tab.h"

/*  any C declaration  */
%}

letter    [a-zA-Z]

digit     [0-9]

number   {digit}+

id       {letter}({letter}|{digit})*

real     {number}"."{number}?|{number}?"."{number}

%%
[ \t]+              { /*do nothing , just skip */ }
{number}            {
                        yylval.type = Integer;
                        yylval.integerValue = atoi( yytext );
	                    return INT;
                    }
{real}              {
                        yylval.type = Real;
                        yylval.realValue = atof( yytext );
                        return REAL;
                    }
{id}                { return ID; }
\"(\\.|[^\\"])*\"   { return STRING_LITERAL; }
.|\n                {
                        yylval.type = Integer;
                        return yylval.integerValue = yytext[0];
                    }
\/\/                  {
                        return DIV;
                    }
%%
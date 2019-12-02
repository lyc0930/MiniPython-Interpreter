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
{id}                {
                        yylval.type = Variable;
                        yylval.variableName.assign(yytext);
                        return ID;
                    }
('(\\.|[^\\'])*')|(\"(\\.|[^\\"])*\")   {
                        yylval.type = String;
                        string temp;
                        temp.assign(yytext);
                        yylval.stringValue = temp.substr(1, temp.length() - 2); /* 删除“” */
                        return STRING_LITERAL;
                    }
.|\n                {
                        yylval.type = Integer;
                        return yylval.integerValue = yytext[0];
                    }
\/\/                {
                        return DIV;
                    }
%%
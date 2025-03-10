%{
    #include "y.tab.h"
    #include <stdlib.h>
    #include <string.h>
    extern int yylineno;
    void yyerror(const char *s);
%}

%%
"begindecl"   return BEGINDECL;
"enddecl"     return ENDDECL;
"integer"     return INTEGER;
"float"       return FLOAT;         /* Support for float type */
"do"          return DO;            /* Support for do-while loop */
"while"       return WHILE;         
"print"       return PRINT;
"write"       return WRITE;

[0-9]+        { yylval.num = atoi(yytext); return NUM; }  
[0-9]+\.[0-9]+ { yylval.fnum = atof(yytext); return FLOAT_NUM; } /* Floating-point numbers */

[a-zA-Z_][a-zA-Z0-9_]* { yylval.s = strdup(yytext); return ID; }

"="           return '=';
";"           return ';';
","           return ',';
"("           return '(';
")"           return ')';
"+"           return '+';
"-"           return '-';
"*"           return '*';
"/"           return '/';
"{"           return '{';
"}"           return '}';
"["           return '[';            /* Support for array indexing */
"]"           return ']';

[ \t\n]       ;  /* Ignore whitespace */

.             { printf("Unrecognized character: %s\n", yytext); }

%%
int yywrap() {
    return 1;  // Indicate end of input
}

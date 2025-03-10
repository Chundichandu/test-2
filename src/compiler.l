%{
#include "y.tab.h"
extern int yylineno;
void yyerror(const char *s);
%}

%%
"decl"       { return DECL; }
"enddecl"    { return ENDDECL; }
"begin"      { return BBEGIN; }
"end"        { return BEND; }
"integer"    { return INTEGER; }
"float"      { return FLOAT; }
"print"      { return PRINT; }
"write"      { return WRITE; }
"if"         { return IF; }
"else"       { return ELSE; }
"for"        { return FOR; }
"do"         { return DO; }
"while"      { return WHILE; }

[0-9]+\.[0-9]+  { yylval.fnum = atof(yytext); return FLOAT_NUM; }
[0-9]+          { yylval.num = atoi(yytext); return NUM; }
[a-zA-Z_][a-zA-Z0-9_]* { yylval.s = strdup(yytext); return ID; }

"="          { return '='; }
";"          { return ';'; }
","          { return ','; }
"("          { return '('; }
")"          { return ')'; }
"{"          { return '{'; }
"}"          { return '}'; }
"["          { return '['; }
"]"          { return ']'; }
"+"          { return '+'; }
"-"          { return '-'; }
"*"          { return '*'; }
"/"          { return '/'; }

[ \t\n]+    ;  // Skip whitespace

.           { printf("Unrecognized character: %s\n", yytext); }
%%

int yywrap() {
    return 1;
}

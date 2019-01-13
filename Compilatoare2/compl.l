%{ //define and include directives of cpp


#include "y.tab.h"

int lineNo = 1;
int colNo = 1;
void yyerror(const char *msg);

%} //definitions

%% //rules

"-"                         { colNo++; return TOK_MINUS; }
"+"                         { colNo++; return TOK_PLUS; }
"*"                         { colNo++; return TOK_INMULTIT; }
"DIV"                         { colNo++; return TOK_DIV; }
"("                         { colNo++; return TOK_LEFT; }
")"                         { colNo++; return TOK_RIGHT; }
","                         { colNo++; return TOK_VIRGULA; }
";"                         { colNo++; return TOK_PUNCT_VIRGULA; }
":"                         { colNo++; return TOK_DOUA_PUNCTE; }
":="                        { colNo++; return TOK_ASSIGN; }
"DO"                        { colNo+=2; return TOK_DO; }
"TO"                        { colNo+=2; return TOK_TO; }
"VAR"                       { colNo+=3; return TOK_VAR; }
"END"                       { colNo+=3; return TOK_END; }
"FOR"                       { colNo+=3; return TOK_FOR; }
"READ"                      { colNo+=4; return TOK_READ; }
"WRITE"                     { colNo+=5; return TOK_WRITE; }
"BEGIN"                     { colNo+=5; return TOK_BEGIN; }
"PROGRAM"                   { colNo+=7; return TOK_PROGRAM; }
"INTEGER"                   { colNo+=7; return TOK_INTEGER; }



[a-zA-Z][a-zA-Z0-9_]*       { yylloc.first_line = lineNo; yylloc.first_column = colNo; colNo+=strlen(yytext); yylval.sir = new char[strlen(yytext)+1]; strcpy(yylval.sir, yytext); return TOK_ID; }
0|([1-9][0-9]*)             { yylloc.first_line = lineNo; yylloc.first_column = colNo; colNo+=strlen(yytext); yylval.val = atoi(yytext); return TOK_INT; }
[ \t\v]                     { ; }
[$.]                        { yyerror("text invalid"); }
.                           { colNo++; return TOK_ERROR; }
\n                          { lineNo++; colNo=1; }

%% //user defines directives
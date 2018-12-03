%{
	#include "grammar.tab.h"
%}

INT "int"
DATE "date"
STRING "string"
WORD ([a-zA-Z_])+
ATTR {WORD}[[:space:]]({INT}|{STRING}|{DATE})
ATTRS {ATTR}(,{ATTR})*
WORD_LIST {WORD}(,{WORD})*

%%

(?i:"where")		{ yylval.lexeme_val = strdup(yytext); return COM_WHERE; }
(?i:"select")		{ yylval.lexeme_val = strdup(yytext); return COM_SELECT; }
(?i:"create")		{ yylval.lexeme_val = strdup(yytext); return COM_CREATE; }
(?i:"table")		{ yylval.lexeme_val = strdup(yytext); return COM_TABLE; }
(?i:"insert")		{ yylval.lexeme_val = strdup(yytext); return COM_INSERT; }
(?i:"into")			{ yylval.lexeme_val = strdup(yytext); return COM_INTO; }
(?i:"values")		{ yylval.lexeme_val = strdup(yytext); return COM_VALUES; }
(?i:"from")			{ yylval.lexeme_val = strdup(yytext); return COM_FROM; }
(?i:"alter")		{ yylval.lexeme_val = strdup(yytext); return COM_ALTER; }
(?i:"delete")		{ yylval.lexeme_val = strdup(yytext); return COM_DELETE; }
(?i:"desc")			{ yylval.lexeme_val = strdup(yytext); return COM_DESC; }
(?i:"update")		{ yylval.lexeme_val = strdup(yytext); return COM_UPDATE; }
(?i:"set")			{ yylval.lexeme_val = strdup(yytext); return COM_SET; }
(?i:"drop")			{ yylval.lexeme_val = strdup(yytext); return COM_DROP; }
(?i:"add")			{ yylval.lexeme_val = strdup(yytext); return COM_ADD; }
(?i:"remove")		{ yylval.lexeme_val = strdup(yytext); return COM_REMOVE; }
(?i:"help")			{ yylval.lexeme_val = strdup(yytext); return COM_HELP; }
(?i:"exit")			{ yylval.lexeme_val = strdup(yytext); return COM_EXIT; }
(?i:"avg")			{ yylval.lexeme_val = strdup(yytext); return FUNCT_AVG; }
(?i:"sum")			{ yylval.lexeme_val = strdup(yytext); return FUNCT_SUM; }
(?i:"min")			{ yylval.lexeme_val = strdup(yytext); return FUNCT_MIN; }
(?i:"max")			{ yylval.lexeme_val = strdup(yytext); return FUNCT_MAX; }
"*"		     		{ yylval.lexeme_val = strdup(yytext); return STAR; }
"<>"			    { yylval.lexeme_val = strdup(yytext); return DIFF; }
"="		            { yylval.lexeme_val = strdup(yytext); return EQUALS; }
 ")"    	        { yylval.lexeme_val = strdup(yytext); return RIGHT_PARENTHESIS; }
"("    		        { yylval.lexeme_val = strdup(yytext); return LEFT_PARENTHESIS; }
";"					{ yylval.lexeme_val = strdup(yytext); return SEMI_COLON; }
{WORD}  			{ yylval.lexeme_val = strdup(yytext); return WORD; }
{ATTRS}  			{ yylval.lexeme_val = strdup(yytext); return ATTRS; }
{WORD_LIST}			{ yylval.lexeme_val = strdup(yytext); return WORD_LIST; }

%%
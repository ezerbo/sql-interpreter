%{
	#include "grammar.tab.h"
%}

int "int"
date "date"
string "string"
digit [0-9]
WORD ([a-zA-Z_])+
ATTR {WORD}[ ]({int}|{string}|{date})
ATTRS ({ATTR}[,])+{ATTR}
INSERT_VALUES [:alpha:]

%%

"WHERE"|"where"			{ yylval.lexeme_val = strdup(yytext); return COM_WHERE; }
"SELECT"|"select"		{ yylval.lexeme_val = strdup(yytext); return COM_SELECT; }
"CREATE"|"create"		{ yylval.lexeme_val = strdup(yytext); return COM_CREATE; }
"TABLE"|"table"			{ yylval.lexeme_val = strdup(yytext); return COM_TABLE; }
"INSERT"|"insert"		{ yylval.lexeme_val = strdup(yytext); return COM_INSERT; }
"INTO"|"into"			{ yylval.lexeme_val = strdup(yytext); return COM_INTO; }
"VALUES"|"values"		{ yylval.lexeme_val = strdup(yytext); return COM_VALUES; }
"FROM"|"from"			{ yylval.lexeme_val = strdup(yytext); return COM_FROM; }
"ALTER"|"alter"			{ yylval.lexeme_val = strdup(yytext); return COM_ALTER; }
"DELETE"|"delete"		{ yylval.lexeme_val = strdup(yytext); return COM_DELETE; }
"DESC"|"desc"			{ yylval.lexeme_val = strdup(yytext); return COM_DESC; }
"UPDATE"|"update"		{ yylval.lexeme_val = strdup(yytext); return COM_UPDATE; }
"SET"|"set"				{ yylval.lexeme_val = strdup(yytext); return COM_SET; }
"DROP"|"drop"			{ yylval.lexeme_val = strdup(yytext); return COM_DROP; }
"ADD"|"add"				{ yylval.lexeme_val = strdup(yytext); return COM_ADD; }
"REMOVE"|"remove"		{ yylval.lexeme_val = strdup(yytext); return COM_REMOVE; }
"HELP"|"help"			{ yylval.lexeme_val = strdup(yytext); return COM_HELP; }
"EXIT"|"exit"			{ yylval.lexeme_val = strdup(yytext); return COM_EXIT; }
"AVG"|"avg"				{ yylval.lexeme_val = strdup(yytext); return FUNCT_AVG; }
"SUM"|"sum"				{ yylval.lexeme_val = strdup(yytext); return FUNCT_SUM; }
"MIN"|"min"				{ yylval.lexeme_val = strdup(yytext); return FUNCT_MIN; }
"MAX"|"max"				{ yylval.lexeme_val = strdup(yytext); return FUNCT_MAX; }
"*"		     			{ yylval.lexeme_val = strdup(yytext); return STAR; }
"<>"			        { yylval.lexeme_val = strdup(yytext); return DIFF; }
"="		                { yylval.lexeme_val = strdup(yytext); return EQUALS; }
 ")"    	            { yylval.lexeme_val = strdup(yytext); return RIGHT_PARENTHESIS; }
"("    		            { yylval.lexeme_val = strdup(yytext); return LEFT_PARENTHESIS; }
";"						{ yylval.lexeme_val = strdup(yytext); return SEMI_COLON; }

{WORD}  			    { yylval.lexeme_val = strdup(yytext); return WORD; }

{ATTR}  				{ yylval.lexeme_val = strdup(yytext); return ATTR; }
 
{ATTRS}  				{ yylval.lexeme_val = strdup(yytext); return ATTRS; }

{INSERT_VALUES}			{ yylval.lexeme_val = strdup(yytext); return INSERT_VALUES; }

%%
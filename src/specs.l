%{
	#include "grammar.tab.h"
%}

int "int"
date "date"
string "string"
digit [0-9]
word ([a-zA-Z_])+
attr {word}[ ]({int}|{string}|{date})
attrs ({attr}[,])+{attr}

%%

"WHERE"|"where"			{ return COM_WHERE; }
"SELECT"|"select"		{ return COM_SELECT; }
"CREATE"|"create"		{ return COM_CREATE; }
"TABLE"|"table"			{ return COM_TABLE; }
"INSERT"|"insert"		{ return COM_INSERT; }
"INTO"|"into"			{ return COM_INTO; }
"VALUES"|"values"		{ return COM_VALUES; }
"FROM"|"from"			{ return COM_FROM; }
"ALTER"|"alter"			{ return COM_ALTER; }
"DELETE"|"delete"		{ return COM_DELETE; }
"DESC"|"desc"			{ return COM_DESC; }
"UPDATE"|"update"		{ return COM_UPDATE; }
"SET"|"set"				{ return COM_SET; }
"DROP"|"drop"			{ return COM_DROP; }
"ADD"|"add"				{ return COM_ADD; }
"REMOVE"|"remove"		{ return COM_REMOVE; }
"HELP"|"help"			{ return COM_HELP; }
"EXIT"|"exit"			{ return COM_EXIT; }
"AVG"|"avg"				{ return FUNCT_AVG; }
"SUM"|"sum"				{ return FUNCT_SUM; }
"MIN"|"min"				{ return FUNCT_MIN; }
"MAX"|"max"				{ return FUNCT_MAX; }
"*"		     			{ return STAR; }
"<>"			        { return DIFF; }
"="		                { return EQUALS; }
 ")"    	            { return RIGHT_PARENTHESIS; }
"("    		            { return LEFT_PARENTHESIS; }
";"						{ return SEMI_COLON; }

{word}  			    { yylval.lexeme_val = strdup(yytext); return word; }

{attr}  				{ yylval.lexeme_val = strdup(yytext); return attr; }
 
{attrs}  				{ yylval.lexeme_val = strdup(yytext); return attrs; }

%%
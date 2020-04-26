%{
	#include "grammar.tab.h"
%}

NUMBER "number"
DATE "date"
STRING "string"
WORD ([a-zA-Z_])+
ATTR {WORD}[[:space:]]({NUMBER}|{STRING}|{DATE})
ATTRS {ATTR}(,{ATTR})*
WORD_LIST {WORD}(,{WORD})*

%%

(?i:"where")		{ return COM_WHERE; }
(?i:"select")		{ return COM_SELECT; }
(?i:"create")		{ return COM_CREATE; }
(?i:"table")		{ return COM_TABLE; }
(?i:"insert")		{ return COM_INSERT; }
(?i:"into")			{ return COM_INTO; }
(?i:"values")		{ return COM_VALUES; }
(?i:"from")			{ return COM_FROM; }
(?i:"alter")		{ return COM_ALTER; }
(?i:"delete")		{ return COM_DELETE; }
(?i:"desc")			{ return COM_DESC; }
(?i:"update")		{ return COM_UPDATE; }
(?i:"set")			{ return COM_SET; }
(?i:"drop")			{ return COM_DROP; }
(?i:"add")			{ return COM_ADD; }
(?i:"remove")		{ return COM_REMOVE; }
(?i:"help")			{ return COM_HELP; }
(?i:"exit")			{ return COM_EXIT; }
(?i:"avg")			{ return FUNCT_AVG; }
(?i:"sum")			{ return FUNCT_SUM; }
(?i:"min")			{ return FUNCT_MIN; }
(?i:"max")			{ return FUNCT_MAX; }
"*"		     		{ return STAR; }
"<>"			    { return DIFF; }
"="		            { return EQUALS; }
 ")"    	        { return RIGHT_PARENTHESIS; }
"("    		        { return LEFT_PARENTHESIS; }
";"					{ return SEMI_COLON; }
{WORD}  			{ return WORD; }
{ATTRS}  			{ return ATTRS; }
{WORD_LIST}			{ return WORD_LIST; }

%%
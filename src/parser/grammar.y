/*
 * grammar.y
 *
 *  Created on: Nov 16, 2018
 *      Author: ezerbo
 */
%{
#include <stdio.h>
#include <string.h>
#include "src/commands/commands.h"

void yyerror(char const *s);
int yylex(void);
%}

%union {
	char* string_value;
};

%token <string_value> WORD ATTRS WORD_LIST
%token <string_value> DIFF EQUALS STAR RIGHT_PARENTHESIS LEFT_PARENTHESIS SEMI_COLON

//TOKENS MATCHING SQL COMMANDS
%token <string_value> COM_WHERE COM_SELECT COM_ALTER COM_CREATE COM_INTO COM_VALUES COM_DELETE COM_INSERT
%token <string_value> COM_FROM COM_TABLE COM_DESC COM_UPDATE COM_SET COM_DROP COM_HELP COM_ADD COM_REMOVE COM_EXIT

//AGGREGATION FUNCTIONS TOKENS
%token FUNCT_AVG FUNCT_SUM FUNCT_MIN FUNCT_MAX

%%

// Production rules of a CQL statement
sql_statement	: create_table_statement
				| insert_into_statement
				| select_statement
				| alter_table_statement
				| delete_statement
				| desc_statement
				| update_statement
				| drop_statement
				| help_statement
				| exit_statement
				| aggregation_statement
				| error {  yyclearin;yyerrok; }
				;

// Production rules of an aggregation statement
aggregation_statement	: average_aggregation
						| summation_aggregation
						| maximum_aggregation
						| minimum_aggregation
						;

 
// Create statements production rules
create_table_statement	: COM_CREATE COM_TABLE WORD LEFT_PARENTHESIS ATTRS RIGHT_PARENTHESIS SEMI_COLON		{ create($3, $5); yyparse(); };

// Insert statements production rules
insert_into_statement	: COM_INSERT COM_INTO WORD COM_VALUES LEFT_PARENTHESIS WORD_LIST RIGHT_PARENTHESIS SEMI_COLON	{ insert($3, NULL, $6); yyparse(); };
						| COM_INSERT COM_INTO WORD COM_VALUES LEFT_PARENTHESIS WORD RIGHT_PARENTHESIS SEMI_COLON	    { insert($3, NULL, $6); yyparse(); };

// Select statments explanation
select_statement		: COM_SELECT WORD COM_FROM WORD	SEMI_COLON	{ printf("select"); yyparse(); }
						| COM_SELECT STAR COM_FROM WORD	SEMI_COLON	{ printf("select star"); yyparse(); };

// Alter statements explanation
alter_table_statement	: COM_ALTER COM_TABLE WORD COM_ADD ATTRS	SEMI_COLON		{ alter($3, $5, ADD); yyparse();} // ADD and DELETE are enums defined in tables/table.h
						| COM_ALTER COM_TABLE WORD COM_REMOVE WORD	SEMI_COLON	{ alter($3, $5, DELETE); yyparse();};

// Delete statements explanation
delete_statement		: COM_DELETE COM_FROM WORD COM_WHERE WORD EQUALS WORD SEMI_COLON	{ printf("delete equals"); yyparse(); }
						| COM_DELETE COM_FROM WORD COM_WHERE WORD DIFF WORD	SEMI_COLON		{ printf("delete different"); yyparse(); };

// Desc statements explanation
desc_statement			: COM_DESC WORD SEMI_COLON	{ desc($2); yyparse(); };


update_statement		: COM_UPDATE WORD COM_SET WORD EQUALS WORD SEMI_COLON								{ printf("update bulk"); yyparse(); }	
						| COM_UPDATE WORD COM_SET WORD EQUALS WORD COM_WHERE WORD EQUALS WORD SEMI_COLON	{ printf("update where"); yyparse(); };

// Drop statments explanation
drop_statement			: COM_DROP COM_TABLE WORD SEMI_COLON	{ drop($3); yyparse(); };

// Help statements explanation
help_statement			: COM_HELP COM_SELECT SEMI_COLON { help($2); yyparse(); }	
						| COM_HELP COM_INSERT SEMI_COLON { help($2); yyparse(); }
						| COM_HELP COM_CREATE SEMI_COLON { help($2); yyparse(); }
						| COM_HELP COM_UPDATE SEMI_COLON { help($2); yyparse(); }
						| COM_HELP COM_DELETE SEMI_COLON { help($2); yyparse(); }
						| COM_HELP COM_DROP SEMI_COLON   { help($2); yyparse(); }
						| COM_HELP COM_DESC SEMI_COLON   { help($2); yyparse(); }
						| COM_HELP COM_ALTER SEMI_COLON  { help($2); yyparse(); };

// Exit statements explanation
exit_statement			: COM_EXIT SEMI_COLON	{ printf("Bye!\n"); exit(0); };


// Average aggregation statements explanation
average_aggregation			: COM_SELECT FUNCT_AVG LEFT_PARENTHESIS WORD RIGHT_PARENTHESIS COM_FROM WORD SEMI_COLON		{ printf("average"); yyparse(); };

// Summation aggregation statements explanation
summation_aggregation		: COM_SELECT FUNCT_SUM LEFT_PARENTHESIS WORD RIGHT_PARENTHESIS COM_FROM WORD SEMI_COLON		{ printf("summation"); yyparse(); };

// Maximum aggregation statements explanation
maximum_aggregation			: COM_SELECT FUNCT_MAX LEFT_PARENTHESIS WORD RIGHT_PARENTHESIS COM_FROM WORD SEMI_COLON		{ printf("maximum"); yyparse(); };

// Minimum aggregation statements explanation
minimum_aggregation			: COM_SELECT FUNCT_MIN LEFT_PARENTHESIS WORD RIGHT_PARENTHESIS COM_FROM WORD SEMI_COLON		{ printf("minimum"); yyparse(); };

%%

/**
*	Handles systax errors
**/
void yyerror(char const *s)
{
	printf("Syntax error, please review query and try again.");
}

int main(int argc, char* argv[]) 
{
	yyparse();
	return(0);
}
//create table tintin(name string,age number, birthday date);
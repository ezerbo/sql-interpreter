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

int yyerror(char const *s);

int yylex(void);
%}

%union {
	char* lexeme_val;
};

%token <lexeme_val> WORD ATTR ATTRS INSERT_VALUES
%token DIFF EQUALS STAR RIGHT_PARENTHESIS LEFT_PARENTHESIS SEMI_COLON

//TOKENS MATCHING SQL COMMANDS
%token COM_WHERE COM_SELECT COM_ALTER COM_CREATE COM_INTO COM_VALUES COM_DELETE COM_INSERT
%token COM_FROM COM_TABLE COM_DESC COM_UPDATE COM_SET COM_DROP COM_HELP COM_ADD COM_REMOVE COM_EXIT

//AGGREGATION FUNCTIONS TOKENS
%token FUNCT_AVG FUNCT_SUM FUNCT_MIN FUNCT_MAX

%%

// Explaination of a SQL statement
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
				| error { yyerrok; yyclearin; }
				;

// Explaination of an aggregation statement
aggregation_statement	: average_aggregation
						| summation_aggregation
						| maximum_aggregation
						| minimum_aggregation
						;

// Create statements explanation
create_table_statement	: COM_CREATE COM_TABLE WORD LEFT_PARENTHESIS ATTRS RIGHT_PARENTHESIS SEMI_COLON		{ create_table($3, $5); yyparse(); };

// Insert statements explanation
insert_into_statement	: COM_INSERT COM_INTO WORD COM_VALUES LEFT_PARENTHESIS INSERT_VALUES RIGHT_PARENTHESIS SEMI_COLON	{ printf("insert"); yyparse(); };

// Select statments explanation
select_statement		: COM_SELECT WORD COM_FROM WORD	SEMI_COLON	{ printf("select"); yyparse(); }
						| COM_SELECT STAR COM_FROM WORD	SEMI_COLON	{ printf("select star"); yyparse(); };

// Alter statements explanation
alter_table_statement	: COM_ALTER COM_TABLE WORD COM_ADD ATTR	SEMI_COLON		{ printf("alter table add"); yyparse();}
						| COM_ALTER COM_TABLE WORD COM_REMOVE WORD	SEMI_COLON	{ printf("alter table remove"); yyparse();};

// Delete statements explanation
delete_statement		: COM_DELETE COM_FROM WORD COM_WHERE WORD EQUALS WORD SEMI_COLON	{ printf("delete equals"); yyparse(); }
						| COM_DELETE COM_FROM WORD COM_WHERE WORD DIFF WORD	SEMI_COLON		{ printf("delete different"); yyparse(); };

// Desc statements explanation
desc_statement			: COM_DESC WORD SEMI_COLON	{ desc($2); yyparse(); };


update_statement		: COM_UPDATE WORD COM_SET WORD EQUALS WORD SEMI_COLON								{ printf("update bulk"); yyparse(); }	
						| COM_UPDATE WORD COM_SET WORD EQUALS WORD COM_WHERE WORD EQUALS WORD SEMI_COLON	{ printf("update where"); yyparse(); };

// Drop statments explanation
drop_statement			: COM_DROP COM_TABLE WORD SEMI_COLON	{ printf("drop"); yyparse(); };

// Help statements explanation
help_statement			: COM_HELP COM_SELECT SEMI_COLON { help("SELECT"); yyparse(); }	
						| COM_HELP COM_INSERT SEMI_COLON { help("INSERT"); yyparse(); }
						| COM_HELP COM_CREATE SEMI_COLON { help("CREATE"); yyparse(); }
						| COM_HELP COM_UPDATE SEMI_COLON { help("UPDATE"); yyparse(); }
						| COM_HELP COM_DELETE SEMI_COLON { help("DELETE"); yyparse(); }
						| COM_HELP COM_DROP SEMI_COLON   { help("DROP");   yyparse(); }
						| COM_HELP COM_DESC SEMI_COLON   { help("DESC");   yyparse(); }
						| COM_HELP COM_ALTER SEMI_COLON  { help("ALTER");  yyparse(); };

// Exit statements explanation
exit_statement			: COM_EXIT SEMI_COLON	{ exit(0); };


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
int yyerror(char const *s) {
	fprintf(stderr, "Syntax error, please review query and try again.");
	yyparse();
	return (0);
}
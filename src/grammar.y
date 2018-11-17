/*
 * grammar.y
 *
 *  Created on: Nov 16, 2018
 *      Author: ezerbo
 */
%{
#include <stdio.h>
#include <string.h>
#include "table/table.h"
void test();

int yyerror(char const *s);

int yylex(void);
%}

%union {
	char* lexeme_val;
};

%token <lexeme_val> word attr attrs
%token DIFF EQUALS STAR RIGHT_PARENTHESIS LEFT_PARENTHESIS SEMI_COLON

//TOKENS MATCHING SQL COMMANDS
%token COM_WHERE COM_SELECT COM_ALTER COM_CREATE COM_INTO COM_VALUES COM_DELETE COM_INSERT
%token COM_FROM COM_TABLE COM_DESC COM_UPDATE COM_SET COM_DROP COM_HELP COM_ADD COM_REMOVE COM_EXIT

//AGGREGATION FUNCTIONS TOKENS
%token FUNCT_AVG FUNCT_SUM FUNCT_MIN FUNCT_MAX

%%

//operation_sql est l'axiome de la grammaire
operation_sql		: op_create | error {yyerrok;yyclearin;};


op_create : COM_CREATE COM_TABLE word LEFT_PARENTHESIS attrs RIGHT_PARENTHESIS SEMI_COLON  { create_table($3, $5); yyparse(); };

%%
int yyerror(char const *s) {
	fprintf(stderr, "Syntax error, please review query and try again.");
	yyparse();
	return (0);
}

void test(char* name, char* attributes_str) {
	printf("TABLE NAME: %s, ATTRIBUTES_STR %s", name, attributes_str);
}
/*
 * table.h
 *
 *  Created on: Nov 14, 2018
 *      Author: ezerbo
 */

#ifndef TABLE_TABLE_H_
#define TABLE_TABLE_H_

#define MAX_ATTR_LEN 50 // Maximum length for a table attribute.

#define NAME_ATTR "name" // Name attribute

#define TYPE_ATTR "type" // Name attribute

#define STRCT_NODE_NAME "struct" // 'struct' node in table file

#define TBL_NODE_NAME "table" // 'table' node in metadata file

#define MDT_NODE_NAME "metadata"

#define EXT ".xml"

#include "../commons/commons.h"


/**
 * Table attributes definition
 * ex: in 'create table test_table(testName int)', `testName` is the 'name' of the attribute and `int` is its 'type'.
 */

typedef struct table_attribute {
	char* name; // Name of the attribute
    char* type; // Type of the attribute
    struct table_attribute* next;
} table_attribute;


/**
 * Function: create_table
 * ----------------------
 * Creates a new table in the database
 *
 * 	table_name: Name of table to create
 * 	sql_query: SQL query to be used to create a new table
 *
 **/
void create_table(char* table_name, char* sql_query);


/**
 * Function: count_attributes
 * --------------------------
 * Counts the number of attributes in a 'create table' statement
 *
 * 	sql_query: 'create table' statement to count attributes from
 *
 * 	returns: the number of attributes in 'sql_query'

 **/
int count_attributes(char* sql_query);


/**
 * Function: exists
 * ----------------
 * Checks if a table exists
 *
 * 	table_name: Name of table to check
 *
 * 	returns: 1 if table exists and 0 otherwise
 *
 **/
int exists(char* table_name, xmlNodePtr root);


/**
 * Function: register_table
 * ------------------------
 * Registers a new table in tables metadata file
 *
 * 	table_name: Name of table to register
 * 	attributes_count: Number of attributes in the table
 *
 *
 **/
void register_table(char* table_name, int attributes_count);


/**
 * Function: get_attributes
 * ------------------------
 * Gets the list of attributes for a given table
 *
 * 	table_name: Name of table to return attributes of
 *
 * 	returns: List of attributes
 **/
table_attribute* get_attributes(char* table_name);


/**
 * Function: parse_attributes
 * ------------------------
 * Parses the list of attributes give a table creation statement
 *
 * 	sql_query: SQL query to parse attributes from
 *
 * 	returns: List of attributes
 **/
table_attribute* parse_attributes(char* sql_query);


/**
 * Function: parse_attribute
 * -------------------------
 * Parses an attribute definition
 *
 * 	attr_string: attribute definition
 * 		ex: `name string`, creates an attribute with name `name` and type `string`
 *
 * 	returns: table attribute
 *
 **/
table_attribute* parse_attribute(char* attr_string);


/**
 * Function: create_metadata_file
 * ------------------------------
 * Creates metadata file
 * If file exists, a message is printed to stdout
 *
 **/
void create_metadata_file();


#endif /* TABLE_TABLE_H_ */

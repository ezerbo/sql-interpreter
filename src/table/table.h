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

#define RECORD_NODE_NAME "record"

#define EXT ".xml"

#include "../commons/commons.h"
#include <stdio.h>
#include <string.h>
#include <unistd.h>

/**
 * Table attributes definition
 * ex: in 'create table test_table(testName int)', `testName` is the 'name' of the attribute and `int` is its 'type'.
 */

typedef struct table_attribute {
	char* name; // Name of the attribute
    char* type; // Type of the attribute
    struct table_attribute* next;
} table_attribute;

//Actions allowed when a table is being altered
typedef enum ALTER_ACTION { ADD, DELETE } ALTER_ACTION;

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
int exists(char* table_name);


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


/**
 * Function: get_table_attributes
 * -----------------------------
 * Gets attributes of a table
 */
table_attribute* get_table_attributes(xmlNodePtr root);


/**
 * Function: get_table_structure
 * -----------------------------
 * Gets the structure of a table
 *
 *
 */
xmlNodePtr get_table_structure(xmlNodePtr table);


/**
 * Function: parse_table_structure
 * -------------------------------
 * Parses the structure of a table
 */
void parse_table_structure(xmlNodePtr root, table_attribute** attributes);


/**
 * Function: get_table_file_name
 * -----------------------------
 * Returns name of file holding records of a table
 *
 * 	table_name: Name of table
 *
 * 	returns: File containing records of table `table_name`
 */
char* get_table_file_name(char* table_name);


/**
 * Function: deregister
 * --------------------
 * Remove a table registration metadata file
 *
 * 	table_name: Name of the table
 * 	metadata_root_node: Root node of the metadata file
 *
 * 	returns: 1 when table is successfully deregistered, 0 otherwise
 *
 */
int deregister(char* table_name, xmlNodePtr metadata_root_node);

/**
 * Function: load_table
 * --------------------
 * Loads a table
 *
 * 	table_name: Name of the table to load
 * 
 *  returns: Root node of table file
 */
xmlNodePtr load_table(char *table_name);

/**
 * Function: is_valid_attribute_type
 * ----------------------------------
 * Assesses whether an attribute type is valide
 *
 * 	attribute_type: Type of the attribute
 *
 * 	returns: 1 if attribute type is valid and 0 otherwise
 */
int is_valid_attribute_type(char* attribute_type);


/**
 * Function: attribute_exists
 * --------------------------
 * Assesses whether an attribute exists
 *
 * 	table_name: Name of table in which to look for attribute
 * 	attribute_name: Name of attribute to look for
 *
 * 	returns: 1 if attribute is found and 0 otherwise
 */
int attribute_exists(char *table_name, char *attribute_name);


/**
 * Function: update_records
 * ------------------------
 * Updates records of a table when a new attribute is added
 *
 * 	table_name: Name of table for which records will be updated
 * 	attribute_name: Name of attribute to set for every record
 *  action: update action(add, delete)
 *
 * 	returns: Number of records updated
 */
int update_records(char *table_name, char *attribute_name, ALTER_ACTION action);


/**
 * Function: is_record_updated
 * ---------------------------
 * Assesses whether a record in a table aleady has an attribute
 *
 * 	record_node: Node of the record to check
 * 	attribute_name: Name of the attribute to find
 *
 * 	returns: 1 if record is updated and 0 otherwise
 */
int is_record_updated(xmlNodePtr record_node, char *attribute_name);



#endif /* TABLE_TABLE_H_ */

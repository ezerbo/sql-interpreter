/*
 * commands.h
 *
 *  Created on: Nov 17, 2018
 *      Author: ezerbo
 */

#ifndef COMMANDS_COMMANDS_H_
#define COMMANDS_COMMANDS_H_

#include "../table/table.h"

/**
 * Function: create
 * ----------------
 * Creates a new table
 *
 * 	table_name: Name of the table to create
 *  attributes_str: Attributes list, formatted as: "attr1 type, attr2 type, ..., attrN type"
 */
void create(char *table_name, char *attributes_str);


/**
 * Function: insert
 * ----------------
 * Inserts a record into a table
 *
 * 	table_name: Name of the table to insert record into
 *  attributes_list: list of table's attibutes, formatted as: "attr1, attr2, ..., attrN"
 *  values: Value of attributes listed in `attributes_list`
 */
void insert(char *table_name, char* attributes_list, char *values);


/**
 * Function: alter
 * ---------------
 * Alters the structure of a table
 * 
 *  table_name: Name of table to alter
 *  action: Alter action(ADD, DELETE)
 *  attribute: Attribute to add or remove
 */
void alter(char *table_name, char *attribute, ALTER_ACTION action);


/**
 * Function: desc
 * --------------
 * Describes a table
 *
 * 	table_name: Name of the table to describe
 */
void desc(char *table_name);


/**
 * Function: drop
 * --------------
 * Drops a table
 *
 * 	table_name: Name of the table
 */
void drop(char *table_name);


/**
 * Function: help
 * --------------
 * Displays help about a command
 *
 * 	command_name: Name of the command
 *
 */
void help(char *command_name);

#endif /* COMMANDS_COMMANDS_H_ */

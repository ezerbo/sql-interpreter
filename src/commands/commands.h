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
 * Function: load_table
 * --------------------
 * Loads a table
 *
 * 	table_name: Name of the table to load
 */
void load_table(char* table_name);

/**
 * Function: desc
 * --------------
 * Describes a table
 *
 * 	table_name: Name of the table to describe
 */
void desc(char* table_name);


/**
 * Function: help
 * --------------
 * Displays help about a command
 *
 * 	command_name: Name of the command
 *
 */
void help(char* command_name);

/**
 * Function: drop
 * --------------
 * Drops a table
 *
 * 	table_name: Name of the table
 */
void drop(char* table_name);

#endif /* COMMANDS_COMMANDS_H_ */

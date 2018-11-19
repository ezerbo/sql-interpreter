/*
 * commands.c
 *
 *  Created on: Nov 17, 2018
 *      Author: ezerbo
 */


#include "commands.h"

void desc(char* table_name) {
	xmlNodePtr metadata = load_metadata();
	if(exists(table_name, metadata)) {
		char* table_name_temp = (char*) malloc((strlen(table_name) + 4) * sizeof(char));
		strcpy(table_name_temp, table_name);
		xmlDocPtr table = xmlParseFile(strcat(table_name_temp, EXT));
		xmlNodePtr root_node = xmlDocGetRootElement(table);
		table_attribute* attributes = get_table_structure(root_node);
		printf("\n{\n");
		while(attributes != NULL) {
			if(attributes -> next != NULL) {
				printf("  \"%s\": \"%s\",\n", attributes -> name, attributes -> type);
			} else {
				printf("  \"%s\": \"%s\"", attributes -> name, attributes -> type);
			}
			attributes = attributes -> next;
		}
		printf("\n}");
		xmlFreeDoc(table);
		free(table_name_temp);
	} else {
		printf("Table %s was not found", table_name);
	}
	xmlFreeDoc(metadata -> doc);
}

void drop(char* table_name) {
	char* table_file_name = get_table_file_name(table_name);
	xmlNodePtr metadata = load_metadata();
	if(exists(table_name, metadata)) {

	} else {
		printf("No such table %s", table_name);
	}

	free(table_file_name);
	xmlFreeDoc(metadata -> doc);
}

void help(char* command_name) { //TODO Add help for functions
	if (!strcasecmp(command_name, "SELECT")) {
		printf("\n Select attributes of tables\n\n"
			   " Syntax: \n\n"
			   " Select a single attribute : SELECT attribute_name FROM table_name;\n\n"
			   " Select all attributes : SELECT * FROM table_name;\n\n");
	} else if (!strcasecmp(command_name, "INSERT")){
		printf("\n Insert records in tables\n\n"
			   " Syntax: \n\n"
			   " INSERT INTO table_name VALUES(val1, val2, ..., valN);\n\n");
	} else if (!strcasecmp(command_name, "UPDATE")) {
		printf("\n Update records in a table\n\n"
			   " Syntax: \n\n"
			   " UPDATE table_name SET attribute_name = value [WHERE attribute_name = another_value];\n\n"
			   " Will update all records without the `WHERE` clause\n\n");
	} else if (!strcasecmp(command_name, "CREATE")) {
		printf("\n Create a new table : \n\n"
			   " Syntax: \n\n"
			   " CREATE TABLE table_name(val1 type, val2 type, ..., valN type);\n\n"
			   " Available types: int, text and date\n\n");
	} else if (!strcasecmp(command_name, "DELETE")) {
		printf("\n Delete a records from tables\n\n"
			   " Syntax: \n\n"
			   " DELETE FROM table_name WHERE attribute_name =|<> value;\n\n");
	} else if (!strcasecmp(command_name, "DROP")) {
		printf("\n Drop tables\n\n"
			   " Syntax:\n\n"
			   " DROP TABLE table_name;\n\n");
	} else if (!strcasecmp(command_name, "DESC")) {
		printf("\n Describe tables\n\n"
			   " Syntax: \n\n"
			   " DESC table_name;\n\n");
	} else if (!strcasecmp(command_name, "ALTER")) {
		printf("\n Alter table structures\n\n"
				" Syntax: \n\n"
				" Add an attribute: ALTER TABLE table_name ADD attribute_name type;\n\n"
				" Delete an attribute: ALTER TABLE table_name REMOVE attribute_name;\n\n");
	} else {
		printf("No such command `%s`", command_name);
	}
}

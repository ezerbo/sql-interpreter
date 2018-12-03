/*
 * commands.c
 *
 *  Created on: Nov 17, 2018
 *      Author: ezerbo
 */

#include "commands.h"

void create(char *table_name, char *attributes_str)
{
	create_table(table_name, attributes_str); //Remove duplicates from table attributes definition
}

void alter(char *table_name, char *attribute, ALTER_ACTION action)
{
	if (!exists(table_name))
	{
		printf("No such table `%s`", table_name);
		return;
	}

	table_attribute *attr = parse_attribute(attribute);
	xmlNodePtr table = load_table(table_name);
	char *file_name = get_table_file_name(table_name);
	xmlNodePtr structure = get_table_structure(table);

	if (action == ADD)
	{
		if (attribute_exists(table_name, attr->name))
		{
			printf("Attribute `%s` already exists\n", attr->name);
			return;
		}

		if (!is_valid_attribute_type(attr->type))
		{
			printf("Invalid attribute type `%s`\n", attr->type);
			return;
		}

		xmlNodePtr new_node = xmlNewNode(NULL, BAD_CAST attr->name);
		xmlSetProp(new_node, BAD_CAST TYPE_ATTR, BAD_CAST attr->type);
		xmlAddChild(structure, new_node);
		xmlSaveFile(file_name, table->doc);
	}
	else
	{
		xmlNodePtr cur_node = structure->children;
		while (cur_node)
		{
			if (!xmlStrcasecmp(cur_node->name, attr->name))
			{
				xmlUnlinkNode(cur_node);
				xmlFreeNode(cur_node);
				xmlSaveFile(file_name, table->doc);
			}
			cur_node = cur_node->next;
		}
	}

	int updated_records = update_records(table_name, attr->name, action); //Update to Enums

	printf("Table `%s` successfully altered. %d records updated.\n", table_name, updated_records);
	xmlCleanupParser();
}

int insert(char *table_name, char* attributes_list, char *values)
{
	
}



void desc(char *table_name)
{
	if (!exists(table_name))
	{
		printf("Table %s was not found", table_name);
		return;
	}

	char *file_name = get_table_file_name(table_name);
	xmlDocPtr table = xmlParseFile(file_name);
	xmlNodePtr root_node = xmlDocGetRootElement(table);
	table_attribute *attributes = get_table_attributes(root_node);
	printf("\n{\n");
	while (attributes != NULL)
	{
		if (attributes->next != NULL)
		{
			printf("  \"%s\": \"%s\",\n", attributes->name, attributes->type);
		}
		else
		{
			printf("  \"%s\": \"%s\"", attributes->name, attributes->type);
		}
		attributes = attributes->next;
	}

	printf("\n}");
	free(file_name);
	xmlFreeDoc(table);
	xmlCleanupParser();
}

void drop(char *table_name)
{
	char *table_file_name = get_table_file_name(table_name);
	xmlNodePtr metadata = load_metadata();
	if (!exists(table_name))
	{
		printf("No such table `%s`", table_name);
		return;
	}

	if (!(remove(table_file_name) || deregister(table_name, metadata)))
	{
		printf("Table '%s' successfully deleted.", table_name);
	}
	free(table_file_name);
	xmlFreeDoc(metadata->doc);
	xmlCleanupParser();
}

void help(char *command_name)
{ //TODO Add help for functions
	if (!strcasecmp(command_name, "SELECT"))
	{
		printf("\n Select attributes of tables\n\n"
			   " Syntax: \n\n"
			   " Select a single attribute : SELECT attribute_name FROM table_name;\n\n"
			   " Select all attributes : SELECT * FROM table_name;\n\n");
	}
	else if (!strcasecmp(command_name, "INSERT"))
	{
		printf("\n Insert records in tables\n\n"
			   " Syntax: \n\n"
			   " INSERT INTO table_name VALUES(val1, val2, ..., valN);\n\n");
	}
	else if (!strcasecmp(command_name, "UPDATE"))
	{
		printf("\n Update records in a table\n\n"
			   " Syntax: \n\n"
			   " UPDATE table_name SET attribute_name = value [WHERE attribute_name = another_value];\n\n"
			   " Will update all records without the `WHERE` clause\n\n");
	}
	else if (!strcasecmp(command_name, "CREATE"))
	{
		printf("\n Create a new table : \n\n"
			   " Syntax: \n\n"
			   " CREATE TABLE table_name(val1 type, val2 type, ..., valN type);\n\n"
			   " Available types: int, text and date\n\n");
	}
	else if (!strcasecmp(command_name, "DELETE"))
	{
		printf("\n Delete a records from tables\n\n"
			   " Syntax: \n\n"
			   " DELETE FROM table_name WHERE attribute_name =|<> value;\n\n");
	}
	else if (!strcasecmp(command_name, "DROP"))
	{
		printf("\n Drop tables\n\n"
			   " Syntax:\n\n"
			   " DROP TABLE table_name;\n\n");
	}
	else if (!strcasecmp(command_name, "DESC"))
	{
		printf("\n Describe tables\n\n"
			   " Syntax: \n\n"
			   " DESC table_name;\n\n");
	}
	else if (!strcasecmp(command_name, "ALTER"))
	{
		printf("\n Alter table structures\n\n"
			   " Syntax: \n\n"
			   " Add an attribute: ALTER TABLE table_name ADD attribute_name type;\n\n"
			   " Delete an attribute: ALTER TABLE table_name REMOVE attribute_name;\n\n");
	}
	else
	{
		printf("No such command `%s`", command_name);
	}
}

/*
 * table.c
 *
 *  Created on: Nov 15, 2018
 *      Author: ezerbo
 */

#include "table.h"

void create_table(char *table_name, char *attributes_str)
{
	create_metadata_file(); // skips if metadata file exists
	int attributes_count = count(attributes_str);
	if (exists(table_name))
	{
		fprintf(stderr, "Table with name '%s' already exists", table_name);
		exit(0);
	}

	char *file_name = get_table_file_name(table_name); // +4 because .xml will be appended to it.
	xmlDocPtr table_doc = xmlNewDoc(BAD_CAST "1.0");
	xmlNodePtr root_node = xmlNewNode(NULL, BAD_CAST TBL_NODE_NAME);
	xmlDocSetRootElement(table_doc, root_node);

	xmlSetProp(root_node, BAD_CAST NAME_ATTR, BAD_CAST table_name);		 //Set 'name' property of table
	xmlNodePtr struct_node = xmlNewNode(NULL, BAD_CAST STRCT_NODE_NAME); //create <struct> node in table file
	table_attribute *attributes = parse_attributes(attributes_str);
	while (attributes != NULL)
	{
		xmlNodePtr attr_node = xmlNewNode(NULL, BAD_CAST attributes->name);   // Set node name
		xmlSetProp(attr_node, BAD_CAST TYPE_ATTR, BAD_CAST attributes->type); //Set 'type' attribut of new node
		xmlAddChild(struct_node, attr_node);								  // Add new node as child of '<struct></struct>' node
		attributes = attributes->next;
	}

	xmlAddChild(root_node, struct_node); // Add '<struct></struct>' as a child of '<table></table>'
	xmlSaveFormatFileEnc(file_name, table_doc, "UTF-8", 1);
	register_table(table_name, attributes_count); // Register table in tables metadat file
	free(attributes);
	free(file_name);
	xmlFreeDoc(table_doc);
	printf("Table '%s' successfully created", table_name);
	xmlCleanupParser(); // Free all resources allocated by parser.
}

int exists(char *table_name)
{
	xmlNodePtr metadata = load_metadata();
	for (xmlNodePtr cur_node = metadata->children; cur_node; cur_node = cur_node->next)
	{
		if (cur_node->type == XML_ELEMENT_NODE && !xmlStrcmp(cur_node->name, BAD_CAST TBL_NODE_NAME) && !xmlStrcmp(xmlGetProp(cur_node, BAD_CAST NAME_ATTR), BAD_CAST table_name))
		{
			xmlFreeDoc(metadata->doc);
			return (1);
		}
	}
	xmlFreeDoc(metadata->doc);
	return (0);
}

table_attribute *parse_attributes(char *attributes_string)
{
	table_attribute *attributes = NULL;
	char *token = strsep(&attributes_string, ",");
	while (token != NULL)
	{
		table_attribute *attribute = parse_attribute(token);
		if (attributes == NULL)
		{ // Allocate first element of the list if empty
			attributes = attribute;
		}
		else
		{
			attribute->next = attributes;
			attributes = attribute;
		}
		token = strsep(&attributes_string, ",");
	}
	return attributes;
}

table_attribute *parse_attribute(char *attr_string)
{
	table_attribute *attr = (table_attribute *)malloc(sizeof(table_attribute));
	attr->name = strsep(&attr_string, " ");
	attr->type = strsep(&attr_string, " ");
	attr->next = NULL;
	return attr;
}

int count(char *cs_str)
{
	if (strlen(cs_str) == 0)
	{
		return 0;
	}

	int count = 1;
	for (int i = 0; i < strlen(cs_str); i++)
	{
		if (cs_str[i] == ',')
			count++;
	}
	return count;
}

void register_table(char *table_name, int attributes_count)
{
	char count[3];
	snprintf(count, 3, "%d", attributes_count);
	xmlNodePtr metadata = load_metadata();
	xmlNodePtr table = xmlNewNode(NULL, BAD_CAST TBL_NODE_NAME);
	xmlSetProp(table, BAD_CAST NAME_ATTR, BAD_CAST table_name);
	xmlSetProp(table, BAD_CAST "records_count", BAD_CAST "0"); // 0 record when table is created
	xmlSetProp(table, BAD_CAST "attributes_count", BAD_CAST count);
	xmlAddChild(metadata, table);
	xmlSaveFile(METADATA_FILE_NAME, metadata->doc);
	xmlFreeDoc(metadata->doc);
}

void create_metadata_file()
{
	if (access(METADATA_FILE_NAME, F_OK) == -1)
	{
		xmlDocPtr metadata_doc = xmlNewDoc(BAD_CAST "1.0");
		xmlNodePtr root_node = xmlNewNode(NULL, BAD_CAST MDT_NODE_NAME);
		xmlDocSetRootElement(metadata_doc, root_node);
		xmlSaveFormatFileEnc(METADATA_FILE_NAME, metadata_doc, "UTF-8", 1);
		xmlFreeDoc(metadata_doc);
		xmlCleanupParser();
	}
}

table_attribute *get_table_attributes(xmlNodePtr root)
{
	table_attribute *attributes = NULL;
	for (xmlNodePtr cur_node = root; cur_node; cur_node = cur_node->next)
	{
		if (cur_node->type == XML_ELEMENT_NODE && !xmlStrcmp(cur_node->name, BAD_CAST STRCT_NODE_NAME))
		{
			parse_table_structure(cur_node->children, &attributes); //Populate the attributes list
			return attributes;
		}
		attributes = get_table_attributes(cur_node->children);
	}
	return attributes;
}

void parse_table_structure(xmlNodePtr root, table_attribute **attributes)
{
	for (xmlNodePtr cur_node = root; cur_node; cur_node = cur_node->next)
	{
		if (cur_node->type == XML_ELEMENT_NODE)
		{
			table_attribute *attribute = (table_attribute *)malloc(sizeof(table_attribute));
			attribute->name = strdup((char *)cur_node->name);
			attribute->type = strdup((char *)xmlGetProp(cur_node, BAD_CAST TYPE_ATTR));
			attribute->next = *attributes;
			*attributes = attribute;
		}
		parse_table_structure(cur_node->children, attributes);
	}
}

char *get_table_file_name(char *table_name)
{
	char *table_file_name = (char *)malloc((strlen(table_name) + 4) * sizeof(char));
	strcpy(table_file_name, table_name);
	strcat(table_file_name, EXT);
	return table_file_name;
}

int deregister(char *table_name, xmlNodePtr root)
{
	int status = 1;
	for (xmlNodePtr cur_node = root; cur_node; cur_node = cur_node->next)
	{
		if (cur_node->type == XML_ELEMENT_NODE && !xmlStrcmp(xmlGetProp(cur_node, BAD_CAST NAME_ATTR), BAD_CAST table_name))
		{
			xmlUnlinkNode(cur_node);
			xmlSaveFile(METADATA_FILE_NAME, cur_node->doc);
			return (0);
		}
		status = deregister(table_name, cur_node->children);
	}
	return status;
}

xmlNodePtr load_table(char *table_name)
{
	if (!exists(table_name))
	{
		printf("No such table `%s`", table_name);
		exit(0);
	}

	char *file_name = get_table_file_name(table_name);
	xmlDocPtr table_file = xmlParseFile(file_name);
	if (table_file == NULL)
	{
		fprintf(stderr, "Unable to get tables metadata, exiting...");
		exit(1);
	}
	free(file_name);
	return xmlDocGetRootElement(table_file);
}

xmlNodePtr get_table_structure(xmlNodePtr table)
{
	xmlNodePtr structure = NULL;
	for (xmlNodePtr cur_node = table->children; cur_node; cur_node = cur_node->next)
	{
		if (cur_node->type == XML_ELEMENT_NODE && !xmlStrcmp(cur_node->name, BAD_CAST STRCT_NODE_NAME))
		{
			structure = cur_node;
			break;
		}
	}
	return structure;
}

int is_valid_attribute_type(char *attribute_type)
{
	if (!(strcasecmp(attribute_type, str(STRING)) && strcasecmp(attribute_type, str(NUMBER))
		&& strcasecmp(attribute_type, str(DATE))))
	{
		return (1);
	}
	return (0);
}

int attribute_exists(char *table_name, char *attribute_name)
{
	xmlNodePtr table = load_table(table_name);
	table_attribute *attribute = get_table_attributes(table);
	while (attribute)
	{
		if (!strcasecmp(attribute_name, attribute->name))
		{
			free(attribute);
			xmlFreeDoc(table->doc);
			return (1);
		}
		attribute = attribute->next;
	}
	free(attribute);
	xmlFreeDoc(table->doc);
	return (0);
}

int update_records(char *table_name, char *attribute_name, ALTER_ACTION action)
{
	int updated_records = 0;
	xmlNodePtr table = load_table(table_name);
	char *file_name = get_table_file_name(table_name);
	for (xmlNodePtr child = table->children; child; child = child->next)
	{
		if (child->type == XML_ELEMENT_NODE && xmlStrcmp(child->name, BAD_CAST STRCT_NODE_NAME)) //We'll get the `records` node
		{
			for (xmlNodePtr record = child->children; record; record = record->next)
			{
				if (record->type == XML_ELEMENT_NODE)
				{
					if (action == ADD && !is_record_updated(record, attribute_name))
					{
						xmlNodePtr new_node = xmlNewNode(NULL, BAD_CAST attribute_name);
						xmlSetProp(new_node, BAD_CAST "value", BAD_CAST "null"); // Set new attribute to null for every record
						xmlAddChild(record, new_node);
						xmlSaveFile(file_name, table->doc);
						updated_records++;
					}
					else if (action == DELETE)
					{
						xmlNodePtr cur_record = record->children;
						while (cur_record)
						{
							if (!xmlStrcasecmp(cur_record->name, BAD_CAST attribute_name))
							{
								xmlUnlinkNode(cur_record);
								xmlFreeNode(cur_record);
								xmlSaveFile(file_name, table->doc);
							}
							cur_record = cur_record->next;
						}
					}
				}
			}
		}
	}
	free(file_name);
	xmlFreeDoc(table->doc);
	xmlCleanupParser();
	return updated_records;
}

int is_record_updated(xmlNodePtr record_node, char *attribute_name)
{
	for (xmlNodePtr cur_node = record_node->children; cur_node; cur_node = cur_node->next)
	{
		if (!xmlStrcasecmp(cur_node->name, BAD_CAST attribute_name))
		{
			return (1);
		}
	}
	return (0);
}

int get_attributes_count(char* table_name)
{
	int attributes_count = 0;
	if(!exists(table_name))
	{
		printf("No such table `%s`", table_name);
	}
	xmlNodePtr tables = load_metadata()->children;
	while(tables)
	{
		if(tables->type == XML_ELEMENT_NODE && !xmlStrcasecmp(tables->name, BAD_CAST TBL_NODE_NAME)
				&& !xmlStrcasecmp(xmlGetProp(tables, BAD_CAST NAME_ATTR), BAD_CAST table_name))
		{
			attributes_count = atoi((char *)xmlGetProp(tables, BAD_CAST "attributes_count"));
			break;
		}
		tables = tables->next;
	}
	return attributes_count;
}

int validate_attribute_value(char *attribute_value, char *attribute_type)
{
	if (!strcasecmp(attribute_type, str(NUMBER)) && atoi(attribute_value) == 0 && strcasecmp(attribute_value, "0"))
	{
		return (1);
	}

	if (!strcasecmp(attribute_type, str(DATE)))
	{
		regex_t regex;
		//[12]\\d{3}-0[1-9]|1[0-2]-0[1-9]|[12]\\d|3[01]
		int result = regcomp(&regex, "[1-2][0-9]{3}[-]0[1-9]|1[0-2][-]0[1-9]|[12][0-9]|3[01]", REG_EXTENDED|REG_NOSUB);

		if (result) {
		    fprintf(stderr, "Could not compile regex\n");
		    exit(1);
		}
		result = regexec(&regex, attribute_value, 0, NULL, 0);
		if (!result) {
		    puts("Match");
		}
		else if (result == REG_NOMATCH) {
		    puts("No match");
		}
		else {
		    fprintf(stderr, "Regex match failed:\n");
		    exit(1);
		}

//		if(regexec(regex, attribute_value, 0, NULL, 0))
//		{
//			return (1);
//		}
		regfree(&regex);
	}

	return (0);
}

/*
 * table.c
 *
 *  Created on: Nov 15, 2018
 *      Author: ezerbo
 */

#include "table.h"

void create_table(char* table_name, char* sql_query) {
	create_metadata_file();// skips if metadata file exists
	xmlNodePtr metadata = load_metadata();
	int attributes_count = count_attributes(sql_query);
	if(!exists(table_name, metadata)) {
		char* table_file_name = (char*) malloc((strlen(table_name) + 4) * sizeof(char*)); // +4 because .xml will be appended to it.
		strcpy(table_file_name, table_name);
		strcat(table_file_name, EXT);
		xmlDocPtr table_doc = xmlNewDoc(BAD_CAST "1.0");
		xmlNodePtr root_node = xmlNewNode(NULL, BAD_CAST TBL_NODE_NAME);
	    xmlDocSetRootElement(table_doc, root_node);

		xmlSetProp(root_node, (xmlChar *) NAME_ATTR, (xmlChar *) table_name);//Set 'name' property of table
		xmlNodePtr struct_node = xmlNewNode(NULL, (xmlChar *) STRCT_NODE_NAME);//create <struct> node in table file
		table_attribute* attributes = parse_attributes(sql_query);
		while(attributes != NULL) {
			xmlNodePtr attr_node = xmlNewNode(NULL, BAD_CAST attributes -> name);// Set node name
			xmlSetProp(attr_node, (xmlChar*) TYPE_ATTR, (xmlChar*) attributes -> type);//Set 'type' attribut of new node
			xmlAddChild(struct_node, attr_node);// Add new node as child of '<struct></struct>' node
			attributes = attributes -> next;
		}

		xmlAddChild(root_node, struct_node); // Add '<struct></struct>' as a child of '<table></table>'
		xmlSaveFormatFileEnc(table_file_name, table_doc, "UTF-8", 1);
		register_table(table_name, attributes_count);// Register table in tables metadat file
		free(attributes);
		free(table_file_name);
	    xmlFreeDoc(table_doc);
	    printf("Table '%s' successfully created", table_name);
	} else {
		fprintf(stderr, "Table with name '%s' already exists", table_name);
	}
	xmlFreeDoc(metadata -> doc);
	xmlCleanupParser();// Free all resources allocated by parser.
}

int exists(char* table_name, xmlNodePtr node) {
	xmlNode *cur_node = NULL;
	int exist = 0;
	for (cur_node = node; cur_node; cur_node = cur_node -> next) {
		if (cur_node -> type == XML_ELEMENT_NODE && !xmlStrcmp(cur_node -> name, (xmlChar*) TBL_NODE_NAME)
				&& !xmlStrcmp(xmlGetProp(cur_node, (xmlChar*) NAME_ATTR ), (xmlChar*) table_name)) {
			return 1;
		}
		exist = exists(table_name, cur_node -> children);
	}
	return exist;
}


table_attribute* parse_attributes(char* attributes_string) {
	table_attribute* attributes = NULL;
	char* token = strsep(&attributes_string, ",");
	while(token != NULL) {
		table_attribute* attribute = parse_attribute(token);
		if(attributes == NULL) { // Allocate first element of the list if empty
			attributes = attribute;
		} else {
			attribute -> next = attributes;
			attributes = attribute;
		}
		token = strsep(&attributes_string, ",");
	}
	return  attributes;
}


table_attribute* parse_attribute(char* attr_string) {
	table_attribute* attr = (table_attribute*) malloc(sizeof(table_attribute));
	attr -> name = strsep(&attr_string, " ");
	attr -> type = strsep(&attr_string, " ");
	attr -> next = NULL;
	return attr;
}


int count_attributes(char* sql_query) {
	//if(sql_query == NULL || strcmp(sql_query, '\0') == 0) return 0;
	int count = 1;
	for(int i = 0; i < strlen(sql_query); i++) {
		if(sql_query[i] == ',') count++;
	}
	return  count;
}


void register_table(char* table_name, int attributes_count) {
	char ac_char[3];
	snprintf(ac_char, 3, "%d", attributes_count);
	xmlNodePtr metadata = load_metadata();
	xmlNodePtr table = xmlNewNode(NULL, (xmlChar*) TBL_NODE_NAME);
	xmlSetProp(table, BAD_CAST NAME_ATTR, BAD_CAST table_name);
	xmlSetProp(table, BAD_CAST "records_count", BAD_CAST "0");// 0 record when table is created
	xmlSetProp(table, BAD_CAST "attributes_count", BAD_CAST ac_char);
	xmlAddChild(metadata, table);
	xmlSaveFile(METADATA_FILE_NAME, metadata -> doc);
	xmlFreeDoc(metadata -> doc);
}

void create_metadata_file() {
	if(access(METADATA_FILE_NAME, F_OK) == -1) {
		xmlDocPtr metadata_doc = xmlNewDoc(BAD_CAST "1.0");
		xmlNodePtr root_node = xmlNewNode(NULL, BAD_CAST MDT_NODE_NAME);
		xmlDocSetRootElement(metadata_doc, root_node);
		xmlSaveFormatFileEnc(METADATA_FILE_NAME, metadata_doc, "UTF-8", 1);
		xmlFreeDoc(metadata_doc);
		xmlCleanupParser();
	}
}

table_attribute* get_table_structure(xmlNodePtr root) {
	table_attribute* attributes = NULL;
	for (xmlNodePtr cur_node = root; cur_node; cur_node = cur_node -> next) {
		if (cur_node -> type == XML_ELEMENT_NODE && !xmlStrcmp(cur_node -> name, BAD_CAST STRCT_NODE_NAME)) {
			parse_table_structure(cur_node -> children, &attributes); //Populate the attributes list
			break;
		}
		attributes = get_table_structure(cur_node -> children);
	}
	return attributes;
}

void parse_table_structure(xmlNodePtr root, table_attribute** attributes) {
	for (xmlNodePtr cur_node = root; cur_node; cur_node = cur_node -> next) {
		if (cur_node -> type == XML_ELEMENT_NODE) {
			table_attribute* attribute = (table_attribute*) malloc(sizeof(table_attribute));
			attribute -> name = strdup((char*) cur_node -> name);
			attribute -> type = strdup((char*) xmlGetProp(cur_node, BAD_CAST "type"));
			attribute -> next = *attributes;
			*attributes = attribute;
		}
		parse_table_structure(cur_node -> children, attributes);
	}
}

char* get_table_file_name(char* table_name) {
	char* table_file_name = (char*) malloc((strlen(table_name) + 4) * sizeof(char));
	strcpy(table_file_name, table_name);
	strcat(table_file_name, EXT);
	return table_file_name;
}

void deregister(char* table_name, xmlNodePtr root) {
	for (xmlNodePtr cur_node = root; cur_node; cur_node = cur_node -> next) {
		if (cur_node -> type == XML_ELEMENT_NODE && !xmlStrcmp(xmlGetProp(cur_node,BAD_CAST "name"), table_name)) {
			xmlUnlinkNode(cur_node);
			xmlSaveFile(METADATA_FILE_NAME, cur_node -> doc);
			break;
		}
		deregister(table_name, cur_node -> children);
	}
}


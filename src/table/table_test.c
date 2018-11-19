/*
 * test.c
 *
 *  Created on: Nov 15, 2018
 *      Author: ezerbo
 */


#include <stdio.h>
#include <string.h>
#include "table.h"

void test_count_attributes();
void test_parse_attribute();
void test_parse_attributes();
void test_create_metadata_file();
void test_register_table();
void test_exists();
void test_create_table();
void test_get_table_structure();
void test_desc();

int main(int argc, char **argv) {
    //test_parse_attributes();
	//test_count_attributes();
	//test_parse_attribute();
	//test_create_metadata_file();
	//test_register_table();
	//test_exists();
	//test_create_table();
	//test_get_table_structure();
	test_desc();
}

void test_desc() {
	desc(strdup("user"));
}

void test_get_table_structure() {
	xmlDocPtr metadata_file = xmlParseFile("test-files/user.xml");
	xmlNodePtr root = xmlDocGetRootElement(metadata_file);
	table_attribute* attribute = get_table_structure(root);
	while(attribute != NULL) {
		printf("Name: %s, Type %s \n", attribute -> name, attribute -> type);
		attribute = attribute -> next;
	}
	xmlFreeDoc(metadata_file);
}

void test_count_attributes() {
	printf("---------------------\n");
	int count = count_attributes(strdup("name string,age integer,another test"));
	printf("Count: %d\n", count);
}

void test_parse_attribute() {
	printf("---------------------\n");
	table_attribute* attribute = parse_attribute(strdup("name string"));
	printf("Name: %s ", attribute -> name);
	printf("Type: %s ", attribute -> type);
}

void test_parse_attributes() {
	printf("---------------------\n");
	table_attribute* attributes = parse_attributes(strdup("name string,age integer"));
	while(attributes != NULL) {
		printf("Name: %s\n", attributes -> name);
		printf("Type: %s\n", attributes -> type);
		attributes = attributes -> next;
	}
}

void test_create_metadata_file() {
	create_metadata_file();
}

void test_register_table() {
	register_table("person", 10);
}

void test_exists() {
	xmlDocPtr metadata_file = xmlParseFile(METADATA_FILE_NAME);
	xmlNodePtr metadata_root = xmlDocGetRootElement(metadata_file);
	int exist = exists("school", metadata_root);
	printf("Exists: %d", exist);
}

void test_create_table() {
	create_table(strdup("user"), strdup("name string,age integer"));
}

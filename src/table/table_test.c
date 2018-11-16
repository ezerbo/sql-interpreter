/*
 * test.c
 *
 *  Created on: Nov 15, 2018
 *      Author: ezerbo
 */


#include <stdio.h>
#include "table.h"

void test_count_attributes();
void test_parse_attribute();
void test_parse_attributes();
void test_create_metadata_file();
void test_register_table();
void test_exists();
void test_create_table();

int main(int argc, char **argv) {
    //test_parse_attributes();
	//test_count_attributes();
	//test_parse_attribute();
	test_create_metadata_file();
	//test_register_table();
	//test_exists();
	//test_create_table();
}

void test_count_attributes() {
	printf("---------------------\n");
	int count = count_attributes("name string,age integer,another test");
	printf("Count: %d\n", count);
}

void test_parse_attribute() {
	printf("---------------------\n");
	char attr[] = "name string";
	table_attribute* attribute = parse_attribute(attr);
	printf("Name: %s ", attribute -> name);
	printf("Type: %s ", attribute -> type);
	printf("attr: %s", attr);
}

void test_parse_attributes() {
	printf("---------------------\n");
	char attrs[] = "name string,age integer";
	table_attribute* attributes = parse_attributes(attrs);

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
	char table_name[] = "user";
	char sql_query[] = "name string,age integer";
	create_table(table_name, sql_query);
}

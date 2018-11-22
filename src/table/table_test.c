/*
 * test.c
 *
 *  Created on: Nov 15, 2018
 *      Author: ezerbo
 */

#include <stdio.h>
#include <string.h>
#include "../commands/commands.h"

void test_count_attributes();
void test_parse_attribute();
void test_parse_attributes();
void test_create_metadata_file();
void test_register_table();
void test_exists();
void test_create_table();
void test_get_table_structure();
void test_desc();
void test_deregister();
void test_drop();
void test_alter();
void test_attribute_exists();
void test_is_attribute_valide();
void test_update_record();

int main(int argc, char **argv)
{
	//test_parse_attributes();
	//test_count_attributes();
	//test_parse_attribute();
	//test_create_metadata_file();
	//test_register_table();
	//test_exists();
	//test_create_table();
	//test_get_table_structure();
	//test_desc();
	//test_deregister();
	//test_drop();
	test_alter();
	//test_attribute_exists();
	//test_is_attribute_valide();
	//test_update_record();
}

void test_update_record() {
	int updated_records = update_records(strdup("person"), strdup("test"));
	printf("Records: %d", updated_records);
}

void test_is_attribute_valide() {
	int status = is_valid_attribute_type("int");
	printf("Status: %d", status);
}

void test_attribute_exists() {
	int status = attribute_exists(strdup("person"), strdup("job"));
	printf("Status: %d", status);
}

void test_alter()
{
	alter(strdup("person"), strdup("test1 string"), strdup("add"));
}

void test_desc()
{
	desc(strdup("user"));
}

void test_drop()
{
	drop(strdup("user"));
}

void test_get_table_structure()
{
	xmlDocPtr metadata_file = xmlParseFile("test-files/user.xml");
	xmlNodePtr root = xmlDocGetRootElement(metadata_file);
	table_attribute *attribute = get_table_attributes(root);
	while (attribute != NULL)
	{
		printf("Name: %s, Type %s \n", attribute->name, attribute->type);
		attribute = attribute->next;
	}
	xmlFreeDoc(metadata_file);
}

void test_count_attributes()
{
	printf("---------------------\n");
	int count = count_attributes(strdup("name string,age integer,another test"));
	printf("Count: %d\n", count);
}

void test_parse_attribute()
{
	printf("---------------------\n");
	table_attribute *attribute = parse_attribute(strdup("name string"));
	printf("Name: %s ", attribute->name);
	printf("Type: %s ", attribute->type);
}

void test_parse_attributes()
{
	printf("---------------------\n");
	table_attribute *attributes = parse_attributes(strdup("name string,age integer"));
	while (attributes != NULL)
	{
		printf("Name: %s\n", attributes->name);
		printf("Type: %s\n", attributes->type);
		attributes = attributes->next;
	}
}

void test_create_metadata_file()
{
	create_metadata_file();
}

void test_register_table()
{
	register_table("person", 10);
}

void test_exists()
{
	int exist = exists("person");
	printf("Exists: %d", exist);
}

void test_create_table()
{
	create_table(strdup("user"), strdup("name string,age integer"));
}

void test_deregister()
{
	xmlNodePtr metadata_root = load_metadata();
	deregister(strdup("user"), metadata_root);
	xmlFreeDoc(metadata_root->doc);
}

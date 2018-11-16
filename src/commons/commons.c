/*
 * commons.c
 *
 *  Created on: Nov 15, 2018
 *      Author: ezerbo
 */
#include <stdio.h>
#include "commons.h"

xmlNodePtr load_metadata() {
	xmlDocPtr metadata_file = xmlParseFile(METADATA_FILE_NAME);
	if (!metadata_file) {
		fprintf(stderr, "Unable to get tables metadata, exiting...");
		exit(1);
	}
	return xmlDocGetRootElement(metadata_file);
}

/*
 * commons.h
 *
 *  Created on: Nov 15, 2018
 *      Author: ezerbo
 */

#ifndef COMMONS_COMMONS_H_
#define COMMONS_COMMONS_H_

#endif /* COMMONS_COMMONS_H_ */

#define METADATA_FILE_NAME "tables_metadata.xml"
#include <libxml/parser.h>

/**
 * Function: load_metadata
 * ------------------------
 * Loads tables metadata
 *
 * 	returns: Pointer to fist node in metadata file
 *
 * */
xmlNodePtr load_metadata();

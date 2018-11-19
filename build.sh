#!/bin/bash
bison -d src/parser/grammar.y 
flex src/parser/specs.l
gcc `xml2-config --cflags --libs` src/commons/commons.c src/table/table.c  src/commands/commands.c  grammar.tab.c lex.yy.c -o parser -ly -lfl -lxml2
./parser


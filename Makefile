CC=gcc
CFLAGS= -ly -lfl -lxml2 `xml2-config --cflags --libs`
DEPS=src/*/.h
BS=bison
FL=flex
cql: 
	$(BS) -d src/parser/grammar.y
	$(FL) src/parser/specs.l 
	$(CC) src/*/*.c grammar.tab.c lex.yy.c -o cql $(CFLAGS)
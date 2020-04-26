/* A Bison parser, made by GNU Bison 3.0.4.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015 Free Software Foundation, Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

#ifndef YY_YY_GRAMMAR_TAB_H_INCLUDED
# define YY_YY_GRAMMAR_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    WORD = 258,
    ATTRS = 259,
    WORD_LIST = 260,
    DIFF = 261,
    EQUALS = 262,
    STAR = 263,
    RIGHT_PARENTHESIS = 264,
    LEFT_PARENTHESIS = 265,
    SEMI_COLON = 266,
    COM_WHERE = 267,
    COM_SELECT = 268,
    COM_ALTER = 269,
    COM_CREATE = 270,
    COM_INTO = 271,
    COM_VALUES = 272,
    COM_DELETE = 273,
    COM_INSERT = 274,
    COM_FROM = 275,
    COM_TABLE = 276,
    COM_DESC = 277,
    COM_UPDATE = 278,
    COM_SET = 279,
    COM_DROP = 280,
    COM_HELP = 281,
    COM_ADD = 282,
    COM_REMOVE = 283,
    COM_EXIT = 284,
    FUNCT_AVG = 285,
    FUNCT_SUM = 286,
    FUNCT_MIN = 287,
    FUNCT_MAX = 288
  };
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED

union YYSTYPE
{
#line 16 "src/parser/grammar.y" /* yacc.c:1909  */

	char* lexeme_val;

#line 92 "grammar.tab.h" /* yacc.c:1909  */
};

typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_GRAMMAR_TAB_H_INCLUDED  */

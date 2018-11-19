%{
#include "grammar.tab.h"
%}

lettre [a-zA-Z_]
chiffre [0-9]
espace [ ]
integer "integer"
text    "text"
type_date    "date"
type_attribut {integer}|{text}|{type_date}
mot ({lettre}|{chiffre})+
mot_create {mot}{espace}({integer}|{text}|{type_date})
def_date (({chiffre}+)[/]({chiffre}+)[/]({chiffre}+))
liste_mots_insert (({mot}|{def_date})[,])+({mot}|{def_date})
liste_mots_create ({mot_create}[,])+{mot_create}


 
%%

"WHERE"|"where"			{return COM_WHERE;}
"SELECT"|"select"		{return COM_SELECT;}
"CREATE"|"create"		{return COM_CREATE;}
"TABLE"|"table"			{return COM_TABLE;}
"INSERT"|"insert"		{return COM_INSERT;}
"INTO"|"into"			{return COM_INTO;}
"VALUES"|"values"		{return COM_VALUES;}
"FROM"|"from"			{return COM_FROM;}
"ALTER"|"alter"			{return COM_ALTER;}
"DELETE"|"delete"		{return COM_DELETE;}
"DESC"|"desc"			{return COM_DESC;}
"UPDATE"|"update"		{return COM_UPDATE;}
"SET"|"set"			{return COM_SET;}
"DROP"|"drop"			{return COM_DROP;}
"ADD"|"add"			{return COM_ADD;}
"REMOVE"|"remove"		{return COM_REMOVE;}
"HELP"|"help"			{return COM_HELP;}
"EXIT"|"exit"			{return COM_EXIT;}
"AVG"|"avg"			{return FONCT_AVG;}
"SUM"|"sum"			{return FONCT_SUM;}
"MIN"|"min"			{return FONCT_MIN;}
"MAX"|"max"			{return FONCT_MAX;}
"*"		     		{return etoile;}
"<>"			        {return difference;}
"="		                {return egalite;}
 ")"    	                {return parenthese_droite;}
"("    		                {return parenthese_gauche;}


{mot}  			{
			yylval.valeur_chaine=(char *) malloc((1+yyleng)*sizeof(char));      
			strcpy(yylval.valeur_chaine, yytext);	
       			return mot;
			}

{mot_create}  		{
			yylval.valeur_chaine=(char *) malloc((1+yyleng)*sizeof(char));      
			strcpy(yylval.valeur_chaine, yytext);	
        		return mot_create;
			}

 
{liste_mots_insert} 	{
 			yylval.valeur_chaine=(char *) malloc((1+yyleng)*sizeof(char));      
			strcpy(yylval.valeur_chaine, yytext);	
			return liste_mots_insert;
 			}
 
{liste_mots_create}  	{
			yylval.valeur_chaine=(char *) malloc((1+yyleng)*sizeof(char));      
			strcpy(yylval.valeur_chaine, yytext);	
			return liste_mots_create;
			}

{def_date}		{
			yylval.valeur_chaine=(char*)malloc((1+yyleng)*sizeof(char));
			strcpy(yylval.valeur_chaine, yytext);	
			return def_date;
			}

%%


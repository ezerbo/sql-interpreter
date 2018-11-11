/************************************
*				    *
*				    *
*				    *
*************************************/
%{
#include <stdio.h>
#include <string.h>
#include "functions.h"//inclusion du header contenant la declaration des fonctions utilisées
%}
%union{// definition du type de la variable yylval
char* valeur_chaine;
};
/*********declaration des tokens**********/
%token <valeur_chaine> mot mot_create liste_mots_insert liste_mots_create   /*les tokens ayant un type doivent etre recuperer pour
faire des traitements dans les fonctions*/
%token <valeur_chaine> difference egalite def_date suppression 
%token etoile espace parenthese_droite parenthese_gauche
%type <valeur_chaine> t_insert t_create 
%token COM_WHERE COM_SELECT COM_ALTER COM_CREATE COM_INTO COM_VALUES COM_DELETE  COM_INSERT
%token  COM_FROM COM_TABLE COM_DESC COM_UPDATE COM_SET COM_DROP COM_HELP COM_ADD COM_REMOVE COM_EXIT
%token FONCT_AVG FONCT_SUM FONCT_MIN FONCT_MAX
%%
//operation_sql est l'axiome de la grammaire
operation_sql		: op_create
			| op_insert
			| op_select
			| op_alter
			| op_delete
			| op_desc
			| op_update
			| op_drop
			| op_help
			| op_exit
			| fonction_aggregation
			| error {yyerrok;yyclearin;}
;
//regle de derivation de fonction_aggregation
fonction_aggregation	: f_avg
			| f_sum
			| f_max
			| f_min
;
f_avg			: COM_SELECT FONCT_AVG parenthese_gauche mot parenthese_droite COM_FROM mot             {fonction_avg($7,$4);yyparse();}
;
f_sum			: COM_SELECT FONCT_SUM parenthese_gauche mot parenthese_droite COM_FROM mot		{fonction_sum($7,$4);yyparse();}
;
f_max			: COM_SELECT FONCT_MAX parenthese_gauche mot parenthese_droite COM_FROM mot             {fonction_max($7,$4);yyparse();}
;
f_min			: COM_SELECT FONCT_MIN parenthese_gauche mot parenthese_droite COM_FROM mot             {fonction_min($7,$4);yyparse();}
;
op_create		: COM_CREATE COM_TABLE mot parenthese_gauche t_create parenthese_droite        	 {creer_table($3,retourne_liste_attribut($5),$5);yyparse();}
;
op_insert		: COM_INSERT COM_INTO mot COM_VALUES parenthese_gauche t_insert parenthese_droite        {commande_insert($3,$6);yyparse();}
;
op_select		: COM_SELECT mot COM_FROM mot								 {commande_select($4,$2);yyparse();}
			| COM_SELECT etoile COM_FROM mot							 {commande_select_etoile($4);yyparse();}
;
op_alter		: COM_ALTER COM_TABLE mot COM_ADD mot_create	 					 {commande_alter($3,$5,"add");yyparse();}
			| COM_ALTER COM_TABLE mot COM_REMOVE mot	 					 {commande_alter($3,$5,"remove");yyparse();}	
;
op_delete		: COM_DELETE COM_FROM mot COM_WHERE mot egalite mot					 {commande_delete($3,$6,$5,$7);yyparse();}
			| COM_DELETE COM_FROM mot COM_WHERE mot difference mot					 {commande_delete($3,$6,$5,$7);yyparse();}
;
op_desc			: COM_DESC mot									         {commande_desc($2);yyparse();}
;
op_update		: COM_UPDATE mot COM_SET mot egalite mot 			{commande_update_sans_where($2,$4,$6);yyparse();}	
			| COM_UPDATE mot COM_SET mot egalite mot COM_WHERE mot egalite mot {commande_update_avec_where($2,$4,$8,$6,$10);yyparse();}
;
op_drop			: COM_DROP  COM_TABLE mot							         {commande_drop($3);yyparse(); }
;
op_help			: COM_HELP mot										 { commande_help($2);yyparse();}
;
op_exit			: COM_EXIT										 {exit(0);}
;
t_insert 		: mot	{$$=$1;}
			| liste_mots_insert {$$=$1;}
			| def_date {$$=$1;}
			
;
t_create		: mot_create {$$=$1;}
			| liste_mots_create {$$=$1;}
			;
%%
int yyerror(){
printf("Erreur de syntaxe\n");
yyparse();
return 0;
}

/**commande permettant de creer une nouvelle table
elle prend en parametre le nom de la table a creer la chaine comprise entre les parentheses et 
une liste chainée des attributs et type de la nouvelle table*/
int creer_table(char* nom_table,attribut*  liste,char*chaine)
{
        int booleen=0;
        xmlDocPtr  doc = xmlParseFile("metaDonnees.xml");
        xmlNodePtr  racine,nouvelle_table,champ;
        if (doc == NULL) {
                fprintf(stderr, "Document XML invalide\n");

        }
        // Récupération0 de la racine
        racine = xmlDocGetRootElement(doc);
        if (racine == NULL) {
                fprintf(stderr, "Document XML vierge\n");
                xmlFreeDoc(doc);
        }
        booleen=si_table_existe(nom_table,racine,&booleen);/**teste l'existence de la table*/

        if(booleen) {
                message_d_erreur("La table   existe  déjà");//si la  table   existe  deja
        } else {
                FILE*   nouvelle_table;
                char   chaine_tempon1[50];
                xmlDocPtr   doc;
                xmlNodePtr  racine,noeud_struct,noeud_attribut;
                char   chaine_tempon2[50];
                int nombre_attribut_int=0;
                char   nombre_attribut_char[50];
                strcpy(chaine_tempon1,nom_table);
                //strcpy(chaine_tempon2,nom_table);
                nouvelle_table=fopen(strcat(chaine_tempon1,".xml"),"a+");/**chaine_tempon1=nom_table.xml*/
                fputs("<table>  </table>",nouvelle_table);/**insertion de la racine dans la table*/
                fclose(nouvelle_table);
                doc=xmlParseFile(chaine_tempon1);
                if(doc==NULL) {
                        printf("document invalide ");
                        return  EXIT_FAILURE;
                }
                racine=xmlDocGetRootElement(doc);
                if(racine==NULL) {
                        printf("document   vide");
                        return  EXIT_FAILURE;
                }
                xmlSetProp(racine,BAD_CAST "name",BAD_CAST  nom_table);/**definition de la propriété "name" de la table*/
                noeud_struct=xmlNewNode(NULL,BAD_CAST   "struct");/**creation d'un noeud <struct> dans la table courante*/
                while(liste->attribut_suivant!=NULL) {
                        noeud_attribut=xmlNewNode(NULL,BAD_CAST liste->nom_attribut);/**application du nom de l'attribut*/
                        xmlSetProp(noeud_attribut,BAD_CAST "type",BAD_CAST liste->type_attribut);/**application du type de l'attribut*/
                        xmlAddChild(noeud_struct,noeud_attribut);/**ajout d'un nouveau champ à la structure de la table courante*/
                        liste=liste->attribut_suivant;
                }
                xmlAddChild(racine,noeud_struct);/**ajout du  noeud <struct> comme fils du noeud racine*/
                xmlSaveFile(chaine_tempon1,doc);/**sauvegarde des  modifications*/
                xmlFreeDoc(doc);/**liberation de la memoire allouée au fichier*/
                nombre_attribut_int=compter_champs(chaine);/**compte le nombre de champ contenu dans la chaine**/
                sprintf(nombre_attribut_char,"%d",nombre_attribut_int);/**  conversion de  int en  char*  */
                inscrire_table(nom_table,nombre_attribut_char);/**inscrit la  nouvelle table créee dans le fichier de meta donneés*/
        }
        return  0;

}
/*verifie l'existence d'une table dans le fichier de meta donnees*/
int   si_table_existe(char*  nom_table,xmlNodePtr racine,int*booleen)
{
        /**teste l'existence d'une table*/
        xmlNodePtr  cur_node=NULL;
        int teste=0;
        int comp=0;
        for(cur_node=racine; cur_node; cur_node=cur_node->next) {
                xmlChar*   nom_noeud;
                nom_noeud   =  xmlGetProp(cur_node,BAD_CAST  "name");

                if(nom_noeud!=NULL) {
                        if(cur_node->type==XML_ELEMENT_NODE&&!strcmp((char*)nom_noeud,nom_table)) {
                                /**si nom du noeud courant  est
                                    celui de  la table passée en  parametre*/
                                *booleen=1;
                                break;
                        }
                }

                si_table_existe(nom_table,cur_node->children,booleen);
        }

        return  *booleen;
}

/*****permet d'inscrire une table dans le fichier de meta données******/
int    inscrire_table(char* nom_table,char* nombre_attribut)
{
        xmlDocPtr  doc = xmlParseFile("metaDonnees.xml");
        xmlNodePtr  racine,nouvelle_table,champ;
        if (doc == NULL) {
                printf("Document XML invalide\n");
                xmlFreeDoc(doc);
                printf("La table n'a pas pu etre inscrite dans le fichier de meta données\n");
                return EXIT_FAILURE;

        }
        // Récupération de la racine
        racine = xmlDocGetRootElement(doc);
        if (racine == NULL) {
                printf("Document XML vierge\n");
                xmlFreeDoc(doc);
                 printf("La table n'a pas pu etre inscrite dans le fichier de meta données\n");
                return EXIT_FAILURE;
        }
        nouvelle_table=xmlNewNode(NULL,BAD_CAST "table");/**creation d'un nouveau noeud dans le fichier de meta données*/
        xmlChar*teste_nom=BAD_CAST   nom_table;
        xmlSetProp(nouvelle_table,BAD_CAST "name",BAD_CAST nom_table );
        champ=xmlNewNode(NULL,BAD_CAST "nombre_tuples");
        xmlNodeSetContent(champ,BAD_CAST "0");/**le nombre de tuples est nulles à la creation du  fichier*/
        xmlAddChild(nouvelle_table,champ);/**ajoute le noeud nombre_tuples comme fils du noeud correspondant à la nouvelle table*/
        champ=xmlNewNode(NULL,BAD_CAST  "nombre_attributs");
        xmlNodeSetContent(champ,BAD_CAST nombre_attribut);
        xmlAddChild(nouvelle_table,champ);
        xmlAddChild(racine,nouvelle_table);/**ajoute la nouvelle  table dans le fichier de meta données*/
        xmlSaveFile("metaDonnees.xml",doc);/**sauvegarde des modifications apportées au fichier de meta données*/
        xmlFreeDoc(doc);
        printf("Une nouvelle table créee avec succes!!!");
        return 0;
}
/**divise une chaine de carateres en plusieurs chaines en fonction 
des virgules rencontrées*/
element*  separe_valeur_inserees(char*chaine)
{
        int    position=0;
        char  tableau_val[compter_champs(chaine)][50];
        char  caractere_temp;
        caractere_temp=chaine[0];
        int compteur=0;
        int temp=0;
        int i;
        int j;
        element*  liste_element;
        liste_element=(element*)malloc(sizeof(element));
        liste_element->element_suivant=NULL;
        if(compter_champs(chaine)>1) {
                for(i=0; i<strlen(chaine); i++) {
                        if(chaine[i]==',') {//si l'element courant est une virgule
                                for(j=position; j<i; j++) {
                                        tableau_val[compteur][temp]=chaine[j];
                                        temp++;
                                }
                                tableau_val[compteur][temp]='\0';//specifie la fin de chaine
                                compteur++;
                                position=i+1;
                                temp=0;
                        }
                }
                temp=0;

                for(j=position; j<strlen(chaine); j++) { /**on enregistre  la  chaine  restante  dans le   tableau*/
                        tableau_val[compteur][temp]=chaine[j];
                        temp++;
                }
                tableau_val[compteur][temp]='\0';
        } else {
                strcpy(tableau_val[0],chaine);
        }
        element*   nouvel_element;
        for(i=0; i<=compteur; i++) {
                nouvel_element=(element*)malloc(sizeof(element));
                strcpy(nouvel_element->valeur,tableau_val[i]);
                nouvel_element->element_suivant=  liste_element;
                liste_element=nouvel_element;

        }
        return  liste_element;
}

/********compte le nombre de champs******/
int    compter_champs(char*chaine)
{
        int compteur=1;//le nombre de champs est egal au nombre de virgule augmenté de 1
        int i=0;
        for(i=0; i<strlen(chaine); i++) {
                if(chaine[i]==',') compteur++;
        }
        return  compteur;
}

void    message_d_erreur(char*message)/**methode personnalisée de gestion d'erreurs**/
{
        printf("L'erreur suivante est survenue : %s\n",message);
        return;
}
/*********retourne une liste chainée des attributs et de leurs types************/
attribut*  retourne_liste_attribut(char*chaine)
{
        int    longueur=compter_champs(chaine);
        element* tableau_valeur;
        tableau_valeur=separe_valeur_inserees(chaine);
        attribut*   liste_attributs=(attribut*)malloc(sizeof(attribut));
        liste_attributs->attribut_suivant=NULL;
        int temp=0;
        char  nom_attribut[50];
        char   type_attribut[50];
        int i,j,k;
        while(tableau_valeur->element_suivant!=NULL) {//chacune des valeurs du tableau doivent-etre separées en fonction des espaces
                for(j=0; j<strlen(tableau_valeur->valeur); j++) {
                        if(tableau_valeur->valeur[j]==' ') {//si  la valeur courante est un espace
                                strncpy(nom_attribut,tableau_valeur->valeur,j);
                                break;/**on  quitte  la  boucle si on rencontre un   un  espace*/
                        }
                }
                nom_attribut[j]='\0';//specifie la fin de chaine
                temp=0;
                for(k=j+1; k<strlen(tableau_valeur->valeur); k++) {
                        type_attribut[temp]=tableau_valeur->valeur[k];
                        temp++;
                }
                type_attribut[temp]='\0';/**specifie    la  fin de  chaine*/

                attribut*    nouvel_attribut=(attribut*)malloc(sizeof(attribut));
                strcpy(nouvel_attribut->nom_attribut,nom_attribut);/**on copie   chaque  nouvel  element dans    la  liste   des attributs--type*/
                strcpy(nouvel_attribut->type_attribut,type_attribut);
                nouvel_attribut->attribut_suivant=liste_attributs;
        
                liste_attributs=nouvel_attribut;
                tableau_valeur=tableau_valeur->element_suivant;
}
        return  liste_attributs;
}
void  appel_sup_enreg(xmlDocPtr doc,xmlNodePtr racine,char*nom_table,char*nom_champ,char*valeur,char*operateur,int compteur)
{/***realise un appel de la fonction de suppression chaque fois qu'un nouveau record repond au critere de comparaison*/
        xmlNodePtr  tuples=NULL;
        int i;
        int nombre_tuples=0;

        char    valeur_char[50];
        xmlDocPtr   doc_meta_donnees =  xmlParseFile("metaDonnees.xml");
        xmlNodePtr  racine_meta_donnees=xmlDocGetRootElement(doc_meta_donnees);
        
        for(i=0; i<compteur; i++) {
        
                supprimer_enregistrement(doc,racine,nom_table,nom_champ,valeur,operateur,&nombre_tuples);
        }
        tuples=maj_nombre_tuple(nom_table,racine_meta_donnees,&tuples);
        
        if(tuples!=NULL) {

                sprintf(valeur_char,"%d",atoi((char*)xmlNodeGetContent(tuples))-nombre_tuples);//conversion du nombre de tuples en char*
                xmlNodeSetContent(tuples,BAD_CAST  valeur_char);//application la  nouvelle valeur du noeud
                xmlSaveFile("metaDonnees.xml",doc_meta_donnees);//sauvegarde des modifications apportées au fichier de meta  données
}
        if(nombre_tuples!=0){
      		  printf("%d enregistrements(s) supprimé(s) avec succes\n",nombre_tuples);
        }
        else{
      		  printf("aucune donneé supprimée\n");
        }
}
/********retourne  les  noeuds fils d'un noeud struct*******/
void retourne_fils_struct(xmlNodePtr noeud_struct,attribut**liste)
{
        xmlNodePtr  cur_node=NULL;
        for(cur_node=noeud_struct->children; cur_node; cur_node=cur_node->next) {
                if(cur_node->type==XML_ELEMENT_NODE) {
                        attribut*    nouvel_attribut=(attribut*)malloc(sizeof(attribut));
                        strcpy(nouvel_attribut->nom_attribut,(char*)cur_node->name);//**on copie   chaque  nouvel  element dans    la  liste   des attributs--type*/
                        strcpy(nouvel_attribut->type_attribut,(char*)xmlGetProp(cur_node,BAD_CAST "type"));
                        nouvel_attribut->attribut_suivant=*liste;
                        *liste=nouvel_attribut;
                }
                retourne_fils_struct(noeud_struct->children,liste);
        }
}

/**********retourne l'adresse d'un noeud satifaisant au critere de comparaison************/
xmlNodePtr retourne_noeud_a_supprimer(xmlNodePtr racine,char*valeur,char*nom_champ,xmlNodePtr* noeud,char*operateur) {
        xmlNodePtr  cur_node=NULL;
        for(cur_node=racine->children; cur_node; cur_node=cur_node->next) {

                if(cur_node->type==XML_ELEMENT_NODE) {
                        if(!strcmp(operateur,"=")) {//si l'operateur de comparaison est l'egalité
                                if(!strcmp((char*)xmlNodeGetContent(cur_node),valeur)&&!strcmp((char*)cur_node->name,nom_champ)) {/**si le champ courant 													une valeur egale à  celle entrée parl'utilisateur*/
                                        *noeud=cur_node;
                                        break;
                                }
                        } else {//si l'operateur de comparaison est la difference
                                if(strcmp((char*)xmlNodeGetContent(cur_node),valeur)&&!strcmp((char*)cur_node->name,nom_champ)) {/**si le champ courant a  une 														valeur   differente de  celle  entrée par l'utilisateur*/
                                        *noeud=cur_node;
                                        break;
                                }
                        }

                }
                retourne_noeud_a_supprimer(cur_node->children,valeur,nom_champ,noeud,operateur);//appel recursif de la fonction
        }
        return  *noeud;
}
int supprimer_enregistrement(xmlDocPtr doc,xmlNodePtr  racine,char*nom_table ,char*nom_champ,char*valeur,char*operateur,int*nombre_tuples)
{/**fonction de suppression d'un record***/
        xmlNodePtr  cur_node=NULL,noeud_a_supprimer=NULL;
        char    egalite[2]="=";
        char    difference[3]="<>";
        char    chaine_temp[50];
        strcpy(chaine_temp,nom_table);
        strcat(chaine_temp,".xml");
        for(cur_node=racine; cur_node; cur_node=cur_node->next) {
                if(cur_node->type==XML_ELEMENT_NODE) {
                        if(!strcmp((char*)cur_node->name,"record")) {/**si le noeud courant est un enregistrement**/

                                noeud_a_supprimer=retourne_noeud_a_supprimer(cur_node,valeur,nom_champ,&noeud_a_supprimer,operateur);/**recuperation du noeud à supprimer**/                   
                                if(!strcmp(operateur,egalite)&&xmlNodeGetContent(noeud_a_supprimer)!=NULL) {/**si l'operateur de  comparaison est l'egalité*/
                      
                                        if(!strcmp((char*)xmlNodeGetContent(noeud_a_supprimer),valeur)) {/**si la condition d'egalité est verifiée*/
                                                xmlUnlinkNode(cur_node);/**suppression d'un noeud*/
                                                xmlSaveFile(chaine_temp,doc);
                                                (*nombre_tuples)++;

                                        }
                                        break;

                                }
                                if(!strcmp(operateur,difference)&&xmlNodeGetContent(noeud_a_supprimer)!=NULL) { /**si l'operateur de comparaison est la difference*/
                                        if(strcmp((char*)xmlNodeGetContent(noeud_a_supprimer),valeur)) {/**si la condition de difference est verifiée*/
                                                xmlUnlinkNode(cur_node);
                                                xmlSaveFile(chaine_temp,doc);
                                                (*nombre_tuples)++;
                                        }
                                        break;
                                }

                        }
                }
                supprimer_enregistrement(doc,cur_node->children,nom_table,nom_champ,valeur,operateur,nombre_tuples);
        }
}
xmlNodePtr  maj_nombre_attribut(char*nom_table,xmlNodePtr  racine,xmlNodePtr* tuples)
{ /**revoie l'adresse en memoire du noeud qui sera mis à jour*/
        xmlNodePtr cur_node = NULL;
        char*   valeur_char;
        int valeur_int;
        for(cur_node = racine; cur_node; cur_node = cur_node->next) {
                if (cur_node->type == XML_ELEMENT_NODE&&xmlGetProp(cur_node,BAD_CAST  "name")!=NULL) {

                        if(!strcmp((char*)xmlGetProp(cur_node,BAD_CAST  "name"), nom_table)) {
                                *tuples=cur_node->last;
                                break;
                        }

                }
                maj_nombre_attribut(nom_table,cur_node->children,tuples);
        }
        return  *tuples;
}
int supprimer_champ(xmlDocPtr doc,xmlNodePtr  racine,char*nom_table,char*attrib)//permet de supprimer un champ
{
        //le nom de la table correspondante et le champ  a supprimer sont donnés par la fonction commande_alter()
        char    nom_tempon[50];//nom_table  tempon
        strcpy(nom_tempon,nom_table);//mise en tempon du  nom la variable
        strcat(nom_tempon,".xml");//concatenation du nom tempon avec
        xmlNodePtr cur_node = NULL;//noeud de parcours de la  table
        for(cur_node=racine; cur_node; cur_node=cur_node->next) {
                if (cur_node->type == XML_ELEMENT_NODE) {//si l'element courant est un noeud
                        if(!strcmp((char*)cur_node->name,attrib)) {//teste l'egalite entre les noeuds
                                xmlUnlinkNode(cur_node);//suppression du noeud
                                xmlSaveFile(nom_tempon,doc);//sauvegarde de la table
                        }
                }
                supprimer_champ(doc,cur_node->children,nom_table,attrib);//appel recursif de la fonction
        }
}
/************ajoute un champ à la structure d'une table*****************/
int ajouter_champ(xmlDocPtr doc,xmlNodePtr racine,char*nom_table,char*attribut_type)
{
        //permet d'ajouter un nouveau champ a  une table
        char    nom_tempon[50];//
        attribut*  attrib=retourne_liste_attribut(attribut_type);//retourne une structure dont les champs sont le nom et le type du nouvel  attribut
        strcpy(nom_tempon,nom_table);//mise en tempon du nom de la variable car sa structure est modifiée par strcat()
        strcat(nom_tempon,".xml");//nom du fichier correspondant a la table cible
        xmlNodePtr cur_node = NULL,nouveau_noeud=NULL;
        for(cur_node=racine; cur_node; cur_node=cur_node->next) {
                if (cur_node->type == XML_ELEMENT_NODE) {
                        if(!strcmp((char*)cur_node->name,"struct")) {//ajout  d'un attribut au niveau du    noeud   "struct"
                                nouveau_noeud=xmlNewNode(NULL,BAD_CAST attrib->nom_attribut);//application du nom du nouvel attribut
                                xmlSetProp(nouveau_noeud,BAD_CAST "type",BAD_CAST attrib->type_attribut);//application du type du nouvel attribut
                                xmlAddChild(cur_node,nouveau_noeud);//ajout du nouveau noeud comme noeud fils du noeud courant
                                xmlSaveFile(nom_tempon,doc);//sauvegarde des  modifications operées sur la table
                        }
                        if(!strcmp((char*)cur_node->name,"record")) { //ajout d'un attribut au niveau des noeuds "record"
                                nouveau_noeud=xmlNewNode(NULL,BAD_CAST attrib->nom_attribut);//application du nom du nouvel attribut
                                xmlSetProp(nouveau_noeud,BAD_CAST "type",BAD_CAST attrib->type_attribut);//application du type du nouvel attribut
                                xmlNodeSetContent(nouveau_noeud,BAD_CAST  "null");//mise a "null" du  nouveau noeud dans tous les enregistrement
                                xmlAddChild(cur_node,nouveau_noeud);//ajout du nouveau noeud comme noeud fils du noeud courant
                                xmlSaveFile(nom_tempon,doc);//sauvegarde des modifications operées sur la table
                        }
                }
                ajouter_champ(doc,cur_node->children,nom_table,attribut_type);

        }


}

/*****commande modifiant la structure d'une table en ajoutant ou en supprimant un champ************************/
int commande_alter(char*nom_table,char*nom_champ,char*nom_operation)//commande permettant de modifier la structure d'une table
{
        //elle effectue deux operations,à savoir l'ajout et la suppression de  champ dans une table
        int    booleen=0;
        char   nom_tempon[50];
        char    attribut_type[50]="";
        strcpy(nom_tempon,nom_table);//mise en tempon du nom de la table car strcat le  modifie
        booleen=si_table_existe(nom_table,retourne_racine(),&booleen);//teste l'existence de la table
        if(booleen!=1)  message_d_erreur("La table n'existe pas");
        else {
                attribut*   liste=(attribut*)malloc(sizeof(attribut));
                xmlDocPtr   doc=xmlParseFile(strcat(nom_tempon,".xml"));//on  parse la table en memoire
                xmlNodePtr  racine=xmlDocGetRootElement(doc);
                char   valeur_char[50];
                liste->attribut_suivant=NULL;
                liste=recuperer_structure_table(nom_table,racine,&liste);//recuperation de la structure de la table
                //lorsqu'elle existe
                while(liste->attribut_suivant!=NULL) {
                        if(strcmp(liste->nom_attribut,nom_champ)) {
                                if(!strcasecmp(nom_operation,"ADD")) {//si l'action concernée par la modification est un  ajout

                                        //traitement pour l'operation d'ajout
                                        attribut*   attrib=(attribut*)malloc(sizeof(attribut));
                                        attrib =retourne_liste_attribut(nom_champ);
                                        strcat(attribut_type,attrib->nom_attribut);
                                        strcat(attribut_type," ");
                                        strcat(attribut_type,attrib->type_attribut);
                                        ajouter_champ(doc,racine,nom_table,attribut_type);//appel de la methode d'ajout d'un champ
                                        doc=xmlParseFile("metaDonnees.xml");//ouverture du fichier de meta donnees pour maj
                                        racine=xmlDocGetRootElement(doc);
                                        xmlNodePtr  tuples;//contiendra l'adresse de la table dans fichier de  meta donnees en  memoire
                                        tuples= maj_nombre_attribut(nom_table,racine,&tuples);
                                        if(tuples!=NULL)    {
                                                sprintf(valeur_char,"%d",atoi((char*)xmlNodeGetContent(tuples))+1);//conversion du nombre de tuples en char*
                                                xmlNodeSetContent(tuples,BAD_CAST  valeur_char);//application la  nouvelle valeur du noeud
                                                xmlSaveFile("metaDonnees.xml",doc);//sauvegarde des modifications apportées au fichier de meta  données
                                                printf("\nLa structure de la table %s a été modifiée avec succes!!!!!\n",nom_table);
                                        }
                                        break;
                                }
                                if(!strcasecmp(nom_operation,"REMOVE")) {//si l'action concernée par la modification est une suppression
                                        //traitement pour l'operation de suppression
                                        supprimer_champ(doc,racine,nom_table,nom_champ);//appel de  la   methode de  suppression
                                        doc=xmlParseFile("metaDonnees.xml");//ouverture du fichier de meta donnees pour maj
                                        racine=xmlDocGetRootElement(doc);//obtention de la racine du document
                                        xmlNodePtr  tuples;//contiendra l'adresse de la table dans fichier de  meta donnees en  memoire
                                        tuples= maj_nombre_attribut(nom_table,racine,&tuples);
                                        if(tuples!=NULL)    {
                                                sprintf(valeur_char,"%d",atoi((char*)xmlNodeGetContent(tuples))-1);//conversion du nombre de tuples en char*
                                                xmlNodeSetContent(tuples,BAD_CAST  valeur_char);//application la  nouvelle valeur du noeud
                                                xmlSaveFile("metaDonnees.xml",doc);//sauvegarde des modifications apportées au fichier de meta  données
                                                printf("\nLa structure de la table %s a été modifiée avec succes!!!!!\n",nom_table);
                                        }
                                        // printf("Operation  de suppression");
                                        break;
                                }
                        }

                        liste=liste->attribut_suivant;
                }
        }
}
/*********commande supprimant un enregistrement repondant à certains criteres
les seuls criteres de comparaison retenus sont l'egalité et la difference
*******/
int commande_delete(char*nom_table,char*operateur,char*nom_champ,char*valeur)//commande permettant de supprimer un enregistrement
{
        //repondant a un critere donné
        int    booleen=0;
        char   nom_tempon[50];
        strcpy(nom_tempon,nom_table);
        booleen=si_table_existe(nom_table,retourne_racine(),&booleen);
        if(booleen!=1)  message_d_erreur("La table n'existe pas");
        else {
       
                xmlDocPtr  doc=xmlParseFile(strcat(nom_tempon,".xml"));
                xmlNodePtr  racine=xmlDocGetRootElement(doc);
                attribut*   liste;
                liste->attribut_suivant=NULL;
                liste=recuperer_structure_table(nom_table,racine,&liste);
                booleen=chercher_nombre_tuples(nom_table,retourne_racine(),&booleen);
                while(liste->attribut_suivant!=NULL) {
                        if(!strcmp(liste->nom_attribut,nom_champ)) { /**si l'attrbut existe*/
                                appel_sup_enreg(doc,racine,nom_table,nom_champ,valeur,operateur,booleen);
                                break;
                        }
                        liste=liste->attribut_suivant;
                }
        }
}
/*affiche le resultat d'une selection*/
void affiche_resultat_selection(xmlNodePtr racine,char* nom_table){
xmlNodePtr cur_node = NULL;

	for(cur_node=racine->children;cur_node;cur_node=cur_node->next){
		if(cur_node->type==XML_ELEMENT_NODE){
		printf("%s               ",xmlNodeGetContent(cur_node));
		}
		affiche_resultat_selection(cur_node->children,nom_table);
	}
}
/****************affiche le resultat  de  la  selection********************/
int selectionne_noeud(xmlNodePtr racine,char* nom_table,int*compteur)//affiche le resultat d'une selection
{
        xmlNodePtr cur_node = NULL;
        attribut* structure_table=(attribut*)malloc(sizeof(attribut));/**recuperation de la structure de la table*/
        
 	structure_table->attribut_suivant=NULL;
 	char nom_tempon[50];
        for(cur_node = racine; cur_node; cur_node = cur_node->next) {
                if (cur_node->type == XML_ELEMENT_NODE&&!strcmp((char*)cur_node->name,"record")) {
                       // if() {
                        if(*(compteur)==0){
                        int nombre_champ=0;//contiendra le nombre d'attribut de la table
                        int i=0;
                        chercher_nombre_attribut(nom_table,retourne_racine(),&nombre_champ);//recupere le nombre d'attribut de la table
                        struct   attribut** tableau=(attribut**)malloc(nombre_champ*sizeof(struct attribut*));//tableau permettant d'inverser l'ordre des elements
                             strcpy(nom_tempon,nom_table);
                                 xmlDocPtr doc = xmlParseFile(strcat(nom_tempon,".xml"));
                		 racine = xmlDocGetRootElement(doc);
                        	recuperer_structure_table(nom_table,racine,&structure_table);/**recuperation de la structure pour l'affichage*/
			        printf("\nRESULTAT DE LA SELECTION\n\n");
             			while(structure_table->attribut_suivant!=NULL){
               				tableau[i]=structure_table;//on place les element dans un tableau pour pour  inverser l'ordre
               				i++;
                			structure_table=structure_table->attribut_suivant;
                	         }
                	         for(i=nombre_champ-1;i>=0;i--){
                	       	    printf("%s(%s)         ",tableau[i]->nom_attribut,tableau[i]->type_attribut);//affichage de l'entete ie les champs et leur type
                	         }
                	      } 
                	      printf("\n");
                       	        affiche_resultat_selection(cur_node,nom_table);//appel de la fonction d'affichage du resultat
                       	        printf("\n");
                       	       
                                (*compteur)+=1;//incrementation du nombre de données trouvées
                              
                }
                selectionne_noeud(cur_node->children,nom_table,compteur);//appel recursif de la fonction
        }
        return *compteur;
}
/**********commande permettant de faire la projection sur un seul champs****************/
int commande_select_etoile(char*nom_table)/***commande permettant de  faire
la selection d'un  seul  champ*/
{
        int booleen=0;
        char nom_tempon[50];
        int nombre_ligne_trouve=0;
        strcpy(nom_tempon,nom_table);/**mise en  tempon du nom de la table car strcat le modifie*/
        booleen=si_table_existe(nom_table,retourne_racine(),&booleen);/**teste  l'existence d'une table*/
        if(booleen!=1)  message_d_erreur("La  table entrée  n'existe pas");/**on teste d'abord si la table existe*/
        else {
                attribut*   liste;
                liste->attribut_suivant=NULL;
                xmlDocPtr doc = xmlParseFile(strcat(nom_tempon,".xml"));
                xmlNodePtr racine = xmlDocGetRootElement(doc);
                liste=recuperer_structure_table(nom_table,racine,&liste);/**recuperation de la structure de la table
                 lorsqu'elle existe*/
                while(liste->attribut_suivant!=NULL) {
                        /**on applique la fonction teste_egalite();  car la  taille du nom dans la liste ne tiens
                        pas compte    de  '\0'*/
                       
                                /***code permettant de faire la selection****/
                                printf("\n");
                                nombre_ligne_trouve=selectionne_noeud(racine,nom_table,&nombre_ligne_trouve);/**affichage du resultat de la selection*/
                                if(nombre_ligne_trouve!=0)
                                printf(" \n%d ligne(s) trouvée(s) \n",nombre_ligne_trouve);
                                else printf("Aucune donnée n'a été trouvée\n");
                                break;
                        
                        liste=liste->attribut_suivant;
                }
                xmlFreeDoc(doc);
        
}
}
/***retourne l'adresse de la table dont les meta  donnees doivent  etre mises à jour**/
xmlNodePtr  maj_nombre_tuple(char*nom_table,xmlNodePtr  racine,xmlNodePtr* tuples){
        xmlNodePtr cur_node = NULL;
        char*   valeur_char;
        int valeur_int;
        for(cur_node = racine; cur_node; cur_node = cur_node->next) {
                if (cur_node->type == XML_ELEMENT_NODE&&xmlGetProp(cur_node,BAD_CAST  "name")!=NULL) {
                        if(!strcmp((char*)xmlGetProp(cur_node,BAD_CAST  "name"), nom_table)) {
                                *tuples=cur_node->children;

                        }

                }
                maj_nombre_tuple(nom_table,cur_node->children,tuples);
        }
        return  *tuples;
}

/**recherche le nombre de tuples d'un table dans fichiers de meta données**/
int chercher_nombre_tuples(char*nom_table,xmlNodePtr racine,int* booleen)
{
        xmlNodePtr cur_node = NULL;
        for(cur_node = racine; cur_node; cur_node = cur_node->next) {
                if (cur_node->type == XML_ELEMENT_NODE&&xmlGetProp(cur_node,BAD_CAST  "name")!=NULL) {

                        if(!strcmp((char*)xmlGetProp(cur_node,BAD_CAST  "name"), nom_table)) {

                                *booleen=atoi((char*)xmlNodeGetContent(cur_node->children));
                           
                                break;
                        }
                }
                chercher_nombre_tuples(nom_table,cur_node->children,booleen);
        }
        return  *booleen;
}

/*******cherche le nombre d'attribut d'une table dans le fichier de meta données********/
int  chercher_nombre_attribut(char*nom_table,xmlNodePtr  racine,int *booleen)
{
        xmlNodePtr cur_node = NULL;
        for(cur_node = racine; cur_node; cur_node = cur_node->next) {
                if (cur_node->type == XML_ELEMENT_NODE&&xmlGetProp(cur_node,BAD_CAST  "name")!=NULL) {

                        if(!strcmp((char*)xmlGetProp(cur_node,BAD_CAST  "name"), nom_table)) {

                                *booleen=atoi((char*)xmlNodeGetContent(cur_node->last));
                                break;
                        }
                }
                chercher_nombre_attribut(nom_table,cur_node->children,booleen);
        }
        return  *booleen;
}
/***********commande permettant l'insertion d'un tuples dans une table********************/
int commande_insert(char * nom_table, char* values)
{
        int booleen=0;
        int nombre_champs=0;
        char   nom_tempon[50];
        attribut*   liste_attributs;
        nombre_champs=chercher_nombre_attribut(nom_table,retourne_racine(),&nombre_champs);//retourne le nombre d'attributs de la table
        booleen=si_table_existe(nom_table,retourne_racine(),&booleen);//teste de l'existence de la table
        if(booleen!=1)  message_d_erreur("La  table n'existe    pas");
        else {
                if(nombre_champs!=compter_champs(values)) {

                        message_d_erreur("Le nombre de valeurs est different du nombre de champs");
                        return 1;
                }
                inserer_tuple(nom_table,values,nombre_champs);

        }

}
/*retourne la racine du fichier de meta donnees*/
xmlNodePtr   retourne_racine()
{
        xmlDocPtr  doc = xmlParseFile("metaDonnees.xml");
        xmlNodePtr  racine,nouvelle_table,champ;
        if (doc == NULL) {
                fprintf(stderr, "Document XML invalide\n");

        }
        // Récupération de la racine
        racine = xmlDocGetRootElement(doc);
        if (racine == NULL) {
                fprintf(stderr, "Document XML vierge\n");
                xmlFreeDoc(doc);
        }
        return  racine;
}
/*cree le fichier de meta donnees*/
void creer_fichier_de_metaDonnees()
{
        FILE*   metaDonnees;
        metaDonnees =  fopen("metaDonnees.xml","a+");
        xmlDocPtr  doc = xmlParseFile("metaDonnees.xml");
        xmlNodePtr  racine;
        if (doc == NULL) {
                fputs("<meta_donnees>  </meta_donnees>",metaDonnees);/**insertion des balises racines*/
        }
        // Récupération de la racine
        racine = xmlDocGetRootElement(doc);
        if (racine == NULL) {
                printf("Document XML vierge\n");
                xmlFreeDoc(doc);

        }
        xmlFreeDoc(doc);
        fclose(metaDonnees);

}
/**********recupere la structure d'une table se trouvant entre les balise  <struct></struct>******************/
attribut*  recuperer_structure_table(char*nom_table,xmlNodePtr  racine,attribut**liste)
{
        /**recupere la  structure d'une table*/
        xmlNodePtr   cur_node=NULL;
        for(cur_node=racine; cur_node; cur_node=cur_node->next) {

                if(cur_node->type == XML_ELEMENT_NODE&&!strcmp((char*)cur_node->name,"struct")) {/**on  recupere tous les noueds entre <struct></struct>*/
                        retourne_fils_struct(cur_node,liste);
                        break;
                }
                recuperer_structure_table(nom_table,cur_node->children,liste);
        }
        return  *liste;
}
/*affiche la structure d'une table
elle presente chaque champ avec leur attribut*/
int commande_desc(char* nom_table){
	char nom_tempon[50];
	int nb_tuples=0;
	int nb_attributs=0;
	int i=0;
	strcpy(nom_tempon,nom_table);
	xmlDocPtr doc = xmlParseFile("metaDonnees.xml");
	xmlNodePtr racine = xmlDocGetRootElement(doc);
	int verif=0;
	verif= si_table_existe(nom_table,racine,&verif);
	if(verif!=1) message_d_erreur("La table entrée n'existe pas");
	else{
	 doc = xmlParseFile(strcat(nom_tempon,".xml"));
	 racine = xmlDocGetRootElement(doc);
	attribut* liste=(attribut*)malloc(sizeof(attribut));
	chercher_nombre_attribut(nom_table,retourne_racine(),&nb_attributs);//cherche le nombre d'attribut d'une table
	struct attribut** tableau_attribut=(attribut**)malloc(nb_attributs*sizeof(struct attribut*));
	liste->attribut_suivant=NULL;
	liste = recuperer_structure_table(nom_table,racine,&liste);//recuperation de la structure de la table
	while(liste->attribut_suivant!=NULL){
	tableau_attribut[i]=liste;
	i++;
	liste=liste->attribut_suivant;
	}
	
	printf("\n\n|          NOM DU CHAMPS         |        TYPE DU CHAMPS       |\n");
	printf("| ____________________________________________________________ |\n");
	for(i=nb_attributs-1;i>=0;i--){
		printf("               %s                      %s             \n",tableau_attribut[i]->nom_attribut,tableau_attribut[i]->type_attribut);
		printf("| ____________________________________________________________ |\n");
	}
	chercher_nombre_tuples(nom_table,retourne_racine(),&nb_tuples);
	printf("\n\nCette table possede %d champs et contient  %d enregistrement(s)",nb_attributs,nb_tuples);
	}
	
	return 0;
}
/**fonction appelée par commande_insert() pour l'insertion d'un tuple dans une table**/
int    inserer_tuple(char*nom_table,char*values,int  nombre_champs)
{
        /**permet d'inserer un tuple dans une table*/
        char  nom_tempon[50];
        int compteur=0;
        int i=0;
        element*  liste =  separe_valeur_inserees(values);
        strcpy(nom_tempon,nom_table);
        xmlDocPtr  doc;
        int verif_type=0;
        doc=xmlParseFile(strcat(nom_tempon,".xml"));
        if(doc==NULL) {
                printf("document introuvable");
                return  1;
        }
        xmlNodePtr  racine=xmlDocGetRootElement(doc);
        if(racine==NULL) {
                printf("document invalide");
                return  1;
        }

        char    tableau_valeur[nombre_champs][50];
        while(liste->element_suivant!=NULL) {/**recupere les données de la liste chainée et les place dans  un tableau*/
                strcpy(tableau_valeur[compteur],liste->valeur);
                liste=liste->element_suivant;
                compteur++;
        }
        attribut*   liste_attributs=(attribut*)malloc(sizeof(attribut));
        liste_attributs->attribut_suivant=NULL;
        recuperer_structure_table(nom_table,racine,&liste_attributs);
        
       struct attribut** tableau_attribut=(attribut**)malloc(nombre_champs*sizeof(struct attribut*));//recuperation des element pour l'inversion
       i=0;
       while(liste_attributs->attribut_suivant!=NULL){
       tableau_attribut[i]=liste_attributs;
       i++;
       liste_attributs=liste_attributs->attribut_suivant;
       }
       
        
        xmlNodePtr  record=xmlNewNode(NULL,BAD_CAST "record");//insertion d'un nouvel enregistrement dans la table
        xmlNodePtr  noeud_attribut;
        compteur--;
        for(i=nombre_champs-1;i>=0;i--) {
        
       		 if(!strcmp( (char*)tableau_attribut[i]->type_attribut,"integer") ){//si le type de l'attribut courant est un entier
       		 	if(strtol(tableau_valeur[compteur],NULL,10)==0&&strlen(tableau_valeur[compteur])!=1){
        	 		printf("L'attribut %s est un entier",tableau_attribut[i]->nom_attribut);
        	 		verif_type=1;
        	 		break;
       		 }  else {
        		noeud_attribut=xmlNewNode(NULL,BAD_CAST tableau_attribut[i]->nom_attribut);
                	xmlSetProp(noeud_attribut,BAD_CAST "type",BAD_CAST tableau_attribut[i]->type_attribut);
                	xmlNodeSetContent(noeud_attribut,BAD_CAST  tableau_valeur[compteur]);
                	xmlAddChild(record,noeud_attribut);
                	compteur--;
           		}
           
        } 
        else{
       		 if(!strcmp( (char*)tableau_attribut[i]->type_attribut,"text") ){/**si le type est text,aucun controle n'est necessaire*/
       			noeud_attribut=xmlNewNode(NULL,BAD_CAST tableau_attribut[i]->nom_attribut);
                	xmlSetProp(noeud_attribut,BAD_CAST "type",BAD_CAST tableau_attribut[i]->type_attribut);
                	xmlNodeSetContent(noeud_attribut,BAD_CAST  tableau_valeur[compteur]);
                	xmlAddChild(record,noeud_attribut);
                	compteur--;
       		 }
       		  else{
       		  if(!strcmp( (char*)tableau_attribut[i]->type_attribut,"date") ){/**on appele là lma fonction de verification de date*/
       			  if(!verifier_date(tableau_valeur[compteur])){
       		  		noeud_attribut=xmlNewNode(NULL,BAD_CAST tableau_attribut[i]->nom_attribut);
                		xmlSetProp(noeud_attribut,BAD_CAST "type",BAD_CAST tableau_attribut[i]->type_attribut);
                		xmlNodeSetContent(noeud_attribut,BAD_CAST  tableau_valeur[compteur]);
                		xmlAddChild(record,noeud_attribut);
                		compteur--;
       		  }
       		  else {
       		  message_d_erreur("La date entrée est invalide");
       		  verif_type=1;
       		  break;
       		  }
       		  }
       		  }
       		  }
             
        
 }
 if(verif_type!=1){
        xmlAddChild(racine,record);//tester la concordance des types
        xmlSaveFile(nom_tempon,doc);
        }
        else return EXIT_FAILURE;
        xmlFreeDoc(doc);
        doc=xmlParseFile("metaDonnees.xml");
        if(doc==NULL) {
                printf("Document    introuvable");
                return EXIT_FAILURE;
        }
        racine=xmlDocGetRootElement(doc);
        char   valeur_char[50];
        xmlNodePtr   tuples;
        tuples=    maj_nombre_tuple(nom_table,racine,&tuples);//contient l'adresse de la table
        if(tuples!=NULL)    {
                sprintf(valeur_char,"%d",atoi((char*)xmlNodeGetContent(tuples))+1);//conversion du nombre de tuples en char*
                xmlNodeSetContent(tuples,BAD_CAST  valeur_char);//application de la nouvelle valeur du noeurd
                xmlSaveFile("metaDonnees.xml",doc);//sauvegarde des modifications apportées au fichier de meta données
                printf("\n\nUne ligne insérée\n");
        }
}
/***verifie la validité d'une date
la date doit-etre ecrite sous l'une des formes jj/mm/yy ou jj/mm/yyyy
elle ne controle ni les annees bisextiles ni le nombre de jour du mois de fevrier*/
int    verifier_date(char* chaine)/**verifie la validité d'une date **/
{
        int verif=0;
        int longueur_chaine=strlen(chaine);
        if(longueur_chaine!=8&&longueur_chaine!=10) {
                verif=1;
        } else {
                char  jour[10]="";
                char  mois[10]="";
                char  annee[10]="";
                int i,comp_mois=0,comp_annees=0;
                for(i=0; i<strlen(chaine); i++) {
                        if(i<2) {
                                if(isdigit(chaine[i]))
                                        jour[i]=chaine[i];
                                else {
                                        verif=1;
                                        break;
                                }
                        } else {
                                if(i>2&&i<5) {
                                        if(isdigit(chaine[i])) {
                                                mois[comp_mois]=chaine[i];
                                                comp_mois++;
                                        } else {
                                                verif=1;
                                                break;
                                        }
                                } else  {
                                        if(i>5) {
                                                if(isdigit(chaine[i])) {
                                                        annee[comp_annees]=chaine[i];
                                                        comp_annees++;
                                                } else {
                                                        verif=1;
                                                        break;
                                                }
                                        }
                                }
                        }
                }
                if(!strtol(jour,NULL,10)||!strtol(mois,NULL,10)||!strtol(annee,NULL,10)) {
                        verif=1;
                }else{
                if(strtol(jour,NULL,10)>31||strtol(mois,NULL,10)>12)    verif=1;
                }
                
        }
        return  verif;
}
/***verifie l'existence d'un attribut dans une table*/
int verifier_attribut(char*nom_table,char*nom_champ)
{
        char  nom_tempon[50];
        strcpy(nom_tempon,nom_table);
        int teste=0;
        xmlDocPtr   doc=xmlParseFile(strcat(nom_tempon,".xml"));
        xmlNodePtr  racine  =xmlDocGetRootElement(doc);
        attribut*  liste=(attribut*)malloc(sizeof(attribut));
        liste->attribut_suivant=NULL;
        recuperer_structure_table(nom_table,racine,&liste);
        while(liste->attribut_suivant!=NULL) {
                if(!strcasecmp(liste->nom_attribut,nom_champ)) {
                        teste=1;
                        break;
                }
                liste=liste->attribut_suivant;
        }
        return  teste;
}
/******commande update sans la clause where*****/
int   commande_update_sans_where(char*nom_table,char*nom_champ,char* valeur)
{//lorsque la clause where est abscente,tous les records sont mis à jour 
        char    nom_tempon[50];
        char    type_attribut[15];
        strcpy(nom_tempon,nom_table);
        attribut* structure_table=(attribut*)malloc(sizeof(attribut));
        structure_table->attribut_suivant=NULL;
        int verif=0;
        int nb_tuples=0;//compteur du nombres de tuples mis à jour
        si_table_existe(nom_table,retourne_racine(),&verif);
        if(!verif)  message_d_erreur("La table n'existe pas");//si la table est inexistante
        else {
                if(!verifier_attribut(nom_table,nom_champ)) message_d_erreur("Le champ entré n'existe pas");
                else {
                        xmlDocPtr  doc = xmlParseFile(strcat(nom_tempon,".xml"));//parsing du fichier en memoire
                        xmlNodePtr  racine=xmlDocGetRootElement(doc);//recuperation de la racine du document
                        recuperer_structure_table(nom_table,racine,&structure_table);/**recuperation de la structure de la table
                        pour en extraire le type de l'attribut**/
                         while(structure_table->attribut_suivant!=NULL) {
                                if(!strcmp(structure_table->nom_attribut,nom_champ)) {
                                        strcpy(type_attribut,structure_table->type_attribut);
                                        break;
                                }
                                structure_table=structure_table->attribut_suivant;
                        }
                        if(!strcmp(type_attribut,"integer")) {
                                if(!strtol(valeur,NULL,10)&&strlen(valeur)!=1) {
                                        /***si le type est un entier et la valeur entrée  n'est pas une valeur entiere**/
                                        printf("Le champ %s est de type integer,la valeur de remplacement n'est pas entier",nom_champ);
                                        return EXIT_FAILURE;
                                } else {
                                       
                                        //execution du code de remplacement pour le type integer
                                       
                                        cherche_record(doc,nom_table,nom_champ,racine,valeur,&nb_tuples);
                                }
                        } else {
                                if(!strcmp(type_attribut,"date")) {/***si l'attribut est de type date***/
                                        if(verifier_date(valeur)) {
                                                printf("Le champ   %s   est de type date,la date entrée n'est pas valide",nom_champ);
                                                return EXIT_FAILURE;
                                        } else {
                                            
                                               // execution du code de remplacement  pour le type date
                                               
                                                cherche_record(doc,nom_table,nom_champ,racine,valeur,&nb_tuples);
                                        }
                                } else { /**si l'attribut   est de type  text**/
                                        
                                        // execution du code de remplacement  pour le type text
                                        
                                        cherche_record(doc,nom_table,nom_champ,racine,valeur,&nb_tuples);
                                }

                        }

                }
        }
printf("%d ligne(s) mise(s) à jour\n",nb_tuples);
}
/****parcours tous les records de la table pour la mise a jour****/
void  cherche_record(xmlDocPtr doc,char*nom_table,char*nom_champ,xmlNodePtr racine,char*valeur,int* nb_tuples)
{// parcours tous les enregistrement d'une table et les passe a la fonction de mise à jour 
        xmlNodePtr  cur_node=NULL;
        for(cur_node=racine; cur_node; cur_node=cur_node->next) {
                if(cur_node->type==XML_ELEMENT_NODE) {
                        if(!strcmp((char*)cur_node->name,"record")) {/**si le noeud courant est un enregistrement**/
                                /**appel de la fonction de remplacement*/
                                maj_valeur_attribut(doc,cur_node,nom_table,nom_champ,valeur,nb_tuples);//appel de la fonction de mise à jour
                        }
                }
                cherche_record(doc,nom_table,nom_champ,cur_node->children,valeur,nb_tuples);//appel recursif
        }
}
/***met a jour un ligne d'un enregistrement***/
void    maj_valeur_attribut(xmlDocPtr doc,xmlNodePtr record,char* nom_table,char*nom_champ,char* valeur,int* nb_tuples)
{
        xmlNodePtr  cur_node=NULL;
        char  nom_tampon[50];
        strcpy(nom_tampon,nom_table);/**mise en tempon du nom de la table car elle strcat la modifie*/
        for(cur_node=record->children; cur_node; cur_node=cur_node->next) {
                if(cur_node->type==XML_ELEMENT_NODE) {
                        if(!strcmp((char*)cur_node->name,nom_champ)) {/**si le noeud courant est un enregistrement**/
                                /**appel de la fonction de remplacement*/
                                xmlNodeSetContent(cur_node,BAD_CAST valeur);//application de la modification
                                xmlSaveFile(strcat(nom_tampon,".xml"),doc);//sauvegarde des informations de la tables
                                *nb_tuples+=1;/**incrementation du nombre trouvé de tuples*/
                        }
                }
                maj_valeur_attribut(doc,cur_node->children,nom_table,nom_champ,valeur,nb_tuples);
        }
}
/***commande update avec la clause where**/
int   commande_update_avec_where(char*nom_table,char*nom_champ1,char*nom_champ2,char* valeur1,char*valeur2)
{
        char    nom_tempon[50];
        char    type_attribut1[15];
        char    type_attribut2[15];
        strcpy(nom_tempon,nom_table);
        attribut* structure_table=(attribut*)malloc(sizeof(attribut));
        structure_table->attribut_suivant=NULL;
        int verif=0;
        int nb_tuples=0;
        si_table_existe(nom_table,retourne_racine(),&verif);
        if(!verif)  message_d_erreur("La table n'existe pas");
        else {
	
                if(!verifier_attribut(nom_table,nom_champ1)||!verifier_attribut(nom_table,nom_champ2)) message_d_erreur("Le champ entré n'existe pas");
                else {
                        xmlDocPtr  doc = xmlParseFile(strcat(nom_tempon,".xml"));
                        xmlNodePtr  racine=xmlDocGetRootElement(doc);
                        recuperer_structure_table(nom_table,racine,&structure_table);/**recuperation de la structure de la table
                        pour en extraire le type de l'attribut**/
                        while(structure_table->attribut_suivant!=NULL) {
                                if(!strcmp(structure_table->nom_attribut,nom_champ1)) {
                                        strcpy(type_attribut1,structure_table->type_attribut);/**recuperation du type du premier champ*/
                                        break;
                                }
                                structure_table=structure_table->attribut_suivant;
                        }
                        recuperer_structure_table(nom_table,racine,&structure_table);/**on recupere une deuxieme fois la structure pour
                        l'extraction du type du second attribut*/
                        while(structure_table->attribut_suivant!=NULL) {
                                if(!strcmp(structure_table->nom_attribut,nom_champ2)) {
                                        strcpy(type_attribut2,structure_table->type_attribut);/**recuperation du type du premier champ*/
                                        break;
                                }
                                structure_table=structure_table->attribut_suivant;
                        }
                        if(!strcmp(type_attribut2,"integer")&&!strtol(valeur1,NULL,10)&&strlen(valeur2)!=1) {
                                /**si le champ de la clause  where
                                    est un  entier et la valeur de comparaison est d'un autre type*/
                                printf("Le champ %s de la clause WHERE est de type integer",nom_champ2);
                                return EXIT_FAILURE;

                        }
                        if(!strcmp(type_attribut2,"date")&&verifier_date(valeur2)) {
                                printf("Le champ %s de la clause WHERE est de type date",nom_champ2);
                                return EXIT_FAILURE;
                        }
                        if(!strcmp(type_attribut1,"integer")) {
                                if(!strtol(valeur1,NULL,10)&&strlen(valeur1)!=1) {
                                        /***si le type est un entier et la valeur entrée  n'est pas une valeur entiere**/
                                        printf("Le champ %s est de type integer,la valeur de remplacement n'est pas entier",nom_champ1);
                                        return;
                                } else {
                                        /***code de remplacement  de **/
                                   
                                      
                                        cherche_record2(doc,nom_table,nom_champ1,nom_champ2,racine,valeur1,valeur2,&nb_tuples);
                                }
                        } else {
                                if(!strcmp(type_attribut1,"date")) {/***si l'attribut est de type date***/
                                        if(verifier_date(valeur1)) {
                                                printf("Le champ   %s   est de type date,la date entrée n'est pas valide",nom_champ1);
                                                return;
                                        } else {

                                                /****code de  remplacement****/
                                                
                                                
                                                cherche_record2(doc,nom_table,nom_champ1,nom_champ2,racine,valeur1,valeur2,&nb_tuples);
                                        }
                                } else { /**si l'attribut   est de type  text**/
                                        /****code de remplacement****/
                                       
                                       
                                        cherche_record2(doc,nom_table,nom_champ1,nom_champ2,racine,valeur1,valeur2,&nb_tuples);
                                }

                        }

                }
        }
        printf("%d ligne(s) mise(s) à jour\n",nb_tuples);
}
/***version 2 de la fonction de recherche de noeud
elle appele la fonction de verification de la condition de la clause  where et execute la mise à jour***/
void  cherche_record2(xmlDocPtr doc,char*nom_table,char*nom_champ1,char*nom_champ2,xmlNodePtr racine,char*valeur1,char*valeur2 ,int* nb_tuples)
{
        xmlNodePtr  cur_node=NULL;
        int testeur=0;
        for(cur_node=racine; cur_node; cur_node=cur_node->next) {
                if(cur_node->type==XML_ELEMENT_NODE) {
                        if(!strcmp((char*)cur_node->name,"record")) {/**si le noeud courant est un enregistrement**/
                                /**appel de la fonction de remplacement*/
                                verifie_condition_where(cur_node,nom_champ2,valeur2,&testeur);
                                if(testeur){
                                        maj_valeur_attribut(doc,cur_node,nom_table,nom_champ1,valeur1,nb_tuples);
                                        testeur=0;
                                }
                        }
                }
                cherche_record2(doc,nom_table,nom_champ1,nom_champ2,cur_node->children,valeur1,valeur2,nb_tuples);
        }
}
/***verifie la condition de la clause where**/
void verifie_condition_where(xmlNodePtr racine,char*nom_champ,char*valeur,int*testeur)
{

        xmlNodePtr  cur_node=NULL;
        for(cur_node=racine->children; cur_node; cur_node=cur_node->next) {
                if(cur_node->type==XML_ELEMENT_NODE) {
                        if(!strcmp((char*)cur_node->name,nom_champ)) {/**si le noeud courant est un enregistrement**/
                                if(!strcmp((char*)xmlNodeGetContent(cur_node),valeur)) {
                                        *(testeur)=1;
                                        break;
                                }

                        }
                }
                verifie_condition_where(cur_node->children,nom_champ,valeur,testeur);
        }

}
/*supprime une table*/
void   commande_drop(char*nom_table)
{
        char  nom_tempon[50];
         strcpy(nom_tempon,nom_table);
        int verif=0;
        si_table_existe(nom_table,retourne_racine(),&verif);//teste d'existence de la table

        if(!verif)  message_d_erreur("La table n'existe pas!");
        else {
                xmlDocPtr   doc=xmlParseFile("metaDonnees.xml");
                xmlNodePtr  racine=xmlDocGetRootElement(doc);
                supprimer_table(nom_table,doc,racine);
                if(!remove(strcat(nom_tempon,".xml"))) printf("La table '%s' a été supprimée avec succes !!",nom_table);
        }
}
/*appeler par la commande drop pour la suppression d'une table*/
void    supprimer_table(char*nom_table,xmlDocPtr doc,xmlNodePtr racine)
{
        xmlNodePtr  cur_node=NULL;
        for(cur_node=racine; cur_node; cur_node=cur_node->next) {
                if(cur_node->type==XML_ELEMENT_NODE&&xmlGetProp(cur_node,BAD_CAST "name")!=NULL) {
                    if(!strcmp((char*)xmlGetProp(cur_node,BAD_CAST "name"),nom_table)){
                        xmlUnlinkNode(cur_node);
                        xmlSaveFile("metaDonnees.xml",doc);
                        break;
                    }
                }
                supprimer_table(nom_table,doc,cur_node->children);
        }
}

int commande_select(char*nom_table,char*nom_champ)/***commande permettant de  faire
la selection d'un  seul  champ*/
{
        int booleen=0;
        char nom_tempon[50];
        strcpy(nom_tempon,nom_table);/**mise en  tempon du nom de la table car strcat le modifie*/
        booleen=si_table_existe(nom_table,retourne_racine(),&booleen);/**teste  l'existence d'une table*/
        if(booleen!=1)  message_d_erreur("La  table entrée  n'existe pas");/**on teste d'abord si la table existe*/
        else {
                attribut*   liste;
                xmlDocPtr   doc=xmlParseFile(strcat(nom_tempon,".xml"));/**chargement de la table en memoire*/
                xmlNodePtr  racine=xmlDocGetRootElement(doc);/**recuperation de la racine du document*/
                liste=recuperer_structure_table(nom_table,racine,&liste);/**recuperation de la structure de la table
                lorsqu'elle existe*/
		int compteur=0; 
                while(liste->attribut_suivant!=NULL) {
                        /**on applique la fonction teste_egalite();  car la  taille du nom dans la liste ne tiens
                        pas compte    de  '\0'*/
                        if(!strcmp(liste->nom_attribut,nom_champ)) {/***on teste si l'existence du champ*/
                                /***code permettant de faire la selection****/
                                printf("RESULTAT DE LA SELECTION\n");
                                printf("\n%s\n",nom_champ);
                                affiche_selection(racine,nom_champ,&compteur);/**affichage du resultat de la selection*/
                                break;
                        }
                        liste=liste->attribut_suivant;
                }
                xmlFreeDoc(doc);//il   reste a gerer le  fait qu'un    attribut   n'existe pas ou  qu'aucune   données
                //n'a  été trouvée
        }

}
/*affiche le resultat d'une selection*/
void affiche_selection(xmlNodePtr racine,char*nom_champ,int*compteur)//affiche le resultat d'une selection
{
        xmlNodePtr cur_node = NULL;
        for(cur_node = racine; cur_node; cur_node = cur_node->next) {
                if (cur_node->type == XML_ELEMENT_NODE) {
                        if(!strcmp((char*)cur_node->name, nom_champ)) {
                                printf("%s\n",xmlNodeGetContent(cur_node));
                                *compteur+=1;//met le verificateur a 1 qui signifie existence d'au moins une donnée
                        }
                }
                affiche_selection(cur_node->children,nom_champ,compteur);//appel recursif de la fonction
        }
       
}
/**commande d'affichage de l'aide*/
void    commande_help(char*nom_commande)
{

        if(!strcasecmp(nom_commande,"op_select")) {//aide sur la commande select
                printf("aide sur la commande select\n\n"
                " La commande select permet d'effectuer la selection d'un ou de tous les champs d'une table\n\n"
                " Sa syntaxe est la suivante : \n\n"
                " Pour la selection d'un champ donné : SELECT|select nom_champ FROM|from nom_table\n\n"
                " Pour la selection de tous les champs : SELECT|select * FROM|from nom_table\n\n");
        } else {
                if(!strcasecmp(nom_commande,"op_insert")) {//aide sur la commande insert
                        printf("aide sur la commande insert\n\n"
                        " La commande insert permet d'inserer un record dans une table\n\n"
                        " Sa syntaxe est la suivante : \n\n"
                        " INSERT|insert INTO|into nom_table VALUES|values(val1,val2,........,valn)\n\n");
                } else {
                        if(!strcasecmp(nom_commande,"op_update")) {//aide sur la commande update
                                printf("aide sur la commande update\n\n"
                                " La commande update permet de mettre à jour les records d'une table\n\n"
                                " Sa syntaxe est la suivante : \n\n"
                                " UPDATE|update nom_table SET|set nom_attribut=valeur [WHERE|where nom_attribut=valeur]\n\n"
                                " Sans la clause where cette commande met à jour tous les records de la table nom_table\n\n");
                        } else {
                                if(!strcasecmp(nom_commande,"op_create")) {//aide sur la commande create
                                        printf("aide sur la commande create\n\n"
                                        " La commade create permet de créer une nouvelle table\n\n"
                                        " Sa syntaxe est la suivante : \n\n"
                                        " CREATE|create TABLE|table nom_table(val1 type,val2 type,..........,valn type)\n\n"
                                        " les types disponibles sont:integer,text et date\n\n");
                                } else {
                                        if(!strcasecmp(nom_commande,"op_delete")) {//aide sur la commande delete
                                                printf("aide sur la commande delete\n\n"
                                                " La commande delete permet de supprimer un record satisfaisant une condition\n\n"
                                                " Sa syntaxe est la suivante : \n\n"
                                                " DELETE|delete FROM|from nom_table WHERE|where nom_attribut =|!= valeur\n\n");
                                        } else {
                                                if(!strcasecmp(nom_commande,"op_drop")) {//aide sur la commande drop
                                                        printf("aide sur la commande drop\n\n"
                                                        " La commande drop supprime une table\n\n"
                                                        " Sa syntaxe est la suivante: \n\n"
                                                        " DROP|drop TABLE|table nom_table\n\n");
                                                } else {
                                                        if(!strcasecmp(nom_commande,"op_desc")) {//aide sur la commande desc
                                                                printf("aide sur la commande desc\n\n"
                                                                " La commande desc donne la description d'une table ie les champs et leurs types\n\n"
                                                                " Sa syntaxe est la suivante : \n\n"
                                                                " DESC|desc nom_table\n\n");
                                                        } else {
                                                                if(!strcasecmp(nom_commande,"op_alter")) {//aide sur la commande alter
                                                                        printf("aide sur la commande alter\n\n"
                                                                        " La commande alter modifie la structure d'une table\n\n"
                                                                        " Sa syntaxe est la suivante : \n\n"
                                                                        " Pour l'ajout d'un nouvel attribut : ALTER|alter TABLE|table nom_table ADD|add| nom_attribut type\n\n"
                                                                        " Pour la suppression d'un attribut : ALTER|alter TABLE|table nom_table REMOVE|remove nom_attribut\n\n");
                                                                } else {
                                                                        printf("La commande %s est introuvable",nom_commande);/*message affichée lorsque la commande saisie est introuvable*/
                                                                }
                                                        }
                                                }
                                        }
                                }
                        }
                }
        }
}
/**fonction permettant de faire la moyenne des valeurs d'un champ*/
int    fonction_avg(char*nom_table,char*nom_champ)
{
        char  nom_tempon[50]="";
        strcpy(nom_tempon,nom_table);
        int verif=0;
        attribut*  liste=(attribut*)malloc(sizeof(attribut));
        liste->attribut_suivant=NULL;
        si_table_existe(nom_table,retourne_racine(),&verif);
        if(!verif)message_d_erreur("La table entrée n'existe pas");
        else {
                if(!verifier_attribut(nom_table,nom_champ)) {
                        printf("Le champ %s n'existe pas dans la  table %s",nom_champ,nom_table);
                        return  EXIT_FAILURE;
                } else {
                        xmlDocPtr doc=xmlParseFile(strcat(nom_tempon,".xml"));
                        xmlNodePtr  racine=xmlDocGetRootElement(doc);
                        int nb_attributs=0;
                        int compteur=0;
                        chercher_nombre_attribut(nom_table,retourne_racine(),&nb_attributs);
                        recuperer_structure_table(nom_table,racine,&liste);
                        attribut** tableau_valeur=(attribut**)malloc(nb_attributs*sizeof(attribut*));
                        while(liste->attribut_suivant!=NULL){
                        tableau_valeur[compteur]=liste;
                        compteur++;
                        liste=liste->attribut_suivant;
                        }
                        for(compteur=nb_attributs-1;compteur>=0;compteur--) {
                                if(!strcmp(tableau_valeur[compteur]->nom_attribut,nom_champ)&&strcmp(tableau_valeur[compteur]->type_attribut,"integer")) {
                                        printf("Les champs consernés par la fonction d'agregation sont de type integer");
                                        return  EXIT_FAILURE;
                                }
                                if(!strcmp(tableau_valeur[compteur]->nom_attribut,nom_champ)&&!strcmp(tableau_valeur[compteur]->type_attribut,"integer")){
                                        /****code d'affichage de  la moyenne*/
                                        double somme_val=0;
                                        int nb_tuples=0;
                                        chercher_nombre_tuples(nom_table,retourne_racine(),&nb_tuples);
                                        somme(racine,nom_champ,&somme_val);
                                        printf("la moyenne est de  :%f",somme_val/nb_tuples);
                                        break;
                                }
					
                        }

                }
        }

}
/**parcours recursivement la table et somme les differentes valeurs trouvées*/
void    somme(xmlNodePtr racine,char*nom_champ,double* somme_val)
{
        xmlNodePtr cur_node=NULL;
        for(cur_node=racine; cur_node; cur_node=cur_node->next) {

                if(cur_node->type==XML_ELEMENT_NODE) {
                        if(!strcmp((char*)cur_node->name,nom_champ)) {
                                (*somme_val)+=atoi( (char*)xmlNodeGetContent(cur_node) );
                        }
                }
                somme(cur_node->children,nom_champ,somme_val);
        }
}
/**fonction permettant d'effectuer la somme de toutes les valeurs d'un champ contenues dans les records*/
int    fonction_sum(char*nom_table,char*nom_champ)
{
	char  nom_tempon[50]="";
        strcpy(nom_tempon,nom_table);
        int verif=0;
        attribut*  liste=(attribut*)malloc(sizeof(attribut));
        liste->attribut_suivant=NULL;
        si_table_existe(nom_table,retourne_racine(),&verif);
        if(!verif)message_d_erreur("La table enttrée n'existe pas");
        else {
                if(!verifier_attribut(nom_table,nom_champ)) {
                        printf("Le champ %s n'existe pas dans la  table %s",nom_champ,nom_table);
                        return  EXIT_FAILURE;
                } else {
                        xmlDocPtr doc=xmlParseFile(strcat(nom_tempon,".xml"));
                        xmlNodePtr  racine=xmlDocGetRootElement(doc);
                        int nb_attributs=0;
                        int compteur=0;
                        chercher_nombre_attribut(nom_table,retourne_racine(),&nb_attributs);
                        recuperer_structure_table(nom_table,racine,&liste);
                        attribut** tableau_valeur=(attribut**)malloc(nb_attributs*sizeof(attribut*));
                        while(liste->attribut_suivant!=NULL){
                        tableau_valeur[compteur]=liste;
                        compteur++;
                        liste=liste->attribut_suivant;
                        }
                        for(compteur=nb_attributs-1;compteur>=0;compteur--) {
                                if(!strcmp(tableau_valeur[compteur]->nom_attribut,nom_champ)&&strcmp(tableau_valeur[compteur]->type_attribut,"integer")) {
                                        printf("Les champs consernés par la fonction d'agregation sont de type integer");
                                        return  EXIT_FAILURE;
                                } 
                                if(!strcmp(tableau_valeur[compteur]->nom_attribut,nom_champ)&&!strcmp(tableau_valeur[compteur]->type_attribut,"integer")) {
                                        /****code d'affichage de  la somme*/
                                        double somme_val=0;
                                        somme(racine,nom_champ,&somme_val);
                                        printf("la somme est de  :%f",somme_val);
                                        break;
                                }
					
                        }

                }
        }
}
/**fonction permettant d'afficher la plus grande valeur d'un champ d'une table*/
int    fonction_max(char*nom_table,char*nom_champ)
{
	char  nom_tempon[50]="";
        strcpy(nom_tempon,nom_table);
        int verif=0;
        attribut*  liste=(attribut*)malloc(sizeof(attribut));
        liste->attribut_suivant=NULL;
        si_table_existe(nom_table,retourne_racine(),&verif);
        if(!verif)message_d_erreur("La table enttrée n'existe pas");
        else {
                if(!verifier_attribut(nom_table,nom_champ)) {
                        printf("Le champ %s n'existe pas dans la  table %s",nom_champ,nom_table);
                        return  EXIT_FAILURE;
                } else {
                        xmlDocPtr doc=xmlParseFile(strcat(nom_tempon,".xml"));
                        xmlNodePtr  racine=xmlDocGetRootElement(doc);
                        int nb_attributs=0;
                        int compteur=0;
                        chercher_nombre_attribut(nom_table,retourne_racine(),&nb_attributs);
                        recuperer_structure_table(nom_table,racine,&liste);
                        attribut** tableau_valeur=(attribut**)malloc(nb_attributs*sizeof(attribut*));
                        while(liste->attribut_suivant!=NULL){
                        tableau_valeur[compteur]=liste;
                        compteur++;
                        liste=liste->attribut_suivant;
                        }
                        for(compteur=nb_attributs-1;compteur>=0;compteur--) {
                                if(!strcmp(tableau_valeur[compteur]->nom_attribut,nom_champ)&&strcmp(tableau_valeur[compteur]->type_attribut,"integer")) {
                                        printf("Les champs consernés par la fonction d'aggregation sont de type integer");
                                        return  EXIT_FAILURE;
                                }
                                if(!strcmp(tableau_valeur[compteur]->nom_attribut,nom_champ)&&!strcmp(tableau_valeur[compteur]->type_attribut,"integer")) {
                                        /****code d'affichage de  la somme*/
                                        int val_max=2;
                                        retourne_premiere_valeur(racine,nom_champ,&val_max);
                                        max(racine,nom_champ,&val_max);//recherche du maximum dans la table
                                        printf("la valeur max est de :%d",val_max);
                                        break;
                                }
					
                        }

                }
        }
}
/**parcours la table recursivement pour comparer les valeurs en vue d'en selectionner la plus grande*/
void	max(xmlNodePtr racine,char* nom_champ,int*val_max){
	xmlNodePtr cur_node=NULL;
	for(cur_node=racine;cur_node;cur_node=cur_node->next){
		if(cur_node->type==XML_ELEMENT_NODE&&!strcmp((char*)cur_node->name,nom_champ)&&!strcmp(cur_node->parent->name,"record")){
			if((*val_max)<atoi((char*)xmlNodeGetContent(cur_node))){
				(*val_max)= atoi((char*)xmlNodeGetContent(cur_node));
			}
		}
		max(cur_node->children,nom_champ,val_max);
	}
}
/**parcours recursivement la table pour comparer les valeurs en vue d'en selectionner la plus petite*/
void	min(xmlNodePtr racine,char* nom_champ,int*val_min){
	xmlNodePtr cur_node=NULL;
	for(cur_node=racine;cur_node;cur_node=cur_node->next){
		if(cur_node->type==XML_ELEMENT_NODE&&!strcmp((char*)cur_node->name,nom_champ)&&!strcmp(cur_node->parent->name,"record")){
			if((*val_min)>atoi((char*)xmlNodeGetContent(cur_node))){
				(*val_min)= atoi((char*)xmlNodeGetContent(cur_node));
			}
		}
		min(cur_node->children,nom_champ,val_min);
	}
}
/**fonction permettant de retourner le minimum d'un champ d'une table*/
int    fonction_min(char*nom_table,char*nom_champ){
	char  nom_tempon[50]="";
        strcpy(nom_tempon,nom_table);
        int verif=0;
        attribut*  liste=(attribut*)malloc(sizeof(attribut));
        liste->attribut_suivant=NULL;
        si_table_existe(nom_table,retourne_racine(),&verif);
        if(!verif)message_d_erreur("La table enttrée n'existe pas");
        else {
                if(!verifier_attribut(nom_table,nom_champ)) {
                        printf("Le champ %s n'existe pas dans la  table %s",nom_champ,nom_table);
                        return  EXIT_FAILURE;
                } else {
                        xmlDocPtr doc=xmlParseFile(strcat(nom_tempon,".xml"));
                        xmlNodePtr  racine=xmlDocGetRootElement(doc);
                        int nb_attributs=0;
                        int compteur=0;
                        chercher_nombre_attribut(nom_table,retourne_racine(),&nb_attributs);
                        recuperer_structure_table(nom_table,racine,&liste);
                        attribut** tableau_valeur=(attribut**)malloc(nb_attributs*sizeof(attribut*));
                        while(liste->attribut_suivant!=NULL){
                        tableau_valeur[compteur]=liste;
                        compteur++;
                        liste=liste->attribut_suivant;
                        }
                        for(compteur=nb_attributs-1;compteur>=0;compteur--) {
                                if(!strcmp(tableau_valeur[compteur]->nom_attribut,nom_champ)&&strcmp(tableau_valeur[compteur]->type_attribut,"integer")) {
                                        printf("Les champs consernés par la fonction d'aggregation sont de type integer");
                                        return  EXIT_FAILURE;
                                } 
                                if(!strcmp(tableau_valeur[compteur]->nom_attribut,nom_champ)&&!strcmp(tableau_valeur[compteur]->type_attribut,"integer")){
                                        /****code d'affichage de  la somme*/
                                        int val_min=0;
                                        retourne_premiere_valeur(racine,nom_champ,&val_min);
                                        min(racine,nom_champ,&val_min);//recherche du minimum dans la table
                                        printf("la valeur min est de :%d",val_min);
                                        break;
                                }
					
                        }

                }
        }
}
/**permet de retourner la valeur d'un champ contenue dans le dernier record de la table*/
int retourne_premiere_valeur(xmlNodePtr racine,char*nom_champ,int*valeur){
	xmlNodePtr cur_node = NULL;
	for(cur_node=racine;cur_node;cur_node=cur_node->next){
		if(cur_node->type=XML_ELEMENT_NODE&&!strcmp((char*)cur_node->name,nom_champ)&&!strcmp(cur_node->parent->name,"record")){
			(*valeur)=atoi((char*)xmlNodeGetContent(cur_node));
			break;	
		}
		retourne_premiere_valeur(cur_node->children,nom_champ,valeur);
	}
}
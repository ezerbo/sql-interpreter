#ifndef SQF_H
# define SQF_H

#include <libxml/parser.h>//correspond au parseur de la librairie libxml2

typedef struct  attribut  attribut;
struct attribut {/**structure representant les attributs*/
        char   nom_attribut[50];
        char   type_attribut[50];
        struct  attribut*   attribut_suivant;
} ;
typedef struct  element element;
struct  element {
        /**structure  representant les element obtenu apres  le
            decoupage d'une chaine de caractere suivant les virgules*/
        char    valeur[50];
        struct  element*    element_suivant;
};
void creer_fichier_de_metaDonnees();/**cree  le  fichier de  metadonnees*/
attribut* ajouter_attribut(char*attr,char*type);/**ajoute  un  attribut dans   une*/
int inscrire_table(char* nom_table,char* nombre_attribut);/**inscrit une table   dans    les metadonnees*/
int creer_table(char* nom_table,attribut*  liste,char*chaine);/**cree une nouvelle table*/
int si_table_existe(char*  nom_table,xmlNodePtr racine,int*booleen);/**teste l'existence d'une table**/
int commande_insert(char * nom_table, char* values);/**commande permettant  l'insertion d'un tuple*/
void message_d_erreur(char*message);/**affiche un message d'erreur personnalisé*/
xmlNodePtr retourne_racine();/**retourne   la  racine  du  fichier de  metadonnees*/
int chercher_nombre_attribut(char*nom_table,xmlNodePtr racine,int* booleen);/**retourne le nombre d'attribut  d'une table*/
int chercher_nombre_tuples(char*nom_table,xmlNodePtr racine,int* booleen);/**retourne le nombre d'attribut  d'une table*/
element*  separe_valeur_inserees(char*chaine);/**separe   les diffrents   attributs   entrés  par l'utilisateur*/
attribut* retourne_liste_attribut(char*chaine);/**separe la  liste   des attributs   et  des types*/
attribut* recuperer_structure_table(char*nom_table,xmlNodePtr  racine,attribut**liste);/**recupere la structure d'une table*/
int inserer_tuple(char*nom_table,char*values,int nombre_champs);/**insere un tuple dans une table*/
xmlNodePtr maj_nombre_tuple(char*nom_table,xmlNodePtr  racine,xmlNodePtr* tuples);/**met à jour le nombre de tuples dans le fichier de  meta  donnees*/
xmlNodePtr maj_nombre_attribut(char*nom_table,xmlNodePtr  racine,xmlNodePtr* tuples);/**met à jour le nombre  d'attrbut dans le fichier de  meta  donnees*/
int commande_select_etoile(char*nom_table);/**effectue une selection sur un seul champ*/
int commande_select(char*nom_table,char* nom_champ);/****/
int selectionne_noeud(xmlNodePtr racine,char*nom_table,int*booleen);/**affiche le resultat d'une selection*/
int commande_delete(char*nom_table,char*operateur,char*nom_champ,char*valeur);/**suppression de tuples satisfaisant une condition*/
int commande_alter(char*nom_table,char*nom_champ,char*nom_operation);/**commande modifiant la structure d'une  table*/
int ajouter_champ(xmlDocPtr doc,xmlNodePtr racine,char*nom_table,char*attribut_type);/**ajoute un attribut à une table*/
int supprimer_champ(xmlDocPtr doc,xmlNodePtr  racine,char*nom_table,char*attrib);/**supprime un attribut d'une  table*/
int supprimer_enregistrement(xmlDocPtr doc,xmlNodePtr  racine,char*nom_table,char*nom_champ,char*valeur,char*operateur,int*nombre_tuples);/**supprime un enregistrement*/
void retourne_fils_struct(xmlNodePtr noeud_struct,attribut**liste);
void appel_sup_enreg(xmlDocPtr doc,xmlNodePtr racine,char*nom_table,char*nom_champ,char*valeur,char*operateur,int compteur);
xmlNodePtr retourne_noeud_a_supprimer(xmlNodePtr racine,char*valeur,char*nom_champ,xmlNodePtr* noeud,char*aperateur);/**retourne l'adresse*/
int commande_desc(char* nom_table);/**affiche la structure d'une table */
void affiche_resultat_selection(xmlNodePtr racine,char* nom_table);
int verifier_date(char*chaine);
int verifier_attribut(char*nom_table,char*nom_champ);
int commande_update_sans_where(char*nom_table,char*nom_champ,char* valeur);
int commande_update_avec_where(char*nom_table,char*nom_champ1,char*nom_champ2,char* valeur1,char*valeur2);
void cherche_record(xmlDocPtr doc,char*nom_table,char*nom_champ,xmlNodePtr racine,char*valeur,int* nb_tuples);
void maj_valeur_attribut(xmlDocPtr doc,xmlNodePtr record,char*nom_table,char*nom_champ,char*valeur,int* nb_tuples);
void cherche_record2(xmlDocPtr doc,char*nom_table,char*nom_champ1,char*nom_champ2,xmlNodePtr racine,char*valeur1,char*valeur2,int* nb_tuples);
void maj_valeur_attribut2(xmlDocPtr doc,xmlNodePtr record,char*nom_table,char*nom_champ1,char*nom_champ2,char*valeur1,char*valeur2);
void verifie_condition_where(xmlNodePtr racine,char*nom_champ,char*valeur,int*testeur);
void commande_drop(char*nom_table);/**realise l'appel a supprimer_table*/
void supprimer_table(char*nom_table,xmlDocPtr doc,xmlNodePtr racine);//suppression d'une table 
void affiche_selection(xmlNodePtr racine,char*nom_champ,int*compteur); 
void commande_help(char*nom_commande);
int fonction_avg(char*nom_table,char*nom_champ);
void somme(xmlNodePtr racine,char*nom_champ,double* somme_val);
int fonction_sum(char*nom_table,char*nom_champ);
int fonction_max(char*nom_table,char*nom_champ);
int fonction_min(char*nom_table,char*nom_champ);
void max(xmlNodePtr racine,char* nom_champ,int*val_max);
void min(xmlNodePtr racine,char* nom_champ,int*val_min);
int retourne_premiere_valeur(xmlNodePtr racine,char*nom_champ,int*valeur);
#endif

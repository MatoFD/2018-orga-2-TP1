#include <stdbool.h>
#include <stdio.h>
#include "string_processor.h"
#include "string_processor_utils.h"
#include <limits.h>
#include <math.h>


//TODO: debe implementar
/**
*	Debe devolver el largo de la lista pasada por parámetro
*/
uint32_t string_proc_list_length(string_proc_list* list){ 

	if (list->first == NULL) {return 0;}

	uint32_t rta = 0;
	string_proc_node *prox = list->first;
	while (prox != NULL) {
		++rta;
		prox = prox->next;
	}

	return rta;

return 0;
}

//TODO: debe implementar
/**
*	Debe insertar el nodo con los parámetros correspondientes en la posición indicada por index desplazando en una
*	posición hacia adelante los nodos sucesivos en caso de ser necesario, la estructura de la lista debe ser
*	actualizada de forma acorde
*	si index es igual al largo de la lista debe insertarlo al final de la misma
*	si index es mayor al largo de la lista no debe insertar el nodo
*	debe devolver true si el nodo pudo ser insertado en la lista, false en caso contrario
*/
bool string_proc_list_add_node_at(string_proc_list* list, string_proc_func f, string_proc_func g, string_proc_func_type type, uint32_t index){ 

	if (index > string_proc_list_length(list)) {return false;}
	else {
		string_proc_node *nodo = string_proc_node_create(f,g,type);
		
		string_proc_node *lugar = list->first;	
		while (index>0) {
			lugar = lugar->next;
			--index;
		}
		if (list->first==NULL){
			list->first=nodo;
			list->last=nodo;
		} else {

			if (lugar==NULL){
                                nodo->previous=list->last;
                                list->last=nodo;
                                nodo->previous->next=nodo;
                        }else if (lugar->previous == NULL){ //si es el 1er elem
				list->first=nodo;
				nodo->next=lugar;
				lugar->previous=nodo;
			}else{
				nodo->previous=lugar->previous;
				nodo->next=lugar;
				lugar->previous->next=nodo;
				lugar->previous=nodo;
			}
		}
	}
	return true;
 }

//TODO: debe implementar
/**
*	Debe eliminar el nodo que se encuentra en la posición indicada por index de ser posible
*	la lista debe ser actualizada de forma acorde y debe devolver true si pudo eliminar el nodo o false en caso contrario
	Lo voy a hacer para que con el indice 0 borre el primer elemento.
*/
bool string_proc_list_remove_node_at(string_proc_list* list, uint32_t index){

	uint32_t length = string_proc_list_length(list);
	if (index > length ) {return false;}
	else {
		string_proc_node *actual = list->first;
		while (index>0) {
			actual = actual->next;
			--index;	
		}
		if (length == 1) {
			list->first = NULL;
			list->last = NULL;
		} else 	if (list->first == actual) {
				list->first = actual->next;
				actual->next->previous = NULL;
			}else if (list->last == actual) {
					list->last = actual->previous;
					actual->previous->next = NULL;
				}else {
					actual->previous->next = actual->next;
		               		 actual->next->previous = actual->previous;
			}

		string_proc_node_destroy(actual);

		return true;
	} 	
	return false;
 }

//TODO: debe implementar
/**
*	Debe devolver una copia de la lista pasada por parámetro copiando los nodos en el orden inverso
*/
string_proc_list* string_proc_list_invert_order(string_proc_list* list){ 

	string_proc_list *nueva = string_proc_list_create("nueva");

	//voy a recorrer la original de atras para adelante, y cada nodo uso add_node con la nueva, lo que le agrega una copia del nodo al final, asi queda al reves.

	string_proc_node *pseudoIt = list->last;
	while (pseudoIt != NULL) {
		string_proc_list_add_node(nueva,pseudoIt->f,pseudoIt->g,pseudoIt->type);

		pseudoIt=pseudoIt->previous;
	}	

	return nueva;
 }

//TODO: debe implementar
/**
*	Hace una llamada sucesiva a los nodos de la lista pasada por parámetro siguiendo la misma lógica
*	que string_proc_list_apply pero comienza imprimiendo una línea 
*	"Encoding key 'valor_de_la_clave' through list nombre_de_la_list\n"
* 	y luego por cada aplicación de una función f o g escribe 
*	"Applying function at [direccion_de_funcion] to get 'valor_de_la_clave'\n"
*/
void string_proc_list_apply_print_trace(string_proc_list* list, string_proc_key* key, bool encode, FILE* file){

	fprintf(file, "Encoding key %s through list %s \n",key->value,list->name);

	string_proc_node *actual;
	if (encode) {
		actual=list->first;
	} else {
		actual=list->last;
	}

	while(actual != NULL){

		if (encode){
			actual->f(key);
			fprintf(file, "Applying function at %p to get %s \n", (void*) &actual->f ,key->value);
		}else{
			actual->g(key);
			fprintf(file, "Applying function at %p to get %s \n", (void*) &actual->g ,key->value);
		}

		if (encode) {
			actual = actual->next;
		} else {
			actual = actual->previous;
		}
	}

	return;
}

//TODO: debe implementar
/**
*	Debe desplazar en dos posiciones hacia adelante el valor de cada caracter de la clave pasada por parámetro
*	si el mismo se encuentra en una posición impar, resolviendo los excesos de representación por saturación
*/
void saturate_2_odd(string_proc_key* key){

	for (uint32_t i=0; key->value[i] != 0; ++i){ 
		if (2*(i/2)!=i){
			if(key->value[i]>CHAR_MAX-2){
				key->value[i]=CHAR_MAX;
			}else{
				key->value[i] = key->value[i]+2;
			}
		}
	}
	return;
}

//TODO: debe implementar
/**
*	Debe desplazar en dos posiciones hacia atrás el valor de cada caracter de la clave pasada por parámetro
*	si el mismo se encuentra en una posición impar, resolviendo los excesos de representación por saturación
*/
void unsaturate_2_odd(string_proc_key* key){
	
	for (uint32_t i=0; key->value[i] != 0; ++i){
        if (2*(i/2)!=i){
            if(key->value[i]<CHAR_MIN+2){
				key->value[i]=CHAR_MIN;
			}else{
				key->value[i] = key->value[i]-2;
            }
        }
    }
    return;
}

bool es_primo(uint32_t num){

	if (num<2){return false;}

	for(uint32_t i=2;i<num;++i){
		if ((num/i)*i==num){return false;}
	}
	return true;
}

//TODO: debe implementar
/**
*	Debe desplazar en tantas posiciones como sea la posición hacia adelante del valor de cada caracter de la clave pasada por parámetro
*	si el mismo se encuentra en una posición que sea un número primo, resolviendo los excesos de representación con wrap around
*/
void shift_position_prime(string_proc_key* key){

	for(uint32_t i=0; key->value[i] != 0; ++i){
		if (es_primo(i)){
			if ((int32_t) key->value[i]+ (int32_t)i> (int32_t)CHAR_MAX){
				key->value[i] = CHAR_MIN+(i-(CHAR_MAX - key->value[i]) -1);
			}else{
				key->value[i] = key->value[i]+i;
			}
		}
	}
	return;
}

//TODO: debe implementar
/**
*	Debe desplazar en tantas posiciones como sea la posición hacia atrás del valor de cada caracter de la clave pasada por parámetro
*	si el mismo se encuentra en una posición que sea un número primo, resolviendo los excesos de representación con wrap around
*/
void unshift_position_prime(string_proc_key* key){
	
	for(uint32_t i=0; key->value[i] != 0; ++i){
		if (es_primo(i)){

			if ((int32_t) key->value[i]- (int32_t) i < (int32_t) CHAR_MIN){
				key->value[i] = CHAR_MAX - (i-(key->value[i] - CHAR_MIN));
			}else{
				key->value[i] = key->value[i]-i;
			}
		}
	}
	return;
}

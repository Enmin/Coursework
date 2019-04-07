#include "SortedList.h"
#include <stdio.h>
#include <sched.h>
#include <string.h>

void SortedList_insert(SortedList_t *list, SortedListElement_t *element) {
	SortedList_t *root = list;
	SortedList_t *temp = list->next;

	while (temp != root) {
		if (strcmp(element->key, temp->key) <= 0) {
			break;
		}
		
	    if (opt_yield & INSERT_YIELD){
	    	sched_yield();
		}
		temp = temp->next;
	}

	element->prev = temp->prev;
	element->next = temp;
	temp->prev->next = element;
	temp->prev = element;
}

int SortedList_delete( SortedListElement_t *element){
    SortedListElement_t *temp = element->next;
    if (temp->prev!=element){
        return 1;
	}
        
    temp=element->prev;
    if (temp->next!=element){
        return 1;
	}
    
    if (opt_yield & DELETE_YIELD){
        sched_yield();
	}
      
    element->next->prev = element->prev;
    element->prev->next = element->next;
    return 0;
}


SortedListElement_t *SortedList_lookup(SortedList_t *list, const char *key){
    SortedListElement_t *temp = list;
    while ((strcmp(temp->next->key, key) != 0)&&(temp->next->key!=NULL)){
        temp=temp->next;
        if (opt_yield & LOOKUP_YIELD){
            sched_yield();
		}    
    }
    if (strcmp(temp->next->key, key) == 0){
        return temp->next;
	}
    else{ 
        return NULL;
	}
}

int SortedList_length(SortedList_t *list){
	if(list == NULL){
		return -1;
	}
    int count =0;
    SortedListElement_t *temp = list;
    SortedListElement_t *tempprev = NULL;
    SortedListElement_t *tempnext = temp->next;
    
    while(temp->next->key!=NULL){
        count++;

        if((tempprev!=NULL)&&(tempprev->next!=temp)){
            return -1;
		}
        if((tempnext!=NULL)&&(tempnext->prev!=temp)){
            return -1;
		}
        
        if (opt_yield & LOOKUP_YIELD){
            sched_yield();
		}

		temp=temp->next;
		tempprev = temp->prev;   
		tempnext = temp->next;       
    }
    return count;
}

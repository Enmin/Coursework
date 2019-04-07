#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <getopt.h>
#include <pthread.h>
#include <time.h>
#include <sched.h>
#include <errno.h>
#include <string.h>
#include <signal.h>
#include "SortedList.h"

long long threads = 1;
long long iterations = 1;
char sync_type = 'n';
int opt_yield = 0;
char* yield = NULL;
SortedList_t *list;
SortedListElement_t **element;
SortedList_t **sublist;
char* pool = "abcdefghijklmnopqrstuvwxyz";
int keylength = 5;
int list_num = 1;
long long* spin_locks;
pthread_mutex_t* mutex_locks;
long long num;

//function declaration
void check_args();
void locks_init();
void lists_init();
void *run_threads();
void signal_handler();
long long thread_wait_time[32] = {0};
int* list_holder;

int main(int argc, char **argv){
	check_args(argc, argv);
	long long wait_for_lock_time = 0;
	struct timespec start;
	struct timespec end;
	int i;
	signal(SIGSEGV, signal_handler);
	
	locks_init();
	int* index = malloc(threads * sizeof(int));
	pthread_t* tid = (pthread_t*)malloc(sizeof(pthread_t) * threads);

	lists_init();

	clock_gettime(CLOCK_MONOTONIC, &start);
	for(i = 0; i < threads; i++){
		//printf("thread %d starts\n", i);
		index[i] = i;
		int r = pthread_create(&tid[i], NULL, run_threads, &index[i]);
		if(r != 0){
			fprintf(stderr, "pthread_create fault");
			exit(1);
		}
	}
	for(i = 0; i < threads; i++){
		int r = pthread_join(tid[i], NULL);
		if(r != 0){
			fprintf(stderr, "pthread_join fault");
			exit(1);
		}
	}
	clock_gettime(CLOCK_MONOTONIC, &end);

	/*
	if (SortedList_length(list) != 0){
		fprintf(stderr, "list corrupted!\n");
		exit(2);
	}
	*/
	
	free(element);
	free(tid);
	free(index);
	free(sublist);
	free(list);
	free(list_holder);

	for (i = 0; i < threads; i++){
		wait_for_lock_time += thread_wait_time[i];
	}

	long long duration = (end.tv_sec - start.tv_sec)*1000000000;
	duration += end.tv_nsec;
	duration -= start.tv_nsec;
	long long performance = threads * iterations * 3;
	printf("list-");
	if(yield == NULL){
		printf("none-");
	}
	else{
		printf("%s-", yield);
	}
	if(sync_type == 'n'){
		printf("none");
	}
	else{
		printf("%c", sync_type);
	}
	printf(",%lld,%lld,%d,%lld,%lld,%lld,%lld\n", threads, iterations, list_num, performance, duration, duration/performance, wait_for_lock_time);
	exit(0);
}

void *run_threads(void* arg){
	long long startpos = ((*(int *)arg)*iterations);
	long long endpos = startpos+iterations;
	//printf("startpos: %lld endpos: %lld\n", startpos, endpos);
	long long listlength = 0;
	long long sublistlength = 0;
    long long which_list = 0;
    struct timespec startwaittime;
	struct timespec endwaittime;
	long long i;
	int k;
	for(i = startpos; i < endpos; i++){
		which_list = list_holder[i];

		clock_gettime(CLOCK_MONOTONIC, &startwaittime);
		if (sync_type == 'm'){
			pthread_mutex_lock(&mutex_locks[which_list]);
		}
		else if (sync_type == 's'){
			while(__sync_lock_test_and_set(&(spin_locks[which_list]), 1));
        }
		clock_gettime(CLOCK_MONOTONIC, &endwaittime);
		SortedList_insert(sublist[which_list], element[i]);

		if (sync_type == 'm'){
			pthread_mutex_unlock(&mutex_locks[which_list]);
		}
		else if (sync_type == 's'){
			__sync_lock_release(&spin_locks[which_list]);
		}
		thread_wait_time[*(int*)arg] += endwaittime.tv_nsec - startwaittime.tv_nsec + 1000000000*(endwaittime.tv_sec - startwaittime.tv_sec);
	}

	clock_gettime(CLOCK_MONOTONIC, &startwaittime);
	if (sync_type == 'm'){
        for(k = 0; k < list_num; k++){
            pthread_mutex_lock(&mutex_locks[k]);
        }
    }
    else if (sync_type == 's'){
        for(k = 0; k < list_num; k++){
    	    while(__sync_lock_test_and_set(&(spin_locks[k]), 1));
        }   
    }
    clock_gettime(CLOCK_MONOTONIC, &endwaittime);
    for (k = 0; k < list_num; k++){
        sublistlength = 0;
        sublistlength = SortedList_length(sublist[k]);
        if (sublistlength < 0){
    	    fprintf(stderr, "length: list corrupted!\n");
    	    exit(2);
        }
        listlength += sublistlength;
    }
    if (sync_type == 'm'){
        for(k = 0; k < list_num; k++){
            pthread_mutex_unlock(&mutex_locks[k]);
        }
    }
    else if (sync_type == 's'){
        for(k = 0; k < list_num; k++){
			__sync_lock_release(&spin_locks[k]);
        }   
    }
	thread_wait_time[*(int*)arg] += endwaittime.tv_nsec - startwaittime.tv_nsec + 1000000000*(endwaittime.tv_sec - startwaittime.tv_sec);

	for(i = startpos; i < endpos; i++){
		SortedListElement_t* d;
		which_list = list_holder[i];

    	clock_gettime(CLOCK_MONOTONIC, &startwaittime);
		if (sync_type == 'm'){
			pthread_mutex_lock(&mutex_locks[which_list]);
		}
		else if (sync_type == 's'){
			while(__sync_lock_test_and_set(&(spin_locks[which_list]), 1));
        }
    	clock_gettime(CLOCK_MONOTONIC, &endwaittime);
		d = SortedList_lookup(sublist[which_list], element[i]->key);
		if(d == NULL){
			fprintf(stderr, "lookup: list corrupted\n");
			exit(2);
		}
		if(SortedList_delete(d)){
			fprintf(stderr, "delete: list corrupted\n");
			exit(2);
		}
		if (sync_type == 'm'){
			pthread_mutex_unlock(&mutex_locks[which_list]);
		}
		else if (sync_type == 's'){
			__sync_lock_release(&spin_locks[which_list]);
		}
		thread_wait_time[*(int*)arg] += endwaittime.tv_nsec - startwaittime.tv_nsec + 1000000000*(endwaittime.tv_sec - startwaittime.tv_sec);
	}

	return NULL;
}

void signal_handler(){
	fprintf (stderr, "Segmentation fault caught.yield:%s threads:%lld iterations:%lld, sync:%c, sublist:%d\n", yield, threads,iterations,sync_type,list_num);
	exit(2);
}

void locks_init(){
	if(sync_type == 'm'){
		int i;
		mutex_locks = malloc(sizeof(pthread_mutex_t)*list_num);
		for(i = 0; i < list_num; i++){
			pthread_mutex_init(&mutex_locks[i], NULL);
		}
	}
	else if(sync_type == 's'){
		int i;
		spin_locks = malloc(sizeof(long long)*list_num);
		for(i = 0; i < list_num; i++){
			spin_locks[i] = 0;
		}
	}
}

void lists_init(){
	num  = threads * iterations;
	list = malloc(sizeof(SortedList_t));
	list->prev = list;
	list->next = list;
	list->key = NULL;
	
	sublist = malloc(list_num * sizeof(SortedList_t));
	int i;
	for(i = 0;i < list_num; i++){
		sublist[i] = malloc(sizeof(SortedList_t));
		sublist[i]->prev = sublist[i];
		sublist[i]->next = sublist[i];
		sublist[i]->key = NULL;
	}

	element = malloc(sizeof(SortedListElement_t*) * num);

	long long l;
	for(l = 0; l < num; l++){
		element[l] = malloc(sizeof(SortedListElement_t*));
		element[l]->prev = NULL;
		element[l]->next = NULL;

		char* temp = malloc(sizeof(char)*(keylength+1));
		int j;
		for(j = 0; j < keylength; j++){
			temp[j] = pool[rand() % strlen(pool)];
		}
		temp[keylength]='\0';
		element[l]->key = temp;
		//printf("element %lld passed: %s\n", l, temp);
	}
	
	list_holder = malloc(num * sizeof(int));
	for(i = 0;i < num; i++){
		list_holder[i] = (long long)(element[i]->key) % list_num;
	}
}

void check_args(int argc, char **argv){
	int opt;
	int option_index=0;
	char *string = "a::";
	static struct option long_options[] = {
		{"threads",  required_argument, NULL,'t'},
		{"iterations",  required_argument, NULL,'i'},
		{"yield",  required_argument, NULL,'y'},
		{"sync",  required_argument, NULL,'s'},
		{"lists", required_argument, NULL,'l'},
		{0, 0, 0, 0}
	};
	
	int is_right = 0;

	while((opt=getopt_long(argc,argv,string,long_options,&option_index))!= -1){
		/*
		printf("opt = %c\t\t", opt);
		printf("optarg = %s\t\t",optarg);
		printf("optind = %d\t\t",optind);
		printf("argv[optind] =%s\t\t", argv[optind-1]);
		printf("option_index = %d\n",option_index); //for debug use 
		*/
		if(opt == 't'){
			threads = atoi(optarg);
		}
		else if(opt == 'i'){
			iterations = atoi(optarg);
		}
		else if(opt == 'y'){
			yield = optarg;
			unsigned int i;
			for(i = 0; i <strlen(yield); i++){
				if(yield[i] == 'i'){
					opt_yield |= INSERT_YIELD;
				}
				else if(yield[i] == 'd'){
					opt_yield |= DELETE_YIELD;
				}
				else if(yield[i] == 'l'){
					opt_yield |= LOOKUP_YIELD;
				}
				else{
					fprintf(stderr, "wrong yield argument\n");
					exit(1);
				}
			}
		}
		else if(opt == 's'){
			sync_type = optarg[0];
			if(sync_type != 'm' && sync_type != 's'){
				fprintf(stderr, "wrong sync argument\n");
				exit(1);
			}
		}
		else if(opt == 'l'){
			list_num = atoi(optarg);	
		}
		else{
			is_right++;
			break;
		}
	}
	
	if(is_right > 0){
		fprintf(stderr,"Invalid Arugments, correct usage: ./lab2_list [--thread=#] [--iterations=#] [--yield] [--sync=m|s] [--lists=#]\n");
		exit(1);
	}
}

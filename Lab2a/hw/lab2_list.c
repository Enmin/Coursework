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
pthread_mutex_t lock = PTHREAD_MUTEX_INITIALIZER;
long long spin_lock = 0;
SortedList_t *list;
SortedListElement_t **element;
char* pool = "abcdefghijklmnopqrstuvwxyz";
int keylength = 5;

void check_args(int argc, char **argv){
	int opt;
	int option_index=0;
	char *string = "a::";
	static struct option long_options[] = {
		{"threads",  required_argument, NULL,'t'},
		{"iterations",  required_argument, NULL,'i'},
		{"yield",  required_argument, NULL,'y'},
		{"sync",  required_argument, NULL,'s'},
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
		else{
			is_right++;
			break;
		}
	}
	
	if(is_right > 0){
		fprintf(stderr,"Invalid Arugments, correct usage: ./lab2_list [--thread=#] [--iterations==#] [--yield] [--sync=m|s]\n");
		exit(1);
	}
}

void *run_threads(void* arg){
	long long startpos = ((*(int *)arg)*iterations);
	long long endpos = startpos+iterations;
	//printf("startpos: %lld endpos: %lld\n", startpos, endpos);
	long long length = 0;
	long long i;
	switch(sync_type){
		case 'n':
		{
			for(i = startpos; i < endpos; i++){
				SortedList_insert(list, element[i]);
			}
			
			length = SortedList_length(list);
			//printf("length = %lld\n", length);
			if(length == -1){
				fprintf(stderr, "list corrupted in insert\n");
				exit(2);
			}

			SortedListElement_t* d;
			for(i = startpos; i < endpos; i++){
				d = SortedList_lookup(list, element[i]->key);
				if(d == NULL){
					fprintf(stderr, "list corrupted in lookup\n");
					exit(2);
				}
				if(SortedList_delete(d) == -1){
					fprintf(stderr, "list corrupted in delete\n");
					exit(2);
				}
			}
			break;
		}
		case 'm':
		{
			pthread_mutex_lock(&lock);
			for(i = startpos; i < endpos; i++){
				SortedList_insert(list, element[i]);
			}
			
			length = SortedList_length(list);
			//printf("length = %lld\n", length);
			if(length == -1){
				fprintf(stderr, "list corrupted in insert\n");
				exit(2);
			}

			SortedListElement_t* d;
			for(i = startpos; i < endpos; i++){
				d = SortedList_lookup(list, element[i]->key);
				if(d == NULL){
					fprintf(stderr, "list corrupted in lookup\n");
					exit(2);
				}
				if(SortedList_delete(d) == -1){
					fprintf(stderr, "list corrupted in delete\n");
					exit(2);
				}
			}
			pthread_mutex_unlock(&lock);
			break;
		}
		case 's':
		{
			while(__sync_lock_test_and_set(&spin_lock, 1));
			for(i = startpos; i < endpos; i++){
				SortedList_insert(list, element[i]);
			}
			
			length = SortedList_length(list);
			//printf("length = %lld\n", length);
			if(length == -1){
				fprintf(stderr, "list corrupted in insert\n");
				exit(2);
			}

			SortedListElement_t* d;
			for(i = startpos; i < endpos; i++){
				d = SortedList_lookup(list, element[i]->key);
				if(d == NULL){
					fprintf(stderr, "list corrupted in lookup\n");
					exit(2);
				}
				if(SortedList_delete(d) == -1){
					fprintf(stderr, "list corrupted in delete\n");
					exit(2);
				}
			}
			__sync_lock_release(&spin_lock);
			break;
		}
		default:
		{
			break;
		}
	}
	return NULL;
}

void signal_handler(){
	fprintf (stderr, "Segmentation fault caught.yield:%s threads:%lld iterations:%lld, sync:%c\n", yield, threads,iterations,sync_type);
	exit(2);
}

int main(int argc, char **argv){
	check_args(argc, argv);
	signal(SIGSEGV, signal_handler);
	int* index = malloc(threads * sizeof(int));
	pthread_t* tid = (pthread_t*)malloc(sizeof(pthread_t) * threads);
	struct timespec start;
	struct timespec end;
	long long num = threads * iterations;
	list = malloc(sizeof(SortedList_t));
	list->prev = list;
	list->next = list;
	list->key = NULL;
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

	clock_gettime(CLOCK_MONOTONIC, &start);
	int i;
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
	printf(",%lld,%lld,1,%lld,%lld,%lld\n", threads, iterations, performance, duration, duration/performance);
	exit(0);
}

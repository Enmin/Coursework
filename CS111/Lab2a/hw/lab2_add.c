#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <getopt.h>
#include <pthread.h>
#include <time.h>
#include <sched.h>
#include <errno.h>

long long threads = 1;
long long iterations = 1;
long long counter = 0;
char sync_type = 'n';
int opt_yield = 0;
pthread_mutex_t lock = PTHREAD_MUTEX_INITIALIZER;
char *solve;
long long spin_lock = 0;

void check_args(int argc, char **argv){
	int opt;
	int option_index=0;
	char *string = "a::";
	static struct option long_options[] = {
		{"threads",  required_argument, NULL,'t'},
		{"iterations",  required_argument, NULL,'i'},
		{"yield",  no_argument, NULL,'y'},
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
			opt_yield = 1;
		}
		else if(opt == 's'){
			sync_type = optarg[0];
			if(sync_type != 'm' && sync_type != 's' && sync_type != 'c'){
				fprintf(stderr,"wrong sync arguments\n");
				exit(1);
			}
		}
		else{
			is_right++;
			break;
		}
	}
	
	if(is_right > 0){
		fprintf(stderr,"Invalid Arugments, correct usage: ./lab2_add [--thread=#] [--iterations==#] [--yield] [--sync=m|s|c]\n");
		exit(1);
	}
}

void add(long long *pointer, long long value) {
	long long sum = *pointer + value;
	if(opt_yield == 1){
		sched_yield();
	}
	*pointer = sum;
}

void *run_threads(void* arg){
	solve = arg;
	int i;
	for(i = 1; i > -2; i -= 2){
		int j;
		for(j = 0; j < iterations; j++){
			switch(sync_type){
				case 'n':
				{
					add(&counter, i);
					break;
				}
				case 'm':
				{
					pthread_mutex_lock(&lock);
					add(&counter, i);
					pthread_mutex_unlock(&lock);
					break;
				}
				case 's':
				{
					while(__sync_lock_test_and_set(&spin_lock, 1));
					add(&counter, i);
					__sync_lock_release(&spin_lock);
					break;
				}
				case 'c':
				{
					long long temp = 0;
					do{ 
					temp = counter;
					}while(__sync_val_compare_and_swap(&counter, temp, temp+i) != temp);
					break;
				}
				default:
				{
					break;
				}
			}
		}
	}
	return NULL;
}

int main(int argc, char **argv){
	check_args(argc, argv);
	pthread_t* tid = (pthread_t*)malloc(sizeof(pthread_t) * threads);
	long long counter = 0;
	struct timespec start;
	struct timespec end;
	clock_gettime(CLOCK_MONOTONIC, &start);
	int i;
	for(i = 0; i < threads; i++){
		int r = pthread_create(&tid[i], NULL, run_threads, NULL);
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
	free(tid);

	long long duration = (end.tv_sec - start.tv_sec)*1000000000;
	duration += end.tv_nsec;
	duration -= start.tv_nsec;
	long long performance = threads * iterations * 2;
	printf("add-");
	if(opt_yield){
		printf("yield-");
	}
	if(sync_type == 'n'){
		printf("none");
	}
	else{
		printf("%c", sync_type);
	}
	printf(",%lld,%lld,%lld,%lld,%lld,%lld\n", threads, iterations, performance, duration, duration/performance, counter);
	exit(0);
}

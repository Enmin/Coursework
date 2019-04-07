#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <getopt.h>
#include <signal.h>
#include <errno.h>

void sig_handler(int signum){
	fprintf(stderr,"Segmentation Fault happens: %d\n", signum);
	exit(4);
}

void copy(int from, int to){
	char buf[100];
	while(read(from, buf, strlen(buf))){
		write(to, buf, strlen(buf));
	}
}

void use(int i){
	dup(i);
}

int main(int argc, char *argv[]){
	
	int opt;
	int option_index=0;
	char *string = "a::b:c:d";
	static struct option long_options[] = {
		{"input",  required_argument, NULL,'i'},
		{"output", required_argument, NULL,'o'},
		{"segfault", no_argument, NULL,'s'},
		{"catch", no_argument,NULL,'c'},
	};
	
	int isseg = 0, iscatch = 0, is_right = 0;
	char *in = NULL, *out = NULL;

	while((opt=getopt_long(argc,argv,string,long_options,&option_index))!= -1){
		/*
		printf("opt = %c\t\t", opt);
		printf("optarg = %s\t\t",optarg);
		printf("optind = %d\t\t",optind);
		printf("argv[optind] =%s\t\t", argv[optind-1]);
		printf("option_index = %d\n",option_index);*/ //for debug use
		if(opt == 's'){
			isseg = 1;
		}
		else if(opt == 'c'){
			iscatch = 1;
		}
		else if(opt == 'i'){
			in = optarg;
		}
		else if(opt == 'o'){
			out = optarg;
		}
		else{
			is_right++;
		}
	}
	
	
	if(is_right > 0){
		fprintf(stderr,"Invalid Arugments, correct usage: ./lab0 [--input=filename], [--output=filename] [--segfault] [--catch]\n");
		exit(1);
	}
	
	if(iscatch){
		if(signal(SIGSEGV, sig_handler)==SIG_ERR){
			fprintf(stderr, "Catch Error Happens");
			exit(5);
		}
	}
	
	if(isseg){
		char *test = NULL;
		*test = 't';
	}
	
	//printf("input: %s, output: %s\n",in, out); // for debug use
	
	int ifd, ofd;
	if(in != NULL){
		ifd = open(in, O_RDWR, S_IREAD);
		if(ifd < 0){
			fprintf(stderr,"Invalid input, %s\n", strerror(errno));
			exit(2);
		}
		else{
			close(0);
			dup(ifd);
		}
	}

	if(out!=NULL){
		ofd = open(out, O_RDWR|O_CREAT, 0666);
		if(ofd < 0){
			fprintf(stderr,"Invalid output: %s\n", strerror(errno));
			exit(3);
		}
		else{
			close(1);
			dup(ofd);
		}
	}

	char buf[1];
	ssize_t n;
	while((n = read(0, buf, 1)) > 0){
		write(1, buf, n);
	}
	close(ofd);
	close(ifd);
	exit(0);
}

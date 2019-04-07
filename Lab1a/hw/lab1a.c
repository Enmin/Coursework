#include <sys/types.h>
#include <sys/stat.h>
#include <wait.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <getopt.h>
#include <signal.h>
#include <errno.h>
#include <termios.h>
#include <poll.h>

//global vairables
static struct termios originalTermParam;
const char lf='\n';
const char cr='\r';
pid_t pid = -1;

void simple_signal_handler(int signum) {
	if(signum == SIGPIPE){
		//printf("SIGPIPE\n");
	    exit(1);
	}
	else if (signum == SIGINT){
	    kill(pid, SIGINT);
	}
}

void set_keypress(void){
	struct termios currentTermParam;
	int r = tcgetattr(0, &originalTermParam);
	if(r != 0){
		fprintf(stderr, "get_mode:%s\n", strerror(errno));
	}
	memcpy(&currentTermParam, &originalTermParam, sizeof(struct termios));
	currentTermParam.c_lflag = ISTRIP;  
					      
	//currentTermParam.c_lflag &= ~ECHO;    // for debug use
	currentTermParam.c_oflag = 0;
	currentTermParam.c_lflag = 0;        // at least one character
	//printf("oflag: %d lflag:%d\n", originalTermParam.c_oflag, originalTermParam.c_lflag); // for debug use
	r = tcsetattr(0, TCSANOW, &currentTermParam);
	if(r != 0){
		fprintf(stderr, "set_mode:%s\n", strerror(errno));
		exit(1);
	}
	return;
}

void reset_keypress(void){
	int r =	tcsetattr(0, TCSANOW, &originalTermParam);
	if(r != 0){
		fprintf(stderr, "reset_mode:%s\n", strerror(errno));
		exit(1);
	}
}

void exit_handler(void){
	int status;
	waitpid(pid, &status, 0);
	reset_keypress();
	fprintf(stderr, "\rSHELL EXIT SIGNAL=%d STATUS=%d\n", WTERMSIG(status), WEXITSTATUS(status));
}

int main(int argc, char *argv[]){
	
	int opt;
	int option_index=0;
	char *string = "a::";
	static struct option long_options[] = {
		{"shell",  required_argument, NULL,'s'},
		{0, 0, 0, 0}
	};
	
	int is_right = 0;
	char *program = NULL;

	while((opt=getopt_long(argc,argv,string,long_options,&option_index))!= -1){
		/*
		printf("opt = %c\t\t", opt);
		printf("optarg = %s\t\t",optarg);
		printf("optind = %d\t\t",optind);
		printf("argv[optind] =%s\t\t", argv[optind-1]);
		printf("option_index = %d\n",option_index); //for debug use 
		*/
		if(opt == 's'){
			program = optarg;
		}
		else{
			is_right++;
			break;
		}
	}
	
	if(is_right > 0){
		fprintf(stderr,"Invalid Arugments, correct usage: ./lab1a [--shell=name]\n");
		exit(1);
	}

	//set mode
	set_keypress();
	atexit(exit_handler);
	int to_child[2], to_parent[2];
	signal(SIGPIPE, simple_signal_handler);
	signal(SIGINT, simple_signal_handler);
	if(pipe(to_child) == -1){
		fprintf(stderr, "pipe:%s\n", strerror(errno));
		exit(1);
	}
	if(pipe(to_parent) == -1){
		fprintf(stderr, "pipe:%s\n", strerror(errno));
		exit(1);
	}
	
	pid = fork();

	if(pid < 0){
		fprintf(stderr, "fork:%s\n", strerror(errno));
		exit(1);
	}
	
	if(pid == 0){
		close(to_child[1]);
        close(to_parent[0]);
        dup2(to_child[0], 0);
        dup2(to_parent[1], 1);
		dup2(to_parent[1], 2);
        close(to_child[0]);
		close(to_parent[1]);

		if(execl("/bin/bash", program, NULL) < 0){
			fprintf(stderr, "exec:%s\n", strerror(errno));
			exit(1);
		}
	}
	else if(pid > 0){
		close(to_child[0]);
		close(to_parent[1]);

		char buf[256];
		struct pollfd fd[2];
		fd[0].fd = 0;
		fd[1].fd = to_parent[0];
		fd[0].events = POLLHUP | POLLIN | POLLERR;
		fd[1].events = POLLHUP | POLLIN | POLLERR;

		while(1){
			int ret = poll(fd, 2, -1);
			if(ret <= 0){
				fprintf(stderr, "poll:%s\n", strerror(errno));
				exit(1);
			}
			if(((fd[0].revents&POLLHUP) == POLLHUP) || ((fd[1].revents&POLLHUP) == POLLHUP)){
				kill(pid, SIGHUP);
				exit(0);
			}
			else if(((fd[0].revents&POLLERR) == POLLERR) || ((fd[1].revents&POLLERR) == POLLERR)){
				kill(pid, SIGINT);
				exit(0);
			}
			else if((fd[0].revents&POLLIN) == POLLIN){
				int num = read(0, buf, 1);
				int i; //c99 declaration outside for loop
				for(i = 0; i < num; i++){
					char temp = buf[i];
					if(temp == 0x03){
						printf("^C\n");
						kill(pid, SIGINT);
					}
					else if(temp == 0x04){
						close(to_child[1]);
						close(to_parent[0]);
						printf("^D\n");
						kill(pid, SIGHUP);
						exit(0);
					}
					else if(temp == '\n' || temp == '\r'){
						//write(1, (char *)"\r\n", 2);
						write(1, &cr, 1);
						write(1, &lf, 1);
						write(to_child[1], &lf, 1);
					}
					else{
						write(1, &temp, 1);
						write(to_child[1], &temp, 1);
					}
				}
			}
			else if((fd[1].revents&POLLIN) == POLLIN){
				int num = read(to_parent[0], buf, 1);
				int i; //c99 declaration outside for loop
				for(i = 0; i < num; i++){
					char temp = buf[i];
					if(temp == '\n'){
						//write(1, (char *)"\r\n", 2);
						write(1, &cr, 1);
						write(1, &lf, 1);
					}
					else{
						write(1, &temp, 1);
					}
				}
			}
		}
	}


	char c;
	while(1){
		if(read(0, &c, 1) < 0){
			fprintf(stderr, "%s\n", strerror(errno));
			exit(1);
		}
		else if(c == 0x04){
			break;
		}
		else if(c == '\n' || c == '\r'){
			write(1, &cr, 1);
			write(1, &lf, 1);
		}
		else{
			write(1, &c, 1);
		}
	}
	//reset mode
	reset_keypress();
	exit(0);
}

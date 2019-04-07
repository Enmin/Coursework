#include <sys/types.h>
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
#include <sys/socket.h>
#include <netinet/in.h>

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
		{"port", required_argument, NULL, 'p'},
		{"encrypt", required_argument, NULL, 'e'},
		{0, 0, 0, 0}
	};
	
	int is_right = 0;
	int port = -1;
	char* encryption_file = NULL;

	while((opt=getopt_long(argc,argv,string,long_options,&option_index))!= -1){
		/*
		printf("opt = %c\t\t", opt);
		printf("optarg = %s\t\t",optarg);
		printf("optind = %d\t\t",optind);
		printf("argv[optind] =%s\t\t", argv[optind-1]);
		printf("option_index = %d\n",option_index); //for debug use 
		*/
		if(opt == 'p'){
			port = atoi(optarg);
		}
		else if(opt == 'e'){
			encryption_file = optarg;
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

	int sockfd, client_sock;
	struct sockaddr_in server;
	struct sockaddr client;

	if(port == -1){
		fprintf(stderr, "Port is mandatory\n");
		exit(1);
	}
	if((sockfd = socket(AF_INET, SOCK_STREAM, 0))==-1){
		fprintf(stderr, "Socket:%s\n",strerror(errno));
		exit(1);
	}
	server.sin_family = AF_INET;
	server.sin_addr.s_addr = INADDR_ANY;
	server.sin_port = htons(port);
	if(bind(sockfd, (struct sockaddr*) &server, sizeof(server)) < 0){
		fprintf(stderr, "Bind:%s\n", strerror(errno));
		exit(1);
	}
	listen(sockfd, 3);
	socklen_t size = sizeof(client);
	if((client_sock = accept(sockfd, &client, &size)) < 0){
		fprintf(stderr, "Error! Accept failed");
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

		char *execvp_argv[2];
		char execvp_filename[] = "/bin/bash";
		execvp_argv[0] = execvp_filename;
		execvp_argv[1] = NULL;
								        
		if (execvp(execvp_filename, execvp_argv) == -1){
			fprintf(stderr, "execvp() failed!\n");
			exit(1);
		}
		/*
		if(execl("/bin/bash", "child", NULL) < 0){
			fprintf(stderr, "exec:%s\n", strerror(errno));
			exit(1);
		}
		*/
	}
	else if(pid > 0){
		close(to_child[0]);
		close(to_parent[1]);

		char buf[256];
		struct pollfd fd[2];
		fd[0].fd = client_sock;
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
				int num = read(client_sock, buf, 256);
				int i; //c99 declaration outside for loop
				for(i = 0; i < num; i++){
					char temp = buf[i];
					if(temp == 0x03){
						kill(pid, SIGINT);
					}
					else if(temp == 0x04){
						close(to_child[1]);
						close(to_parent[0]);
						kill(pid, SIGHUP);
						exit(0);
					}
					else if(temp == '\n' || temp == '\r'){
						write(to_child[1], &lf, 1);
					}
					else{
						write(to_child[1], &temp, 1);
					}
				}
			}
			else if((fd[1].revents&POLLIN) == POLLIN){
				int num = read(to_parent[0], buf, 256);
				if(num > 0){
					write(client_sock, buf, num);
				}
				/*
				int i;
				for(i = 0; i < num; i++){
					char temp = buf[i];
					if(temp == '\n'){
						write(1, &cr, 1);
						write(1, &lf, 1);
					}
					else{
						write(1, &temp, 1);
					}
				}
				*/

			}
		}
	}

	//reset mode
	reset_keypress();
	exit(0);
}

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
#include <sys/resource.h>
#include <netdb.h>
#include <zlib.h>


//global vairables
static struct termios originalTermParam;
const char lf='\n';
const char cr='\r';
struct hostent *server;

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

int main(int argc, char *argv[]){
	
	int opt;
	int option_index=0;
	char *string = "a::";
	static struct option long_options[] = {
		{"port", required_argument, NULL, 'p'},
		{"encrypt", required_argument, NULL, 'e'},
		{"log", required_argument, NULL, 'l'},
		{0, 0, 0, 0}
	};
	
	int is_right = 0;
	int port = -1;
	char* encryption_file = NULL, *log_file = NULL;

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
		else if(opt =='l'){
			log_file = optarg;
		}
		else{
			is_right++;
			break;
		}
	}
	
	if(is_right > 0){
		fprintf(stderr,"Invalid Arugments, correct usage: ./lab1b-client [--log=file] [--encrypt=file] [--port=number]\n");
		exit(1);
	}

	int sockfd;
	struct sockaddr_in server_addr;

	if(port == -1){
		fprintf(stderr, "Port is mandatory\n");
		exit(1);
	}
	if((sockfd = socket(AF_INET, SOCK_STREAM, 0))==-1){
		fprintf(stderr, "Socket:%s\n",strerror(errno));
		exit(1);
	}
	
	server = gethostbyname("127.0.0.1");
	memset((char*) &server_addr, 0, sizeof(server_addr));
	server_addr.sin_family = AF_INET;
	server_addr.sin_port = htons(port);
	memcpy((char *) &server_addr.sin_addr.s_addr, (char*) server->h_addr, server->h_length);


	if(connect(sockfd, (struct sockaddr*) &server_addr, sizeof(server_addr)) < 0){
		fprintf(stderr, "Connect:%s\n)", strerror(errno));
		exit(1);
	}
	
	//log handle
	int logfd;
	if(log_file != NULL){
		logfd = open(log_file, O_RDWR|O_CREAT, 0666);
		if(logfd < 0){
			fprintf(stderr, "Log Open:%s\n)", strerror(errno));
			exit(1);
		}
	}
	
	//set mode
	set_keypress();
	atexit(reset_keypress);

	int kill = 0;
	char buf[256];
	char logbuf[256];
	struct pollfd fd[2];
	int count;
	fd[0].fd = 0;
	fd[1].fd = sockfd;
	fd[0].events = POLLHUP | POLLIN | POLLERR;
	fd[1].events = POLLHUP | POLLIN | POLLERR;

	while(1){
		int ret = poll(fd, 2, -1);
		if(ret <= 0){
			fprintf(stderr, "poll:%s\n", strerror(errno));
			exit(1);
		}
		if(((fd[0].revents&POLLHUP) == POLLHUP) || ((fd[1].revents&POLLHUP) == POLLHUP)){
			exit(0);
		}
		else if(((fd[0].revents&POLLERR) == POLLERR) || ((fd[1].revents&POLLERR) == POLLERR)){
			exit(0);
		}
		else if((fd[0].revents&POLLIN) == POLLIN){
			count = read(0, buf, 1);
			int i; //c99 declaration outside for loop
			for(i = 0; i < count; i++){
				char temp = buf[i];
				if(temp == 0x03){
					printf("^C\n");
					write(sockfd, &temp, 1);
					kill = 1;
				}
				else if(temp == 0x04){
					printf("^D\n");
					write(sockfd, &temp, 1);
					kill = 1;
				}
				else if(temp == '\n' || temp == '\r'){
					write(1, &cr, 1);
					write(1, &lf, 1);

					write(sockfd, &lf, 1);
				}
				else{
					write(1, &temp, 1);
					write(sockfd, &temp, 1);
				}
			}
			if(logfd > 0){
				logbuf[count] = '\0';
				int num = sprintf(logbuf, "SENT %ld bytes: %s \n", sizeof(char)*count, buf);
				write(logfd, logbuf, num);
			}
			if(kill == 1){
				exit(0);
			}
		}
		else if((fd[1].revents&POLLIN) == POLLIN){
			count = read(sockfd, buf, 1);
			int i;
			for(i = 0; i < count; i++){
				char temp = buf[i];
				if(temp == '\n'){
					write(1, &cr, 1);						
					write(1, &lf, 1);
				}	
				else{
					write(1, &temp, 1);
				}
			}
			if(logfd > 0){
				logbuf[count] = '\0';
				int num = sprintf(logbuf, "RECIEVED %ld bytes: %s \n", sizeof(char)*count, buf);
				write(logfd, logbuf, num);
			}
		}
	}

	//reset mode
	reset_keypress();
	exit(0);
}

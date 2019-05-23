#include <sys/types.h>
#include <sys/resource.h>
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
#include <sys/socket.h>
#include <netinet/in.h>
#include <mcrypt.h>
#include <netdb.h>
#include <zlib.h>

//global vairables
static struct termios originalTermParam;
const char lf='\n';
const char cr='\r';

MCRYPT enc;
MCRYPT dec;
struct hostent *server;

void reset_keypress(void){
	int r =	tcsetattr(0, TCSANOW, &originalTermParam);
	if(r != 0){
		fprintf(stderr, "reset_mode:%s\n", strerror(errno));
		exit(1);
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
	//currentTermParam.c_cc[VMIN] = 1;
	//currentTermParam.c_cc[VTIME] = 0;
	r = tcsetattr(0, TCSANOW, &currentTermParam);
	if(r != 0){
		fprintf(stderr, "set_mode:%s\n", strerror(errno));
		exit(1);
	}
	atexit(reset_keypress);
	return;
}

void de_encryption(void){
	mcrypt_generic_deinit(enc);
	mcrypt_module_close(enc);

	mcrypt_generic_deinit(dec);
	mcrypt_module_close(dec);
}

void encryption(char* filename){
	char buffer[128];
	int key = open(filename, O_RDONLY);
	int len = read(key, buffer, 128);
	enc = mcrypt_module_open("twofish", NULL, "cfb", NULL);
	dec = mcrypt_module_open("twofish", NULL, "cfb", NULL);
	if ((enc==MCRYPT_FAILED) || (dec==MCRYPT_FAILED)){
		fprintf(stderr, "Encryption error!\n");
		exit(0);
	}
                
	int i;
	char* iv_enc= malloc(mcrypt_enc_get_iv_size(enc));
	for (i=0; i< mcrypt_enc_get_iv_size(enc); i++) {
		iv_enc[i]=0; 
	}
	char* iv_dec= malloc(mcrypt_enc_get_iv_size(dec));
	for (i=0; i< mcrypt_enc_get_iv_size(dec); i++) {
		iv_dec[i]=0;
	}
              
	int poserror1, poserror2;
	poserror1=mcrypt_generic_init(enc, buffer, len, iv_enc);
	poserror2=mcrypt_generic_init(dec, buffer, len, iv_dec);
	if ((poserror1 < 0) || (poserror2 < 0)) {
		fprintf(stderr, "Encryption initialization:%s\n", strerror(errno));
		exit(1);
	}
	atexit(de_encryption);	
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
	int flag = 0;

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
			flag = 1;
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
	/*
	server.sin_family = AF_INET;
	server.sin_port = htons(port);
	*/
	if(connect(sockfd, (struct sockaddr*) &server_addr, sizeof(server_addr)) < 0){
		fprintf(stderr, "Connect:%s\n)", strerror(errno));
		exit(1);
	}
	
	if(encryption_file != NULL){
		encryption(encryption_file);
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
			count = read(0, buf, 256);
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
					if(flag){
						buf[i] = lf;
						mcrypt_generic(enc, &temp, 1);
						write(sockfd, &temp, 1);
						buf[i] = temp;
					}
					else{
						write(sockfd, &lf, 1);
					}
				}
				else{
					write(1, &temp, 1);
					if(flag){
						mcrypt_generic(enc, &temp, 1);
						buf[i] = temp;
					}
					write(sockfd, &temp, 1);
				}
			}
			if(logfd > 0){
				logbuf[count] = '\0';
				int num = sprintf(logbuf, "SENT %d bytes: %s\n", 1, buf);
				write(logfd, logbuf, num);
			}
			if(kill == 1){
				exit(0);
			}
		}
		else if((fd[1].revents&POLLIN) == POLLIN){
			count = read(sockfd, buf, 256);
			int i;
			if(logfd > 0){
				logbuf[count] = '\0';
				int num = sprintf(logbuf, "RECIEVED %ld bytes: %s\n", (count * sizeof(char)), buf);
				write(logfd, logbuf, num);
			}
			if(flag){
				mdecrypt_generic(dec, buf, count);
			}
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
		}
	}

	//reset mode
	exit(0);
}

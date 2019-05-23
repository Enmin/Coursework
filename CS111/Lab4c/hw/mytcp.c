#include <stdio.h>
#include <poll.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <stdlib.h>
#include <unistd.h>
#include <getopt.h>
#include <string.h>
#include <mraa.h>
#include <mraa/aio.h>
#include <signal.h>
#include <math.h>
#include <netinet/in.h>
#include <netdb.h>
#include <sys/socket.h>

mraa_aio_context temperature;
mraa_gpio_context button;
int stop = 1;
int period = 1;
char scale = 'C';
FILE* logfd = NULL;
int read_temperature=0;
int log_opt=0;

char *id=NULL;
char *host=NULL;
int port=0;
struct hostent *server;
struct sockaddr_in server_address;
int socketfd = -1;

void print_time();
void exit_handler();
void command_handler(const char * big);
void check_arg(int argc, char* argv[]);

int main(int argc, char* argv[]){
	check_arg(argc, argv);



	temperature=mraa_aio_init(1);

    button=mraa_gpio_init(60);
    mraa_gpio_dir(button,MRAA_GPIO_IN);
    mraa_gpio_isr(button,MRAA_GPIO_EDGE_RISING,&exit_handler,NULL);

    time_t now,begin,end;
    char formatted_string[15];
    struct tm* time_info;

    struct pollfd pfd[1];
    pfd[0].fd=socketfd;
    pfd[0].events= POLLIN | POLLHUP | POLLERR;


    while(1){
        read_temperature=mraa_aio_read(temperature);
        double temp = 1023.0 / ((double)read_temperature)-1.0;
        temp=100000.0 * temp;
        //by formula
        double centigrade=1.0 /(log(temp/100000.0)/4275+1/298.15)-273.15;
        if(scale=='F'){
            centigrade=centigrade *9/5 +32;
        }

        time(&now);
        time_info=localtime(&now);
        strftime(formatted_string,15, "%H:%M:%S",time_info);

        if(stop){
            dprintf(socketfd,"%s %.1f\n",formatted_string, centigrade);
            if(log_opt){
                fprintf(logfd,"%s %.1f\n",formatted_string, centigrade);
                fflush(logfd);
            }
        }
        time(&begin);
        time(&end);

        while(difftime(end,begin) < period){
            int result=poll(pfd,1,0);
            if(result<0){
                fprintf(stderr,"poll error");
                exit(1);
            }
            if(pfd[0].revents & POLLIN){
	            char big[1024];
	            char small[20];
	            int j = 0;
	            memset(big,0,1024);
    	        memset(small,0,20);
    	        int num_read=read(socketfd,big,1024);
    	        if(num_read<0){
    	            fprintf(stderr, "read error\n");
    	            exit(1);
    	        }
    	        int i;
        	    for(i=0;i<num_read;i++){
	                if(big[i]=='\n'){
	                    command_handler(small);
	                    j=0;
	                    memset(small,0,20);
	                }
	                else{
	                    small[j]=big[i];
	                    j++;
	                }
	            }
            }
            time(&end);
        }
    }
    exit(0);
}

void print_time(){
  time_t now;
  char formatted_string[15];
  struct tm* time_info;

  time(&now);
  time_info = localtime(&now);
  strftime(formatted_string, 15, "%H:%M:%S",time_info);
  fprintf(stdout,"%s ",formatted_string);
  if(log_opt){
    fprintf(logfd,"%s ",formatted_string);
    fflush(logfd);
  }
}


void exit_handler(){
  print_time();
  fprintf(stdout,"SHUTDOWN\n");

  if(log_opt){
    fprintf(logfd,"%s","SHUTDOWN\n");
    fflush(logfd);
  }
  mraa_aio_close(temperature);
  mraa_gpio_close(button);
  exit(0);
}

void command_handler(const char * big){

  if(strcmp(big,"OFF")==0){
    if(log_opt){fprintf(logfd,"%s\n","OFF");
      fflush(logfd);}

    exit_handler();
  }
  else if (strcmp(big,"SCALE=C")==0){
    scale='C';
    if(log_opt){
        fprintf(logfd,"%s\n","SCALE=C");
        fflush(logfd);
    }
  }
  else if (strcmp(big,"SCALE=F")==0){
    scale='F';
    if(log_opt){
        fprintf(logfd,"%s\n","SCALE=F");
        fflush(logfd);
     }
  }
  else if (strcmp(big,"STOP")==0){
    stop=0;
    if(log_opt){
        fprintf(logfd,"%s\n","STOP");
        fflush(logfd);
    }
  }
  else if (strcmp(big,"START")==0){
    stop=1;
    if(log_opt){
        fprintf(logfd,"%s\n","START");
        fflush(logfd);
    }
  }
  else if(strncmp(big,"PERIOD=",7*sizeof(char))==0){
    period=atoi(big+7);
    if(log_opt){
        fprintf(logfd,"%s\n",big);
        fflush(logfd);
    }
  }
  else if(strncmp(big,"LOG ",4*sizeof(char))==0){
    if(log_opt){
        fprintf(logfd,"%s\n",big);
        fflush(logfd);
    }
  }
  else{
    fprintf(stderr,"bad argument from stdin");
    fprintf(stderr,"%s",big);
    exit(1);
  }
}

void check_arg(int argc, char* argv[]){
	int opt;
	int option_index=0;
	char *string = "a::b:c:d";
	static struct option long_options[] = {
		{"period",  required_argument, NULL,'p'},
		{"scale", required_argument, NULL,'s'},
		{"log", required_argument, NULL,'l'},
		{"id",required_argument,0,'i'},
        {"host",required_argument,0,'h'},
		{0,0,0,0},
	};

	int is_right = 0;
	while((opt=getopt_long(argc,argv,string,long_options,&option_index))!= -1){
		/*
		printf("opt = %c\t\t", opt);
		printf("optarg = %s\t\t",optarg);
		printf("optind = %d\t\t",optind);
		printf("argv[optind] =%s\t\t", argv[optind-1]);
		printf("option_index = %d\n",option_index);*/ //for debug use
		if(opt == 'p'){
			period = atoi(optarg);
		}
		else if(opt == 'l'){
		    log_opt = 1;
			logfd = fopen(optarg, "w+");
            if(logfd == NULL){
                fprintf(stderr,"fail to open file\n");
                exit(1);
            }
		}
		else if(opt == 's'){
			if ((optarg[0] != 'F') & (optarg[0] != 'C')){
				fprintf(stderr, "Unrecognized Scale, correct usage includes: --scale=[C|F]\n");
				exit(1);
			}
			scale = optarg[0];
		}
		else if(opt == 'i'){
		    id = optarg;
		}
		else if(opt == 'h'){
		    host = optarg;
		}
		else{
			is_right++;
		}
	}

	if(is_right > 0){
		fprintf(stderr,"Invalid Arugments, correct usage: ./lab4b [--period=#], [--scale=] [--log=filename]\n");
		exit(1);
	}

	if(optind<argc){
	    port=atoi(argv[optind]);
	}
    //printf("%d",port);
    socketfd=socket(AF_INET,SOCK_STREAM,0);
    if(socketfd<0){
        fprintf(stderr,"Error socket open\n");
        exit(1);
    }
    server=gethostbyname(host);
    if(server==NULL){
        fprintf(stderr,"Error no host\n");
        exit(1);
    }
    memset(&server_address,0,sizeof(server_address));//the order was fucked up
    server_address.sin_family=AF_INET;

    memcpy((char *)&server_address.sin_addr.s_addr,(char *)server->h_addr_list[0],server->h_length);
    server_address.sin_port=htons(port);
    if(connect(socketfd,(struct sockaddr*)&server_address,sizeof(server_address))<0){
        fprintf(stderr,"Error Connect TCP\n");
        exit(1);
    }

    dprintf(socketfd,"ID=%s\n", id);
    fprintf(logfd,"ID=%s\n", id);
    fflush(logfd);
}

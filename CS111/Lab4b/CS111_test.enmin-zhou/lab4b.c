#include <unistd.h>
#include <getopt.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>    
#include <poll.h>
#include <fcntl.h>
#include <math.h>
#include <time.h>
#include <pthread.h>
#include <ctype.h>
#include <mraa.h>
#include <mraa/aio.h>

int period = 1;
int scale = 'F';
int logfd = -1;
const int B = 4275;               // B value of the thermistor
const int R0 = 100000;            // R0 = 100k
const int bufferSize = 32;
mraa_aio_context temperature_Pin;
mraa_gpio_context button_Pin;
pthread_mutex_t lock = PTHREAD_MUTEX_INITIALIZER;
int input_found = 0;
int button_State = 0;
int report_opt = 1;
int on_opt = 1;
int prs = 0;

void press();
void check_arg(int argc, char* argv[]);
void* run_thread();
void clear(char* array, int size);

int main(int argc, char* argv[]){
	check_arg(argc, argv);

	temperature_Pin = mraa_aio_init(1); 
	button_Pin = mraa_gpio_init(62);
	float current_Temp;
	time_t readtime = time(NULL);
	struct tm* readtimePTR;						    
	char buffer[bufferSize];
	int buffCount = 0;

	mraa_gpio_isr(button_Pin, MRAA_GPIO_EDGE_RISING, &press, NULL);
	char input_buff[2048];
	int input_Count = 0;

	pthread_t* tid = (pthread_t*)malloc(sizeof(pthread_t));
	if(pthread_create(&tid[0], NULL, run_thread, NULL) < 0){
		fprintf(stderr, "Error: Thread create failure\n");
		exit(1);
	}
	while(1){
		current_Temp = mraa_aio_read(temperature_Pin);
		mraa_gpio_dir(button_Pin, MRAA_GPIO_IN);

        readtime = time(NULL);
		readtimePTR = localtime(&readtime);
		float R = 1023.0/current_Temp-1.0;
		R = R0*R;
		float temperature = 1.0/(log(R/R0)/B+1/298.15)-273.15; // convert to temperature via datasheet
		if (scale == 'F'){
			temperature = temperature*(1.8) + 32; //convert to F
		}
		if ((button_State == 1) | (on_opt == 0)){
			buffCount = sprintf(buffer, "%.2d:%.2d:%.2d SHUTDOWN\n", readtimePTR->tm_hour, readtimePTR->tm_min, readtimePTR->tm_sec);
			write(1, buffer, buffCount);
			if (logfd >= 0){
				write(logfd, buffer, buffCount);
			}
			exit(0);
		}
		if (report_opt == 1){
			buffCount = sprintf(buffer, "%.2d:%.2d:%.2d %0.1f\n", readtimePTR->tm_hour, readtimePTR->tm_min, readtimePTR->tm_sec, temperature);
			write(1, buffer, buffCount);
			if (logfd >= 0){
				write(logfd, buffer, buffCount);
			}
		}

		char tbuf[16];
		clear(tbuf, 16);
		int index = 0;
		int tbuf_pos = 0;

		if(prs > 0){
			pthread_mutex_lock(&lock);
			input_Count = read(0, input_buff, 2048);
			index = 0;
			tbuf_pos = 0;
			pthread_mutex_unlock(&lock);

			while(index < input_Count){
				tbuf[tbuf_pos] = input_buff[index];
				if((tbuf[tbuf_pos] == '=')|(tbuf[tbuf_pos] == '\n')){
					if (strcmp(tbuf, "SCALE=") == 0){
						tbuf_pos++;
						index++; 
						tbuf[tbuf_pos] = input_buff[index];
						tbuf_pos++;
                    	index++;
                    	tbuf[tbuf_pos] = input_buff[index];
						if (strcmp(tbuf, "SCALE=F\n") == 0){
							scale = 'F';
							write(1, "SCALE=F\n", 8);
							if (logfd >= 0){
                	            write(logfd, "SCALE=F\n", 8); 
							}
                    	}
                   		else if (strcmp(tbuf, "SCALE=C\n") == 0){
                            scale = 'C';
                            write(1, "SCALE=C\n", 8);
                            if (logfd >= 0){
                               write(logfd, "SCALE=C\n", 8);
                            }
                        }
					}
                    
                    else if (strcmp(tbuf, "PERIOD=") == 0){
                        char temp_num[2] = {' ',' '};
                        int temp_num_indx = 0;
                        while(tbuf[tbuf_pos] != '\n'){
                            tbuf[tbuf_pos] = input_buff[index];
                            if (isdigit(tbuf[tbuf_pos]) > 0)
                            {
                                temp_num[temp_num_indx] = tbuf[tbuf_pos];
                                temp_num_indx++;
                            }
                            tbuf_pos++;
                            index++;
                        }
                        tbuf_pos++;
                        if (temp_num_indx >= 1){
                            
                            write(1, "PERIOD=", 7);
                            write(1, temp_num, temp_num_indx);
                            write(1, "\n", 1);
                            if (logfd >= 0){
                                write(logfd, "PERIOD=", 7);
                                write(logfd, temp_num, temp_num_indx);
                                write(logfd, "\n", 1);
                            }
                            period = atoi(temp_num);
                        }
                        else{
                            write(1, "Incorrect Command\n", 18);
                            clear(tbuf, 16);
                        }
                    }
                    
                    else if (strcmp(tbuf, "STOP\n") == 0){
                        report_opt = 0;
                        write(1, "STOP\n", 5);
                        if (logfd >= 0){
                           write(logfd, "STOP\n", 5);
                        }
                    }
                    else if (strcmp(tbuf, "START\n") == 0){
                        report_opt = 1;
                        write(1, "START\n", 6);
                        if (logfd >= 0){
                           write(logfd, "START\n", 6);
                        }
                    }
                    else if (strcmp(tbuf, "OFF\n") == 0){
                        on_opt = 0;
                        write(1, "OFF\n", 4);
                        if (logfd >= 0){
                           write(logfd, "OFF\n", 4);
                        }
                        break;
                    }
                    else{
                        write(1, "Incorrect Command\n", 18);
                        clear(tbuf, 16);
                    }
					tbuf_pos = -1;
				}
			}

			pthread_mutex_lock(&lock);
			input_found = 0;
			prs = 0;
			clear(tbuf, 16);
			pthread_mutex_unlock(&lock);
		}

		sleep(period);
	}
}

void* run_thread(){
	struct pollfd pfd[1];
	pfd[0].fd = 0;
	pfd[0].events = POLLIN;
	while(1){
		while(!input_found){
			pthread_mutex_lock(&lock);
			prs = poll(pfd, 2, -1);
			if(prs > 0){
				input_found = 1;
			}
			pthread_mutex_unlock(&lock);
		}
	}
	return NULL;
}

void press(){
	button_State = 1;
}

void clear(char* array, int size){
	int i = 0;
	for (i=0; i < size; i++){
		array[i] = 0;
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
			logfd = open(optarg, O_RDWR|O_CREAT, 0666);
			if (logfd < 0){
				fprintf(stderr, "Error creating file\n");
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
		else{
			is_right++;
		}
	}
	
	if(is_right > 0){
		fprintf(stderr,"Invalid Arugments, correct usage: ./lab4b [--period=#], [--scale=] [--log=filename]\n");
		exit(1);
	}
}

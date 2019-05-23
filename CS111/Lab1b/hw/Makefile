all:lab1b-client lab1b-server
lab1b-client:lab1b-client.c
	gcc -Wall -Wextra -lmcrypt lab1b-client.c -o lab1b-client
lab1b-server:lab1b-server.c
	gcc -Wall -Wextra -lmcrypt lab1b-server.c -o lab1b-server
clean:
	rm -f lab1b-server lab1b-client *.tar.gz
dist:
	tar -czvf lab1b-104756697.tar.gz lab1b-server.c lab1b-client.c Makefile README my.key

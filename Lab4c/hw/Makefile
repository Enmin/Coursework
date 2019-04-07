default:
	gcc -Wall -Wextra lab4c_tcp.c -o lab4c_tcp -lm -lmraa
	gcc -Wall -Wextra lab4c_tls.c -o lab4c_tls -lm -lmraa -lssl -lcrypto
dist:
	tar -czvf lab4c-104756697.tar.gz README Makefile lab4c_tcp.c lab4c_tls.c
clean:
	rm -rf lab4c lab4c-104756697.tar.gz

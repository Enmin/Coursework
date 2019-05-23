lab0:lab0.c
	gcc -Wall -Wextra lab0.c -o lab0
clean:
	rm -f lab0 *.tar.gz
dist:
	tar -czvf lab0-104756697.tar.gz lab0.c Makefile README backtrace.png breakpoint.png mytest.sh
check:
	bash mytest.sh

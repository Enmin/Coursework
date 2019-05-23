default:
	gcc -Wall -Wextra lab4b.c -o lab4b -lm -lmraa
check:
	echo OFF | ./lab4b --log=logfiletest --period=2 --scale=C
	rm -rf logfiletest
clean:
	rm -rf lab4b lab4b-104756697.tar.gz logfile
dist:
	tar -czvf lab4b-104756697.tar.gz lab4b.c Makefile README

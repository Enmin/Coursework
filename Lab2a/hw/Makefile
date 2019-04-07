build:
	gcc -Wall -Wextra -g -pthread -lrt -o lab2_add lab2_add.c
	gcc -Wall -Wextra -g -pthread -lrt -o lab2_list SortedList.c lab2_list.c
graphs:
	gnuplot lab2_add.gp
	gnuplot lab2_list.gp
clean:
	rm -rf lab2_add lab2_list lab2a-104756697.tar.gz
dist:clean build tests graphs
	tar -czvf lab2a-104756697.tar.gz lab2_add.c lab2_list.c SortedList.h SortedList.c Makefile README addtest.sh listtest.sh lab2_add.gp lab2_list.gp \
	lab2_add.csv lab2_list.csv lab2_add-1.png lab2_add-2.png lab2_add-3.png lab2_add-4.png lab2_add-5.png lab2_list-1.png lab2_list-2.png lab2_list-3.png lab2_list-4.png
tests:
	bash listtest.sh
	bash addtest.sh

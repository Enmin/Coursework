default:
	gcc -Wall -Wextra -g -pthread -lrt -o lab2_list SortedList.c lab2_list.c
graphs:default tests
	gnuplot lab2_list.gp
profile:
	gcc -Wall -Wextra -pthread -lrt -o lab2_list lab2_list.c SortedList.c
	CPUPROFILE=lab2_list.prof ./lab2_list --threads=12 --iterations=1000 --sync=s 
	google-pprof --text lab2_list lab2_list.prof > profile.out
	google-pprof --list=my_sync_handler lab2_list lab2_list.prof >> profile.out
	-rm -f lab2_list.prof
clean:
	rm -rf lab2_list lab2b-104756697.tar.gz *.png *.csv
dist:clean profile graphs
	tar -czvf lab2b-104756697.tar.gz lab2_list.c SortedList.h SortedList.c Makefile README lab2_list.gp lab2_list.csv lab2_list-1.png lab2_list-2.png lab2_list-3.png lab2_list-4.png lab2_list-5.png test.sh
tests:
	bash test.sh

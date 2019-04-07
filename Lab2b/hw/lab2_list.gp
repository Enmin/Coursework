#! /usr/bin/gnuplot
#
# purpose:
#	 generate data reduction graphs for the multi-threaded list project
#
# input: lab2_list.csv
#	1. test name
#	2. # threads
#	3. # iterations per thread
#	4. # lists
#	5. # operations performed (threads x iterations x (ins + lookup + delete))
#	6. run time (ns)
#	7. run time per operation (ns)
#
# output:
#	lab2b_1.png ... throughput vs. number of threads for mutex and spin-lock synchronized list operations.
#	lab2b_2.png ... mean time per mutex wait and mean time per operation for mutex-synchronized list operations.
#	lab2b_3.png ... successful iterations vs. threads for each synchronization method.
#	lab2b_4.png ... throughput vs. number of threads for mutex synchronized partitioned lists.
#	lab2b_5.png ... throughput vs. number of threads for spin-lock-synchronized partitioned lists.
#
# Note:
#	Managing data is simplified by keeping all of the results in a single
#	file.  But this means that the individual graphing commands have to
#	grep to select only the data they want.
#
#	Early in your implementation, you will not have data for all of the
#	tests, and the later sections may generate errors for missing data.
#

# general plot parameters
set terminal png
set datafile separator ","


# 1. throughput vs. number of threads for mutex and spin-lock synchronized list operations.
set title "1. Troughput vs. Number of Threads"
set xlabel "threads"
set xrange [1:25]
set logscale x 2
set ylabel "Throughput (operations/sec)"
set logscale y 10
set output 'lab2b_1.png'

plot \
	"< grep 'list-none-m,[0-9]*,1000,1,' lab2b_list.csv" using ($2):(1000000000/($7)) \
	title 'Mutex' with linespoints lc rgb 'blue', \
	"< grep 'list-none-s,[0-9]*,1000,1,' lab2b_list.csv" using ($2):(1000000000/($7)) \
	title 'Spin-Lock' with linespoints lc rgb 'red'



# 2. mean time per mutex wait and mean time per operation for mutex-synchronized list ops.
set title "2. Mean Time per Mutex Wait and Mean Time per Operation"
set xlabel "threads"
set xrange [1:25]
set logscale x 2
set ylabel "time (ns)"
set logscale y 10
set output 'lab2b_2.png'

#plot \
#	"< grep 'list-none-m,[0-9]*,1000,1' lab2b_list.csv" using ($2):($8) \
#	title 'wait-for-lock-time' with linespoints lc rgb 'blue', \
#	"< grep 'list-none-s,[0-9]*,1000,1,' lab2b_list.csv" using ($2):($7) \
#	title 'average time per operation' with linespoints lc rgb 'red'
plot \
	"< grep -E 'list-none-m,[0-9],1000,1,|list-none-m,16,1000,1,|list-none-m,24,1000,1,' lab2b_list.csv" using ($2):($7) \
	title 'completion time' with linespoints lc rgb 'red', \
	"< grep -E 'list-none-m,[0-9],1000,1,|list-none-m,16,1000,1,|list-none-m,24,1000,1,' lab2b_list.csv" using ($2):($8) \
	title 'wait-for-lock time' with linespoints lc rgb 'blue'


# 3. successful iterations vs. threads for each synchronization method.
set title "3. Successful Iterations vs. Threads for Each Synchronization Method"
set xlabel "threads"
set logscale x 2
set xrange [0.75:]
set ylabel "iterations per thread"
set logscale y 10
set output 'lab2b_3.png'

plot \
	"< grep -E 'list-id-none,[0-9]+,[0-9]+,4,' lab2b_list.csv" using ($2):($3) \
	title 'unprotected w/yields' with points lc rgb 'red', \
	"< grep -E 'list-id-m,[0-9]+,[0-9]+,4,' lab2b_list.csv" using ($2):($3) \
	title 'mutex w/yields' with points lc rgb 'blue', \
	"< grep -E 'list-id-s,[0-9]+,[0-9]+,4,' lab2b_list.csv" using ($2):($3) \
	title 'spin w/yields' with points lc rgb 'green'



# 4. throughput vs. number of threads for mutex synchronized partitioned lists.
set title "Throughput vs. Number of Threads (Mutex)"
set xlabel "threads"
set logscale x 2
set xrange [0.75:]
set ylabel "throughput (operations/sec)"
set logscale y 10
set output 'lab2b_4.png'

#plot \
#	"< grep 'list-none-m,.*,1000,1,' lab2b_list.csv" using ($2):(1000000000/($7)) \
#	title '1 list' with linespoints lc rgb 'blue', \
#	"< grep 'list-none-m,.*,1000,4' lab2b_list.csv" using ($2):(1000000000/($7)) \
#	title '4 lists' with linespoints lc rgb 'green', \
#	"< grep 'list-none-m,.*,1000,8' lab2b_list.csv" using ($2):(1000000000/($7)) \
#	title '8 lists' with linespoints lc rgb 'red', \
#	"< grep 'list-none-m,.*,1000,16' lab2b_list.csv" using ($2):(1000000000/($7)) \
#	title '16 lists' with linespoints lc rgb 'orange', 
plot \
	"< grep -E 'list-none-m,[0-9],1000,1,|list-none-m,12,1000,1,' lab2b_list.csv" using ($2):(1000000000/($7)) \
	title '1 list' with linespoints lc rgb 'red', \
	"< grep -E 'list-none-m,[0-9],1000,4,|list-none-m,12,1000,4,' lab2b_list.csv" using ($2):(1000000000/($7)) \
	title '4 lists' with linespoints lc rgb 'green', \
	"< grep -E 'list-none-m,[0-9],1000,8,|list-none-m,12,1000,8,' lab2b_list.csv" using ($2):(1000000000/($7)) \
	title '8 lists' with linespoints lc rgb 'blue', \
	"< grep -E 'list-none-m,[0-9],1000,16,|list-none-m,12,1000,16,' lab2b_list.csv" using ($2):(1000000000/($7)) \
	title '16 lists' with linespoints lc rgb 'orange'



# 5. throughput vs. number of threads for spin-lock-synchronized partitioned lists.
set title "Throughput vs. Number of Threads (Spin Lock)"
set xlabel "threads"
set logscale x 2
set xrange [0.75:]
set ylabel "Throughput (operations/sec)"
set logscale y 10
set output 'lab2b_5.png'

#plot \
#	"< grep 'list-none-s,.*,1000,1,' lab2b_list.csv" using ($2):(1000000000/($7)) \
#	title '1 list' with linespoints lc rgb 'blue', \
#	"< grep 'list-none-s,.*,1000,4' lab2b_list.csv" using ($2):(1000000000/($7)) \
#	title '4 lists' with linespoints lc rgb 'green', \
#	"< grep 'list-none-s,.*,1000,8' lab2b_list.csv" using ($2):(1000000000/($7)) \
#	title '8 lists' with linespoints lc rgb 'red', \
#	"< grep 'list-none-s,.*,1000,16' lab2b_list.csv" using ($2):(1000000000/($7)) \
#	title '16 lists' with linespoints lc rgb 'orange'

plot \
	"< grep -E 'list-none-s,[0-9],1000,1,|list-none-s,12,1000,1,' lab2b_list.csv" using ($2):(1000000000/($7)) \
	title '1 list' with linespoints lc rgb 'red', \
	"< grep -E 'list-none-s,[0-9],1000,4,|list-none-s,12,1000,4,' lab2b_list.csv" using ($2):(1000000000/($7)) \
	title '4 lists' with linespoints lc rgb 'green', \
	"< grep -E 'list-none-s,[0-9],1000,8,|list-none-s,12,1000,8,' lab2b_list.csv" using ($2):(1000000000/($7)) \
	title '8 lists' with linespoints lc rgb 'blue', \
	"< grep -E 'list-none-s,[0-9],1000,16,|list-none-s,12,1000,16,' lab2b_list.csv" using ($2):(1000000000/($7)) \
title '16 lists' with linespoints lc rgb 'orange'

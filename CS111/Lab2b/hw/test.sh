rm -rf lab2b_list.csv
touch lab2b_list.csv
# For lab2b_1.png and lab2b_2.png
./lab2_list --threads=1  --iterations=1000 --sync=m > lab2b_list.csv	
./lab2_list --threads=2  --iterations=1000 --sync=m >> lab2b_list.csv
./lab2_list --threads=4  --iterations=1000 --sync=m >> lab2b_list.csv
./lab2_list --threads=8  --iterations=1000 --sync=m >> lab2b_list.csv
./lab2_list --threads=12 --iterations=1000 --sync=m >> lab2b_list.csv
./lab2_list --threads=16 --iterations=1000 --sync=m >> lab2b_list.csv
./lab2_list --threads=24 --iterations=1000 --sync=m >> lab2b_list.csv
./lab2_list --threads=1  --iterations=1000 --sync=s >> lab2b_list.csv	
./lab2_list --threads=2  --iterations=1000 --sync=s >> lab2b_list.csv	
./lab2_list --threads=4  --iterations=1000 --sync=s >> lab2b_list.csv	
./lab2_list --threads=8  --iterations=1000 --sync=s >> lab2b_list.csv	
./lab2_list --threads=12 --iterations=1000 --sync=s >> lab2b_list.csv	
./lab2_list --threads=16 --iterations=1000 --sync=s >> lab2b_list.csv	
./lab2_list --threads=24 --iterations=1000 --sync=s >> lab2b_list.csv	
	
#For lab2b_2.png	
#./lab2_list --threads=1  --iterations=1000 --sync=m >> lab2b_list.csv
#./lab2_list --threads=2  --iterations=1000 --sync=m >> lab2b_list.csv
#./lab2_list --threads=4  --iterations=1000 --sync=m >> lab2b_list.csv
#./lab2_list --threads=8  --iterations=1000 --sync=m >> lab2b_list.csv
#./lab2_list --threads=16 --iterations=1000 --sync=m >> lab2b_list.csv
#./lab2_list --threads=24 --iterations=1000 --sync=m >> lab2b_list.csv

#For lab2b_3.png
#No sync
./lab2_list  --threads=1  --iterations=1  --list=4 --yield=id	>> lab2b_list.csv
./lab2_list  --threads=1  --iterations=2  --list=4 --yield=id	>> lab2b_list.csv
./lab2_list  --threads=1  --iterations=4  --list=4 --yield=id	>> lab2b_list.csv
./lab2_list  --threads=1  --iterations=8  --list=4 --yield=id	>> lab2b_list.csv
./lab2_list  --threads=1  --iterations=16 --list=4 --yield=id	>> lab2b_list.csv
./lab2_list --threads=4  --iterations=1  --list=4 --yield=id	>> lab2b_list.csv
./lab2_list --threads=4  --iterations=2  --list=4 --yield=id	>> lab2b_list.csv
./lab2_list --threads=4  --iterations=4  --list=4 --yield=id	>> lab2b_list.csv
./lab2_list --threads=4  --iterations=8  --list=4 --yield=id	>> lab2b_list.csv
./lab2_list --threads=4  --iterations=16 --list=4 --yield=id	>> lab2b_list.csv
./lab2_list --threads=8  --iterations=1  --list=4 --yield=id	>> lab2b_list.csv
./lab2_list --threads=8  --iterations=2  --list=4 --yield=id	>> lab2b_list.csv
./lab2_list --threads=8  --iterations=4  --list=4 --yield=id	>> lab2b_list.csv
./lab2_list --threads=8  --iterations=8  --list=4 --yield=id	>> lab2b_list.csv
./lab2_list --threads=8  --iterations=16 --list=4 --yield=id	>> lab2b_list.csv
./lab2_list --threads=12 --iterations=1  --list=4 --yield=id	>> lab2b_list.csv
./lab2_list --threads=12 --iterations=2  --list=4 --yield=id	>> lab2b_list.csv
./lab2_list --threads=12 --iterations=4  --list=4 --yield=id	>> lab2b_list.csv
./lab2_list --threads=12 --iterations=8  --list=4 --yield=id	>> lab2b_list.csv
./lab2_list --threads=12 --iterations=16 --list=4 --yield=id	>> lab2b_list.csv
./lab2_list --threads=16 --iterations=1  --list=4 --yield=id	>> lab2b_list.csv
./lab2_list --threads=16 --iterations=2  --list=4 --yield=id	>> lab2b_list.csv
./lab2_list --threads=16 --iterations=4  --list=4 --yield=id	>> lab2b_list.csv
./lab2_list --threads=16 --iterations=8  --list=4 --yield=id	>> lab2b_list.csv
./lab2_list --threads=16 --iterations=16 --list=4 --yield=id	>> lab2b_list.csv
#with mutex
./lab2_list --threads=1  --iterations=10 --list=4 --yield=id --sync=m >> lab2b_list.csv
./lab2_list --threads=4  --iterations=10 --list=4 --yield=id --sync=m >> lab2b_list.csv
./lab2_list --threads=8  --iterations=10 --list=4 --yield=id --sync=m >> lab2b_list.csv
./lab2_list --threads=12 --iterations=10 --list=4 --yield=id --sync=m >> lab2b_list.csv
./lab2_list --threads=16 --iterations=10 --list=4 --yield=id --sync=m >> lab2b_list.csv
./lab2_list --threads=1  --iterations=20 --list=4 --yield=id --sync=m >> lab2b_list.csv
./lab2_list --threads=4  --iterations=20 --list=4 --yield=id --sync=m >> lab2b_list.csv
./lab2_list --threads=8  --iterations=20 --list=4 --yield=id --sync=m >> lab2b_list.csv
./lab2_list --threads=12 --iterations=20 --list=4 --yield=id --sync=m >> lab2b_list.csv
./lab2_list --threads=16 --iterations=20 --list=4 --yield=id --sync=m >> lab2b_list.csv
./lab2_list --threads=1  --iterations=40 --list=4 --yield=id --sync=m >> lab2b_list.csv
./lab2_list --threads=4  --iterations=40 --list=4 --yield=id --sync=m >> lab2b_list.csv
./lab2_list --threads=8  --iterations=40 --list=4 --yield=id --sync=m >> lab2b_list.csv
./lab2_list --threads=12 --iterations=40 --list=4 --yield=id --sync=m >> lab2b_list.csv
./lab2_list --threads=16 --iterations=40 --list=4 --yield=id --sync=m >> lab2b_list.csv
./lab2_list --threads=1  --iterations=80 --list=4 --yield=id --sync=m >> lab2b_list.csv
./lab2_list --threads=4  --iterations=80 --list=4 --yield=id --sync=m >> lab2b_list.csv
./lab2_list --threads=8  --iterations=80 --list=4 --yield=id --sync=m >> lab2b_list.csv
./lab2_list --threads=12 --iterations=80 --list=4 --yield=id --sync=m >> lab2b_list.csv
./lab2_list --threads=16 --iterations=80 --list=4 --yield=id --sync=m >> lab2b_list.csv
#with spin and lock
./lab2_list --threads=1  --iterations=10 --list=4 --yield=id --sync=s >> lab2b_list.csv
./lab2_list --threads=4  --iterations=10 --list=4 --yield=id --sync=s >> lab2b_list.csv
./lab2_list --threads=8  --iterations=10 --list=4 --yield=id --sync=s >> lab2b_list.csv
./lab2_list --threads=12 --iterations=10 --list=4 --yield=id --sync=s >> lab2b_list.csv
./lab2_list --threads=16 --iterations=10 --list=4 --yield=id --sync=s >> lab2b_list.csv
./lab2_list --threads=1  --iterations=20 --list=4 --yield=id --sync=s >> lab2b_list.csv
./lab2_list --threads=4  --iterations=20 --list=4 --yield=id --sync=s >> lab2b_list.csv
./lab2_list --threads=8  --iterations=20 --list=4 --yield=id --sync=s >> lab2b_list.csv
./lab2_list --threads=12 --iterations=20 --list=4 --yield=id --sync=s >> lab2b_list.csv
./lab2_list --threads=16 --iterations=20 --list=4 --yield=id --sync=s >> lab2b_list.csv
./lab2_list --threads=1  --iterations=40 --list=4 --yield=id --sync=s >> lab2b_list.csv
./lab2_list --threads=4  --iterations=40 --list=4 --yield=id --sync=s >> lab2b_list.csv
./lab2_list --threads=8  --iterations=40 --list=4 --yield=id --sync=s >> lab2b_list.csv
./lab2_list --threads=12 --iterations=40 --list=4 --yield=id --sync=s >> lab2b_list.csv
./lab2_list --threads=16 --iterations=40 --list=4 --yield=id --sync=s >> lab2b_list.csv
./lab2_list --threads=1  --iterations=80 --list=4 --yield=id --sync=s >> lab2b_list.csv
./lab2_list --threads=4  --iterations=80 --list=4 --yield=id --sync=s >> lab2b_list.csv
./lab2_list --threads=8  --iterations=80 --list=4 --yield=id --sync=s >> lab2b_list.csv
./lab2_list --threads=12 --iterations=80 --list=4 --yield=id --sync=s >> lab2b_list.csv
./lab2_list --threads=16 --iterations=80 --list=4 --yield=id --sync=s >> lab2b_list.csv

#for lab2b_4.png (sync=m)
./lab2_list --threads=1  --iterations=1000 --list=4  --sync=m >> lab2b_list.csv
./lab2_list --threads=2  --iterations=1000 --list=4  --sync=m >> lab2b_list.csv
./lab2_list --threads=4  --iterations=1000 --list=4  --sync=m >> lab2b_list.csv
./lab2_list --threads=8  --iterations=1000 --list=4  --sync=m >> lab2b_list.csv
./lab2_list --threads=12 --iterations=1000 --list=4  --sync=m >> lab2b_list.csv
./lab2_list --threads=1  --iterations=1000 --list=8  --sync=m >> lab2b_list.csv
./lab2_list --threads=2  --iterations=1000 --list=8  --sync=m >> lab2b_list.csv
./lab2_list --threads=4  --iterations=1000 --list=8  --sync=m >> lab2b_list.csv
./lab2_list --threads=8  --iterations=1000 --list=8  --sync=m >> lab2b_list.csv
./lab2_list --threads=12 --iterations=1000 --list=8  --sync=m >> lab2b_list.csv
./lab2_list --threads=1  --iterations=1000 --list=16 --sync=m >> lab2b_list.csv
./lab2_list --threads=2  --iterations=1000 --list=16 --sync=m >> lab2b_list.csv
./lab2_list --threads=4  --iterations=1000 --list=16 --sync=m >> lab2b_list.csv
./lab2_list --threads=8  --iterations=1000 --list=16 --sync=m >> lab2b_list.csv
./lab2_list --threads=12 --iterations=1000 --list=16 --sync=m >> lab2b_list.csv

#for lab2b_5.png (sync=s)
./lab2_list --threads=1  --iterations=1000 --list=4  --sync=s >> lab2b_list.csv
./lab2_list --threads=2  --iterations=1000 --list=4  --sync=s >> lab2b_list.csv
./lab2_list --threads=4  --iterations=1000 --list=4  --sync=s >> lab2b_list.csv
./lab2_list --threads=8  --iterations=1000 --list=4  --sync=s >> lab2b_list.csv
./lab2_list --threads=12 --iterations=1000 --list=4  --sync=s >> lab2b_list.csv
./lab2_list --threads=1  --iterations=1000 --list=8  --sync=s >> lab2b_list.csv
./lab2_list --threads=2  --iterations=1000 --list=8  --sync=s >> lab2b_list.csv
./lab2_list --threads=4  --iterations=1000 --list=8  --sync=s >> lab2b_list.csv
./lab2_list --threads=8  --iterations=1000 --list=8  --sync=s >> lab2b_list.csv
./lab2_list --threads=12 --iterations=1000 --list=8  --sync=s >> lab2b_list.csv
./lab2_list --threads=1  --iterations=1000 --list=16 --sync=s >> lab2b_list.csv
./lab2_list --threads=2  --iterations=1000 --list=16 --sync=s >> lab2b_list.csv
./lab2_list --threads=4  --iterations=1000 --list=16 --sync=s >> lab2b_list.csv
./lab2_list --threads=8  --iterations=1000 --list=16 --sync=s >> lab2b_list.csv
./lab2_list --threads=12 --iterations=1000 --list=16 --sync=s >> lab2b_list.csv

rm -rf lab2_list.csv
list_its1=(10 100 1000 10000 20000)
list_t2=(2 4 8 12)
list_its2=(10 100 1000)
list_t4=(1 2 4 8 12)
list_its4=(1 2 4 8 16 32)
list_t5=(1 2 4 8 12 16 24)
yields=(i d l id il dl idl)
syncoptslist=(m s)
for i in "${list_its1[@]}"; do
	./lab2_list --threads=1 --iterations=$i >> lab2_list.csv
done	
for i in "${list_t2[@]}"; do
	for j in "${list_its2[@]}"; do
		./lab2_list --threads=$i --iterations=$j >> lab2_list.csv
	done
done
for i in "${list_t2[@]}"; do
	for j in "${list_its2[@]}"; do
		for k in "${yields[@]}"; do
			./lab2_list --threads=$i --iterations=$j --yield=$k >> lab2_list.csv
		done
	done
done
for i in "${list_t4[@]}"; do
	for j in "${list_its4[@]}"; do
		for k in "${yields[@]}"; do
				./lab2_list --threads=$i --iterations=$j --yield=$k --sync=m >> lab2_list.csv
		done
	done
done
for i in "${list_t4[@]}"; do
	for j in "${list_its4[@]}"; do
		for k in "${yields[@]}"; do
				./lab2_list --threads=$i --iterations=$j --yield=$k --sync=s >> lab2_list.csv
		done
	done
done
for i in "${list_t5[@]}"; do
	for j in "${syncoptslist[@]}"; do
		./lab2_list --threads=$i --sync=$j --iterations=1000 >> lab2_list.csv
	done
done

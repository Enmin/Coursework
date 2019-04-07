#!/bin/bash
rm -rf lab2_add.csv
threads=(1 2 4 8 12)
iterations=(10 20 40 80 100 1000 10000 10000)
syncoptsadd=(m s c)
for i in "${threads[@]}"; do
	for j in "${iterations[@]}"; do
		./lab2_add --threads=$i --iterations=$j >> lab2_add.csv
	done
done
for i in "${threads[@]}"; do
	for j in "${iterations[@]}"; do
		./lab2_add --threads=$i --iterations=$j --yield >> lab2_add.csv
	done
done
for i in "${threads[@]}"; do
	for j in "${iterations[@]}"; do
		for k in "${syncoptsadd[@]}"; do
			./lab2_add --threads=$i --iterations=$j --sync=$k >> lab2_add.csv
		done
	done
done
for i in "${threads[@]}"; do
	for j in "${iterations[@]}"; do
		for k in "${syncoptsadd[@]}"; do
			./lab2_add --threads=$i --iterations=$j --sync=$k --yield >> lab2_add.csv
		done
	done
done


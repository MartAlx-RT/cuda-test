#!/bin/bash

set -e
rm -f test_*

make -C ..

lengths=(1024 5120 10240 51200 102400 512000 1024000)
for length in ${lengths[@]}
do
	echo 'test with length' $length
	../test_cuda --tests=100 --threads=1024 --vector-length=$length > test_$length.csv
done

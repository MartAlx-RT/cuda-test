.PHONY:	vec_add all main clean

CFLAGS = -Iinclude -O3

all:	vec_add main
	nvcc $(CFLAGS) -o test_cuda vec_add.o main.o

vec_add:	src/vec_add.cu | include/vec_add.cuh
	nvcc $(CFLAGS) -c -DNDEBUG $^

main:		src/main.cu
	nvcc $(CFLAGS) -c $^

clean:
	rm -rf *.o
	rm test_cuda

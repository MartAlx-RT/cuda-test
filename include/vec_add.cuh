#ifndef	VEC_ADD_CUH
#define	VEC_ADD_CUH

#include <cstddef>
#include <cstdlib>
#include <stdio.h>
#include <assert.h>
#include <time.h>

#define CUDA_CHECK(func)					\
	do							\
	{							\
		if(func)					\
			fprintf(stderr,				\
				"cuda %d error (%s:%s:%d)",	\
				cudaGetLastError(),		\
				__FILE__, __func__, __LINE__);	\
	} while(0)

#define print_vec(vec, vec_len)	fprint_vec(stdout, vec, vec_len)

__global__ void add_vec(const float *vec_a, const float *vec_b, float *vec_sum, const size_t vec_len);
void add_vec_test(const size_t vec_len, const size_t n_threads, const size_t n_tests);
void input_vec(float *vec, const size_t vec_len);
void fprint_vec(FILE *f, float *vec, const size_t vec_len);
void rand_vec(float *vec, const size_t vec_len);
void silly_add_vec(const float *vec_a, const float *vec_b, float *vec_sum, const size_t vec_len);

#endif

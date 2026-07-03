#include "vec_add.cuh"
#include <ctime>

/* adds vectors using gpu */
__global__ void add_vec(const float *vec_a, const float *vec_b, float *vec_sum, const size_t vec_len)
{
	assert(vec_a); assert(vec_b); assert(vec_sum);

	size_t idx = threadIdx.x + blockDim.x*blockIdx.x;
	if(idx < vec_len)
		vec_sum[idx] = vec_a[idx] + vec_b[idx];
	else
		printf("%s: dim error\n", __func__);
}

/* adds vectors using cpu */
void silly_add_vec(const float *vec_a, const float *vec_b, float *vec_sum, const size_t vec_len)
{
	assert(vec_a); assert(vec_b); assert(vec_sum);

	for(size_t i = 0; i < vec_len; i++)
		vec_sum[i] = vec_a[i] + vec_b[i];
}

/* compares `add_vec` and `silly_add_vec` */
void add_vec_test(const size_t vec_len, const size_t n_threads, const size_t n_tests)
{
	assert(vec_len);

	/* h_ are host vars, d_ are device vars */
	float *h_vec_a = nullptr, *h_vec_b = nullptr, *h_vec_sum = nullptr;
	float *d_vec_a = nullptr, *d_vec_b = nullptr, *d_vec_sum = nullptr;
	const size_t n_blocks = 1 + (vec_len-1)/n_threads;

	/* allocating host mem */
	CUDA_CHECK(cudaMallocHost(&h_vec_a, vec_len*sizeof(float)));
	CUDA_CHECK(cudaMallocHost(&h_vec_b, vec_len*sizeof(float)));
	CUDA_CHECK(cudaMallocHost(&h_vec_sum, vec_len*sizeof(float)));

	/* allocating dev mem */
	CUDA_CHECK(cudaMalloc(&d_vec_a, vec_len*sizeof(float)));
	CUDA_CHECK(cudaMalloc(&d_vec_b, vec_len*sizeof(float)));
	CUDA_CHECK(cudaMalloc(&d_vec_sum, vec_len*sizeof(float)));

	for(size_t i = 0; i < n_tests; i++)
	{
		/* initializing vectors */
		rand_vec(h_vec_a, vec_len);
		rand_vec(h_vec_b, vec_len);
		CUDA_CHECK(cudaMemcpy(d_vec_a, h_vec_a, vec_len*sizeof(float), cudaMemcpyDefault));
		CUDA_CHECK(cudaMemcpy(d_vec_b, h_vec_b, vec_len*sizeof(float), cudaMemcpyDefault));

		/* cpu test */
		size_t time = clock();
		silly_add_vec(h_vec_a, h_vec_b, h_vec_sum, vec_len);
		time = clock() - time;	printf("%lu", time);

#ifndef NDEBUG
		fprintf(stderr, "\non host:\n");
		fprint_vec(stderr, h_vec_a, vec_len);	putc('+', stderr);
		fprint_vec(stderr, h_vec_b, vec_len);	putc('=', stderr);
		fprint_vec(stderr, h_vec_sum, vec_len);	putc('\n', stderr);
#endif

		/* gpu test */
		time = clock();
		add_vec<<<n_blocks, n_threads>>>(d_vec_a, d_vec_b, d_vec_sum, vec_len);
		CUDA_CHECK(cudaDeviceSynchronize());
		time = clock() - time;	printf("\t%lu\n", time);

#ifndef NDEBUG
		/* d_ memory isn't avaliable for host !!! */
		CUDA_CHECK(cudaMemcpy(h_vec_sum, d_vec_sum, vec_len, cudaMemcpyDefault)); 
		fprintf(stderr, "on device:\n");
		fprint_vec(stderr, h_vec_a, vec_len);	putc('+', stderr);
		fprint_vec(stderr, h_vec_b, vec_len);	putc('=', stderr);
		fprint_vec(stderr, h_vec_sum, vec_len);	putc('\n', stderr);
#endif
	}

	/* freeing mem */
	cudaFree(d_vec_a); cudaFree(d_vec_b); cudaFree(d_vec_sum);
	cudaFree(h_vec_a); cudaFree(h_vec_b); cudaFree(h_vec_sum);
	d_vec_a = d_vec_b = d_vec_sum = nullptr;
	h_vec_a = h_vec_b = h_vec_sum = nullptr;
}

void input_vec(float *vec, const size_t vec_len)
{
	assert(vec);
	for(size_t i = 0; i < vec_len; i++)
		scanf("%f", &vec[i]);
}

void fprint_vec(FILE *f, float *vec, const size_t vec_len)
{
	assert(vec); assert(f);

	fprintf(f, "( ");
	for(size_t i = 0; i < vec_len; i++)
		fprintf(f, "%.3f ", vec[i]);
	putc(')', f);
}

void rand_vec(float *vec, const size_t vec_len)
{
	assert(vec);

	for(size_t i = 0; i < vec_len; i++)
		vec[i] = (float)std::rand() / std::rand();
}


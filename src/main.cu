#include "vec_add.cuh"
#include <string.h>

int main(int argc, char *argv[])
{
	size_t n_tests = 0, n_threads = 0, vec_len = 0;
	for(int i = 1; i < argc; i++)
	{
		if(sscanf(argv[i], "--tests=%lu", &n_tests));
		else if(sscanf(argv[i], "--threads=%lu", &n_threads));
		else if(sscanf(argv[i], "--vector-length=%lu", &vec_len));
		else if(!strcmp(argv[i], "--help"))
		{
			printf(	"usage: %s [options]\n"
				"\t--tests=NUMBER_OF_TESTS\n"
				"\t--threads=NUMBER_OF_THREADS\n"
				"\t--vector-length=LENGTH_OF_VECTOR\n",
				argv[0]);
		}
		else
		{
			fputs("invalid arguments\n", stderr);
			return 1;
		}
	}

	add_vec_test(vec_len, n_threads, n_tests);
	return 0;
}

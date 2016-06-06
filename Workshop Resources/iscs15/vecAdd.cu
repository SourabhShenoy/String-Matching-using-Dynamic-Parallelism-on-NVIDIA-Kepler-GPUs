#include <stdio.h>
#include <stdlib.h>

#include "cuda_utils.h"

#include "timer.h"

/*
 * **CUDA KERNEL** 
 * 
 * Compute the sum of two vectors 
 *   C[i] = A[i] + B[i]
 * 
 */
__global__ void vecAdd(float* a, float* b, float* c) {

 /* Calculate index for this thread */
 int i = blockIdx.x * blockDim.x + threadIdx.x;

 /* Compute the element of C */
 c[i] = a[i] + b[i];
}

void compute_vec_add(int N, float *a, float* b, float *c); 

/*
 * 
 * Host code to drive the CUDA Kernel
 * 
 */
int main() { 

float *d_a, *d_b, *d_c;
float *h_a, *h_b, *h_c, *h_temp;
int i; 
int N = 1024 * 1;

//struct stopwatch_t* timer = NULL;
long double t_pcie_htd, t_pcie_dth, t_kernel, t_cpu;

/* Setup timers */
//stopwatch_init ();
//timer = stopwatch_create ();

/*
  Create the vectors
*/
h_a = (float *) malloc(sizeof(float) * N);
h_b = (float *) malloc(sizeof(float) * N);
h_c = (float *) malloc(sizeof(float) * N);

/*
  Set the initial values of h_a, h_b, and h_c
*/
for (i=0; i < N; i++) {
	h_a[i] = (float) (rand() % 100) / 10.0;
	h_b[i] = (float) (rand() % 100) / 10.0;
	h_c[i] = 0.0;
}


/*
  Allocate space on the GPU
*/
CUDA_CHECK_ERROR(cudaMalloc(&d_a, sizeof(float) * N));
CUDA_CHECK_ERROR(cudaMalloc(&d_b, sizeof(float) * N));
CUDA_CHECK_ERROR(cudaMalloc(&d_c, sizeof(float) * N));

/*
  Copy d_a and d_b from CPU to GPU
*/
//stopwatch_start (timer);
CUDA_CHECK_ERROR(cudaMemcpy(d_a, h_a, sizeof(float) * N, cudaMemcpyHostToDevice));
CUDA_CHECK_ERROR(cudaMemcpy(d_b, h_b, sizeof(float) * N, cudaMemcpyHostToDevice));
//t_pcie_htd = stopwatch_stop (timer);
printf ("Time to transfer data from host to device: %Lg secs\n", 
				 t_pcie_htd);

/*
  Run N/256 blocks of 256 threads each
*/
dim3 GS (N/256, 1, 1);
dim3 BS (256, 1, 1);

//stopwatch_start (timer);
vecAdd<<<GS, BS>>>(d_a, d_b, d_c);
cudaThreadSynchronize ();
//t_kernel = stopwatch_stop (timer);
printf ("Time to execute GPU kernel: %Lg secs\n", 
				 t_kernel);

/*
  Copy d_cfrom GPU to CPU
*/
//stopwatch_start (timer);
CUDA_CHECK_ERROR(cudaMemcpy(h_c, d_c, sizeof(float) * N, cudaMemcpyDeviceToHost));
//t_pcie_dth = stopwatch_stop (timer);
printf ("Time to transfer data from device to host: %Lg secs\n", 
				 t_pcie_dth);


/* 
	Double check errors
 */
h_temp = (float *) malloc(sizeof(float) * N);
//stopwatch_start (timer);
compute_vec_add (N, h_a, h_b, h_temp);
//t_cpu = stopwatch_stop (timer);
printf ("Time to execute CPU program: %Lg secs\n", 
				 t_cpu);

int cnt = 0;
for(int i = 0; i < N; i++) {
	if(abs(h_temp[i] - h_c[i]) > 1e-5) cnt++;
}
printf("number of errors: %d out of %d\n", cnt, N);


/*
 Free the device memory
*/
cudaFree(d_a);
cudaFree(d_b);
cudaFree(d_c);


/*
 Free the host memory
*/
free(h_a);
free(h_b);
free(h_c);

/* 
 Free timer 
*/
//stopwatch_destroy (timer);

if(cnt == 0) {
	printf("\n\nSuccess\n");
}
}

void
compute_vec_add(int N, float *a, float* b, float *c) {
int i;
for (i=0;i<N;i++)
c[i]=a[i]+b[i];
}



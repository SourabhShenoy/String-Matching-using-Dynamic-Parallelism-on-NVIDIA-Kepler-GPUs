#include <stdio.h>
#include <assert.h>

// Part 3 of 5: implement the kernel
__global__ void myFirstKernel(int *A)
{
    int idx = blockIdx.x*blockDim.x + threadIdx.x;
    A[idx] = idx;
}

////////////////////////////////////////////////////////////////////////////////
// Program main
////////////////////////////////////////////////////////////////////////////////
int main( int argc, char** argv) 
{
    // pointer for host memory
    int *h_a;

    // pointer for device memory
    int *d_a;

    // define grid and block size
    int numBlocks = 8;
    int numThreadsPerBlock = 8;

    // Part 1 of 5: allocate host and device memory
    size_t memSize = numBlocks * numThreadsPerBlock * sizeof(int);
    h_a = (int *) malloc(memSize);
    cudaMalloc( (void **) &d_a, memSize );

    // Part 2 of 5: launch kernel
    dim3 dimGrid(numBlocks);
    dim3 dimBlock(numThreadsPerBlock);
    myFirstKernel<<< dimGrid, dimBlock >>>( d_a );

    // Part 4 of 5: device to host copy
    cudaMemcpy( h_a, d_a, memSize, cudaMemcpyDeviceToHost );

    // Part 5 of 5: verify the data returned to the host is correct
    for (int i = 0; i < numBlocks*numThreadsPerBlock; i++)
            assert(h_a[i] == i);
    }

    // free device memory
    cudaFree(d_a);

    // free host memory
    free(h_a);

    printf("Correct!\n");

    return 0;
}

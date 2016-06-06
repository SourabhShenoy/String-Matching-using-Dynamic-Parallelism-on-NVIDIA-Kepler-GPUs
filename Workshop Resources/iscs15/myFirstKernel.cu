#include <stdio.h>
#include <assert.h>

// Part 3 of 5: implement kernel 
// It receives an array A as argument
// Each thread finds its linearized id in the grid and sets A[id] = id
__global__ void myFirstKernel(                           )
{



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
    cudaMalloc(                                              );

    // Part 2 of 5: configure and launch kernel
    dim3 dimGrid(             );
    dim3 dimBlock(             );
    myFirstKernel<<<             ,             >>>(             );

    // Part 4 of 5: device to host copy
    cudaMemcpy(                                                 );

    // Part 5 of 5: verify the data returned to the host is correct
    for (int i = 0; i <              ; i++)
            assert(h_a[i] ==      );
    }


    // free device memory
    cudaFree(d_a);

    // free host memory
    free(h_a);

    printf("Correct!\n");

    return 0;
}

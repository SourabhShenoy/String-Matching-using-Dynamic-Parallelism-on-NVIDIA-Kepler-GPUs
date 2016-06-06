#include <cuda.h>
#include <helper_cuda.h>
#include <stdio.h>
#include <stdlib.h>
#include <string>
#include <iostream>
#include <fstream>

#define ASIZE 256
#define PRIME 1000009

__global__ void processPattern(char* x ,int m, int shifts[]) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;

    if ( idx >= m ) return;    
    char c = x[idx];
    for( int i = m - 1; i >= idx; --i ) {
        if ( x[i] == c ) {
            shifts[c] = m - i;
            return;
        }
    }
}

__global__ void compare(int idx,char *x, char *y, int m, int* results) {
    int id = blockIdx.x * blockDim.x + threadIdx.x;
//	printf("%d\t%d\n",idx,id);
	
	if(x[id]!=y[idx+id]) {
		results[idx]=0;
		return;
	} else {
		return;
	}
}


__global__ void search(char *x, int m, char* y, int n, int shifts[], int indx[], int results[]) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;

    if ( idx > (n - m) ) {		        results[idx] = 0; return; }
    if ( indx[idx] != idx ) {		        results[idx] = 0; return; }

	if(x[0]==y[idx] && x[m-1]==y[idx+m-1]) {
/*
if(idx>1000 && idx<1100) {
	compare<<<1,m>>>(idx);
}
*/
	if(m>2)
	compare<<<1,m>>>(idx,x,y,m,results);

/*
		for( int i = 0; i < m; ++i ) {
		    if ( x[i] != y[idx + i] ) {
		        results[idx] = 0;
		        return;
		    }
		}
*/
	} else {
		        results[idx] = 0;
	}
}

char* readfile(const char* filename) {
	FILE* f;
	char* data;
	f= fopen(filename, "r");
	if ( f != NULL )  {
		fseek(f,0,SEEK_END);
	    int size=ftell(f);
		fseek(f,0,SEEK_SET);
		data = (char*)malloc((size) * sizeof(char));
		fread(data, size,1,f);
	}
	fclose(f);
	return data;
}

void precomputeShiftIndx(char* y, int n, int m, int shifts[], int indx[]) {
    int j = 0;
    int limit = n - m;
 
    while (j <= limit ) {
        j += shifts[ y[j + m] ];
        indx[j] = j;
    }
}

void display_results(int n, int  res[]) {
    int j=0;
    for( int i =0; i < n; ++i )
        if ( res[i] == 1 ) {
		      j++;
//        printf("%d\n",i);
		}

//       printf("%d\n",j);
}

int main(int argc, char* argv[]) {
    int cuda_device = 0;
    size_t n = 0;
    size_t m = 0;

    if ( argc < 4 ) {
//        printf("Usage: ./a.out <device number> <pattern> <data file>\n");
        return -1;
    }

    if( argc > 1 )
        cuda_device = atoi( argv[1] );

    char* mainString = readfile(argv[3]);
    char* subString = (char*) malloc( (strlen(argv[2])) * sizeof(char) );
    strcpy(subString, argv[2]);
    n = strlen(mainString);
    m = strlen(subString);

    int* results=(int*)malloc(n * sizeof(int));

    int* l_shifts = (int*)malloc( ASIZE * sizeof(int) );
    for( int i = 0; i < ASIZE; ++i )
        l_shifts[i] = m + 1;
    int* l_indx = (int*) malloc( n * sizeof(int) );
    for( int i = 0; i < n; ++i ) {
        l_indx[i] = -1;
 	results[i]=1;
	}
	l_indx[0]=0;

//    cudaError_t error;
    cudaEvent_t start_event, stop_event;
    float time1, time2;
    
    checkCudaErrors( cudaEventCreate(&start_event) );
	checkCudaErrors( cudaEventCreate(&stop_event) );

    int num_devices=0;
    checkCudaErrors( cudaGetDeviceCount(&num_devices) );
    if(0==num_devices)
    {
 //       printf("Your system does not have a CUDA capable device\n");
        return 1;
    }
/*
    if( cuda_device >= num_devices )
    {
		if(num_devices==0)
//			printf("You have only 1 device and it's id is 0\n");
		else    
//		    printf("choose device ID between 0 and %d\n", num_devices-1);
        return 1;
    }
*/
    cudaDeviceProp deviceProp;

    checkCudaErrors( cudaGetDeviceProperties(&deviceProp, cuda_device) );
//    if( (1 == deviceProp.major) && (deviceProp.minor < 1))
//    printf("%s does not have compute capability 1.1 or later\n", deviceProp.name);

//    printf("Device name : %s\n", deviceProp.name );
//    printf("CUDA Capable SM %d.%d hardware with %d multi-processors\n", deviceProp.major, deviceProp.minor, deviceProp.multiProcessorCount);
 //   printf("array_size   = %zd\n", n);

    char* d_substr = 0;
    int* d_shifts = 0;
    int* d_indx = 0;
    char* d_text = 0;
    int* d_results = 0;



    checkCudaErrors( cudaMalloc((void**)&d_shifts, sizeof(int)*ASIZE));
    checkCudaErrors( cudaMalloc((void**)&d_indx, n * sizeof(int)) );
    checkCudaErrors( cudaMalloc((void**)&d_results, n * sizeof(int)) );
    checkCudaErrors( cudaMalloc((void**)&d_substr, (m)*sizeof(char)) );
    checkCudaErrors( cudaMalloc((void**)&d_text, (strlen(mainString))*sizeof(char)) );
	checkCudaErrors( cudaMemcpy(d_shifts, l_shifts, sizeof(int) * ASIZE, cudaMemcpyHostToDevice ) );
    checkCudaErrors( cudaMemcpy(d_results, results, sizeof(int) * n, cudaMemcpyHostToDevice ) );
    checkCudaErrors( cudaMemcpy(d_text, mainString, sizeof(char)*(strlen(mainString)), cudaMemcpyHostToDevice ) );
    checkCudaErrors( cudaMemcpy(d_substr, subString, sizeof(char)*(m), cudaMemcpyHostToDevice) );

 //   error = cudaGetLastError();
 //   printf("%s\n", cudaGetErrorString(error));

    dim3 threadsPerBlocks(ASIZE, 1);
    int t = m / threadsPerBlocks.x;
    int t1 = m % threadsPerBlocks.x;
    if ( t1 != 0 ) t += 1;
    dim3 numBlocks(t,1);

//    printf("Launching kernel with blocks=%d, threadsperblock=%d\n", numBlocks.x, threadsPerBlocks.x);

	cudaEventRecord(start_event, 0);
		    processPattern<<<numBlocks,threadsPerBlocks>>>(d_substr, m, d_shifts);
		    cudaThreadSynchronize();
    cudaEventRecord(stop_event, 0);
    cudaEventSynchronize( stop_event );
    cudaEventElapsedTime( &time1, start_event, stop_event );

	checkCudaErrors( cudaMemcpy(l_shifts, d_shifts, sizeof(int) * ASIZE, cudaMemcpyDeviceToHost ) );
    precomputeShiftIndx(mainString , n, m, l_shifts, l_indx);
    checkCudaErrors( cudaMemcpy(d_indx, l_indx, n * sizeof(int), cudaMemcpyHostToDevice) );

/*
//	For debugging
    for( int i = 0; i < ASIZE; ++i )
	printf("%d\t",l_shifts[i]);

	printf("\n\n");

    for( int i = 0; i < n; ++i )
	printf("%d\t",l_indx[i]);

	printf("\n\n");
	printf("%zd\t%zd",n,m);

	printf("\n\n");
*/

    t = n / threadsPerBlocks.x;
    t1 = n % threadsPerBlocks.x;
    if ( t1 != 0 ) t += 1;
    dim3 numBlocks2(t, 1);
 //   printf("Launching kernel with blocks=%d, threadsperblock=%d\n", numBlocks2.x, threadsPerBlocks.x);
    cudaEventRecord(start_event, 0);
	    search<<<numBlocks2,threadsPerBlocks>>>(d_substr, m, d_text, n, d_shifts, d_indx, d_results);
    cudaThreadSynchronize();
    cudaEventRecord(stop_event, 0);
    cudaEventSynchronize( stop_event );
    cudaEventElapsedTime( &time2, start_event, stop_event );

    cudaEventDestroy( start_event );
    cudaEventDestroy( stop_event );
 //   printf("%f+%f=%f milliseconds\t",time1, time2, time1+time2);
   printf("%f\t",time1+time2);
    checkCudaErrors( cudaMemcpy(results, d_results, n * sizeof(int), cudaMemcpyDeviceToHost) );

    display_results(n, results);


	cudaFree(d_substr);
	cudaFree(d_shifts);
	cudaFree(d_indx);
	cudaFree(d_text);
	cudaFree(d_results);
//	free(mainString);
	free(subString);
	free(l_indx);
	free(l_shifts);
	free(results);
	
	cudaThreadExit();
}

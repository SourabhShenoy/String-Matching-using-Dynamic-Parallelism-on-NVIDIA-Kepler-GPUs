//regular upto 32, till 256 4 bytes/thread, till 1024 8bytes, above that try 8,12,16
#include <cuda.h>
#include <helper_cuda.h>
#include <stdio.h>
#include <stdlib.h>
#include <string>
#include <iostream>
#include <fstream>
# include <sys/time.h>
#define ASIZE 256
struct timeval tim;
double dTime1; 

__global__ void compare(int idx,char* x, char* y,int results[],int chunk) {
    int id = blockIdx.x * blockDim.x + threadIdx.x;
		switch(chunk) {
			case 16:
				if(x[id*chunk+15]!=y[idx+id*chunk+15] || x[id*chunk+14]!=y[idx+id*chunk+14] || x[id*chunk+13]!=y[idx+id*chunk+13] ||  x[id*chunk+12]!=y[idx+id*chunk+12] || x[id*chunk+11]!=y[idx+id*chunk+11] || x[id*chunk+10]!=y[idx+id*chunk+10] || x[id*chunk+9]!=y[idx+id*chunk+9] ||  x[id*chunk+8]!=y[idx+id*chunk+8]){
						results[idx]=0;
						return;
					}
			case 8:

				if(x[id*chunk+4]!=y[idx+id*chunk+4] || x[id*chunk+5]!=y[idx+id*chunk+5] || x[id*chunk+6]!=y[idx+id*chunk+6] ||  x[id*chunk+7]!=y[idx+id*chunk+7]){
						results[idx]=0;
						return;
					}
	//		case 4:
				if(x[id*chunk+1]!=y[idx+id*chunk+1] || x[id*chunk+2]!=y[idx+id*chunk+2] || x[id*chunk+3]!=y[idx+id*chunk+3]){
						results[idx]=0;
						return;
					}
		//	case 1:
			if(x[id*chunk]!=y[idx+id*chunk]){
						results[idx]=0;
						return;
					} else {
						return;
					}
		}

/*
	if(x[id*4]!=y[idx+id*4] || x[id*4+1]!=y[idx+id*4+1] || x[id*4+2]!=y[idx+id*4+2]|| x[id*4+3]!=y[idx+id*4+3]) {
		results[idx]=0;
		return;
	} else {
		return;
	}
*/
}


__global__ void search(char *x, int m, char* y, int n, int results[],int chunk) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
     
    if ( idx > (n - m) ) {results[idx]=0; return;}

	   if(x[0]==y[idx] && x[m-1]==y[idx+m-1]) {
		compare<<<1,m/chunk>>>(idx,x,y,results,chunk);
		return;
	  } else {
		results[idx]=0;
		return;
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
		data = (char*)malloc((size+1) * sizeof(char));
		fread(data, size,1,f);
	}
	fclose(f);
	return data;
}

void display_results(int n, int  res[]) {
	int c=0;
    for( int i =0; i < n; ++i )
        if ( res[i] == 1 )
		c++;
		printf("\n\nCount:%d\n\n",c);
//            printf("%d. Found match at %d\n",j++, i);

}

int main(int argc, char* argv[]) {
    int cuda_device = 0;
    size_t n = 0;
    size_t m = 0;

    if ( argc < 4 ) {
  //      printf("Usage: ./a.out <device number> <pattern> <data file>\n");
        return -1;
    }

    if( argc > 1 )
        cuda_device = atoi( argv[1] );

	char* mainString = readfile(argv[3]);
    char* subString = (char*) malloc( (strlen(argv[2])) * sizeof(char) );
    strcpy(subString, argv[2]);
    n = strlen(mainString);
    m = strlen(subString);
		int chunk=0;
	int* results=(int*)malloc(n * sizeof(int));
	for( int i = 0; i < n; ++i ) {
		results[i]=1;
	}

  //  cudaError_t error;
    cudaEvent_t start_event, stop_event;
    float time1;
    
    checkCudaErrors( cudaEventCreate(&start_event) );
	checkCudaErrors( cudaEventCreate(&stop_event) );

    int num_devices=0;
    checkCudaErrors( cudaGetDeviceCount(&num_devices) );
    if(0==num_devices)
    {
  //      printf("Your system does not have a CUDA capable device\n");
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
    //cudaSetDevice( cuda_device );
    cudaDeviceProp deviceProp;

    checkCudaErrors( cudaGetDeviceProperties(&deviceProp, cuda_device) );
 //   if( (1 == deviceProp.major) && (deviceProp.minor < 1))
//   printf("%s does not have compute capability 1.1 or later\n", deviceProp.name);

//    printf("Device name : %s\n", deviceProp.name );
//    printf("CUDA Capable SM %d.%d hardware with %d multi-processors\n", deviceProp.major, deviceProp.minor, deviceProp.multiProcessorCount);
 //   printf("array_size   = %zd\n", n);

    char* d_substr = 0;
    char* d_text = 0;
    int* d_results = 0;

    checkCudaErrors( cudaMalloc((void**)&d_results, n * sizeof(int)) );
    checkCudaErrors( cudaMalloc((void**)&d_substr, (m)*sizeof(char)) );
    checkCudaErrors( cudaMalloc((void**)&d_text, (strlen(mainString))*sizeof(char)) );
    checkCudaErrors( cudaMemcpy(d_results, results, sizeof(int) * n, cudaMemcpyHostToDevice ) );
    checkCudaErrors( cudaMemcpy(d_text, mainString, sizeof(char)*(strlen(mainString)), cudaMemcpyHostToDevice ) );
    checkCudaErrors( cudaMemcpy(d_substr, subString, sizeof(char)*(m), cudaMemcpyHostToDevice) );
//    error = cudaGetLastError();
 //   printf("%s\n", cudaGetErrorString(error));

    dim3 threadsPerBlocks(ASIZE, 1);
    int t = n / threadsPerBlocks.x;
    int t1 = n % threadsPerBlocks.x;
    if ( t1 != 0 ) t += 1;
    dim3 numBlocks(t,1);

//    printf("Launching kernel with blocks=%d, threadsperblock=%d\n", numBlocks.x, threadsPerBlocks.x);
		if(m<32) {
			chunk=1;
		} else if (m<256) {
			chunk=4;
		} else if (m<1024) {
			chunk=8;
		} else {
			chunk=16;
		}

    cudaEventRecord(start_event, 0);
		    search<<<numBlocks,threadsPerBlocks>>>(d_substr, m, d_text, n, d_results, chunk);
    cudaThreadSynchronize();
    cudaEventRecord(stop_event, 0);
    cudaEventSynchronize( stop_event );
    cudaEventElapsedTime( &time1, start_event, stop_event );

    cudaEventDestroy( start_event );
    cudaEventDestroy( stop_event );

    printf("%lf\t",time1);

    checkCudaErrors( cudaMemcpy(results, d_results, n * sizeof(int), cudaMemcpyDeviceToHost) );
	display_results(n, results);

	cudaFree(d_substr);
	cudaFree(d_text);
	cudaFree(d_results);
	free(mainString);
	free(subString);
	free(results);
	
	cudaThreadExit();
}

#include <cuda.h>
#include <stdio.h>
#include <helper_cuda.h>
#include <stdlib.h>
#include <string.h>


#define cutilSafeCall(x) checkCudaErrors(x)
#define cutilCheckMsg(x) getLastCudaError(x)

#define BLOCK_SIZE 32

static __constant__ char d_stringPattern[BLOCK_SIZE];

__global__ void compare(int idx,const char* x, char* y,int results[],int shift) {
    int id = blockIdx.x * blockDim.x + threadIdx.x;
//			printf("%d %c %c\n",id,x[id],y[id+idx]);
	if(x[id]!=y[idx+id]) {
		results[shift]=0;
	}
}

template<class TDATA, unsigned int SUBSTRLEN, unsigned int LEN>
__global__ void strmatch(const char* substr, const char* data,  size_t len, size_t substrlen, int* results) {
    __shared__ char sharedData[BLOCK_SIZE + SUBSTRLEN];
 
    int shft = blockIdx.x * blockDim.x + threadIdx.x;

	if ( threadIdx.x == (warpSize - 1) )
		for(int i = 0; i < SUBSTRLEN; ++i)
			sharedData[threadIdx.x + i] = data[shft+i];
	else 
		sharedData[threadIdx.x] = data[shft];
    __syncthreads();

    const char* s2 = substr;

/*    if ( (LEN - shft) < SUBSTRLEN ) {
        results[shft] = 0;
        return;
    }
*/
		char *c = sharedData;
//			strcpy(c,sharedData);

	//		printf("%d %d \n",shft,results[shft]);

		if((s2[0] == sharedData[threadIdx.x]) && (s2[SUBSTRLEN-1] == sharedData[threadIdx.x + SUBSTRLEN - 1])) {
					compare<<<1,SUBSTRLEN>>>(threadIdx.x,s2,c,results,shft);
//			printf("%d %s %s %d %d\n",threadIdx.x,s2,c,results[shft],shft);
		} else {
				results[shft]=0;
		}
	//			printf("%d\n",results[shft]);

/*
    for( int i = threadIdx.x ; curr_marker <= SUBSTRLEN && i < LEN; curr_marker++, i++ ) {
        if ( s2[curr_marker] && (s2[curr_marker] != sharedData[i]) ) {
            yes = 0;
            break;
        }
    }
*/
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

//
// simple print function to see the shifts in the res array
//
void print_shifts(int *iptr, int strlen) {
int j=0;
    for(unsigned int i = 0; i < strlen; i++ ) {
  //      printf("%d\n",iptr[i]);
        if (iptr[i] == 1) {
		j++;
//        printf("%d\n",i);
	}
}
		printf("\n\nCount:%d\n\n",j);    
//        printf("Match found at position: %d\n", i);
   
}

int main(int argc, char** argv) {
    int cuda_device = 0; // variable used to denote the device ID
    int n = 0;           // number of ints in the data set
    cudaError_t error;   // capture returned error code
    cudaEvent_t start_event, stop_event; // data structures to capture events in GPU
    float time;
	// Sanity checks
	{
	    // check the compute capability of the device
	    int num_devices=0;
	    cutilSafeCall( cudaGetDeviceCount(&num_devices) );
	    if(0==num_devices)
	    {
//	        printf("your system does not have a CUDA capable device\n");
	        return 1;
	    }
    	if( argc > 1 )
       		cuda_device = atoi( argv[1] );

	    // check if the command-line chosen device ID is within range, exit if not
	    if( cuda_device >= num_devices )
	    {
//	        printf("choose device ID between 0 and %d\n", num_devices-1);
	        return 1;
	    }

    	cudaSetDevice( cuda_device );

		if ( argc < 4 ) {
//      		printf("Usage: bruteforcematcher <device number> <pattern> <data file>\n");
      		return -1;
    	}
	} // end of sanity checks


    // read in the filename and string pattern to be searched
    char* mainString = readfile( argv[3] );
    char* subString = (char*)malloc( (strlen(argv[2])) * sizeof(char) );
    strcpy(subString, argv[2]);
    n = strlen(mainString);
//    m = strlen(subString);

    // initializing the GPU timers
    cutilSafeCall( cudaEventCreate(&start_event) );
    cutilSafeCall( cudaEventCreate(&stop_event) );
   
    cudaDeviceProp deviceProp;
    cutilSafeCall( cudaGetDeviceProperties(&deviceProp, cuda_device) );
/*    if( (1 == deviceProp.major) && (deviceProp.minor < 1))
        printf("%s does not have compute capability 1.1 or later\n", deviceProp.name);

    printf("> Device name : %s\n", deviceProp.name );
    printf("> CUDA Capable SM %d.%d hardware with %d multi-processors\n", deviceProp.major, deviceProp.minor, deviceProp.multiProcessorCount);
    printf("> Data Size = %d\n", n);
    printf("> String Pattern = %s\n\n", subString);
*/
    // allocate host memory
    char* d_substr = 0;
    char* d_data = 0;
    int*  d_finalres = 0;
    int* finalres = (int*)malloc( (strlen(mainString))*sizeof(int) );
		
		for(int i=0;i<n;i++) finalres[i]=1;

    cutilSafeCall( cudaMalloc((void**)&d_substr, (strlen(subString))*sizeof(char)) );
    cutilSafeCall( cudaMalloc((void**)&d_finalres, (strlen(mainString))*sizeof(int)) );
    cutilSafeCall( cudaMemcpy(d_finalres, finalres, sizeof(int)*(n), cudaMemcpyHostToDevice ) );
    
cutilSafeCall( cudaMemcpyToSymbol(d_stringPattern, subString, sizeof(char)*(strlen(subString))) );
    cutilSafeCall( cudaMalloc((void**)&d_data, (strlen(mainString))*sizeof(char)) );

    cutilSafeCall( cudaMemcpy(d_data, mainString, sizeof(char)*(strlen(mainString)), cudaMemcpyHostToDevice ) );
    cutilSafeCall( cudaMemcpy(d_substr, subString, sizeof(char)*(strlen(subString)), cudaMemcpyHostToDevice) );
//		cutilSafeCall( cudaMemset(d_finalres, 1, sizeof(int)*strlen(mainString)) );
    
    dim3 threadsPerBlocks(BLOCK_SIZE, 1);
    dim3 numBlocks((int)ceil((float)n/threadsPerBlocks.x), 1);

//	printf("Launching kernel with %d blocks, %d threads per block\n", numBlocks.x, threadsPerBlocks.x);
	// start timer!
    cudaEventRecord(start_event, 0);

	// conduct actual search!!
//	    strmatch<char*, m, n><<<numBlocks,threadsPerBlocks>>>(d_substr, d_data, strlen(mainString), strlen(subString), d_finalres);
	    strmatch<char*, 5, 1181741><<<numBlocks,threadsPerBlocks>>>(d_substr, d_data, strlen(mainString), strlen(subString), d_finalres);
	// stop timer
    cudaEventRecord(stop_event, 0);
    cudaEventSynchronize( stop_event );

    cudaEventElapsedTime( &time, start_event, stop_event );
    cudaEventDestroy( start_event ); // cleanup
    cudaEventDestroy( stop_event ); // cleanup

    error = cudaGetLastError();
    if ( error ) {
//    	printf("Error caught: %s\n", cudaGetErrorString( error ));
    }
    printf("%f\t", time);

    cutilSafeCall( cudaMemcpy(finalres, d_finalres, (strlen(mainString))*sizeof(int), cudaMemcpyDeviceToHost) );

 
    // check whether the output is correct
//    printf("-------------------------------\n");
    print_shifts(finalres, strlen(mainString)+1);
//    printf("-------------------------------\n");

    cudaFree(d_substr);
    cudaFree(d_data);
    cudaFree(d_finalres);
    free(finalres);
	free(subString);
	free(mainString);
	
    return 0;
}

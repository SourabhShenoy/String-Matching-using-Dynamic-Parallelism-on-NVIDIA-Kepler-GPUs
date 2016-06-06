__global__ void reverseArrayBlock(int *d_out, int *d_in)
{
    int in = threadIdx.x;
    int out = blockDim.x - 1 - threadIdx.x;
    d_out[out] = d_in[in];
}

#!/bin/bash

#Submit this script with: sbatch thefilename

#SBATCH --time=0:05:00   # walltime
#SBATCH --ntasks=1   # number of processor cores (i.e. tasks)
#SBATCH --nodes=1   # number of nodes
#SBATCH --mem-per-cpu=8G   # memory per CPU core
#SBATCH --error=myRecord.err
#SBATCH --output=myRecord.out
#SBATCH --gres=gpu:kepler:1

#nvcc CDP_QS.cu -o cdp-qs.out -I /home/gpu_users/sourabhs/Other/Header -rdc=true -arch=sm_35
nvcc MultiGPU.cu -o cdp-qs.out -I /home/gpu_users/sourabhs/Other/Header -rdc=true -arch=sm_35
#nvcc CDP-.cu -o cdp-qs.out
./cdp-qs.out
#rm Results/myRecord.err
#rm Results/myRecord.out

#declare -a files=("Dataset/Numbers.txt")

#cd $HOME/Samples

#for i in "${files[@]}"
#do
#		srun /home/gpu_users/sourabhs/Other/testscript1.sh "$i"
#done

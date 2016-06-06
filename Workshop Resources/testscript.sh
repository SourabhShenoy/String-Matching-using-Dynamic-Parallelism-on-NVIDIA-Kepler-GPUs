#!/bin/bash

#Submit this script with: sbatch thefilename

#SBATCH --time=0:05:00   # walltime
#SBATCH --ntasks=1   # number of processor cores (i.e. tasks)
#SBATCH --nodes=1   # number of nodes
#SBATCH --mem-per-cpu=8G   # memory per CPU core
#SBATCH --error=myRecord.err
#SBATCH --output=myRecord.out
#SBATCH --gres=gpu:kepler:1

#nvcc iscs15/vecAdd.cu timer.c -o vecAdd
iscs15_sln/a.out

#nvcc cdp-quicksort.cu -o Output/cdp-quicksort.out -I /home/gpu_users/sourabhs/Other/Header -rdc=true -arch=sm_35

#rm Results/myRecord.err
#rm Results/myRecord.out

#declare -a files=("Dataset/Numbers.txt")

#cd $HOME/Samples

#for i in "${files[@]}"
#do
#		srun /home/gpu_users/sourabhs/Other/testscript1.sh "$i"
#done

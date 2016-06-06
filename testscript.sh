#!/bin/bash

#Submit this script with: sbatch thefilename

#SBATCH --time=1:00:00   # walltime
#SBATCH --ntasks=1   # number of processor cores (i.e. tasks)
#SBATCH --nodes=1   # number of nodes
#SBATCH --mem-per-cpu=8G   # memory per CPU core
#SBATCH --error=Result/myRecord.err
#SBATCH --output=Result/myRecord.out
#SBATCH --gres=gpu:kepler:1

#janus-debug

# LOAD MODULES, INSERT CODE, AND RUN YOUR PROGRAMS HERE
nvcc Quick-Search.cu -o Output/Quicksearch.out -I /home/gpu_users/sourabhs/Done/Final/Header
#nvcc DynQS.cu -o Output/DynQS.out -I /home/gpu_users/sourabhs/Done/Final/Header -rdc=true -arch=sm_35
#nvcc SimpleBF.cu -o Output/SimpleBF.out -I /home/gpu_users/sourabhs/Done/Final/Header
#nvcc DynSimpleBF.cu -o Output/DynSimpleBF.out -I /home/gpu_users/sourabhs/Done/Final/Header -rdc=true -arch=sm_35
#nvcc SharedBF.cu -o Output/SharedBF.out -I /home/gpu_users/sourabhs/Done/Final/Header

#nvcc SBF-Boost.cu -o Output/SBF-Boost.out -I /home/gpu_users/sourabhs/Done/Final/Header

#nvcc Horspool.cu -o Output/Horspool.out -I /home/gpu_users/sourabhs/Done/Final/Header
#nvcc DynHP.cu -o Output/DynHP.out -I /home/gpu_users/sourabhs/Done/Final/Header -rdc=true -arch=sm_35
#nvcc SharedDynBF.cu -o Output/SharedDynBF.out -I /home/gpu_users/sourabhs/Done/Final/Header -rdc=true -arch=sm_35
#nvcc SharedDynBF-Global.cu -o Output/SharedDynBFG.out -I /home/gpu_users/sourabhs/Done/Final/Header -rdc=true -arch=sm_35
#nvcc DynChunkBF.cu -o Output/DynChunkBF.out -I /home/gpu_users/sourabhs/Done/Final/Header -rdc=true -arch=sm_35

#rm Result/myRecord.err
#rm Result/myRecord.out

declare -a str=("hellohellohellohellohellohellohellohellohellohello" "sdkg")
declare -a files=("Input/Sample-Text.txt")

cd $HOME/Done/Final

for i in "${files[@]}"
do
	echo -e "File Name: $i\n"
	for j in "${str[@]}"
	do
		srun /home/gpu_users/sourabhs/Done/Final/testscript1.sh "$j" "$i" 1000
	done
	echo -e '\n\n\n'
done

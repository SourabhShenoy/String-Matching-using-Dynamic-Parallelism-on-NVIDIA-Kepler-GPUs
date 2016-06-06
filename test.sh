#!/bin/bash

#Submit this script with: sbatch thefilename

#SBATCH --time=1:00:00   # walltime
#SBATCH --ntasks=1   # number of processor cores (i.e. tasks)
#SBATCH --nodes=1   # number of nodes
#SBATCH --gres=gpu:kepler:1
#SBATCH --mem-per-cpu=8G   # memory per CPU core
#SBATCH --error=Result/myRecord.err
#SBATCH --output=Result/myRecord.out

# LOAD MODULES, INSERT CODE, AND RUN YOUR PROGRAMS HERE

#nvcc Quick-Search.cu -o Output/Quicksearch.out -I /home/gpu_users/sourabhs/Done/Final/Header
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


declare -a str=("These Greek capitals, black with age, and quite deeply graven in
the stone, with I know not what signs peculiar to Gothic caligraphy
imprinted upon their forms and upon their attitudes, as though with the
purpose of revealing that it had been a hand of the Middle Ages which
had inscribed them there, and especially the fatal and melancholy
meaning contained in them, struck the author deeply.

He questioned himself; he sought to divine who could have been that soul
in torment which had not" "fojafuoapofshfojafuoapofsdfjbakjfhahaflsfhafk;gfajklgfajkfrhaihhellosflahfojafuoapofsdfjbakjfhahaflsfhafk;gfajklgfajkfrhaihhellosflahfojafuoapofsdfjbakjfhahaflsfhafk;gfajklgfajkfrhaihhellosflahfojafuoapofsdfjbakjfhahaflsfhafk;gfajklgfajkfrhaihhellosflahfojafuellosflahfojafuoapofsdfjbakjfhahaflsfhafk;gfajklgfajkfrhaihhellosflahfojafuoapofsdfjbakjfhahaflsfhafk;gfajklgfajkfrhaihhellosflahfojafuoapofsdfjbakjfhahaflsfhafk;gfajklgfajkfrhaihhelafk;gfajklgfajkfrhaihhellosflahfojafuoapofsdfjbakjfhahaflsfhafk;gfajklgfajkfrhaihhellosflahfojafuoapofsdfjbakjfhahaflsfhafk;gfajklgfajkfrhaihhellosflahfojafuoapofsdfjbakjfhahaflsfhafk;gfajklgfajkfrhaihhellosflahfojafuoapofsdfjbakjfhahaflsfhafk;gfajklgfajkfrhaihhellosflahfojafuoapofsdfjbakjfhahaflsfhafk;gfajklgfajkfrhaihhellosflahfojafuoapofsdfjbakjfhahaflsfhafk;gfajklgfajkfrhaihhellosflahfojafuoapofsdfjbakjfhahaflsfhafk;gfhellohellohellohellohelloajklgfajkfrhaihhellosflahfojafuoapofsdfjbakjfhahaflsfhafk;gfajklgfajkfrhaihhellosflahfojafuoapofsdfjbakjfhahaflsfhafk;gfajklgfajkfrhaihhellosflahfojafuoapofsdfjbakjfhahaflsfhafk;gfajklgfajkfrhaihhellosflahfojafuoapofsdfjbakjfhahaflsfhafk;gfajklgfajkfrhaihhellosflahfojafuoapofsdfjbakjfhahaflsfhafk;gfajklgfajkfrhaihhellosflahfojafuoapofsdfjbakjfhahaflsfhafk;gfajklgfajkfrhaihhellosflahfojafuoapofsdfjbakjfhahaflsfhafk;gfajklgfajkfrhaihhellosflahfojafuoapofsdfjbakjfhahaflsfhafk;gfajklgfajkfrhaihhellosflahfojafuoapofsdfjbakjfhahaflsfhafk;gfajklgfajkfrhaihhellosflahfojafuoapofsdahuoapofsdfjbakjfhahaflsfhafk")
declare -a files=("Input/Sample-Text.txt" "Input/gutenberg.txt" "Input/bible.txt" "Input/ecoli.txt")

#declare -a str=("hello")
#declare -a files=("Input/Sample-Text.txt")

cd $HOME/Done/Final

#echo -e "Brute Force \t Brute Force Shared \t Brute Force -Dyn \t Quick Search \t Quick Search -Dyn"

for i in "${files[@]}"
do
	echo -e "File Name: $i\n"
	for j in "${str[@]}"
	do
		srun --gres=gpu:kepler:1 /home/gpu_users/sourabhs/Done/Final/test1.sh "$j" "$i" 1000
	done
	echo -e '\n\n\n'
done

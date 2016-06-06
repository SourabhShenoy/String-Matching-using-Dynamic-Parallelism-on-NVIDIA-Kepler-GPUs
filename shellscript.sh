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

nvcc Quick-Search.cu -o Output/Quicksearch.out -I /home/gpu_users/sourabhs/Done/Final/Header
nvcc DynQS.cu -o Output/DynQS.out -I /home/gpu_users/sourabhs/Done/Final/Header -rdc=true -arch=sm_35
nvcc SimpleBF.cu -o Output/SimpleBF.out -I /home/gpu_users/sourabhs/Done/Final/Header
nvcc DynSimpleBF.cu -o Output/DynSimpleBF.out -I /home/gpu_users/sourabhs/Done/Final/Header -rdc=true -arch=sm_35
nvcc SharedBF.cu -o Output/SharedBF.out -I /home/gpu_users/sourabhs/Done/Final/Header

declare -a str=("a" "hello" "abcdefghij" "And God saw every thing that he had made, and, be" "And out of the ground made the LORD God to grow every tree that is pleasant to the sight, and good " "These Greek capitals, black with age, and quite deeply graven in
the stone, with I know not what signs peculiar to Gothic caligraphy
imprinted upon their forms and upon their attitudes, as though with the
purpose of revealing that it had been a ha" "These Greek capitals, black with age, and quite deeply graven in
the stone, with I know not what signs peculiar to Gothic caligraphy
imprinted upon their forms and upon their attitudes, as though with the
purpose of revealing that it had been a hand of the Middle Ages which
had inscribed them there, and especially the fatal and melancholy
meaning contained in them, struck the author deeply.

He questioned himself; he sought to divine who could have been that soul
in torment which had not" "These Greek capitals, black with age, and quite deeply graven in
the stone, with I know not what signs peculiar to Gothic caligraphy
imprinted upon their forms and upon their attitudes, as though with the
purpose of revealing that it had been a hand of the Middle Ages which
had inscribed them there, and especially the fatal and melancholy
meaning contained in them, struck the author deeply.

He questioned himself; he sought to divine who could have been that soul
in torment which had not been willing to quit this world without leaving
this stigma of crime or unhappiness upon the brow of the ancient church.

Afterwards, the wall was whitewashed or scraped down, I know not which,
and the inscription disappeared. For it is thus that people have been in
the habit of proceeding with the marvellous churches of the Middle Ages
for the last two hundred years. Mutilations come to them from every
quarter, from within as well as from without. The priest whitewashes
them, the archd" "fojafuoapofshfojafuoapofsdfjbakjfhahaflsfhafk;gfajklgfajkfrhaihhellosflahfojafuoapofsdfjbakjfhahaflsfhafk;gfajklgfajkfrhaihhellosflahfojafuoapofsdfjbakjfhahaflsfhafk;gfajklgfajkfrhaihhellosflahfojafuoapofsdfjbakjfhahaflsfhafk;gfajklgfajkfrhaihhellosflahfojafuellosflahfojafuoapofsdfjbakjfhahaflsfhafk;gfajklgfajkfrhaihhellosflahfojafuoapofsdfjbakjfhahaflsfhafk;gfajklgfajkfrhaihhellosflahfojafuoapofsdfjbakjfhahaflsfhafk;gfajklgfajkfrhaihhelafk;gfajklgfajkfrhaihhellosflahfojafuoapofsdfjbakjfhahaflsfhafk;gfajklgfajkfrhaihhellosflahfojafuoapofsdfjbakjfhahaflsfhafk;gfajklgfajkfrhaihhellosflahfojafuoapofsdfjbakjfhahaflsfhafk;gfajklgfajkfrhaihhellosflahfojafuoapofsdfjbakjfhahaflsfhafk;gfajklgfajkfrhaihhellosflahfojafuoapofsdfjbakjfhahaflsfhafk;gfajklgfajkfrhaihhellosflahfojafuoapofsdfjbakjfhahaflsfhafk;gfajklgfajkfrhaihhellosflahfojafuoapofsdfjbakjfhahaflsfhafk;gfhellohellohellohellohelloajklgfajkfrhaihhellosflahfojafuoapofsdfjbakjfhahaflsfhafk;gfajklgfajkfrhaihhellosflahfojafuoapofsdfjbakjfhahaflsfhafk;gfajklgfajkfrhaihhellosflahfojafuoapofsdfjbakjfhahaflsfhafk;gfajklgfajkfrhaihhellosflahfojafuoapofsdfjbakjfhahaflsfhafk;gfajklgfajkfrhaihhellosflahfojafuoapofsdfjbakjfhahaflsfhafk;gfajklgfajkfrhaihhellosflahfojafuoapofsdfjbakjfhahaflsfhafk;gfajklgfajkfrhaihhellosflahfojafuoapofsdfjbakjfhahaflsfhafk;gfajklgfajkfrhaihhellosflahfojafuoapofsdfjbakjfhahaflsfhafk;gfajklgfajkfrhaihhellosflahfojafuoapofsdfjbakjfhahaflsfhafk;gfajklgfajkfrhaihhellosflahfojafuoapofsdahuoapofsdfjbakjfhahaflsfhafk")
declare -a files=("Input/Sample-Text.txt" "Input/gutenberg.txt" "Input/bible.txt" "Input/ecoli.txt" "Input/lexicon.txt")

#declare -a str=("hello")
#declare -a files=("Input/Sample-Text.txt")

cd $HOME/Done/Final

echo -e "Brute Force \t Brute Force Shared \t Brute Force -Dyn \t Quick Search \t Quick Search -Dyn"

for i in "${files[@]}"
do
	echo -e "File Name: $i\n"
	for j in "${str[@]}"
	do
		srun --gres=gpu:kepler:1 /home/gpu_users/sourabhs/Done/Final/shellscript1.sh "$j" "$i" 1000
	done
	echo -e '\n\n\n'
done

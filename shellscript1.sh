#!/bin/bash
cd $HOME/Done/Final
echo 'BF '
./Output/SimpleBF.out 0 "$1" "$2"
echo 'SBF '
./Output/SharedBF.out 0 "$1" "$2"
echo 'DBF '
./Output/DynSimpleBF.out 0 "$1" "$2"
echo 'QS '
./Output/Quicksearch.out 0 "$1" "$2"
echo 'DQS '
./Output/DynQS.out 0 "$1" "$2"
echo -e '\n'

g++ timer.c -c
nvcc vecAdd.cu timer.o -o vecAdd
nvcc matAdd.cu  timer.o -o matAdd


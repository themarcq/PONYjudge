#!/bin/bash
DIRBIN="./binaries/"
DIRSRC="./sources/"
DIRIN="./tests/in/"
DIROUT="./tests/out/"
DIRRST="./results/"

GPP="g++"
GCC="gcc"
ASM="g++"

# $1 - compilator name
# $2 - code number
${1} $DIRRST/$2.out $DIRSRC 
# run program on specified user and send results to judged

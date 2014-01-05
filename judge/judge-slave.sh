#!/bin/bash
source ./judge.conf
id=$1
problem=$2
language=$3
memlimit=$4
timelimit=$5
outlimit=$5
echo $id $problem $language $memlimit $timelimit $outlimit
# compile
case $language in
cpp) 
    g++ -O2 -o $DIRCELLS/$id/out $DIRCELLS/$id/source.cpp;
    chmod +x $DIRCELLS/$id/out
    ;;
c) 
    gcc -O2 -o $DIRCELLS/$id/out $DIRCELLS/$id/source.c;
    chmod +x $DIRCELLS/$id/out
    ;;
*) 
    cp $DIRCELLS/$id/source.$language $DIRCELLS/$id/out;
    chmod +x $DIRCELLS/$id/out
    ;;
esac
#in case of compile errors -> say it to storage

#create ulimits
ulimit -c 0             # max. size of coredump files in kB
ulimit -v $memlimit     # max. total memory usage in kB
ulimit -s $memlimit     # max. stack size: set the same as max. memory usage
ulimit -f $outlimit     # max. size of created files in kB
ulimit -u 0             # max. no. processes


# define if its binary or interpreter
# run it on tests and diff with outs
# send results to storage

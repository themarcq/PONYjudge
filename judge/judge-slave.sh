#!/bin/bash
source ./judge.conf
id=$1
problem=$2
language=$3
memlimit=$4
timelimit=$5
outlimit=$5

#compile and if there was something wrong - send it to storage
compile=`$RUN $DIRCOMP/compile_$language $id 1024 1 10.000`  
if [ ! "x`echo \"$compile\" | grep 'ERROR'`" == "x" ]
then
    $REQUEST "DATABASE UPDATE sources SET status='Compilation Error', error='$compile', judging=FALSE, judged=TRUE WHERE id='$id'"
    exit
fi


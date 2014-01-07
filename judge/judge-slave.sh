#!/bin/bash
source ./judge.conf
id=$1
problem=$2
language=$3
memlimit=$4
timelimit=$5
outlimit=$5

#compile and if there was something wrong - send it to storage
compile=`$RUN $DIRCOMP/compile_$language $id 1024 128 10.000`  
if [ ! "x`echo \"$compile\" | grep 'ERROR'`" == "x" ] 
then
    $REQUEST "DATABASE UPDATE sources SET status='Compilation Error', error='$compile', judging=FALSE, judged=TRUE WHERE id='$id'"
    exit
fi
if [ ! "x`echo \"$compile\" | grep 'TLE'`" == "x" ]
then
    $REQUEST "DATABASE UPDATE sources SET status='Compilation Error', error='Time limit excided', judging=FALSE, judged=TRUE WHERE id='$id'"
    exit
fi

tmpfile="/tmp/$RANDOM$RANDOM$RANDOM$RANDOM$RANDOM$RANDOM"

#run it on tests
for test in `ls $DIRINS/$id`
do
    $RUN $DIRCELLS/$id/out $memlimit $outlimit $timelimit < $DIRINS/$id/$test > $tmpfilee
    #check if there where errors TODO
    #check diff
    differents=`diff $tmpfile $DIROUTS/$id/$test`
    #go to storage
    $REQUEST "DATABASE UPDATE sources SET "
done
$REQUEST "DATABASE UPDATE sources SET status='judged', judging=FALSE, judged=TRUE, WHERE id='$id'"


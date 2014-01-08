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
    $REQUEST "DATABASE UPDATE solutions SET results='Compilation Error - $compile', judging=FALSE, judged=TRUE WHERE id='$id'"
    exit
fi
if [ ! "x`echo \"$compile\" | grep 'TLE'`" == "x" ]
then
    $REQUEST "DATABASE UPDATE solutions SET results='Compilation Error - Time limit excided', judging=FALSE, judged=TRUE WHERE id='$id'"
    exit
fi

tmpfile="/tmp/$RANDOM$RANDOM$RANDOM$RANDOM$RANDOM$RANDOM"
$REQUEST "DATABASE UPDATE solutions SET results='' WHERE id='$id'"
#run it on tests
for test in `ls $DIRINS/$id`
do
    $RUN $DIRCELLS/$id/out $memlimit $outlimit $timelimit < $DIRINS/$id/$test > $tmpfilee
    #check if there where errors TODO
    #check diff
    differents=`diff $tmpfile $DIROUTS/$id/$test`
    #go to storage
    $result = `$REQUEST "DATABASE SELECT results FROM solutions WHERE id='$id'"`
    if [ "x$differents" == "x" ]
    then
        $result="$result$id:WA;"
    else
        $result="$result$id:AC;"
    fi
    $REQUEST "DATABASE UPDATE solutions SET results='$result' WHERE id='$id'"
done
$REQUEST "DATABASE UPDATE solutions SET status='judged', judging=FALSE, judged=TRUE, WHERE id='$id'"


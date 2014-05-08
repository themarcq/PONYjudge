#!/bin/bash
source ./judge.conf
id=$1
problem=$2
language=$3
memlimit=$4
timelimit=$5
outlimit=$5
nbd=$6
#compile

tmpfile="/tmp/$RANDOM$RANDOM$RANDOM"
timelimit -t 60 -T 61 $DIRCOMP/compile_$language $id 2>&1 > $tmpfile
exitcode=$?
if [ "$exitcode" != "0" ]
then
echo sth wrong
fi

#make .img out of tests and program
qemu-img create -f qcow2 $DIRCELLS/$id/image.img 5G
qemu-nbd -c /dev/nbd$nbd $DIRCELLS/$id/image.img 5G
mkdir $DIRCELLS/$id/mount
mkdir $DIRCELLS/$id/mount/ins
mkdir $DIRCELLS/$id/mount/outs
mount /dev/nbd$nbd $DIRCELLS/$id/mount
cp $DIRINS/$id/* $DIRINS/$id/mount/ins/
cp $DIRINS/$id/out $DIRINS/$id/mount/

#run judge.img(read only) with previously created img as hdb
umount $DIRCELLS/$id/mount
qemu-nbd -d /dev/nbd$nbd
qemu-system-i386 -drive file=$JUDGEVM,index=0,media=disk,readonly -drive file=$DIRCELLS/$id/image.img,index=1,media=disk -vga none

#take its results and send to storage
qemu-nbd -c /dev/nbd$nbd $DIRCELLS/$id/image.img 5G
mkdir $DIRCELLS/$id/mount
mount /dev/nbd$nbd $DIRCELLS/$id/mount
cat $DIRCELLS/$id/mount/raport

#clean
umount $DIRCELLS/$id/mount
qemu-nbd -d /dev/nbd$nbd
rm -R $DIRCELLS/$id
$REQUEST "DATABASE UPDATE solutions SET status='judged', judging=FALSE, judged=TRUE, WHERE id='$id'"

#compile and if there was something wrong - send it to storage
#compile=`$RUN $DIRCOMP/compile_$language $id 1024 128 10.000`  
#if [ ! "x`echo \"$compile\" | grep 'ERROR'`" == "x" ] 
#then
#
#$REQUEST "DATABASE UPDATE solutions SET results='' WHERE id='$id'"
#run it on tests
#for test in `ls $DIRINS/$id`
#do
#    $RUN $DIRCELLS/$id/out $memlimit $outlimit $timelimit < $DIRINS/$id/$test > $tmpfile
#    #check if there where errors TODO
#    #check diff
#    differents=`diff $tmpfile $DIROUTS/$id/$test`
#    #go to storage
#    $result = `$REQUEST "DATABASE SELECT results FROM solutions WHERE id='$id'"`
#    if [ "x$differents" == "x" ]
#    then
#        $result="$result:$id:WA;"
#    else
#        $result="$result:$id:AC;"
#    fi
#    $REQUEST "DATABASE UPDATE solutions SET results='$result' WHERE id='$id'"
#done
#$REQUEST "DATABASE UPDATE solutions SET status='judged', judging=FALSE, judged=TRUE, WHERE id='$id'"


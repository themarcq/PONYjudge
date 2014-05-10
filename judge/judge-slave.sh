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
rm $tmpfile
exit
fi
rm $tmpfile

#make .img out of tests and program
qemu-img create -f qcow2 $DIRCELLS/$id/image.img 10G
qemu-nbd -c /dev/nbd$nbd $DIRCELLS/$id/image.img
mkfs.ext2 /dev/nbd0
MOUNT="$DIRCELLS/$id/mount"
mkdir $MOUNT
mount /dev/nbd$nbd $MOUNT
cp $DIRCELLS/$id/out $MOUNT/program
cp JudgeVM/Judge.sh $MOUNT
mkdir $MOUNT/ins
mkdir $MOUNT/outs
7z e -o$MOUNT/ins $DIRINS/$problem.7z
7z e -o$MOUNT/outs $DIROUTS/$problem.7z

#run judge.img(read only) with previously created img as hdb
umount $DIRCELLS/$id/mount
qemu-nbd -d /dev/nbd$nbd
LOCATION="./JudgeVM"
KERNEL="bzImage"
				
qemu-system-i386 -kernel $LOCATION/$KERNEL \
-serial stdio \
-append "console=ttyS0" \
-hda $DIRCELLS/$id/image.img \
-boot c \
-m $memlimit \
-localtime \
-no-reboot \

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


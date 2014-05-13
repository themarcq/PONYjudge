#!/bin/bash
#set -x
#trap read debug

source ./judge.conf
id=1
nbd=0
problem=1
memlimit=128
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
qemu-nbd -c /dev/nbd$nbd $DIRCELLS/$id/image.img
mkdir $DIRCELLS/$id/mount
mount /dev/nbd$nbd $DIRCELLS/$id/mount
cat $DIRCELLS/$id/mount/raport

#clean
umount $DIRCELLS/$id/mount
qemu-nbd -d /dev/nbd$nbd
rm -R $DIRCELLS/$id
$REQUEST "DATABASE UPDATE solutions SET status='judged', judging=FALSE, judged=TRUE, WHERE id='$id'"

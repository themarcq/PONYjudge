#!/bin/bash
echo Loading Config
source ./judge.conf
echo "Checking if modules aren't missing"
#making sure nbd is loaded
modprobe nbd max_part=63
if [[ $? -ne 0 ]]; then
    echo Modprobe failed!
    exit 1
fi
id=1
problem=1
language=c
timelimit=1
memlimit=128
nbd=0
LOGDIR="$DIRCELLS/$id/logs"
mkdir $LOGDIR -p

#compile
echo Compiling source
timelimit -t 60 -T 60 \
  $DIRCOMP/$language \
    $DIRCELLS/$id/source.$language \
    $DIRCELLS/$id/out \
    $LOGDIR/compile

if [[ $? -ne 0 ]]; then
    echo "Compilation error!"
    echo "Sending Report"
    #send report
    exit 0
fi

#make .img out of tests and program
echo Creating tests image
qemu-img create -f qcow2 $DIRCELLS/$id/image.img 10G > $LOGDIR/imgcreate

if [[ $? -ne 0 ]]; then
    echo "Creating image failed!"
    exit 1
fi

echo Formatting image
qemu-nbd -c /dev/nbd$nbd $DIRCELLS/$id/image.img >> $LOGDIR/imgcreate

if [[ $? -ne 0 ]]; then
    echo "Connecting image to /dev/nbd failed!"
    exit 1
fi

mkfs.ext2 /dev/nbd0 >> $LOGDIR/imgcreate

if [[ $? -ne 0 ]]; then
    echo "Formatting Failed!"
    exit 1
fi

echo Mounting image and extracting tests
MOUNT="$DIRCELLS/$id/mount"
mkdir $MOUNT -p
mount /dev/nbd$nbd $MOUNT
cp $DIRCELLS/$id/out $MOUNT/program
cp JudgeVM/Judge.sh $MOUNT
cp JudgeVM/timelimit $MOUNT
cp JudgeVM/time $MOUNT
mkdir $MOUNT/ins
mkdir $MOUNT/outs
7z e -o$MOUNT/ins $DIRINS/$problem.7z > $LOGDIR/extracting
7z e -o$MOUNT/outs $DIROUTS/$problem.7z >> $LOGDIR/extracting
sed -i "s/\%TIMELIMIT\%/$timelimit/g" $MOUNT/Judge.sh

#run judging VM with created image as hda
echo Running Testing Virtual Machine
umount $DIRCELLS/$id/mount
qemu-nbd -d /dev/nbd$nbd
LOCATION="./JudgeVM"
KERNEL="bzImage"
				
qemu-system-i386 -kernel $LOCATION/$KERNEL \
-serial stdio \
-append "quiet console=ttyS0" \
-append "console=ttyS0" \
-hda $DIRCELLS/$id/image.img \
-boot c \
-m $memlimit \
-localtime \
-no-reboot > $LOGDIR/VM

if [[ $? -ne 0 ]]; then
    echo "Machine Failed to start!"
    exit 1
fi
echo Judged!

#take its results and send to storage
echo Sending results to storage
qemu-nbd -c /dev/nbd$nbd $DIRCELLS/$id/image.img
mkdir $DIRCELLS/$id/mount
mount /dev/nbd$nbd $DIRCELLS/$id/mount
cat $DIRCELLS/$id/mount/raport

#clean
echo Cleaning
umount $DIRCELLS/$id/mount
qemu-nbd -d /dev/nbd$nbd
exit 0

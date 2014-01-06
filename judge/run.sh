#!/bin/bash
source ./judge.conf
timelimit=$4
tmpfile="/tmp/$RANDOM$RANDOM$RANDOM$RANDOM$RANDOM$RANDOM"
echo "sudo -u $JUDGEUSER bash $LIMITER $1 $2 $3"
sudo -u $JUDGEUSER "bash $LIMITER $1 $2 $3" > $tmpfile &
pid=$!
(sleep $timelimit;if [ ! "x`ps -e | grep $pid`" == "x" ]; then kill $pid; fi)&
wait $pid
cat $tmpfile
rm $tmpfile

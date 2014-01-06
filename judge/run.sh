#!/bin/bash
PATH=/usr/bin:/bin:/usr/sbin:/sbin
source ./judge.conf
timelimit=$4
tmpfile="/tmp/$RANDOM$RANDOM$RANDOM$RANDOM$RANDOM$RANDOM"
sudo -u $JUDGEUSER $LIMITER "$1" "$2" "$3" > $tmpfile &
pid=$!
(sleep $timelimit;if [ ! "x`ps -e | grep $pid`" == "x" ]; then kill $pid;echo 'lol, I killed that fucker'; fi)&
wait $pid
echo '<wynik>'
cat $tmpfile
echo '</wynik>'
rm $tmpfile

#!/bin/bash
timelimit=$4
tmpfile="/tmp/$RANDOM$RANDOM$RANDOM"
sudo -u $JUDGEUSER "$LIMITER $1 $2 $3" > $tmpfile &
pid=$!
(sleep $timelimit;kill $pid)&
wait $pid
cat $tmpfile
rm $tmpfile

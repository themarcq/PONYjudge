#!/bin/bash
PATH=/usr/bin:/bin:/usr/sbin:/sbin
source ./judge.conf
timelimit=$4
tmpfile="/tmp/$RANDOM$RANDOM$RANDOM$RANDOM$RANDOM$RANDOM"
commandline="$LIMITER \"$1\" $2 $3"
su $JUDGEUSER -s /bin/bash -c "${commandline}" > $tmpfile &
pid=$!
(sleep $timelimit;if [ ! "x`ps -e | grep $pid`" == "x" ]; then kill -s SIGKILL $pid;echo 'lol, I killed that fucker'; fi)&
wait $pid 2> /dev/null
echo '<wynik>'
cat $tmpfile
echo '</wynik>'
rm $tmpfile

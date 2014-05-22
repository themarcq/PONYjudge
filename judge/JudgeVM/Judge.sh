#!/bin/sh

USER="judgeuser"
adduser -g "" -H -D $USER

TIMELIMIT=%TIMELIMIT%

echo
echo "==========================starting judge process=========================="
echo

DIR="/mnt"
touch $DIR/tmpout
chmod -R 0 $DIR
chmod +x $DIR/program
chmod +x $DIR/timelimit
chmod +x $DIR/time
chmod 555 $DIR
chmod 444 $DIR/ins/*
chmod 555 $DIR/ins
chmod 777 $DIR/tmpout
RAPORT="$DIR/raport"
echo "RAPORT" > $RAPORT
chmod 0 $RAPORT
echo "----------"

for i in $DIR/ins/*
do
    FILE=`echo $i | grep -o '[0-9]*'`
    IN="$DIR/ins/$FILE.in"
    OUT="$DIR/outs/$FILE.out"
    echo "Judging $IN"
    $DIR/timelimit -t $TIMELIMIT -T $TIMELIMIT \
      $DIR/time -o $DIR/timelog -f "%e" \
        echo "ulimit -p 2;$DIR/program < $IN > $DIR/tmpout;exit $?" | su $USER
    EXIT=$?
    if [ "x$EXIT" == "x143" ]
    then
        echo "$FILE:TLE" >> $RAPORT
        echo "$FILE:TLE"
        echo "----------"
    elif [ "x$EXIT" != "x0" ]
    then
        echo "$FILE:NZEC:$EXIT"
        echo "$FILE:NZEC:$EXIT" >> $RAPORT
        echo "---------"
    else
        a=`diff -B -b $DIR/tmpout $OUT`
        if [ "x$a" == "x" ]
        then
            echo -n -e "$FILE:AC:" >> $RAPORT
            echo -n -e "$FILE:AC:"
            cat $DIR/timelog >> $RAPORT
            cat $DIR/timelog
            echo "----------"
        else
            echo "$FILE:WA" >> $RAPORT
            echo "$FILE:WA"
            echo "----------"
        fi
    fi
done

echo
echo "==========================stopping judge process=========================="
echo

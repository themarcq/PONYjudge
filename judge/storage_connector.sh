#/bin/bash
source ./judge.conf
RESPONSE=`echo "$1" | ssh storage@$STORAGEIP -q`
if [ "x`grep '^DATABASE' $1`" == "x" ]
then
    echo $RESPONSE;
fi

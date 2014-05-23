#!/bin/bash
source ./judge.conf
RESPONSE=`echo "$1" | ssh storage@$STORAGEIP -q -i $DIRCERTS/id_rsa`
echo $RESPONSE;

#!/bin/bash
source ./judge.conf
echo $1 | ssh ponyjudge_storage@$STORAGEIP -q -i $DIRCERTS/id_rsa
#echo $RESPONSE;

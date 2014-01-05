#/bin/bash
source ./judge.conf
echo "$1" | ssh storage@$STORAGEIP -q

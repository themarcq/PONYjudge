#/bin/bash
./judge.config
echo "$1" | ssh -i $DIR/id_rsa $STORAGEIP

#@/bin/bash
./judge.conf
REQUEST="./storage_connector.sh "
slots=0 
while :
do
    #if we have free slots
    if [ $slots -lt $MAXSLOTS ]
    then
        #check if there is something new
        id=`$REQUEST 'DATABASE SELECT ids FROM sources WHERE judged=FALSE AND judging=FALSE LIMIT 1' `
        if [ -n $id ]
        then
            #check what problem it is and download md5hash of tests
            problem=`$REQUEST "DATABASE SELECT problem FROM sources WHERE id=$id"`
            inshash=`$REQUEST "DATABASE SELECT inshash FROM problems WHERE id=$problem"`
            outshash=`$REQUEST "DATABASE SELECT outshash FROM problems WHERE id=$problem"`
            #if there are no ins or they are outdated
            if [ ! -a $DIR/tests/ins/$problem.7z ] || [ $inshash != `cat $DIR/tests/ins/$problem.hash` ]
            then
                $REQUEST "FILE TESTSIN $id.7z" > $DIR/tests/ins/$problem.7z
                $REQUEST "DATABASE SELECT inshash FROM problems WHERE id=$problem" > $DIR/tests/ins/$problem.hash
            fi
            #if there are no outs or they are outdated
            if [ ! -a $DIR/tests/outs/$problem.7z ] || [ $outshash != `cat $DIR/tests/outs/$problem.hash` ]
            then
                $REQUEST "FILE TESTSOUT $id.7z" > $DIR/tests/outs/$problem.7z
                $REQUEST "DATABASE SELECT outshash FROM problems WHERE id=$problem" > $DIR/tests/outs/$problem.hash
            fi
            #download source,create cell and give all the info for some judge-slave
            
        fi
        #cleaning ( I don't know what to do here, but if there would be something, it will be there )
    fi
    sleep 0.25
done

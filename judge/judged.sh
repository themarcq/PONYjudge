#@/bin/bash
source ./judge.conf
REQUEST="./storage_connector.sh "
slots=1 
while :
do
    #if we have free slots
    if [ "$slots" -lt "$MAXSLOTS" ]
    then
        #check if there is something new
        id=`$REQUEST 'DATABASE SELECT id FROM sources WHERE judged=FALSE AND judging=FALSE LIMIT 1' `
        if [ -n $id ]
        then
            #reserve it
            $REQUEST "DATABASE UPDATE VALUES judging=TRUE FROM sources WHERE id=$id"
            #check what problem it is and download md5hash of tests
            problem=`$REQUEST "DATABASE SELECT problem FROM sources WHERE id=$id"`
            inshash=`$REQUEST "DATABASE SELECT inshash FROM problems WHERE id=$problem"`
            outshash=`$REQUEST "DATABASE SELECT outshash FROM problems WHERE id=$problem"`
            #if there are no ins or they are outdated
            if [ ! -a $DIRINS/$problem.7z ] || [ $inshash != `cat $DIRINS/$problem.hash` ]
            then
                $REQUEST "FILE TESTSIN $id.7z" > $DIRINS/$problem.7z
                $REQUEST "DATABASE SELECT inshash FROM problems WHERE id=$problem" > $DIRINS/$problem.hash
            fi
            #if there are no outs or they are outdated
            if [ ! -a $DIROUTS/$problem.7z ] || [ $outshash != `cat $DIROUTS/$problem.hash` ]
            then
                $REQUEST "FILE TESTSOUT $id.7z" > $DIROUTS/$problem.7z
                $REQUEST "DATABASE SELECT outshash FROM problems WHERE id=$problem" > $DIROUTS/$problem.hash
            fi
            #download source and give all the info for some judge-slave
            #create cell
            if [ ! -d "$DIRECTORY" ]; then
                mkdir "$DIRCELLS/$id"
            fi
            
            #download sources
            type=`$REQUEST "DATABASE SELECT type FROM sources WHERE id=$id"`
            memlimit=`$REQUEST "DATABASE SELECT memlimit FROM problems WHERE id=$problem"`
            timelimit=`$REQUEST "DATABASE SELECT timelimit FROM problems WHERE id=$problem"`
            $REQUEST "FILE source $id.$type" > "$DIRCELLS/$id/source.$type"
            chmod 0 "$DIRCELLS/$id"
            #give infos to judge-slave
            $DIR/judge-slave.sh $id $problem $type $memlimit $timelimit &
        fi
        #cleaning ( I don't know what to do here, but if there would be something, it will be there )
    fi
    sleep 0.25
done

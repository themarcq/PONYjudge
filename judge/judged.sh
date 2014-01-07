#@/bin/bash
source ./judge.conf
pids[0]=0

function slots_busy {
    for i in `seq 1 ${pids[0]}`
    do
        if [ "x`ps -e | grep ${pids[$i]}`" == "x" ]
        then
            remove_pid $i
            pids[0]=`expr ${pids[0]} - 1`
        fi
    done
}

function remove_pid {
    end=`expr ${pids[0]} - 1`
    for i in `seq $1 ${pids[0]}`
    do
        pids[$i]=pids[`expr $i + 1`]
    done
}

function add_pid {
    pids[0]=`expr ${pids[0]} + 1`
    pids[${pids[0]}]=$1
}

while :
do
    #if we have free slots
    slotsb=`slots_busy`
    if [ "$slotsb" -lt "$MAXSLOTS" ]
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
                rm -R $DIRINS/$problem
                mkdir $DIRINS/$problem
                7z e $DIRINS/$problem.7z -o$DIRINS/$problem/
            fi
            #if there are no outs or they are outdated
            if [ ! -a $DIROUTS/$problem.7z ] || [ $outshash != `cat $DIROUTS/$problem.hash` ]
            then
                $REQUEST "FILE TESTSOUT $id.7z" > $DIROUTS/$problem.7z
                $REQUEST "DATABASE SELECT outshash FROM problems WHERE id=$problem" > $DIROUTS/$problem.hash
                 rm -R $DIROUTS/$problem
                 mkdir $DIROUTS/$problem
                 7z e $DIROUTS/$problem.7z -o$DIROUTS/$problem/
            fi
            #download source and give all the info for some judge-slave
            type=`$REQUEST "DATABASE SELECT type FROM sources WHERE id=$id"`
            memlimit=`$REQUEST "DATABASE SELECT memlimit FROM problems WHERE id=$problem"`
            timelimit=`$REQUEST "DATABASE SELECT timelimit FROM problems WHERE id=$problem"`
            $REQUEST "FILE source $id.$type" > "$DIRCELLS/$id/source.$type"
            #give infos to judge-slave
            $SLAVE $id $problem $type $memlimit $timelimit &
            #save its pid
            add_pid $!
        fi
    fi
    sleep 0.25
done

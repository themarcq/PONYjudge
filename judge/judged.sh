#@/bin/bash
source ./judge.conf
echo Loading modules
modprobe nbd max_part=63
echo Establishing connectin to storage
autossh -M 0 -f -- ponyjudge_storage@192.168.56.101 -MNf -i $DIRCERTS/id_rsa

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
    echo ${pids[0]}
}

function remove_pid {
    echo "releasing pid ${pids[$i]}"
    end=`expr ${pids[0]} - 1`
    for i in `seq $1 ${pids[0]}`
    do
        pids[$i]=pids[`expr $i + 1`]
    done
}

function add_pid {
    pids[0]=`expr ${pids[0]} + 1`
    pids[${pids[0]}]=$1
    echo "adding pid $1"
}

while :
do
    #if we have free slots
    slotsb=`slots_busy`
    if [ "$slotsb" -lt "$MAXSLOTS" ]
    then
        #check if there is something new
        id=`$REQUEST 'DATABASE SELECT id FROM solutions WHERE judged=FALSE AND judging=FALSE LIMIT 1' `
	if [ "x$id" != "x" ]
        then
	    re='^[0-9]+$'
            if ! [[ $id =~ $re ]] ; then
                echo "error: Wrong id, maybe wrong storage request"; exit 1
            fi
            #reserve it
            $REQUEST "DATABASE UPDATE VALUES judging=TRUE FROM solutions WHERE id=$id"
            #check what problem it is and download md5hash of tests
            problem=`$REQUEST "DATABASE SELECT problem FROM solutions WHERE id=$id"`
            inshash=`$REQUEST "DATABASE SELECT inshash FROM problems WHERE id=$problem"`
            outshash=`$REQUEST "DATABASE SELECT outshash FROM problems WHERE id=$problem"`
            #if there are no ins or they are outdated
            if [ ! -a $DIRINS/$problem.7z ] || [ $inshash != `cat $DIRINS/$problem.hash` ]
            then
                $REQUEST "FILE TAKE $id.in.7z" > $DIRINS/$problem.7z
                $REQUEST "DATABASE SELECT inshash FROM problems WHERE id=$problem" > $DIRINS/$problem.hash
            fi
            #if there are no outs or they are outdated
            if [ ! -a $DIROUTS/$problem.7z ] || [ $outshash != `cat $DIROUTS/$problem.hash` ]
            then
                $REQUEST "FILE TAKE $id.out.7z" > $DIROUTS/$problem.7z
                $REQUEST "DATABASE SELECT outshash FROM problems WHERE id=$problem" > $DIROUTS/$problem.hash
            fi
            #download source and give all the info for some judge-slave
            type=`$REQUEST "DATABASE SELECT type FROM solutions WHERE id=$id"`
            memlimit=`$REQUEST "DATABASE SELECT memlimit FROM problems WHERE id=$problem"`
            timelimit=`$REQUEST "DATABASE SELECT timelimit FROM problems WHERE id=$problem"`
            $REQUEST "FILE TAKE $id.$type" > "$DIRCELLS/$id/source.$type"
            #give infos to judge-slave
            $SLAVE $id $problem $type $memlimit $timelimit `expr ${pids[0]} + 1` &
            #save its pid
            add_pid $!
        fi
    fi
    sleep 1
done

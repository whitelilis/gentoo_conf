#!/bin/bash
lsof=$(which lsof)
sshpass=$(which sshpass)

local_port=7070
servers=(162.217.249.116)
ports=(180 22 185)
pws=(H872f2fsd )
users=(btssh )
try_times=5

function show_now(){
    ps ux | grep -v grep | grep $local_port
}

function proxy(){
    $lsof -i :$local_port
    if [ $? -eq 0 ] # proxy started
    then
        show_now
    else
        for server in ${servers[@]}
        do
            for port in ${ports[@]}
            do
                for user in ${users[@]}
                do
                    for pw in ${pws[@]}
                    do
                        $sshpass -p $pw ssh -fnCTN -D $local_port $user@$server -p $port
                        if [ $? -eq 0 ]
                        then
                            show_now
                            exit 0
                        fi
                    done
                done
            done
        done
    fi
}

for f in $(seq $try_times)
do
    proxy
done

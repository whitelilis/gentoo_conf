#!/bin/bash
lsof=$(which lsof)
sshpass=$(which sshpass)

local_port=7070
servers=(162.248.5.237 198.148.115.128 192.228.104.237 198.148.115.128)
ports=(22 25 110)
pws=(btssh.com )
users=(btssh )

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

proxy

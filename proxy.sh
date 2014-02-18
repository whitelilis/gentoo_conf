#!/bin/bash

function proxy(){
    port=7070
    lsof -i :$port
    if [ $? -eq 0 ] # proxy started
    then
        exit 0
    else
        sshpass -p btsshcom ssh -fnCTN -D $port btssh@192.228.104.237 -p 22 || \
        sshpass -p btsshcom ssh -fnCTN -D $port btssh@198.148.115.128 -p 22 || \
        sshpass -p btsshcom ssh -fnCTN -D $port btssh@192.228.104.237 -p 25 || \
        sshpass -p btsshcom ssh -fnCTN -D $port btssh@198.148.115.128 -p 25
    fi
}

proxy

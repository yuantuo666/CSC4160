#!/bin/bash

names=(
    "N. Virginia-c5.large"
    "Oregon-c5.large"
)

# server
servers_outer=(
    "54.224.252.25"
    "54.188.55.65"
)

servers_inner=(
    "172.31.40.132"
    "172.31.17.208"
)

# client
clients_outer=(
    "35.153.133.153"
    "35.93.32.3"
)

if [ ! -f login.pem ]; then
    echo "login.pem not found"
    exit 1
fi


if [ $1 == "env_server" ]; then
    for i in ${!names[@]}; do
        host=${servers_outer[$i]}
        type=${names[$i]}
        pem="login.pem"
        if [ "$type" == "Oregon-c5.large" ]; then
            pem="login2.pem"
        fi
        echo "=== [server] Connecting $type ($host) ==="
        ssh -i $pem ubuntu@$host 'hostname && exit'
        ssh -i $pem ubuntu@$host 'bash -s' < install_env.sh
    done
    exit 0
fi

if [ $1 == "env_client" ]; then
    for i in ${!names[@]}; do
        host=${clients_outer[$i]}
        type=${names[$i]}
        pem="login.pem"
        if [ "$type" == "Oregon-c5.large" ]; then
            pem="login2.pem"
        fi
        echo "=== [client] Connecting $type ($host) ==="
        ssh -i $pem ubuntu@$host 'hostname && exit'
        ssh -i $pem ubuntu@$host 'bash -s' < install_env.sh
    done
    exit 0
fi

if [ $1 == "start" ]; then
    for i in ${!names[@]}; do
        host=${servers_outer[$i]}
        type=${names[$i]}
        pem="login.pem"
        if [ "$type" == "Oregon-c5.large" ]; then
            pem="login2.pem"
        fi
        echo "=== [server] Connecting $type ($host) ==="
        ssh -i $pem ubuntu@$host 'bash -s' < start_iperf_server.sh
    done
    exit 0
fi

if [ $1 == "check" ]; then
    for i in ${!names[@]}; do
        host=${servers_outer[$i]}
        type=${names[$i]}
        pem="login.pem"
        if [ "$type" == "Oregon-c5.large" ]; then
            pem="login2.pem"
        fi
        echo "=== [server] Connecting $type ($host) ==="
        ssh -i $pem ubuntu@$host 'ps aux | grep iperf | grep -v grep'
    done
    exit 0
fi

if [ $1 == "stop" ]; then
    for i in ${!names[@]}; do
        host=${servers_outer[$i]}
        type=${names[$i]}
        pem="login.pem"
        if [ "$type" == "Oregon-c5.large" ]; then
            pem="login2.pem"
        fi
        echo "=== [server] Connecting $type ($host) ==="
        ssh -i $pem ubuntu@$host 'bash -s' < stop_iperf_server.sh
    done
    exit 0
fi

function run_exp() {
    server_index=$1
    client_index=$2
    server_outer=${servers_outer[$server_index]}
    server_inner=${servers_inner[$server_index]}
    client_outer=${clients_outer[$client_index]}
    client_type=${names[$client_index]}
    server_type=${names[$server_index]}
    pem="login.pem"
    if [ "$client_type" == "Oregon-c5.large" ]; then
        pem="login2.pem"
    fi
    echo "==============================================================================="
    echo "=== [client] $client_type ($client_outer) --> [server] $server_type ($server_inner) ==="
    echo "==============================================================================="
    ssh -i $pem ubuntu@$client_outer "ping $server_inner -c 5"
    ssh -i $pem ubuntu@$client_outer "iperf -c $server_inner -w 256K -p 80"
}

if [ $1 == "exp" ]; then
    run_exp 0 0 # N. Virginia --> N. Virginia
    run_exp 0 1 # N. Virginia --> Oregon
    run_exp 1 0 # Oregon --> N. Virginia
    run_exp 1 1 # Oregon --> Oregon
    exit 0
fi


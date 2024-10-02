#!/bin/bash

names=(
    "t3.medium"
    "m5.large"
    "c5n.large"
)

# server
servers_outer=(
    "107.22.94.171"
    "54.164.5.16"
    "44.212.51.107"
)

servers_inner=(
    "172.31.17.181"
    "172.31.22.208"
    "172.31.10.187"
)

# client
clients_outer=(
    "34.234.69.10"
    "34.202.231.79"
    "98.81.51.117"
)

if [ ! -f login.pem ]; then
    echo "login.pem not found"
    exit 1
fi


if [ $1 == "env_server" ]; then
    for i in ${!names[@]}; do
        host=${servers_outer[$i]}
        type=${names[$i]}
        echo "=== [server] Connecting $type ($host) ==="
        ssh -i login.pem ubuntu@$host 'hostname && exit'
        ssh -i login.pem ubuntu@$host 'bash -s' < install_env.sh
    done
    exit 0
fi

if [ $1 == "env_client" ]; then
    for i in ${!names[@]}; do
        host=${clients_outer[$i]}
        type=${names[$i]}
        echo "=== [client] Connecting $type ($host) ==="
        ssh -i login.pem ubuntu@$host 'hostname && exit'
        ssh -i login.pem ubuntu@$host 'bash -s' < install_env.sh
    done
    exit 0
fi

if [ $1 == "start" ]; then
    for i in ${!names[@]}; do
        host=${servers_outer[$i]}
        type=${names[$i]}
        echo "=== [server] Connecting $type ($host) ==="
        ssh -i login.pem ubuntu@$host 'bash -s' < start_iperf_server.sh
    done
    exit 0
fi

if [ $1 == "check" ]; then
    for i in ${!names[@]}; do
        host=${servers_outer[$i]}
        type=${names[$i]}
        echo "=== [server] Connecting $type ($host) ==="
        ssh -i login.pem ubuntu@$host 'ps aux | grep iperf | grep -v grep'
    done
    exit 0
fi

if [ $1 == "stop" ]; then
    for i in ${!names[@]}; do
        host=${servers_outer[$i]}
        type=${names[$i]}
        echo "=== [server] Connecting $type ($host) ==="
        ssh -i login.pem ubuntu@$host 'bash -s' < stop_iperf_server.sh
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
    echo "==============================================================================="
    echo "=== [client] $client_type ($client_outer) --> [server] $server_type ($server_inner) ==="
    echo "==============================================================================="
    ssh -i login.pem ubuntu@$client_outer "ping $server_inner -c 5"
    ssh -i login.pem ubuntu@$client_outer "iperf -c $server_inner -w 256K -p 80"
}

if [ $1 == "exp" ]; then
    run_exp 0 0 # t3.medium --> t3.medium
    run_exp 1 1 # m5.large --> m5.large
    run_exp 2 2 # c5n.large --> c5n.large
    run_exp 0 2 # t3.medium --> c5n.large
    run_exp 1 2 # m5.large --> c5n.large
    run_exp 1 0 # m5.large --> t3.medium
    exit 0
fi


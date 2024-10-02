#!/bin/bash

hosts=(
    "ubuntu@3.85.184.103"
    "ubuntu@18.208.214.238"
    "ubuntu@54.89.227.254"
)
types=(
    "t3.medium"
    "m5.large"
    "c5d.large"
)

if [ ! -f login.pem ]; then
    echo "login.pem not found"
    exit 1
fi

if [ ! -f "$1" ]; then
    echo "$1 not found"
    exit 1
fi

for i in ${!hosts[@]}; do
    host=${hosts[$i]}
    type=${types[$i]}
    echo "=== Connecting $type ($host) ==="
    ssh -i login.pem $host 'bash -s' < $1
done

# ./ssh_start.sh install_env.sh
# ./ssh_start.sh benchmark_q1.sh
# ./ssh_start.sh start_iperf_server.sh
# ./ssh_start.sh stop_iperf_server.sh
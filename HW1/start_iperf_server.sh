#!/bin/bash

function print_run() {
    echo "+ $@"
    eval $@
}

echo "> Starting iperf server"
print_run sudo iperf -p 80 -s -w 256K > ./iperf_server.log 2>&1 & disown
echo "> iperf server started"
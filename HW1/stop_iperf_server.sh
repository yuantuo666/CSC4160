#!/bin/bash

function print_run() {
    echo "+ $@"
    eval $@
}


echo "> Stopping iperf server"
print_run sudo pkill -f "iperf"
echo "> iperf server stopped"
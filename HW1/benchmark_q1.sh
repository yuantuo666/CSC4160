#!/bin/bash

function print_run() {
    echo "+ $@"
    eval $@
}

echo "> Benchmarking CPU"
print_run sysbench --threads=4 --cpu-max-prime=20000 cpu run

echo "> Benchmarking Memory"
print_run sysbench --threads=4 --memory-total-size=10G memory run
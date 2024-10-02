# CSC4160 Assignment-1: EC2 Measurement (2 questions)

### Deadline: 23:59, Sep 22, Sunday
---

### Name: Wang Chaoren
### Student Id: 122090513
---

## Question 1: Measure the EC2 CPU and Memory performance

1. (1 mark) Report the name of measurement tool used in your measurements (you are free to choose any open source measurement software as long as it can measure CPU and memory performance). Please describe your configuration of the measurement tool, and explain why you set such a value for each parameter. Explain what the values obtained from measurement results represent (e.g., the value of your measurement result can be the execution time for a scientific computing task, a score given by the measurement tools or something else).

    - Tool: SysBench. 
    - Environment setup: Ubuntu 24.04 LTS. + `sudo apt-get update && sudo apt-get install sysbench -y`
    - Command for benchmarking CPU performance: `sysbench --threads=4 --cpu-max-prime=20000 cpu run`
        - `cpu`: specify the test type as CPU.
        - `--threads=4`: number of worker threads. Maximizing the utilization of CPU across multiple cores.
        - `--cpu-max-prime=20000`: N upper limit for primes generator. Make sure the CPU is fully utilized.
    - Command for benchmarking memory performance: `sysbench --threads=4 --memory-total-size=10G memory run`
        - `memory`: specify the test type as memory.
        - `--threads=4`: number of worker threads. Maximizing the utilization of CPU across multiple cores.
        - `--memory-total-size=10G`: total size of data to transfer. Make sure the memory transfer rate is fully utilized.
    - CPU performance: `the events per second`, the number of events that can be processed per second.
    - Memory performance: `the memory transfer rate`, the rate of transferring data between memory and CPU.

2. (1 mark) Run your measurement tool on general purpose `t3.medium`, `m5.large`, and `c5d.large` Linux instances, respectively, and find the performance differences among them. Launch all instances in the **US East (N. Virginia)** region. What about the differences among these instances in terms of CPU and memory performance? Please try explaining the differences. 

    In order to answer this question, you need to complete the following table by filling out blanks with the measurement results corresponding to each instance type.

    | Size      | CPU performance | Memory performance |
    |-----------|-----------------|--------------------|
    | `t3.medium` |     571.28      |   5788.18 MiB/sec  |
    | `m5.large`  |     642.29      |   6910.65 MiB/sec  |
    | `c5d.large` |     747.78      |   7962.76 MiB/sec  |

    > Region: US East (N. Virginia)

    Full log can be found in file `q1.log`.

## Question 2: Measure the EC2 Network performance

1. (1 mark) The metrics of network performance include **TCP bandwidth** and **round-trip time (RTT)**. Within the same region, what network performance is experienced between instances of the same type and different types? In order to answer this question, you need to complete the following table.  

    | Type          | TCP b/w (Gbits/sec) | RTT (ms) |
    |---------------|----------------|----------|
    | `t3.medium`-`t3.medium` |  2.28  |  0.248  |
    | `m5.large`-`m5.large`   |  4.61  |  0.169  |
    | `c5n.large`-`c5n.large` |  4.21  |  0.121  |
    | `t3.medium`-`c5n.large` |  1.22  |  0.552  |
    | `m5.large`-`c5n.large`  |  1.21  |  0.532  |
    | `m5.large`-`t3.medium`  |  3.66  |  0.162  |

    > Region: US East (N. Virginia)

    Note here `c5n.large` is assigned in available zone `us-east-1d`, which causes the TCP bandwidth to be lower than the other two instances (which both are `us-east-1b`). The RTT is also higher than the other two instances.

    TCP Bandwith: *.large > *.medium. RTT: *.medium > *.large.

    TCP Bandwith: same zone > different zone. RTT: different zone > same zone.

    Full log can be found in file `q2_1.log`.

2. (1 mark) What about the network performance for instances deployed in different regions? In order to answer this question, you need to complete the following table.

    | Connection | TCP b/w (Mbps)  | RTT (ms) |
    |------------|-----------------|--------------------|
    | N. Virginia-Oregon |   12.1 Mbits/sec  |  64.5  |
    | N. Virginia-N. Virginia  | 4.06 Gbits/sec |  0.197    |
    | Oregon-Oregon |   3.26 Gbits/sec   |   0.239   |

    > All instances are `c5.large`.

    Note that different reigons did not share a internal network, which causes cross-region performance lower than the same region.

    TCP Bandwith: Same region >> different region. RTT: different region >> same region.

    Full log can be found in file `q2_2.log` and `q2_2_public.log`. The public log is the log for the public IP address of the instances.


## References

- [SysBench](https://github.com/akopytov/sysbench?tab=readme-ov-file#general-command-line-options)

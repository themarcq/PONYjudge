#!/bin/bash
$program=$1
$memlimit=$2
$outlimit=$3

ulimit -c 0             # max. size of coredump files in kB
ulimit -v $memlimit     # max. total memory usage in kB
ulimit -s $memlimit     # max. stack size: set the same as max. memory usage
ulimit -f $outlimit     # max. size of created files in kB
ulimit -u 1             # max. no. processes

$program &>1

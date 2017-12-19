#!/bin/bash

if [ `grep -c $1 /home/group/config/my.cnf` -eq '0' ]; then
    exit 1
else
    exit 0
fi

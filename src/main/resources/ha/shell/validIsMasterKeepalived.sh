#!/bin/bash

ipaddrs=$(ip addr | grep '[0-9]\{1,3\}\.[0-9]\{1,3\}\.' | grep -v "127.0.0.1" | grep $1 | grep inet | cut -d "/" -f1 | sed "s/^.*inet//g")
if [ ! -z "$ipaddrs" ]; then
    exit 0
else
    exit 1
fi

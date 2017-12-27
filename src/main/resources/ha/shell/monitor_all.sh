#!/bin/bash

##
docker_process=`docker ps | grep $1 | awk  "{print $5}"`
if [ -z "$docker_process" ];then
    exit 1
else
    exit 0
fi

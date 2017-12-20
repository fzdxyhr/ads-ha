#!/bin/bash


otherIp=192.168.104.120

OLD_IFS="$IFS"
IFS=","
arr=($otherIp)
IFS="$OLD_IFS"
for ip in ${arr[@]}
do
	echo $ip
done


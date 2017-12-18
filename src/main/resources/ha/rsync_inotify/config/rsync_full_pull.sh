#!/bin/bash

source /opt/ads-ha/WEB-INF/classes/ha/shell/resource.sh
source $PATH/global.sh

log_file=$HA_PATH/rsync_inotify/log/rsync_client.log

server_ip=$1

if [[ ! $server_ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
	echo "parameter input error, Please enter the correct ip" 
	echo "$FORMAT_DATE: parameter input error, Please enter the correct ip" >> $log_file
	exit 1
fi

ret=`/bin/ping -c 3 -W 1 $server_ip |grep ttl|wc -l`   #ping
if [ $ret -eq 0 ]; then     #等于0，不通
	echo "$FORMAT_DATE: Remote Rsyncd off, give up pull data from $localhost"
	echo "$FORMAT_DATE: Remote Rsyncd off, give up pull data from $localhost" >> $log_file
	exit 0
fi

echo "$FORMAT_DATE : start rsync file and report $server_ip" >> $log_file
#rsync tftp file
##$HA_PATH/rsync_inotify/config/rsync_full_pull_file.sh $server_ip
#rsync report file
##$HA_PATH/rsync_inotify/config/rsync_full_pull_report.sh $server_ip

## 循环读取配置文件中需要同步的目录，从第二行开始读取，第一行用于说明格式
cat $HA_PATH/rsync_inotify/config/path_property.txt | awk 'NR>1' | while read line
do
    OLD_IFS="$IFS" 
	IFS=":" 
	arr=($line) 
	IFS="$OLD_IFS" 
	RSYNC_MODULE=${arr[0]}
	SOURCE_PATH=${arr[1]}
	RSYNC_EXCLUDE=${arr[2]}
	## 启动对应的监听
	$HA_PATH/rsync_inotify/config/rsync_full_pull_common.sh $server_ip $RSYNC_MODULE $SOURCE_PATH $RSYNC_EXCLUDE
done

echo "$FORMAT_DATE : rsync file and report $server_ip success" >> $log_file
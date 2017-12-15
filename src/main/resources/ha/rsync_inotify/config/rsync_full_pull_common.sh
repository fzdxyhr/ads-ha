#!/bin/bash

source /opt/ads-ha/ha/shell/resource.sh
source $PATH/global.sh

log_file=$HA_PATH/rsync_inotify/log/rsync_client.log

peerIP=$1
if [[ ! $peerIP =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
	echo "$FORMAT_DATE: parameter input error, Please enter the correct ip" >>  $log_file
	exit 1
fi

ret=`/bin/ping -c 3 -W 1 $peerIP |grep ttl|wc -l`   #ping
if [ $ret -eq 0 ]; then     #等于0，不通
	echo "$FORMAT_DATE: Remote Rsyncd off, give up pull data from $peerIP" >> $log_file
	exit 0
fi


#rsync
RSYNC_SERVER=$1
RSYNC_MODULE=$2
SOURCE_PATH=$3
RSYNC_EXCLUDE=$4


#rsync client pwd check
if [ ! -e ${RSYNC_PWD} ];then
    echo -e "rsync client passwod file ${RSYNC_PWD} does not exist!" >> $log_file
    exit 0
fi

#pull the file from the server to the local

/usr/bin/rsync -auvrtzopgP --exclude-from=${RSYNC_EXCLUDE} --progress --password-file=${RSYNC_PWD} \
${RSYNC_USER}@${RSYNC_SERVER}::${RSYNC_MODULE}  ${SOURCE_PATH} >> ${log_file}




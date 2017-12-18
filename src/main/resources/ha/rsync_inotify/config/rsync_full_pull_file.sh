#!/bin/bash

source /opt/ads-ha/WEB-INF/classes/ha/shell/resource.sh
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
rsync_server=$1
rsync_user=rsync
rsync_module=files_sync
INOTIFY_EXCLUDE='(.*/*\.ooo|.*/*\.swp|^/opt/OMC-W/upgrade/backup/)'
RSYNC_EXCLUDE='/opt/OMC-W/rsync_inotify/config/rsync_exclude.lst'
source_path=/opt/OMC-W/tomcat/tftp/


#rsync client pwd check
if [ ! -e ${rsync_pwd} ];then
    echo -e "rsync client passwod file ${rsync_pwd} does not exist!" >> $log_file
    exit 0
fi

#pull the file from the server to the local

/usr/bin/rsync -auvrtzopgP --exclude-from=${RSYNC_EXCLUDE} --progress --password-file=${rsync_pwd} \
${rsync_user}@${rsync_server}::${rsync_module}  ${source_path} >> ${log_file}




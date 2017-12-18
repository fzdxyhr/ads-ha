#!/bin/bash

source /opt/ads-ha/WEB-INF/classes/ha/shell/resource.sh
source $PATH/global.sh
LOG_PATH=$HA_PATH/logs/ha.log


function switch_ha(){
	
	echo "$FORMAT_DATE : switch_ha start run ">> $LOG_PATH
	
	$(`ps -ef | grep inotifywait |grep -v 'grep' | awk '{print $2}'  | xargs kill -9`)
	
	## 本机为主备状态
	if [ $masterState -eq 1 ];then
		echo "$FORMAT_DATE : $HA_PATH/rsync_inotify/config/rsync.sh" >> $LOG_PATH
		# 开始执行文件监听命令
		$HA_PATH/rsync_inotify/config/rsync.sh
	else
		#同步一次文件
		$HA_PATH/rsync_inotify/config/rsync_full_pull.sh $VIRTUAL_IP >> $LOG_PATH
	fi

}
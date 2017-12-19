#!/bin/bash

source /opt/ads-ha/WEB-INF/classes/ha/shell/resource.sh
source $SHELL_PATH/global.sh

LOCAL_LOG="$HA_PATH/keepalived/logs/check_log.log"

#因为keepalived重试次数设置了3，所以，这个文件要在第三次才去删除
if [ -e $HA_PATH/psh/Recovery_err ]; then
	ret=`cat $HA_PATH/psh/Recovery_err |grep checked2`
	if [ -z "$ret" ];then
	   ret=`cat $HA_PATH/psh/Recovery_err | grep checked1`
	   if [ -z "$ret" ];then
			echo "$FORMAT_DATE,checked1;" >> $HA_PATH/psh/Recovery_err
	   else
			echo "$FORMAT_DATE,checked2;" >> $HA_PATH/psh/Recovery_err
	   fi
	else
	   ret=`cat $HA_PATH/psh/Recovery_err | grep checked3`
	   if [ -z "$ret" ];then
	   		echo "$FORMAT_DATE,checked3;" >> $HA_PATH/psh/Recovery_err
	   		echo "$FORMAT_DATE,$LOCAL_IP,PSH,1" >> $LOCAL_LOG
	   		echo `cat $HA_PATH/psh/Recovery_err` >> $LOCAL_LOG
	   fi
	fi
    exit 1
fi

exit 0
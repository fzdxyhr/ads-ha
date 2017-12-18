#!/bin/bash

PROJECT_ALIAS="ads-ha/WEB-INF/classes"
RUIJIE_HOME="/opt/$PROJECT_ALIAS"
HA_PATH=$RUIJIE_HOME/ha
PATH=$HA_PATH/shell
##VIRTUAL_IP=192.168.104.120

## rsync common resouce
RSYNC_PWD=$HA_PATH/rsync_inotify/config/rsync_client.passwd
RSYNC_USER=rsync

FORMAT_DATE=`date '+%Y-%m-%d %H:%M:%S'`

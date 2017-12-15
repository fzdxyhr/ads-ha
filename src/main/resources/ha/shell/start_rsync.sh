#!/bin/bash

source /opt/ads-ha/ha/shell/resource.sh
source $PATH/global.sh

LOG_PATH=/opt/ads-ha/ha/logs/ha.log


#安装Rsync
function install_rsync () {
	
	echo "$FORMAT_DATE : begin install rsync" >> $LOG_PATH
	if command_exists rsync; then
		echo "$FORMAT_DATE : rsync has been installed. skip this step" >> $LOG_PATH
		exit 0
	fi
	
	echo "$FORMAT_DATE : install rsync......" >> $LOG_PATH
	tar -xzf $HA_PATH/tools/rsync-3.1.2.tar.gz >> $LOG_PATH
	cd $HA_PATH/tools/rsync-3.1.2
	./configure --prefix=/usr/local/rsync >> $LOG_PATH
	make && make install >> $LOG_PATH
	
	if command_exists rsync; then
		echo "$FORMAT_DATE : install rsync rpm success" >> $LOG_PATH
	else
		echo "rsync unable to install. Please see the installation log" >> $LOG_PATH
		exit 1
	fi
	
	chmod 600 $HA_PATH/rsync_inotify/config/rsync_client.passwd
	chmod 600 $HA_PATH/rsync_inotify/config/rsync.passwd
	
	chmod 777 $HA_PATH/rsync_inotify/config/rsync.sh
	chmod 777 $HA_PATH/rsync_inotify/config/rsyncd.conf
	chmod 777 $HA_PATH/rsync_inotify/config/rsync_exclude.lst
	chmod 777 $HA_PATH/rsync_inotify/config/rsync_full_pull_common.sh
	chmod 777 $HA_PATH/rsync_inotify/config/rsync_full_pull.sh
	
	
	#start rsync service
	/usr/local/rsync/bin/rsync --daemon --config=$HA_PATH/rsync_inotify/config/rsyncd.conf
	sleep 2
	pid=`ps -ef|grep /opt/ads-ha/ha/rsync_inotify/config/rsyncd.conf |grep -v 'grep' |awk '{print $2}'`
	if [ "$pid" ];then
		echo "$FORMAT_DATE : rsync service start success" >> $LOG_PATH
	else
		echo "$FORMAT_DATE : rsync service unable to start. Please see the installation log" >> $LOG_PATH
		exit 1
	fi
	
}

function uninstall_rsync () {
	echo "$FORMAT_DATE : begin uninstall rsync" >> $LOG_PATH
	if command_exists rsync; then
		$(`ps -ef | grep inotifywait |grep -v 'grep' | awk '{print $2}'  | xargs kill -9`)
		killall rsync >> $LOG_PATH
		cd $HA_PATH/tools/rsync-3.1.2
		make uninstall >> $LOG_PATH
		if [ -e $HA_PATH/rsync_inotify/rsyncd.pid ]; then
			rm -rf $HA_PATH/rsync_inotify/rsyncd.pid
		fi
		echo "$FORMAT_DATE : uninstall rsync success" >> $LOG_PATH
	else
		echo "$FORMAT_DATE : rsync is not installed. Skip this step" >> $LOG_PATH
	fi
}

#安装inotify
function install_inotify () {
	echo "$FORMAT_DATE : begin install inotify" >> $LOG_PATH
	if command_exists inotifywait; then
		echo "$FORMAT_DATE : inotify has been installed. skip this step" >> $LOG_PATH
		exit 0
	fi
	
	echo "$FORMAT_DATE : install inotify......" >> $LOG_PATH
	tar -xzf $HA_PATH/tools/inotify-tools-3.14.tar.gz >> $LOG_PATH
	cd $HA_PATH/tools/inotify-tools-3.14
	./configure --prefix=/usr/local/inotify-tools >> $LOG_PATH
	make && make install >> $LOG_PATH
	
	if command_exists inotifywait; then
		echo "$FORMAT_DATE : install inotify rpm success" >> $LOG_PATH
	else
		echo "$FORMAT_DATE : inotify unable to install. Please see the installation log" >> $LOG_PATH
		exit 1
	fi
	
}

function uninstall_inotify () {
	echo "$FORMAT_DATE : begin uninstall inotify" >> $LOG_PATH
	if command_exists inotifywait; then
		$(`ps -ef | grep inotifywait |grep -v 'grep' | awk '{print $2}'  | xargs kill -9`)
		
		cd $HA_PATH/tools/inotify-tools-3.14
		make uninstall >> $LOG_PATH
		
		echo "$FORMAT_DATE : uninstall inotifywait success" >> $LOG_PATH
	else
		echo "$FORMAT_DATE : inotify is not installed. Skip this step" >> $LOG_PATH
	fi
}

function install(){
	##安装Rsync
	install_rsync
	##安装inotify
	install_inotify
}

function start(){
	/usr/local/rsync/bin/rsync --daemon --config=$HA_PATH/rsync_inotify/config/rsyncd.conf
}

function stop(){
	killall rsync
}

function uninstall(){
	uninstall_rsync
	uninstall_inotify
}

case $1 in 
	"start") 
		install 
		;; 
	"stop") 
		stop
		;; 
	"uninstall") 
		uninstall
		;; 
	"restart") 
		stop
		start
		;; 
	*) 
	echo 
		echo  "Usage: $0 start|stop|restart|uninstall" 
	echo 
esac






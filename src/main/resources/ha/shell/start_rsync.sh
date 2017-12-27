#!/bin/bash

source /opt/ads-ha/WEB-INF/classes/ha/shell/resource.sh
source $SHELL_PATH/global.sh

LOG_PATH=$HA_PATH/rsync_inotify/rsync_install.log

function command_exists () {
    if [ `whereis $1 | awk -F: '{print $2"x"}'|sed "s/ //g"` = "x" ];then
    	exit 1
    else
    	exit 0
    fi
}

#安装Rsync
function install_rsync () {
	
	echo "$FORMAT_DATE : begin install rsync" >> $LOG_PATH
	if [ ! -d "/usr/local/rsync"  ];then
		echo "$FORMAT_DATE : install rsync......" >> $LOG_PATH
		cd $HA_PATH/tools
		tar -xzf rsync-3.1.2.tar.gz >> $LOG_PATH
		cd rsync-3.1.2
		./configure --prefix=/usr/local/rsync >> $LOG_PATH
		make && make install >> $LOG_PATH
	else
		echo "$FORMAT_DATE : rsync has been installed. skip this step" >> $LOG_PATH
	fi
	if [ ! -d "/usr/local/rsync"  ];then
		echo "rsync unable to install. Please see the installation log" >> $LOG_PATH
		exit 1
	else
		echo "$FORMAT_DATE : install rsync rpm success" >> $LOG_PATH
	fi

	chmod 600 $HA_PATH/rsync_inotify/config/rsync_client.passwd
	chmod 600 $HA_PATH/rsync_inotify/config/rsync.passwd
	chmod 600 $HA_PATH/rsync_inotify/config/rsyncd.conf
	chmod 600 $HA_PATH/rsync_inotify/config/rsync_exclude.lst

	chmod 777 $HA_PATH/rsync_inotify/config/rsync.sh
	chmod 777 $HA_PATH/rsync_inotify/config/rsync_full_pull_common.sh
	chmod 777 $HA_PATH/rsync_inotify/config/rsync_full_pull.sh
	
	
	#start rsync service
	/usr/local/rsync/bin/rsync --daemon --config=$HA_PATH/rsync_inotify/config/rsyncd.conf
	sleep 2
	pid=`ps -ef|grep $HA_PATH/rsync_inotify/config/rsyncd.conf |grep -v 'grep' |awk '{print $2}'`
	if [ "$pid" ];then
		echo "$FORMAT_DATE : rsync service start success" >> $LOG_PATH
	else
		echo "$FORMAT_DATE : rsync service unable to start. Please see the installation log" >> $LOG_PATH
		exit 1
	fi
	
}

function uninstall_rsync () {
	echo "$FORMAT_DATE : begin uninstall rsync" >> $LOG_PATH
	if [ ! -d "/usr/local/rsync"  ];then
		echo "$FORMAT_DATE : rsync is not installed. Skip this step" >> $LOG_PATH
	else
		result_rsync=$(ps -e|grep rsync)
		if [ -z "$result_rsync" ]; then
			echo "$FORMAT_DATE : rsync is not Running. Skip this step" >> $LOG_PATH
		else
			killall rsync >> $LOG_PATH
		fi
		#cd $HA_PATH/tools/rsync-3.1.2
		#make uninstall >> $LOG_PATH
		if [ -e $HA_PATH/rsync_inotify/rsyncd.pid ]; then
			rm -rf $HA_PATH/rsync_inotify/rsyncd.pid
		fi
		if [ -e $HA_PATH/tools/rsync-3.1.2 ]; then
			rm -rf $HA_PATH/tools/rsync-3.1.2
		fi
		if [ -e /usr/local/rsync ]; then
			rm -rf /usr/local/rsync
		fi
		echo "$FORMAT_DATE : uninstall rsync success" >> $LOG_PATH
	fi
}

#安装inotify
function install_inotify () {
	echo "$FORMAT_DATE : begin install inotify" >> $LOG_PATH
	result=`whereis inotify-tools | awk -F: '{print $2}'|sed "s/ //g"`
	if [ -z "$result" ]; then
		echo "$FORMAT_DATE : install inotify......" >> $LOG_PATH
		cd $HA_PATH/tools/
		tar -xzf inotify-tools-3.14.tar.gz >> $LOG_PATH
		cd inotify-tools-3.14
		./configure --prefix=/usr/local/inotify-tools >> $LOG_PATH
		make && make install >> $LOG_PATH
	else
		echo "$FORMAT_DATE : inotify has been installed. skip this step" >> $LOG_PATH
		exit 0
	fi

	result=`whereis inotify-tools | awk -F: '{print $2}'|sed "s/ //g"`
	if [ -z "$result" ]; then
		echo "$FORMAT_DATE : inotify unable to install. Please see the installation log" >> $LOG_PATH
		exit 1
	else
		echo "$FORMAT_DATE : install inotify rpm success" >> $LOG_PATH
	fi
	
}

function uninstall_inotify () {
	echo "$FORMAT_DATE : begin uninstall inotify" >> $LOG_PATH
	result=`whereis inotify-tools | awk -F: '{print $2}'|sed "s/ //g"`
	if [ -z "$result" ]; then
		echo "$FORMAT_DATE : inotify is not installed. Skip this step" >> $LOG_PATH
	else
		$(`ps -ef | grep inotifywait |grep -v 'grep' | awk '{print $2}'  | xargs kill -9`)
		cd $HA_PATH/tools/inotify-tools-3.14
		make uninstall >> $LOG_PATH
		if [ -e /usr/local/inotify-tools ]; then
			rm -rf /usr/local/inotify-tools
		fi
		if [ -e $HA_PATH/tools/inotify-tools-3.14 ]; then
			rm -rf $HA_PATH/tools/inotify-tools-3.14
		fi
		echo "$FORMAT_DATE : uninstall inotifywait success" >> $LOG_PATH
	fi
}

function install(){
	##安装Rsync
	install_rsync
	##安装inotify
	install_inotify
	##启动监听
	$SHELL_PATH/switch.sh

}

function config(){
	chmod 600 $HA_PATH/rsync_inotify/config/rsync_client.passwd
	chmod 600 $HA_PATH/rsync_inotify/config/rsync.passwd
	chmod 600 $HA_PATH/rsync_inotify/config/rsyncd.conf
	chmod 600 $HA_PATH/rsync_inotify/config/rsync_exclude.lst

	chmod 777 $HA_PATH/rsync_inotify/config/rsync.sh
	chmod 777 $HA_PATH/rsync_inotify/config/rsync_full_pull_common.sh
	chmod 777 $HA_PATH/rsync_inotify/config/rsync_full_pull.sh

	#start rsync service
	/usr/local/rsync/bin/rsync --daemon --config=$HA_PATH/rsync_inotify/config/rsyncd.conf
	sleep 2
	pid=`ps -ef|grep $HA_PATH/rsync_inotify/config/rsyncd.conf |grep -v 'grep' |awk '{print $2}'`
	if [ "$pid" ];then
		echo "$FORMAT_DATE : rsync service start success" >> $LOG_PATH
	else
		echo "$FORMAT_DATE : rsync service unable to start. Please see the installation log" >> $LOG_PATH
		exit 1
	fi
	##安装inotify
	install_inotify
	##启动监听
	$SHELL_PATH/switch.sh
}

function start(){
	result=$(ps -e|grep 'rsync')
	if [ -z "$result" ]; then
		/usr/local/rsync/bin/rsync --daemon --config=$HA_PATH/rsync_inotify/config/rsyncd.conf
	fi
}

function stop(){
	result=$(ps -e|grep 'rsync')
	if [ -n "$result" ]; then
		killall rsync
	fi

	result=$(ps -e|grep 'inotifywait')
	if [ -n "$result" ]; then
		$(`ps -ef | grep inotifywait |grep -v 'grep' | awk '{print $2}'  | xargs kill -9`)
	fi
}

function uninstall(){
	uninstall_rsync
	uninstall_inotify
}

case $1 in 
	"start") 
		start
		;;
	"install")
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







#!/bin/bash

source /opt/ads-ha/WEB-INF/classes/ha/shell/resource.sh
source $SHELL_PATH/global.sh

LOG_PATH=$HA_PATH/keepalived/logs/install.log

function command_exists () {
    command -v "$1" > /dev/null 2>&1;
}


function install_keepalived () {
	echo "$FORMAT_DATE : start install keepalived" >> $LOG_PATH
	if command_exists keepalived; then
		echo "$FORMAT_DATE : keepalived has been installed. skip this step" >> $LOG_PATH
		exit 0
	fi
	
	echo "$FORMAT_DATE : install keepalived rpm......" >> $LOG_PATH
	dpkg -i $HA_PATH/tools/zlib1g-dev_1.2.11.dfsg-0ubuntu1_amd64.deb >> $LOG_PATH
	dpkg -i $HA_PATH/tools/libssl-dev_1.0.2g-1ubuntu11.4_amd64.deb >> $LOG_PATH
	dpkg -i $HA_PATH/tools/libpopt-dev_1.16-10_amd64.deb >> $LOG_PATH
	tar -xzf $HA_PATH/tools/keepalived-1.3.9.tar.gz >> $LOG_PATH
	cd $HA_PATH/tools/keepalived-1.3.9
	./configure --prefix=/usr/local/keepalived >> $LOG_PATH
	make && make install >> $LOG_PATH
	mkdir /etc/keepalived
	sed -i "s/vrrpIp/$vrrpIp/g" $HA_PATH/keepalived/keepalived.conf
	sed -i "s/interface_name/$interface_name/g" $HA_PATH/keepalived/keepalived.conf
	cp $HA_PATH/keepalived/keepalived.conf /etc/keepalived/
	##启动keepalived
	./usr/local/keepalived/sbin/keepalived
	echo "$FORMAT_DATE : install keepalived success"  >> $LOG_PATH
	
}

function uninstall_keepalived () {
	echo "$FORMAT_DATE : begin uninstall keepalived" >> $LOG_PATH
	if command_exists keepalived; then	
		killall keepalived >> $LOG_PATH
		cd $HA_PATH/tools/keepalived-1.3.9  
		make uninstall >> $LOG_PATH
		echo "$FORMAT_DATE : uninstall keepalived success" >> $LOG_PATH
	else
		echo "$FORMAT_DATE : keepalived is not installed. Skip this step" >> $LOG_PATH
	fi
	
}

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

function start_ha(){
	
	service keepalived start >> $LOG_PATH
	
}



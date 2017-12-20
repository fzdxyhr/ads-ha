#!/bin/bash

source /opt/ads-ha/WEB-INF/classes/ha/shell/resource.sh
source $SHELL_PATH/global.sh

LOG_PATH=$HA_PATH/keepalived/keepalived_install.log

function command_exists () {
    command -v "$1" > /dev/null 2>&1;
}


function install_keepalived () {
	echo "$FORMAT_DATE : start install keepalived" >> $LOG_PATH
	if [ -d "/usr/local/keepalived"  ];then
		echo "$FORMAT_DATE : keepalived has been installed. skip this step" >> $LOG_PATH
		exit 0
	fi
	
	echo "$FORMAT_DATE : install keepalived......" >> $LOG_PATH
	dpkg -i $HA_PATH/tools/zlib1g-dev_1.2.11.dfsg-0ubuntu1_amd64.deb >> $LOG_PATH
	dpkg -i $HA_PATH/tools/libssl-dev_1.0.2g-1ubuntu11.4_amd64.deb >> $LOG_PATH
	dpkg -i $HA_PATH/tools/libpopt-dev_1.16-10_amd64.deb >> $LOG_PATH
	cd $HA_PATH/tools
	tar -xzf keepalived-1.3.9.tar.gz >> $LOG_PATH
	cd keepalived-1.3.9
	./configure --prefix=/usr/local/keepalived >> $LOG_PATH
	make && make install >> $LOG_PATH
	mkdir /etc/keepalived/
	sed -i "s/vrrpIp/$vrrpIp/g" $HA_PATH/keepalived/keepalived.conf
	sed -i "s/interface_name/$interface_name/g" $HA_PATH/keepalived/keepalived.conf
	cp $HA_PATH/keepalived/keepalived.conf /etc/keepalived/keepalived.conf
	echo $vrrpIp >> $LOG_PATH
	##启动keepalived
	/usr/local/keepalived/sbin/keepalived
	echo "$FORMAT_DATE : install keepalived success"  >> $LOG_PATH
	
}

function uninstall_keepalived () {
	echo "$FORMAT_DATE : begin uninstall keepalived" >> $LOG_PATH
	result=$(ps -e|grep 'keepalived')
	if [ -z "$result" ]; then
		echo "$FORMAT_DATE : keepalived is not installed. Skip this step" >> $LOG_PATH
	else
		killall keepalived >> $LOG_PATH
		cd $HA_PATH/tools/keepalived-1.3.9
		make uninstall >> $LOG_PATH
		if [ -e /usr/local/keepaliv$HA_PATH/tools/keepalived-1.3.9 ]; then
			rm -rf $HA_PATH/tools/keepalived-1.3.9
		fi
		if [ -e /etc/keepalived ]; then
			rm -rf /etc/keepalived
		fi
		if [ -e /usr/local/keepalived ]; then
			rm -rf /usr/local/keepalived
		fi
		sed -i "s/$vrrpIp/vrrpIp/g" $HA_PATH/keepalived/keepalived.conf
		sed -i "s/$interface_name/interface_name/g" $HA_PATH/keepalived/keepalived.conf
		echo "$FORMAT_DATE : uninstall keepalived success" >> $LOG_PATH
	fi
}


function stop(){
	result=$(ps -e|grep 'keepalived')
	if [ -z "$result" ]; then
		echo "$FORMAT_DATE : keepalived is not installed. Skip this step" >> $LOG_PATH
	else
		killall keepalived >> $LOG_PATH
		echo "$FORMAT_DATE : stop keepalived success" >> $LOG_PATH
	fi
}


function start(){
	/usr/local/keepalived/sbin/keepalived
}
function uninstall(){
	uninstall_keepalived
}

case $1 in 
	"start") 
		start
		;; 
	"stop") 
		stop
		;;
	"install")
		install_keepalived
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











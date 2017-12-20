#!/bin/bash

source /opt/ads-ha/WEB-INF/classes/ha/shell/resource.sh
source $SHELL_PATH/global.sh

LOG_PATH=$HA_PATH/keepalived/state_log.log

## 更新全局变量
function updateGlobal(){
	masterState="masterState=$1";
	sed -i "s/^masterState=.*$/$masterState/g" $SHELL_PATH/global.sh
}

case "$1" in
	master)  ##当前节点成为master时，通知脚本执行任务
		echo "$FORMAT_DATE : keepalive is master" >> ${LOG_PATH}
		ret=`/bin/ping -c 3 -W 1 $gatewayIp |grep ttl|wc -l`   #ping
		if [ $ret -eq 0 ]; then     #等于0，不通
			echo "$FORMAT_DATE : GATEWAY Ping Unreasonable ." >> $log_file
			exit 0
		fi
		## 将当前主机设置为主备状态
		updateGlobal 1
		
		$SHELL_PATH/switch.sh
		
		#curl -s "http://localhost:8989/ssm/act/haServlet/tomcatRa.action?type=restart"
    ;;  
  	backup)  ##当前节点成为backup时，通知脚本执行任务
  	
		echo "$FORMAT_DATE : keepalive is backup" >> ${LOG_PATH}
		
		## 将当前主机设置为备份状态
		updateGlobal 0
		
		$SHELL_PATH/switch.sh
		
		#curl -s "http://localhost:8989/ssm/act/haServlet/tomcatRa.action?type=stop"
		
    ;;
    fault)  ##当前节点出现故障，通知脚本执行任务 
		echo "$FORMAT_DATE : keepalive is fault" >> ${LOG_PATH}
		
		## 将当前主机设置为备份状态
		updateGlobal 0
		
		$SHELL_PATH/switch.sh
		
		#curl -s "http://localhost:8989/ssm/act/haServlet/tomcatRa.action?type=stop"
    ;; 
    stop)  ##当前节点停止，通知脚本执行任务;
		echo "$FORMAT_DATE : keepalive is stop" >> ${LOG_PATH}
    ;;   
  *)  
   echo $"Usage: $0 {master|backup|fault|stop}"  
   exit 2  
esac  
  
exit $?   

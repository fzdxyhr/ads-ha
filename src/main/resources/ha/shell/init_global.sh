#!/bin/bash

source /opt/ads-ha/WEB-INF/classes/ha/shell/resource.sh

interip=""
otherIp=""
## 根据传进来的ip链表循环判断获取当前主机ip
## 格式: ./init_global vistualIp ip1 ip2 ip3 ... 
count=1
for ip in $@
do
	if [[ $count -gt 1 ]];then
		ipaddrs=$(ip addr | grep '[0-9]\{1,3\}\.[0-9]\{1,3\}\.' | grep -v "127.0.0.1" | grep $ip | grep inet | cut -d "/" -f1 | sed "s/^.*inet//g")
		if [ ! -z "$ipaddrs" ]; then
			interip=$ip
		else
			otherIp+=$ip","
		fi
	fi
	((count++));
done
length=${#otherIp}-1
otherIp=${otherIp:0:length}
## 根据ip获取网关名称
interface_name=$(ip addr | grep $interip |awk -F' ' '{print $8}')
if [ -z "${interface_name}" ]
then      
	echo "$interip unable to find, please enter the correct ip"
	exit 1
fi
gateway_ip=`ip route show | grep "default" |awk -F' ' '{print $3}'`
if [ -z "$gateway_ip" ];then      
	echo "gateway_ip is empty."
	exit 1
fi

localhost="localhost=$interip"
sed -i "s/^localhost=.*$/$localhost/g" $SHELL_PATH/global.sh
interfaceName="interface_name=$interface_name"
sed -i "s/^interface_name=.*$/$interfaceName/g" $SHELL_PATH/global.sh
gatewayIp="gatewayIp=$gateway_ip"
sed -i "s/^gatewayIp=.*$/$gatewayIp/g" $SHELL_PATH/global.sh
otherIp="otherIp=$otherIp"
sed -i "s/^otherIp=.*$/$otherIp/g" $SHELL_PATH/global.sh
vrrpIp="vrrpIp=$1"
sed -i "s/^vrrpIp=.*$/$vrrpIp/g" $SHELL_PATH/global.sh

exit 0
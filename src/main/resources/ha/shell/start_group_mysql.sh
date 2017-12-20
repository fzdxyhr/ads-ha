#!/bin/bash
## 输入参数时将本机ip放在ip参数的第一个
## 格式为 ./group.sh type container_name localIp otherIp otherIp ...
## 说明：type:取值区分以哪台机子为主，包括master和slave
## container_name 容器名称
## localIp为执行脚本的ip,otherIp 为组复制中其他的机子ip

## docker内mysql数据库配置文件挂载到linux的目录结构
configDir=/home/group/config
mysql_user_name=root
mysql_user_password=root

## 更新数据库配置文件
function updateMyCnf(){
	## 清空原来配置文件
	: > $configDir/my.cnf
	## ip地址拼接
	address=""
	## 当前主机ip地址
	localAddress=$3
	count=1
	for i in $@  
	do  
		if [[ $count -gt 2 ]];then
			address+=$i":24901,"
		fi
		((count++));
	done
	length=${#address}-1
	address=${address:0:length}
	## BASE CONFIG
	echo "[mysqld]" >> $configDir/my.cnf
	echo "skip-host-cache" >> $configDir/my.cnf
	echo "skip-name-resolve" >> $configDir/my.cnf
	echo "pid-file =/var/run/mysqld/mysqld.pid" >> $configDir/my.cnf
	echo "socket =/var/run/mysqld/mysqld.sock" >> $configDir/my.cnf
	echo "port=3306" >> $configDir/my.cnf
	echo "basedir=/usr" >> $configDir/my.cnf
	echo "datadir=/var/lib/mysql" >> $configDir/my.cnf
	echo "tmpdir=/tmp" >> $configDir/my.cnf
	echo "lc-messages-dir=/usr/share/mysql" >> $configDir/my.cnf
	echo "explicit_defaults_for_timestamp" >> $configDir/my.cnf
	echo "log-error=/var/log/mysql/error.log" >> $configDir/my.cnf
	echo "sql_mode=NO_ENGINE_SUBSTITUTION,STRICT_ALL_TABLES" >> $configDir/my.cnf
	echo "symbolic-links=0" >> $configDir/my.cnf
	
	## GROUP REPLICATION CONFIG
	echo "server_id=${localAddress##*.}" >> $configDir/my.cnf
	echo "gtid_mode=ON" >> $configDir/my.cnf
	echo "enforce_gtid_consistency=ON" >> $configDir/my.cnf
	echo "master_info_repository=TABLE" >> $configDir/my.cnf
	echo "relay_log_info_repository=TABLE" >> $configDir/my.cnf
	echo "binlog_checksum=NONE" >> $configDir/my.cnf
	echo "log_slave_updates=ON" >> $configDir/my.cnf
	echo "log_bin=binlog" >> $configDir/my.cnf
	echo "binlog_format=ROW" >> $configDir/my.cnf
	echo "transaction_write_set_extraction=XXHASH64" >> $configDir/my.cnf
	echo "loose-group_replication_group_name=\"ce9be252-2b71-11e6-b8f4-00212844f856\"" >> $configDir/my.cnf
	echo "loose-group_replication_start_on_boot=off" >> $configDir/my.cnf
	echo "loose-group_replication_bootstrap_group=off" >> $configDir/my.cnf
	echo "loose-group_replication_local_address=\"${localAddress}:24901\"" >> $configDir/my.cnf
	echo "loose-group_replication_group_seeds=\"${address}\"" >> $configDir/my.cnf
	echo "loose-group_replication_single_primary_mode=off" >> $configDir/my.cnf
	echo "loose-group_replication_enforce_update_everywhere_checks=on" >> $configDir/my.cnf	
	#echo "skip-grant-tables" >> $configDir/my.cnf
}

## 安装mysql-client
function execMysqlClient(){
	sudo apt-get update
	sudo apt autoremove mysql-client -y
	sudo apt-get install mysql-client -y
}

function main() {
	## 先安装mysql-client
	## execMysqlClient
	if [ $# == 0 ]; then
		echo "Error;You should input type and ip"
		exit 0
	elif [ $# > 2 ]; then
		## 将输入的ip地址添加到linux /etc/hosts 文件中
		count=1
		for i in $@  
		do  
			if [[ $count -gt 2 ]]; then
				var=$i
				echo "$i mgr${var##*.}" >> /etc/hosts
			fi
			((count++));
		done
		
		## 启动docker mysql 服务
		##docker run --net=host  --name $2 -p 3306:3306 -v $configDir/my.cnf:/etc/mysql/my.cnf  -e MYSQL_ROOT_PASSWORD=mytest  -d percona/percona-server:latest
		##docker run --net=host  --name db001 -p 3306:3306 -v /home/group/config/my.cnf:/etc/mysql/my.cnf  -e MYSQL_ROOT_PASSWORD=root  -d percona/percona-server:latest
		## 修改mysql my.cnf配置文件
	    updateMyCnf $@
		## 重启mysql 
		docker restart $2
		
		sleep 2
		
		## 用户root授权
		mysql -h$3 -uroot -proot -e "
		set global read_only=0;
		flush privileges;
		grant all privileges on *.* to '${mysql_user_name}'@'192.168.%' identified by '${mysql_user_password}' with grant option;
		set global read_only=1;
		flush privileges;
		"
		
		## 进入数据库
		mysql -h$3 -u$mysql_user_name -p$mysql_user_password -e "
		## 开始执行数据库相关脚本
		## 建立复制账户
		SET SQL_LOG_BIN=0;
		GRANT REPLICATION SLAVE ON *.* TO 'repl'@'192.168.%' IDENTIFIED BY 'rlpbright_1927@ys';
		SET SQL_LOG_BIN=1;
		## 安装group replication插件
		INSTALL PLUGIN group_replication SONAME 'group_replication.so';
		## 开始构建group replication集群
		CHANGE MASTER TO MASTER_USER='repl', MASTER_PASSWORD='rlpbright_1927@ys' FOR CHANNEL 'group_replication_recovery';
		"
		if [ "$1"x = "master"x ]; then
			## 设置group_replication_bootstrap_group为ON是为了标示以后加入集群的服务器以这台服务器为基准
			## 以后加入的就不需要设置
			mysql -h$3 -u$mysql_user_name -p$mysql_user_password -e "
			SET GLOBAL group_replication_bootstrap_group = ON;
			## 启动GROUP_REPLICATION
			START GROUP_REPLICATION;
			SET GLOBAL group_replication_bootstrap_group=OFF;"
		else 
			mysql -h$3 -u$mysql_user_name -p$mysql_user_password -e "
			set global group_replication_allow_local_disjoint_gtids_join=ON;
			START GROUP_REPLICATION;"
		fi 
	fi
	
}
myPath=$configDir/
configFile="$myPath"my.cnf
mkdir -p $myPath
touch $configFile

main $@
exit 0

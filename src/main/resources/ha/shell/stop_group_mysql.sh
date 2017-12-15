#!/bin/bash


## docker内mysql数据库配置文件挂载到linux的目录结构
configDir=/home/group/config

## 更新数据库配置文件
function updateMyCnf(){
	## 清空原来配置文件
	: > $configDir/my.cnf

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
	
}

## 安装mysql-client
function execMysqlClient(){
	sudo apt-get update
	sudo apt autoremove mysql-client -y
	sudo apt-get install mysql-client -y
}

function main() {
	## 修改mysql my.cnf配置文件
	updateMyCnf
	## 重启mysql 
	docker restart $1
	
}
myPath=$configDir/
configFile="$myPath"my.cnf
mkdir -p $myPath
touch $configFile

main $@
exit 0

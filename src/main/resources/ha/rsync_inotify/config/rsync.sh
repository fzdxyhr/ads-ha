#!/bin/bash

source /opt/ads-ha/WEB-INF/classes/ha/shell/resource.sh
source $SHELL_PATH/global.sh

LOG_FILE=$HA_PATH/rsync_inotify/rsync_notify.log

#rsync
INOTIFY_EXCLUDE='(.*/*\.ooo|.*/*\.swp|^/opt/OMC-W/upgrade/backup/)'
##RSYNC_EXCLUDE='/opt/OMC-W/rsync_inotify/config/rsync_exclude_simple.lst'


#rsync client pwd check
if [ ! -e ${RSYNC_PWD} ];then
    echo "rsync client passwod file ${RSYNC_PWD} does not exist!" >> $LOG_FILE
    exit 0
fi

#inotify_function
function inotify_fun(){
	source_path=$1
	rsync_module=$2
	rsync_exclude=$3
	
	/usr/local/inotify-tools/bin/inotifywait -mrq --timefmt '%Y/%m/%d-%H:%M:%S' --format '%T %Xe %w%f' \
	--exclude ${INOTIFY_EXCLUDE} -e modify,create,delete,attrib,close_write,move ${source_path} \
	| while read file
	do
		echo "inotifywait start: $file" >> ${LOG_FILE}
		if [ $masterState -eq 1 ];then
			FORMAT_DATE=`date '+%Y-%m-%d %H:%M:%S'`
			INO_EVENT=`echo $file | awk '{print $2}'`
			INO_FILE=`echo $file | awk '{print $3}'`
			DIR_N="$(dirname ${INO_FILE})/"
			#对于前两种操作。目前的效果是全局，后期看性能是否有必要优化,为保证两边文件完全一致去掉了-u参数
			if [[ $INO_EVENT =~ 'CREATE' ]] || [[ $INO_EVENT =~ 'MODIFY' ]] || [[ $INO_EVENT =~ 'CLOSE_WRITE' ]] || [[ $INO_EVENT =~ 'MOVED_TO' ]]
			then
				echo "$FORMAT_DATE inotify: $INO_EVENT, $INO_FILE, push ${DIR_N} to @${rsync_server}" >> ${LOG_FILE}
				OLD_IFS="$IFS"
				IFS=","
				arr=($otherIp)
				IFS="$OLD_IFS"
				for ip in ${arr[@]}
				do
					rsync_server=$ip
					/usr/local/rsync/bin/rsync -auvrtzopgP --timeout=60 --progress --include=${DIR_N} --exclude-from=${rsync_exclude} --bwlimit=1024 --password-file=${RSYNC_PWD} \
					${source_path} ${RSYNC_USER}@${rsync_server}::${rsync_module}  >> ${LOG_FILE}

				done
			fi

			if [[ $INO_EVENT =~ 'ATTRIB' ]]
			then
				if [ ! -d "$INO_FILE" ]
				then
					echo "$FORMAT_DATE inotify: $INO_EVENT, $INO_FILE, push ${DIR_N} to @${rsync_server}"  >> ${LOG_FILE}
					OLD_IFS="$IFS"
					IFS=","
					arr=($otherIp)
					IFS="$OLD_IFS"
					for ip in ${arr[@]}
					do
						rsync_server=$ip
						/usr/local/rsync/bin/rsync -auvrtzopgP --timeout=60 --progress --include=${DIR_N} --exclude-from=${rsync_exclude} --bwlimit=1024 --password-file=${RSYNC_PWD} \
						${source_path} ${RSYNC_USER}@${rsync_server}::${rsync_module}  >> ${LOG_FILE}
					done

				fi
			fi

			#对于delete操作，缩小起影响范围到两端本文件夹
			if [[ $INO_EVENT =~ 'DELETE' ]] || [[ $INO_EVENT =~ 'MOVED_FROM' ]]
			then
				echo "$FORMAT_DATE inotify: $INO_EVENT, $INO_FILE, push ${DIR_N} to @${rsync_server}::${rsync_module}"  >> ${LOG_FILE}
				OLD_IFS="$IFS"
				IFS=","
				arr=($otherIp)
				IFS="$OLD_IFS"
				for ip in ${arr[@]}
				do
					rsync_server=$ip
					/usr/local/rsync/bin/rsync -auvrtzopgP --timeout=60 --delete --exclude-from=${rsync_exclude} --progress --bwlimit=1024 --password-file=${RSYNC_PWD} \
					${source_path} ${RSYNC_USER}@${rsync_server}::${rsync_module}  >> ${LOG_FILE}
				done

			fi
		fi
	done
}

#inotify log
## 循环读取配置文件中需要同步的目录，从第二行开始读取，第一行用于说明格式
echo "read file from path_property.txt" >> $LOG_FILE
cat $HA_PATH/rsync_inotify/config/path_property.txt | awk 'NR>1' | while read line
do
    OLD_IFS="$IFS" 
	IFS=":" 
	arr=($line) 
	IFS="$OLD_IFS" 
	RSYNC_MODULE=${arr[0]}
	SOURCE_PATH=${arr[1]}
	RSYNC_EXCLUDE=${arr[2]}
	## 启动对应的监听
	echo "inotify_fun start param:$RSYNC_MODULE,$SOURCE_PATH" >> $LOG_FILE
	inotify_fun $SOURCE_PATH $RSYNC_MODULE $RSYNC_EXCLUDE & >> $LOG_FILE 2>&1 &
done

##inotify_fun $source_path_tftp $rsync_module_tftp >> ${LOG_FILE} 2>&1 &

##inotify_fun $source_path_report $rsync_module_report >> ${LOG_FILE} 2>&1 &

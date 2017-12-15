#!/bin/bash
source /opt/ads-ha/ha/shell/resource.sh
source $PATH/global.sh
LOG_PATH=$HA_PATH/logs/ha.log


LOG_FILE=/opt/ads-ha/ha/rsync_inotify/rsync_client.log

#rsync
INOTIFY_EXCLUDE='(.*/*\.ooo|.*/*\.swp|^/opt/OMC-W/upgrade/backup/)'
RSYNC_EXCLUDE='/opt/OMC-W/rsync_inotify/config/rsync_exclude_simple.lst'
source_path_tftp=/opt/OMC-W/tomcat/tftp/
rsync_module_tftp=files_sync
source_path_report=/opt/OMC-W/omc-w/report/
rsync_module_report=report_sync

#rsync client pwd check
if [ ! -e ${rsync_pwd} ];then
    echo -e "rsync client passwod file ${rsync_pwd} does not exist!"
    exit 0
fi

#inotify_function
inotify_fun(){
	source_path=$1
	rsync_module=$2
	
	/usr/bin/inotifywait -mrq --timefmt '%Y/%m/%d-%H:%M:%S' --format '%T %Xe %w%f' \
		--exclude ${INOTIFY_EXCLUDE} -e modify,create,delete,attrib,close_write,move ${source_path} \
  		| while read file
		do
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
					/usr/bin/rsync -auvrtzopgP --timeout=60 --progress --include=${DIR_N} --exclude-from=${RSYNC_EXCLUDE} --bwlimit=1024 --password-file=${rsync_pwd} \
					${source_path} ${rsync_user}@${rsync_server}::${rsync_module}  >> ${LOG_FILE}
					
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
						/usr/bin/rsync -auvrtzopgP --timeout=60 --progress --include=${DIR_N} --exclude-from=${RSYNC_EXCLUDE} --bwlimit=1024 --password-file=${rsync_pwd} \
						${source_path} ${rsync_user}@${rsync_server}::${rsync_module}  >> ${LOG_FILE}
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
					/usr/bin/rsync -auvrtzopgP --timeout=60 --delete --exclude-from=${RSYNC_EXCLUDE} --progress --bwlimit=1024 --password-file=${rsync_pwd} \
					${source_path} ${rsync_user}@${rsync_server}::${rsync_module}  >> ${LOG_FILE}
				done
				
        	fi
		fi
	done
}

#inotify log

inotify_fun $source_path_tftp $rsync_module_tftp >> ${LOG_FILE} 2>&1 &

inotify_fun $source_path_report $rsync_module_report >> ${LOG_FILE} 2>&1 &

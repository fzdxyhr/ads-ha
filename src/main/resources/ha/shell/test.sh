#!/bin/bash
src=/home/software/sync/
dst=rsync@192.168.104.128::files_sync
 
function test(){
 
 /usr/local/inotify-tools/bin/inotifywait -mrq --timefmt '%d/%m/%y %H:%M' --format '%T %w%f%e' -e modify,delete,create,attrib $src | while read files
	do
		echo "aaaaa"
		echo "${files} was rsynced >> /home/software/sync>>"
		rsync -vzrtopg --delete --progress --password-file=/etc/rsyncd/rsyncd.pass $src $dst
		echo "${files} was rsynced >> /home/software/sync>>"
	done
}

test -d 

exit 0

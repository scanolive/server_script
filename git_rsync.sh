#!/bin/bash 

git_update_log=/var/log/git_update.log
git_rsync_log=/var/log/git_rsync.log
sdir=/opt/data/gogs-repositories/
rdir="192.168.0.8:/opt/data/git_repo/"

function rsync_file()
{
	echo "" >> $git_rsync_log
	echo "-----------------------------"`date '+%Y-%m-%d %H:%M:%S'`" start-----------------------------------" >> $git_rsync_log
	/usr/bin/rsync -av --delete -e "ssh -p 22" $sdir $rdir >> $git_rsync_log  2>&1 
	echo "------------------------------"`date '+%Y-%m-%d %H:%M:%S'`" end------------------------------------" >> $git_rsync_log
	echo "" >> $git_rsync_log
	date +%s > $git_update_log
}

function check_update()
{
	if [[ `ps -ef|grep inotifywait|grep "$sdir"|wc -l` -eq 0 ]];then
		/usr/bin/inotifywait -mrqd --timefmt '%s' --format '%T' -e close_write,delete,create,attrib -o $git_update_log $sdir
	fi
}

check_update 

if [[ ! -e $git_update_log ]] || [[ `tail -1 $git_update_log` == "" ]];then
	update_time=`date -d "1 hour ago" +%s`
else
	update_time=`tail -1 $git_update_log`
fi
now_time=`date +%s`


if [[ `expr $now_time - $update_time ` -lt 60 ]];then
	rsync_file
fi

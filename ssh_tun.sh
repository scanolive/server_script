#!/bin/bash

#################################################
#
#   File Name: ssh_tun.sh
#   Author: scan
#   Created Time: 2019-08-08 12:21:36
# 
#################################################

REMOTE_HOST='xxx.xxx.xxx.xxx'

date_str="$(/bin/date "+%Y-%m-%d %H:%M:%S")"
echo "========${date_str}========="
if [ $# -eq 2 ] && [ -z "`echo $1|sed 's/[0-9]//g'`" ] && [ -z "`echo $2|sed 's/[0-9]//g'`" ];then
	LOCAL_PORT=$1
	REMOTE_PORT=$2
fi 

#LOCAL_PORT=22
#REMOTE_PORT=1980
if [ -z "${LOCAL_PORT}" ] || [ -z "${REMOTE_PORT}" ];then
	echo "Usage: $0 local_port remote_port "
	exit 1
fi
server_listen_num=`ssh root@"${REMOTE_HOST}" "netstat -anl|grep ${REMOTE_PORT} |wc -l"`
if [[ $? -ne 0 ]];then
	echo  "can't connect server"
	exit 
fi
if [[ "$server_listen_num" -lt 1 ]];then
	if [[ `ps -ef|grep $REMOTE_HOST|grep $REMOTE_PORT:localhost:$LOCAL_PORT|wc -l` -gt 0 ]];then
		kill `ps -ef|grep $REMOTE_HOST|grep $REMOTE_PORT:localhost:$LOCAL_PORT|awk '{print $2}'`
	fi
	/usr/bin/ssh -NfR $REMOTE_PORT:localhost:$LOCAL_PORT root@$REMOTE_HOST
	if [[ $? -eq 0 ]];then
		echo  "ssh_tun reconnect OK"
	else
		echo  "ssh_tun reconnect Err"
	fi
else
	echo "ssh_tun is OK"
fi

#!/bin/bash

route_cmd=`which route`
if [ -z $1 ] ;then
	interface=`$route_cmd -n |awk 'NR==3 {print $8}'`
else
	if [ "$1" -gt 0 ] 2>/dev/null; then
		delta_t=$1
		interface=`$route_cmd -n |awk 'NR==3 {print $8}'`
	else
		interface=$1
	fi
fi

if [ -z ${delta_t} ];then
	if [ -z $2 ];then
		delta_t=1
	else
		delta_t=$2
	fi
fi


ifconfig ${interface} > /dev/null 2>&1

if [[ $? -eq 0 ]] && [[ ${delta_t} -gt 0 ]];then
	:
else
	echo "Usage: $0 interface interval"
	exit 1
fi



function check_speed()
{
	delta_t=$2
	eth=$1
	echo  -e  "dev         down                 up"
	while [ "1" ]
	do
		RXpre=$(cat /proc/net/dev | grep "$eth:" | tr : " " | awk '{print $2}')
		TXpre=$(cat /proc/net/dev | grep "$eth:" | tr : " " | awk '{print $10}')
		sleep $delta_t
		RXnext=$(cat /proc/net/dev | grep "$eth:" | tr : " " | awk '{print $2}')
		TXnext=$(cat /proc/net/dev | grep "$eth:" | tr : " " | awk '{print $10}')
		#clear
		#echo  -e  "\t RX `date +%k:%M:%S` TX"
		RX=$((${RXnext}-${RXpre}))
		TX=$((${TXnext}-${TXpre}))
		#RX=$((((${RXnext}-${RXpre}))/$delta_t))
		#TX=$((((${TXnext}-${TXpre}))/$delta_t))
		if [[ $RX -gt 1048576 ]];then
				RX=$(echo $RX | awk '{printf("%8.2fMB",$1/1048576)}')
		else
				RX=$(echo $RX | awk '{printf("%8.2fkB",$1/1024)}')
		fi
		if [[ $TX -gt 1048576 ]];then
				TX=$(echo $TX | awk '{printf("%8.2fMB",$1/1048576)}')
		else
				TX=$(echo $TX | awk '{printf("%8.2fkB",$1/1024)}')
		fi
		echo -e "$eth    $RX""/""$delta_t""s""        $TX/""$delta_t""s"
	done
}
check_speed ${interface} $delta_t
#################################################################################


#/bin/bash

log_file=/usr/local/openvpn/vpn.log
conf_file=/usr/local/openvpn/rill.ovpn
ds_ip='192.168.0.8'
vpn_cmd=`which openvpn`
function start()
{
	if [[ `ps -ef|grep openvpn|grep -v grep|wc -l` -eq 0  ]];then
		sudo $vpn_cmd --config $conf_file >> $log_file 2>&1 &
		sleep 3
		check
	else
		check
	fi
}

function stop()
{
	if [[ `ps -ef|grep openvpn|grep -v grep|wc -l` -ne 0 ]];then
		sudo kill -9 `ps -ef|grep openvpn|grep -vE "sudo|grep"|awk '{print $2}'`
	fi
}

function check()
{
	if [[ `ping  -c 1 $ds_ip |grep 'time='|wc -l` -eq 1 ]];then
		echo "Connection successful"
	else
		echo "Connection fail"
	fi
}

case "$1" in
start)
    start
    ;;
stop)
    stop
    ;;
*)
    echo "Usage: $0 {start|stop}"
    exit 1
    ;;
esac

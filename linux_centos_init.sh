#!/bin/bash

#################################################
#
#   File Name: centos_init.sh
#   Author: scan
#   Created Time: 2020-11-11 18:31:26
# 
#################################################

CHECK_ROOT() {
	        [[ $EUID != 0  ]] && echo -e "not root" && exit 1
}

CHECK_SYS() {
        if [[ -f /etc/redhat-release ]]; then
                release="centos"
        fi
        bit=$(uname -m)
		[[ ${release} != "centos" ]] && echo -e "${ERROR} 本脚本暂时不支持当前系统 ${release} ! 当前仅支持CentOS7+ 感谢理解" && exit 110
}

OFFSELINUX() {
SELINUX_CONF_PATH="/etc/selinux/config"
sed -i '/SELINUX/s/enforcing/disabled/' ${SELINUX_CONF_PATH}
setenforce 0 
}



TIMELOCK() {
CONF_FILE=/etc/chrony.conf
if [[ `which chronyd` ]];then
    sed -i '/iburst/d' $CONF_FILE
    echo 'pool ntp.aliyun.com iburst' >> $CONF_FILE
    systemctl enable chronyd.service
    systemctl stop chronyd.service
    systemctl start chronyd.service

    ## 修改时区
    timedatectl set-timezone Asia/Shanghai
	ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime


    ## 启用NTP时间同步：
    timedatectl set-ntp yes

    ## 将当前的 UTC 时间写入硬件时钟
    timedatectl set-local-rtc 0

    ## 重启依赖于系统时间的服务
    systemctl restart rsyslog.service
    systemctl restart crond.service

    ## 查看当前时间和时区
    date -R
fi
}

LIMITSCONF() {
CONF_PATH="/etc/security/limits.conf"
sed -i '/^[^#]/{/soft/d}' $CONF_PATH
sed -i '/^[^#]/{/hard/d}' $CONF_PATH
cat >> ${CONF_PATH} << COMMENTBLOCK
*           soft   nofile       655360
*           hard   nofile       655360
*           soft   nproc        655360
*           hard   nproc        655360
COMMENTBLOCK
SYSTEM_CONF_PATH="/etc/systemd/system.conf"
sed -i '/^*/{/soft/d}' /etc/security/limits.d/20-nproc.conf
sed -i 's/^#DefaultLimitNOFILE=.*/DefaultLimitNOFILE=655360/g' ${SYSTEM_CONF_PATH}
sed -i 's/^#DefaultLimitNPROC=.*/DefaultLimitNPROC=655360/g' ${SYSTEM_CONF_PATH}
}



SYSCTLCONF() {
SYSCTL_CONF_PATH="/etc/sysctl.conf"
true > ${SYSCTL_CONF_PATH}
cat >> ${SYSCTL_CONF_PATH} << EIZ
net.ipv4.ip_forward = 0
#该文件内容为0 表示禁止数据包转发 1表示允许
net.ipv4.conf.default.rp_filter = 0
#是否忽略arp请求
net.ipv4.conf.default.accept_source_route = 0
#是否接受源路由(source route)
kernel.sysrq = 0
#是否开启sysrq,0为disable sysrq, 1为enable sysrq completely
kernel.core_uses_pid = 1
#如果这个文件的内容被配置成1,那么即使core_pattern中没有设置%p,最后生成的core dump文件名仍会加上进程ID
kernel.unknown_nmi_panic = 0
#该参数的值影响的行为(非屏蔽中断处理).当这个值为非0,未知的NMI受阻,PANIC出现.这时,内核调试信息显示控制台,则可以减轻系统中的程序挂起.
kernel.msgmnb = 65536
#指定内核中每个消息队列的最大字节限制
kernel.msgmax = 65536
#指定内核中单个消息的最大长度(bytes).进程间的消息传递是在内核的内存中进行的,不会交换到磁盘上,所以如果增大该值,则将增大操作系统所使用的内存数量
kernel.shmmax = 68719476736
#指定共享内存片段的最大尺寸(bytes)
kernel.shmall = 4294967296
#指定可分配的共享内存数量
vm.swappiness = 10
#内存不足时=0,进行少量交换 而不禁用交换=1,系统内存足够时=10 提高性能,默认值=60,值=100将积极使用交换空间

net.ipv4.tcp_tw_reuse = 1
#开启重用,允许Time-WAIT sockets重新用于新的TCP连接
net.ipv4.tcp_syncookies = 1
#开启SYN Cookies,当出现SYN等待队列溢出时,启用cookies来处理
net.ipv4.tcp_fin_timeout = 30
#如果套接字有本端要求关闭,这个参数决定了保持在FIN-WAIT-2状态的时间,对端可以出错并永远关闭连接,甚至以外宕机,缺省值是60秒,2.2内核的通常值是180秒,你可以按这个设置,但要记住的是,即时你的机器是一个轻载的WEB服务器,也有因为大量的死套接字而内存溢出的风险,FIN-WAIT-2的危险性比FIN-WAIT-1要小,因为它最多只能吃掉1.5K内存,但是他们生存期长些
net.ipv4.tcp_syn_retries = 3
#在内核放弃建立连接之前发送SYN包的数量可以设置为1
net.ipv4.tcp_synack_retries = 3
#为了打开对端的连接,内核需要发送一个SYN并附带一个回应前面一个SYN的ACK,也就是所谓的三次握手中的第二次握手,这个设置决定了内核放弃连接之前发送SYN+ACK包的数量可以设置为1
net.ipv4.tcp_max_orphans = 262144
#系统中最多有多少个TCP套接字不被关联到任何一个用户文件句柄上,如果超过这个数字,孤儿连接将即刻被复位并打印出警告信息,这个限制仅仅是为了防止简单的Dos攻击,不能过分依靠它或者人为地减小这个值,更应该增加这个值(如果增加了内存之后)
net.ipv4.tcp_keepalive_time = 60
#当keepzlived起作用的时候,TCP发送keepzlived消息的频度,缺省是两小时,可以设置为30
net.ipv4.tcp_max_tw_buckets = 180000
#time_wait的数量,默认是180000
net.ipv4.conf.all.send_redirects = 0
#禁止转发重定向报文
net.ipv4.conf.default.send_redirects = 0
#不充当路由器
net.ipv4.conf.all.secure_redirects = 0
#如果服务器不作为网关/路由器,该值建议设置为0
net.ipv4.conf.default.secure_redirects = 0
#禁止转发安全ICMP重定向报文
net.ipv4.conf.all.accept_redirects = 0
#禁止包含源路由的ip包
net.ipv4.conf.default.accept_redirects = 0
#禁止包含源路由的ip包

##### iptables ##############
net.ipv4.neigh.default.gc_thresh1 = 2048
#存在于ARP高速缓存中的最少层数,如果少于这个数,垃圾收集器将不会运行.缺省值是128。
net.ipv4.neigh.default.gc_thresh2 = 4096
#保存在 ARP 高速缓存中的最多的记录软限制.垃圾收集器在开始收集前,允许记录数超过这个数字 5 秒.缺省值是 512
net.ipv4.neigh.default.gc_thresh3 = 8192
#保存在 ARP 高速缓存中的最多记录的硬限制,一旦高速缓存中的数目高于此,垃圾收集器将马上运行.缺省值是1024
net.ipv4.ip_local_port_range = 1024 65535
#用于定义网络连接可用作其源(本地)端口的最小和最大端口的限制,同时适用于TCP和UDP连接.
net.ipv6.conf.all.disable_ipv6 = 1
#禁用整个系统所有接口的IPv6
fs.file-max = 1000000
#系统最大打开文件描述符数
fs.inotify.max_user_watches = 10000000
#表示同一用户同时可以添加的watch数目(watch一般是针对目录,决定了同时同一用户可以监控的目录数量)
net.core.rmem_max = 16777216
#接收套接字缓冲区大小的最大值(以字节为单位)
net.core.wmem_max = 16777216
#发送套接字缓冲区大小的最大值(以字节为单位)
net.core.wmem_default = 262144
#发送套接字缓冲区大小的默认值(以字节为单位)
net.core.rmem_default = 262144
#接收套接字缓冲区大小的默认值(以字节为单位)
net.core.somaxconn = 65535
#用来限制监听(LISTEN)队列最大数据包的数量,超过这个数量就会导致链接超时或者触发重传机制
net.core.netdev_max_backlog = 262144
#当网卡接收数据包的速度大于内核处理的速度时,会有一个队列保存这些数据包.这个参数表示该队列的最大值
net.ipv4.tcp_max_syn_backlog = 8120
#表示系统同时保持TIME_WAIT套接字的最大数量.如果超过此数,TIME_WAIT套接字会被立刻清除并且打印警告信息.之所以要设定这个限制,纯粹为了抵御那些简单的DoS攻击,不过,过多的TIME_WAIT套接字也会消耗服务器资源,甚至死机
net.netfilter.nf_conntrack_max = 1000000
#CONNTRACK_MAX 允许的最大跟踪连接条目,是在内核内存中netfilter可以同时处理的"任务"(连接跟踪条目)

EIZ
/sbin/sysctl -p
}

INSTALL_PACKAGE()
{
	package_list="vim-enhanced wget telnet lsof net-tools bc epel-release screen lrzsz"
	for i in `echo $package_list`
	do
		if [[ `rpm -qa |grep ^"$i"|wc -l` -eq 0 ]];then
			yum install $i -y
		else
			echo "$i already installed"
		fi
	done
}

INSTALL_DOCKER()
{
	if [[ `rpm -qa |grep ^docker-ce|wc -l` -eq 0 ]];then
		if [[ ! -f /etc/yum.repos.d/docker-ce.repo ]];then
			if [[ `rpm -qa |grep ^wget|wc -l` -eq 0 ]];then
				yum install wget -y
			fi
			wget -P /etc/yum.repos.d/ https://download.docker.com/linux/centos/docker-ce.repo
		fi
		yum install docker-ce -y
	else
		echo "docker-ce already installed"
	fi
	if [[ ! -e /etc/docker/ ]];then
		mkdir -p /etc/docker/
	fi
	if [[ `grep insecure-registries /etc/docker/daemon.json |wc -l` -eq 0 ]];then
		cat > /etc/docker/daemon.json << EOF
{
	"insecure-registries": [
		"192.168.0.8"
	],
	"registry-mirrors": ["http://hub-mirror.c.163.com", "https://docker.mirrors.ustc.edu.cn"]
}
EOF
systemctl restart docker
fi
}

SET_IF_ON()
{
	sed -i 's/ONBOOT=no/ONBOOT=yes/'	/etc/sysconfig/network-scripts/ifcfg-ens33
}


SET_VIM()
{
cat << "ENOF" >/root/.vimrc
set ts=4
set ruler     
syntax on
set tabstop=4
set nobackup
nmap <C-c> :q!<cr>
nmap <C-z> <esc>
nmap <C-e> :wq<cr>
nmap <space> /
nmap ' $
nmap ; 0

imap <C-w> <esc>:wq<cr>
imap <C-d> <esc>
imap <C-c> <esc>:q!<cr>
imap <C-u> <Up>
imap <C-k> <Down>
imap <C-j> <Left>
imap <C-l> <Right>
imap <C-b> <C-o>b
imap <C-f> <C-o>w
imap <C-v> set paste
ENOF
}

CHECK_ROOT
CHECK_SYS
OFFSELINUX
INSTALL_PACKAGE
INSTALL_DOCKER
SET_IF_ON
TIMELOCK
LIMITSCONF
SYSCTLCONF
SET_VIM

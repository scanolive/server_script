#server script

###shell

```
alias开头的文件放于/etc/profile.d/目录下 
---- 自定义alias

git_rsync.sh 
---- 加入定时任务,监控目录变化后自动同步

iftraf.sh 
---- 实时查看系统当前流量

java_env.sh 
---- 放于/etc/profile.d/定义java环境变量

linux_centos_init.sh
---- 初始化centos7

ssh_tun.sh local_port remote_port 
---- ssh隧道启动和检测脚本,一般用于加入crontab,以保证ssh隧道断开自动重连,需配置远程IP并添加密钥可免密登录

vpn.sh start|stop
---- openvpn启动关闭
```

###python

```
check_port.py ip port
---- 替换目录下所有文件名包含的特殊字符

check_url.py url 
---- 检测url状态
check_url.py -c url
---- 加入定时任务,用于监控url,不可用或恢复时报警

simple_web.py
---- 简单的web服务器,支持自定义目录和端口

send_mail.py
---- 发送邮件,支持群发,附件,需要配置用于发邮件的邮箱相关信息

```


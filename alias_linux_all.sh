PATH=/usr/local/bin:$PATH
alias ls='ls --color=auto'
alias l='ls -l'
alias la='ls -la'
alias laa='ls -lad .*'
alias lah='ls -lah'
alias lh='ls -lhSr'
alias ll='ls -l'
alias lsh='ls -l *.sh 2>/dev/null'
alias lpy='ls -l *.py 2>/dev/null'
alias lpdf='ls -l *.pdf'
alias ljpg='ls -l *.jp*g'
alias lpng='ls -l *.png'
alias ltxt='ls -l *.txt'
alias lld='ls -l |grep "^d"'
alias llf='ls -l |grep -v "^d"'
alias hs='cat /etc/hosts|grep -Ev "127.0.|localhost|ip6|^#"'
alias ..="cd .."
alias .2="cd ../.." 
alias .3="cd ../../.."
alias cc='cd ..'
alias cds='echo "`pwd`" > ~/.cdsave'
alias cdb='cd "`cat ~/.cdsave`"'
alias c='cat'
alias llw='ll | wc -l'
alias ka='killall '
alias h='cd $HOME'
alias dh='df -lht `grep -vE "^#|swap|cdrom|^$" /etc/fstab |awk "{if (\\$2==\"/\") print \\$3}"`'  
alias g2u='iconv -f gbk -t utf8 '
alias hg='history |grep '
alias psg='ps -ef|grep'
alias psa='ps -ef|grep -v "\["'
alias pgl='ping www.google.com.hk'
alias rr='rm -r '
alias grep='grep -i --color' 
alias sedc="sed 's/[^ -z]//g' "
alias lvim="vim -c \"normal '0\""  
alias tf='tail -f '  
alias nos='grep -Ev '\''^(#|$)'\'''
alias kill9='kill -9'
alias k9='kill -9' 
alias pd='ping baidu.com'
alias ipp="dig +short myip.opendns.com @resolver1.opendns.com"
alias dukk="du -sk -- * | sort -n | perl -pe '@SI=qw(K M G T P); s:^(\d+?)((\d\d\d)*)\s:\$1.\" \".\$SI[((length \$2)/3)].\"\t\":e'"
alias dk="du -sh -- * | sort -rn  | perl -e 'sub h{%h=(K=>10,M=>20,G=>30);(\$n,\$u)=shift=~/([0-9.]+)(\D)/;return \$n*2**\$h{\$u}}print reverse sort{h(\$b)<=>h(\$a)}<>;'"
alias filetree="ls -R | grep ":$" | sed -e 's/:$//' -e 's/[^-][^\/]*\//--/g' -e 's/^/ /' -e 's/-/|/'" 
alias dstr='date  +"%Y-%m-%d_%H:%M:%S"'
##-------------------------
alias ifcc='ifconfig |grep inet|grep -v inet6|awk "{gsub(\"addr:\",\"\");print \$2}"'
alias ifc='ifconfig |sed -n "/flags\|HWaddr\|Link/{N;s/\n/\t/;P}"|grep -v "inet6"|awk "{gsub(\"addr:\",\"\"); for(i=1;i<=NF;i++) if (\$(i+1) ~/</) {m=\$i} else if (\$i == \"inet\") {n=\$(i+1)} {printf \"%-15s%-15s\\n\", \$1,n}}"'
alias ifrr='ifconfig |sed -n "/flags\|HWaddr\|Link/{N;s/\n/\t/;P}"|grep -vE "`ls /sys/devices/virtual/net/|tr "\n" "|"`inet6" |awk -F "inet" "{print \$2}"|awk "{print \$1}"'
alias ifr='ifconfig |sed -n "/flags\|HWaddr\|Link/{N;s/\n/\t/;P}"|grep -vE "`ls /sys/devices/virtual/net/|tr "\n" "|"`inet6"|awk "{gsub(\"addr:\",\"\"); for(i=1;i<=NF;i++) if (\$(i+1) ~/</) {m=\$i} else if (\$i == \"inet\") {n=\$(i+1)} {printf \"%-15s%-15s\\n\", \$1,n}}"'
##-------------------------
alias ipam='for i in `ip link |grep -v "link" |awk -F ":" "{print \\$2}"|awk -F "@" "{print \\$1}"`;do iipp=`ip a show $i|grep " inet "|awk  "{print \\$2}"|tr "\n" "|"`;if test "$iipp";then  printf "%-18s%8s\n" "$i" "$iipp"|sed "s/|/ /g"; fi;done'
alias ipa='for i in `ip link |grep -v "link" |awk -F ":" "{print \\$2}"|awk -F "@" "{print \\$1}"`;do iipp=`ip a show $i|grep " inet "|awk  "{print \\$2}"|tr "\n" "|"`;if test "$iipp";then  printf "%-18s%8s\n" "$i" "$iipp"|sed "s/|/ /g"; fi;done |sed "s#/[1-9]*[1-9] #  #g"'
alias ipaa='for i in `ip link |grep -v "link" |awk -F ":" "{print \\$2}"|awk -F "@" "{print \\$1}"`;do ip a show $i|grep " inet "|awk  "{print \$2}" |sed "s#/[1-9]*[1-9]#  #g" ; done'
alias ipaam='for i in `ip link |grep -v "link" |awk -F ":" "{print \\$2}"|awk -F "@" "{print \\$1}"`;do ip a show $i|grep " inet "|awk  "{print \$2}"; done'
##-------------------------
alias iprr='for i in `ip link |grep -v "link" |awk -F ":" "{print \\$2}"|awk -F "@" "{print \\$1}"`;do if ! test $(ls /sys/devices/virtual/net/|grep $i);then ip a show $i | grep " inet "|awk  "{print \$2}"|awk -F "/" "{print \$1}";fi;done'
alias iprrm='for i in `ip link |grep -v "link" |awk -F ":" "{print \\$2}"|awk -F "@" "{print \\$1}"`;do if ! test $(ls /sys/devices/virtual/net/|grep $i);then ip a show $i | grep " inet "|awk  "{print \$2}";fi;done'
alias ipr='for i in `ip link |grep -v "link" |awk -F ":" "{print \\$2}"|awk -F "@" "{print \\$1}"`;do if ! test $(ls /sys/devices/virtual/net/|grep $i);then ipp=`ip a show $i | grep " inet "|awk  "{print \\$2}"|awk -F "/" "{print \\$1}"`;printf "%-18s%8s\n" "$i" "$ipp";fi;done'
alias iprm='for i in `ip link |grep -v "link" |awk -F ":" "{print \\$2}"|awk -F "@" "{print \\$1}"`;do if ! test $(ls /sys/devices/virtual/net/|grep $i);then ipp=`ip a show $i | grep " inet "|awk  "{print \\$2}"`;printf "%-18s%8s\n" "$i" "$ipp";fi;done'
##-------------------------
alias nel='netstat -anltp|grep LISTEN'
alias net='netstat -anltp'
alias fin='find / -name '
alias nlg='netstat -anltp|grep LISTEN|grep  '
alias net80='netstat -anltp |awk "/:80 / {print \$5}"|awk -F ":" "{print \$1}" |sort |uniq -c|sort -r'
alias lsv='systemctl list-units --type=service|grep -v "^systemd"|grep  "loaded active running"|grep -E -v "ssh|user|cron|rsyslog|dbus|getty"'

alias adx='chmod +x '

alias o='cd /opt/'
alias oa='cd /opt/applications'

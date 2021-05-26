alias fws='/usr/bin/firewall-cmd --stat'
alias fwl='/usr/bin/firewall-cmd --list-port|tr " " "\n"'
alias fwr='firewall-cmd --reload'

function fwa()
{
	if [[ "$1" != "" ]];then
		ports=$1
		for port in $ports
		do
		        echo $port
		        firewall-cmd --permanent --zone=public --add-port="$port"/tcp
		done

		firewall-cmd --reload
		firewall-cmd --list-port |tr ' ' "\n"
	fi
}

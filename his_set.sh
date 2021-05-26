#------------------history config----------------
export HISTFILESIZE=1024000
export HISTSIZE=1024000
export HISTTIMEFORMAT='%F %T  '
#export HISTCONTROL=ignoredups
export HISTCONTROL=ignorespace
export HISTIGNORE='ls:ll:l:pwd:rn:cd:'
#-------------------my history file config--------------------------
if [[ `uname` == 'Darwin' ]];then
	if [[ ${HOME} == '' ]];then
		MY_HISFILE_DIR="/var/root/logs/.hisfile/"
	fi
	MY_HISFILE_DIR=${HOME}'/logs/.hisfile/'
	MY_HISFILE_FILE="${MY_HISFILE_DIR}""/my_his_file.his"
else
	HISFILE_DIR="/var/log/.hisfile/"
	[[ -d "${HISFILE_DIR}" ]] || mkdir -p -m 777 "${HISFILE_DIR}"
	MY_HISFILE_DIR="${HISFILE_DIR}""$USER""/"
	[[ -d "${MY_HISFILE_DIR}" ]] || mkdir -p "${MY_HISFILE_DIR}"
	MY_HISFILE_FILE="${MY_HISFILE_DIR}""/my_his_file.his"
fi
[[ -f  "${MY_HISFILE_FILE}" ]] || touch "${MY_HISFILE_FILE}"

function sync_his()
{
 	history -a; history -c; history -r
}

function prompt_cmd()
{
        his_str=`history 1|awk '{$1="";$3=$3" ";print $0}'`
        his_str_date=`echo "${his_str}"|awk '{print $1" "$2}'`
        if ! grep -q "${his_str_date}" ${MY_HISFILE_FILE};then
        {
                echo "`who am i|awk '{if (NF==6) {ip=$NF} else {ip=\"loaclhost\"} {print ip\"_\"$1\"@\"$2}}'` ${sep_str_his} $OLDPWD ${sep_str_his}$his_str" >> "${MY_HISFILE_FILE}"
        }
        fi
        sync_his
}

function his_recent()
{
	if [[ ! $1 ]];then
	        day=3
	else
	        day=$1
	fi
	if [[ `uname` == 'Darwin' ]];then
		s_date=`date -v -${day}d "+%Y-%m-%d"`
	else
		s_date=`date -d "${day} days ago" "+%Y-%m-%d"`
	fi
	cat $MY_HISFILE_FILE |awk -F '=#@#=' '{print FNR" "$3}'|awk '{if ($2>"'"$s_date"'") print $0}' 
}

readonly MY_HISFILE_FILE
readonly sep_str_his='=#@#='
readonly PROMPT_COMMAND="${PROMPT_COMMAND:-:};prompt_cmd"
alias hha="cat ${MY_HISFILE_FILE}* |awk -F '$sep_str_his' '{print FNR\" \"\$3}'"
alias hh="cat ${MY_HISFILE_FILE} |awk -F '$sep_str_his' '{print FNR\" \"\$3}'"
alias his='his_recent'
OLDPWD=${HOME}

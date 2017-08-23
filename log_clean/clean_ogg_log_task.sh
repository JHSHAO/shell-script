#!/bin/bash
cd "$(dirname "$0")"
path=`pwd`
hostsfile="$path/hosts_ogg.txt"

ogg_user_path="/home/ogg"

while read remotehost
do
	sudo scp $path/clean_ogg_log.sh $remotehost:$ogg_user_path >/dev/null 2>&1
	sudo ssh -tt $remotehost << EOF
#清理ogg的dirrpt目录日志
chmod 755  $ogg_user_path/clean_ogg_log.sh
$ogg_user_path/clean_ogg_log.sh $ogg_user_path
exit
EOF
done < $hostsfile

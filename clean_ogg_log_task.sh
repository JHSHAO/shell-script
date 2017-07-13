#!/bin/bash
cd "$(dirname "$0")"
path=`pwd`
hostsfile="$path/hosts_ogg.txt"

ogg_root_path="/data/v01/ogg12"
ogg_user_path="/home/ogg"

while read remotehost
do
#	if sudo ssh $remotehost test ! -e $ogg_user_path/clean_ogg_log.sh; then
		sudo scp $path/clean_ogg_log.sh $remotehost:$ogg_user_path >/dev/null 2>&1
#	fi
	sudo ssh -tt $remotehost >/dev/null 2>&1 << EOF
chmod 755  $ogg_user_path/clean_ogg_log.sh
$ogg_user_path/clean_ogg_log.sh $ogg_root_path $ogg_user_path
exit
EOF
done < $hostsfile

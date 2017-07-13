#!/bin/sh
cd "$(dirname "$0")"
path=`pwd`

hosts_conf="$path/hosts.txt"

while read line
do
    if [ ${line:0:1} != "#" ];then
        args=($line)
        if [ "$1" = "setup" ];then
	    $path/setup_host.sh ${args[0]} ${args[1]}
	fi
        if [ "$1" = "hosts" ];then
            $path/update_hosts_file.sh ${args[0]} ${args[1]}
        fi
        if [ "$1" = "cprepo" ];then
	    $path/cp_repo.sh ${args[0]} ${args[1]}		
        fi
	if [ "$1" = "cmd" ];then
	    if [ $# == 3 ];then	
	        if [ ${args[0]} == $3 ]||[ ${args[1]} == $3 ]||[ ${args[2]} == $3 ]||[ ${args[3]} == $3 ]||[ $3 == 0 ];then
	            $path/cmds.sh ${args[0]} ${args[1]} $2
	        fi
	    elif [ $# == 4 ];then
		if [ ${args[0]} == $3 ]||[ ${args[1]} == $3 ]||[ ${args[2]} == $3 ]||[ ${args[3]} == $3 ]||[ $3 == 0 ];then
			$path/cmds.sh ${args[0]} ${args[1]} $2 $4
		fi
	    else
		$path/cmds.sh ${args[0]} ${args[1]} $2
	    fi
	fi
        if [ "$1" = "shell" ];then
            $path/$2 ${args[0]} ${args[1]} $3
        fi
    fi
done < $hosts_conf


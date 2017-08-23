#!/bin/bash
ogg_root_path=$OGGPATH
ogg_user_path=$1
#查找7天之前的日志
ogg_del_log=$(find $ogg_root_path/dirrpt -type f -mtime +7 -exec ls {} \;)
if [ ! -z "$ogg_del_log" ]; then
    ogg_log_arr=($ogg_del_log)
    #echo ${ogg_log_arr[@]}
    #ogg进程信息，用来排除不能删除的当前进程日志
    ogg_process_info=`$ogg_root_path/ggsci << EOF
info all
quit	
EOF`
    ogg_process=`echo "$ogg_process_info" | grep "EXTRACT" | awk 'BEGIN{print "MGR"}{print $3}' | xargs`
    ogg_process_arr=($ogg_process)
    #echo ${ogg_process_arr[@]}
    #排除不能删除的当前进程日志
    echo ${ogg_log_arr[@]}
    for process in ${ogg_process_arr[@]}
    do
        #echo $process
        echo "***************************"
        echo ${ogg_log_arr[@]} | sed -e "s/${process}\.dsc\|${process}\.rpt//g"
        echo ${#ogg_log_arr[@]}
        for ogg_log in ${ogg_log_arr[@]}
        do
            echo "$ogg_log" | grep "${process}\.dsc\|${process}\.rpt"
            #if [ $? -eq 0 ]; then
            #    echo "$ogg_log"
            #    #unset 
            #fi
            #sed -i "/${process}\.dsc\|${process}\.rpt/d" $ogg_user_path/ogg_clean_file.log
        done
    done
    #删除7天之前的日志（排除了当前进程的日志）
    #while read file
    #do
    #    echo $file
    #    #rm $file
    #done < $ogg_user_path/ogg_clean_file.log
fi
#磁盘空间大于80%，清理当天日志
if [ "$ogg_root_path" == "/data/v01/ogg12" ]; then
    ogg_disk=$(df -TH | awk '$7=="/data/v01"{print $6}' | sed 's/%//g')
else
    ogg_disk=$(df -TH | awk '$1=="/dev/sda3"{print $6}' | sed 's/%//g')
fi

#if [ $ogg_disk -ge 80 ]; then
#    echo "磁盘大小：$ogg_disk"
#    for file in `ls $ogg_root_path/dirrpt`; do
#        echo $file
#        #echo > $file
#    done
#    echo "磁盘空间超过80%，清空日志！"
#fi

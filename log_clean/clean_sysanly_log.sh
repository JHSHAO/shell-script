#!/bin/bash
#清理监控脚本sysanly.sh产生的日志
cd "$(dirname "$0")"
path=`pwd`
log_path="/home/babel/wtf/script/dkmonitor"
#days=$1
#if [ -z $days ]; then
#    days=20
#fi

days_ago=$(date +"%s" -d '-20 day')
for dir_name in `ls $log_path`
do
    log_date=$(date +"%s" -d "${dir_name#*_}")
    if [ $log_date -lt $days_ago ]; then
        echo "***********删除${dir_name}***********"
        rm -rf $log_path/$dir_name
    fi
done

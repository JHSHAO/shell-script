#!/bin/bash
del_date=$(date +"%Y-%m-%d" -d'-1 month')
del_date_second=$(date +"%s" -d "$del_date")
#echo $del_date $del_date_second

del_filedump_path=$1

for file in `ls $del_filedump_path`;do
  #echo $file
  log_date=$(echo $file | sed 's/[log.log_]//g' | sed 's/[.log]//g')
  log_date_second=$(date +"%s" -d "$log_date")
  #echo $log_date $log_date_second
  if [ $log_date_second -le $del_date_second ];then
    #echo $log_date $log_date_second
    #rm $del_filedump_path$file
    echo $del_filedump_path$file
  fi
done

del_inputhbase_path=$2

for file in `ls $del_inputhbase_path`;do
  #echo $file
  log_date=$(echo $file | sed 's/[log.log_]//g' | sed 's/[.log]//g')
  log_date_second=$(date +"%s" -d "$log_date")
  #echo $log_date $log_date_second
  if [ $log_date_second -le $del_date_second ];then
    #echo $log_date $log_date_second
    #rm $del_inputhbase_path$file
    echo $del_inputhbase_path$file
  fi
done
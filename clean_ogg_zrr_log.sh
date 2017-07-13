#!/bin/bash
ogg_root_path=$1
ogg_user_path=$2
ogg_zrr_log_path="/data/v01/ogg12/release/log9*"
if [ -e "$ogg_user_path/ogg_zrr_clean_file.log" ]; then
	rm $ogg_user_path/ogg_zrr_clean_file.log
fi
#自然人日志目录的所有日志文件，不包括链接（链接指向的文件就在当前目录），但包含了链接所指向的文件
ogg_zrr_log=$(find $ogg_zrr_log_path -type f -exec ls {} \;)
for file in $ogg_zrr_log; do
#	echo $file
	echo $file >> $ogg_user_path/ogg_zrr_clean_file.log
done
#查找不能删除的文件，链接包含的文件
ogg_zrr_keep_log=$(find $ogg_zrr_log_path -type l -exec ls -l {} \; | awk '{print $11}')
for file in $ogg_zrr_keep_log; do
#	echo $file
	sed -i "/$file/d" "$ogg_user_path/ogg_zrr_clean_file.log"
done
#删除日志
while read file
do
	echo $file
#	rm $file	
done < $ogg_user_path/ogg_zrr_clean_file.log 
#删除当天之前的日志
#ogg_zrr_del_log=$(find $ogg_zrr_log_path -type f -mtime +0 -exec ls {} \;)
#for file in $ogg_zrr_del_log; do
#	echo $file
#	echo $file >> $ogg_user_path/ogg_zrr_clean_file.log
#	rm $file
#done
#删除当天日志，保留最后一个200M文件
#ogg_zrr_del_log1=$(find $ogg_zrr_log_path -type f -mtime 0 -exec ls {} \;)
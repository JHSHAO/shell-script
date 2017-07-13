#!/bin/bash
ogg_root_path=$1
ogg_user_path=$2
if [ -e "$ogg_user_path/ogg_clean_file.log" ]; then
	rm $ogg_user_path/ogg_clean_file.log
fi
#清理7天之前的日志
ogg_del_log=$(find $ogg_root_path/dirrpt -type f -mtime +7 -exec ls {} \;)
for file in $ogg_del_log; do
	echo "$file" >> $ogg_user_path/ogg_clean_file.log
#	rm $file
done
#for file in `ls $ogg_root_path/dirrpt`; do
#	echo "$ogg_root_path/$file" >> $ogg_user_path/ogg_clean_file.log
#done
#ogg进程信息
#ogg_process=`$ogg_root_path/ggsci << EOF
#info all
#quit	
#EOF`

#echo "$ogg_process" | grep "EXTRACT" | awk '{print $3}' > $ogg_user_path/ogg_process.log

#清理非当天的日志
#while read file
#do
#	echo $file
#	rm $file
#done < $ogg_user_path/ogg_clean_file.log
echo "完成删除日志！"
#磁盘空间大于80%，清理当天日志
ogg_disk=$(df -h | awk '$6=="/data/v01"{print $5}' | sed 's/%//g')
if [ $ogg_disk -ge 80 ]; then
	echo "磁盘大小：$ogg_disk"
	for file in `ls $ogg_root_path/dirrpt`; do
		echo $file
#		echo > $file
	done
	echo "磁盘空间超过80%，清空日志！"
fi
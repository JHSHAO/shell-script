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
echo "完成删除日志！"
#磁盘空间大于80%，清理当天日志
ogg_disk=$(df -h | awk '$6=="/data/v01"{print $5}' | sed 's/%//g')
if [ $ogg_disk -le 80 ]; then
	echo "磁盘大小：$ogg_disk"
#	for file in `ls $ogg_root_path/dirrpt`; do
#		echo $file >/dev/null 2>&1
#		echo > $file
#	done
	echo "磁盘空间超过80%，清空日志！"
fi

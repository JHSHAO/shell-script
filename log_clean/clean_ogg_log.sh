#!/bin/bash
ogg_root_path=$OGGPATH
ogg_user_path=$1
if [ -e "$ogg_user_path/ogg_clean_file.log" ]; then
	rm $ogg_user_path/ogg_clean_file.log
fi
#查找7天之前的日志
ogg_del_log=$(find $ogg_root_path/dirrpt -type f -mtime +7 -exec ls {} \;)
for file in $ogg_del_log; do
	echo "$file" >> $ogg_user_path/ogg_clean_file.log
done
#ogg进程信息，用来排除不能删除的当前进程日志
ogg_process=`$ogg_root_path/ggsci << EOF
info all
quit	
EOF`
if [ -e "$ogg_user_path/ogg_process.log" ]; then
	rm $ogg_user_path/ogg_process.log
fi
echo "$ogg_process" | grep "EXTRACT" | awk '{print $3}' >> $ogg_user_path/ogg_process.log
echo "MGR" >> $ogg_user_path/ogg_process.log
#排除不能删除的当前进程日志
while read process
do
#	echo $process
	sed -i "/${process}\.dsc\|${process}\.rpt/d" $ogg_user_path/ogg_clean_file.log
done < $ogg_user_path/ogg_process.log
#删除7天之前的日志（排除了当前进程的日志）
while read file
do
	echo $file
#	rm $file
done < $ogg_user_path/ogg_clean_file.log
#磁盘空间大于80%，清理当天日志
if [ "$ogg_root_path" == "/data/v01/ogg12" ]; then
	ogg_disk=$(df -TH | awk '$7=="/data/v01"{print $6}' | sed 's/%//g')
else
	ogg_disk=$(df -TH | awk '$1=="/dev/sda3"{print $6}' | sed 's/%//g')
fi

if [ $ogg_disk -ge 80 ]; then
	echo "磁盘大小：$ogg_disk"
	for file in `ls $ogg_root_path/dirrpt`; do
		echo $file
#		echo > $file
	done
	echo "磁盘空间超过80%，清空日志！"
fi

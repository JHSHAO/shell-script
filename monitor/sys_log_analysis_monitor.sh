#!/bin/bash
#分析监控日志，查看监控状态，超过正常值报警
cd "$(dirname "$0")"
path=`pwd`
hostsfile="/home/babel/wtf/script/hosts.txt"
send_sms_command=$1
send_email_command=$2

#短信内容
#sms_content=""
#邮件内容
email_content=""
while read remotehosts
do
    #主机IP地址及别名
    remotehost=`echo $remotehosts | awk '{print $1}'`
    remotehost_name=`echo $remotehosts | awk '{print $3}'`
    #短信内容
    sms_content=""
    log_path="/home/babel/wtf/script/dkmonitor/${remotehost}_$(date +'%Y-%m-%d')"

    #通过磁盘日志判断主机ssh是否卡住，因为磁盘是第一个记录，即使ssh卡住，也会记录第一行非ssh连接的内容。
    disk_row_num=(`cat -n $log_path/diskinfo | grep "diskinfo" | tail -n 2 | awk '{print $1}'`)
    disk_row_step=$[${disk_row_num[1]}-${disk_row_num[0]}]
    if [ $disk_row_step -le 1 ]; then
        sms_content+="${remotehost_name}主机ssh卡住，可能宕机。"
    fi
    
    #磁盘使用量
    #disk_v01=(`cat $log_path/diskinfo | head -n ${disk_row_num[1]} | tail -n +${disk_row_num[0]} | grep "/data/v01" | awk '{print $5"\t"$6}'`)
    disk_v01=(`sed -n "${disk_row_num[0]},${disk_row_num[1]}p" $log_path/diskinfo | grep "/data/v01" | awk '{print $5"\t"$6}'`)
    disk_v01_use=`echo ${disk_v01[1]} | sed 's/%//'`
    disk_v02=(`sed -n "${disk_row_num[0]},${disk_row_num[1]}p" $log_path/diskinfo | grep "/data/v02" | awk '{print $5"\t"$6}'`)
    disk_v02_use=`echo ${disk_v02[1]} | sed 's/%//'`
    if [ $disk_v01_use -ge 80 ]; then
        email_content+="<div>${remotehost_name}:文件系统/data/v01可用${disk_v01[0]},使用百分比${disk_v01_use}%。</dvi>"
        large_files=`sudo ssh -n $remotehost du --exclude="/data/v01/ProvincesDatas/*" --max-depth=3 /data/v01/ | sort -n | tail -n 8 | awk '{print $2}'`
        email_content+="<div>其中大文件："
        disk_v01_used=`sudo ssh -n $remotehost df -Thm | grep "/data/v01" | awk '{print $4}'`
        disk_v01_ex_pd=`sudo ssh -n $remotehost du -hm --max-depth=0 --exclude="/data/v01/ProvincesDatas" /data/v01/ | awk '{print $1}'`
        disk_v01_pd=$[($disk_v01_used-$disk_v01_ex_pd)/1024]
        email_content+="${disk_v01_pd}G=/data/v01/ProvincesDatas。"
        for large_file in $large_files; do
            large_file_size=`sudo ssh -n $remotehost du -h --exclude="/data/v01/ProvincesDatas/*" --max-depth=0 $large_file | awk '{print $1"="$2}'`
            email_content+="$large_file_size。"
        done
        email_content+="</div>"
    fi

    if [ $disk_v01_use -ge 90 ]; then
        sms_content+="${remotehost_name}:文件系统/data/v01可用${disk_v01[0]},使用百分比${disk_v01_use}%。"
        large_files=`sudo ssh -n $remotehost du --exclude="/data/v01/ProvincesDatas/*" --max-depth=3 /data/v01/ | sort -n | tail -n 8 | awk '{print $2}'`
        for large_file in $large_files; do
            large_file_size=`sudo ssh -n $remotehost du -h --exclude="/data/v01/ProvincesDatas/*" --max-depth=0 $large_file | awk '{print $1"="$2}'`
            sms_content+="$large_file_size。"
        done
    fi

    if [ $disk_v02_use -ge 80 ]; then
        email_content+="<div>${remotehost_name}:文件系统/data/v02可用${disk_v02[0]},使用百分比${disk_v02_use}%。</div>"
        large_files=`sudo ssh -n $remotehost du --exclude="/data/v02/ProvincesDatas/*" --max-depth=3 /data/v02/ | sort -n | tail -n 8 | awk '{print $2}'`
        email_content+="<div>其中大文件："
        for large_file in $large_files; do
            large_file_size=`sudo ssh -n $remotehost du -h --exclude="/data/v02/ProvincesDatas/*" --max-depth=0 $large_file | awk '{print $1"="$2}'`
            email_content+="$large_file_size。"
        done
        email_content+="</div>"
    fi

    if [ $disk_v02_use -ge 90 ]; then
        sms_content+="${remotehost_name}:文件系统/data/v02可用${disk_v02[0]},使用百分比${disk_v02_use}%。"
        large_files=`sudo ssh -n $remotehost du --exclude="/data/v02/ProvincesDatas/*" --max-depth=3 /data/v02/ | sort -n | tail -n 8 | awk '{print $2}'`
        for large_file in $large_files; do
            large_file_size=`sudo ssh -n $remotehost du -h --exclude="/data/v02/ProvincesDatas/*" --max-depth=0 $large_file | awk '{print $1"="$2}'`
            sms_content+="$large_file_size。"
        done
    fi

    #kafka端口6667的网络连接数
    conn_row_num=(`cat -n $log_path/netconect | grep "6667" | tail -n 2 | awk '{print $1}'`)
    conn_row_step=$[${conn_row_num[1]}-${conn_row_num[0]}]
    #判断单个ip连接数，关注连接数最高的前10个
    if [ $conn_row_step -gt 1 ]; then
        conn_count_top10=(`sed -n "$[${conn_row_num[0]}+1],$[${conn_row_num[0]}+10]p" $log_path/netconect | awk '{print $1}'`)
        conn_temp_content=""
        for ((i=0;i<10;i++))
        do
            if [ ${conn_count_top10[$i]} -ge 1000 ]; then
                conn_row=`sed -n "$[${conn_row_num[0]}+$i+1]p" $log_path/netconect | awk '{print $1"="$2}'`
                conn_temp_content+="${conn_row}。"
            fi
        done
        if [ ! -z "$conn_temp_content" ]; then
            sms_content+="${remotehost}单个IP连接数报警:${conn_temp_content}"
        fi
    fi
    #计算总连接数
    conn_count_arr=(`sed -n "$[${conn_row_num[0]}+1],$[${conn_row_num[1]}-1]p" $log_path/netconect | awk '{print $1}'`)
    conn_total=""
    for conn_count in ${conn_count_arr[@]}
    do
        conn_total=$[${conn_total}+${conn_count}]
    done
    if [ $conn_total -ge 15000 ]; then
        sms_content+="${remotehost}连接总数报警:${conn_total}。"
    fi

    #负载
    uptime_row_num=(`cat -n $log_path/uptime | grep "uptime" | tail -n 2 | awk '{print $1}'`)
    load_aver_arr=(`sed -n "$[${uptime_row_num[0]}+1],$[${uptime_row_num[1]}-1]p" $log_path/uptime | sed "s/.*average://g" | awk -F , '{print $1"\t"$2"\t"$3}'`)
    if [ `echo ${load_aver_arr[0]}\>=10|bc` -eq 1 -o `echo ${load_aver_arr[1]}\>=10|bc` -eq 1 -o `echo ${load_aver_arr[2]}\>=10|bc` -eq 1 ]; then
        sms_content+="${remotehost}负载报警:${load_aver_arr[@]}。"
    fi

    #发送短信
    #recivers="13120228321,17600908312,13001927192,17600196269,15510798997"
    recivers="17600908312"
    if [ ! -z "$sms_content" ]; then
       $send_sms_command $recivers $sms_content 250
       send_date_name=`date +"%Y_%m_%d"`
       send_time=`date +"%Y-%m-%d %H:%M:%S"`
       echo "{\"sendTime\":\"${send_time}\",\"smsContent\":\"${sms_content}\"}" >> $path/sms_message_${send_date_name}.log
    fi
done < $hostsfile
#发送邮件
#to_address="wutf5@chinaunicom.cn,microcosm8023@163.com,wangc238@chinaunicom.cn,apache_jianhua@163.com,1160880871@qq.com"
to_address="1160880871@qq.com"
cc_address="null"
subject="主机系统监控报警"
user_name="hqs-cbss-babel@chinaunicom.cn"
password="E94#l#eE"
if [ ! -z "$email_content" ]; then
   #记录发送邮件日志文件名字中的日期部分
   send_date_name=`date +"%Y_%m_%d"`
   if [ ! -e "$path/email_message_${send_date_name}.log" ]; then
       touch $path/email_message_${send_date_name}.log
   fi
   #上次发送邮件的时间
   last_send_time=`grep "sendTime" $path/email_message_${send_date_name}.log | tail -n 1 | awk -F \" '{print $4}'`
   last_send_stamp=`date -d "$last_send_time" +"%s"`
   current_stamp=`date +"%s"`
   interval_min=$[($current_stamp-$last_send_stamp)/60]
   #邮件发送频率30分钟
   if [ $interval_min -ge 30 ]; then
       $send_email_command $to_address $cc_address $subject $user_name $password $email_content
       send_time=`date +"%Y-%m-%d %H:%M:%S"`
       echo "{\"sendTime\":\"${send_time}\",\"emailContent\":\"${email_content}\"}" >> $path/email_message_${send_date_name}.log
   fi
fi
#清理7天之前记录发送短信和邮件的日志
find $path -name "sms_message_*.log" -type f -mtime +7 -exec rm {} \;
find $path -name "email_message_*.log" -type f -mtime +7 -exec rm {} \;

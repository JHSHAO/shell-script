#!/bin/bash
#分析监控日志，查看监控状态，超过正常值报警
hostsfile="/home/babel/wtf/script/hosts.txt"

while read remotehost
do
    sms_content=""
    log_path="/home/babel/wtf/script/dkmonitor/${remotehost}_$(date +'%Y-%m-%d')"

    #通过磁盘日志判断主机ssh是否卡住，因为磁盘是第一个记录，即使ssh卡住，也会记录第一行非ssh连接的内容。
    disk_row_num=(`cat -n $log_path/diskinfo | grep "diskinfo" | tail -n 2 | awk '{print $1}'`)
    disk_row_step=$[${disk_row_num[1]}-${disk_row_num[0]}]
    if [ $disk_row_step -le 1 ]; then
        sms_content+="${remotehost}主机ssh卡住，可能宕机。"
    fi
    
    #磁盘使用量
    #disk_v01=(`cat $log_path/diskinfo | head -n ${disk_row_num[1]} | tail -n +${disk_row_num[0]} | grep "/data/v01" | awk '{print $5"\t"$6}'`)
    disk_v01=(`sed -n "${disk_row_num[0]},${disk_row_num[1]}p" $log_path/diskinfo | grep "/data/v01" | awk '{print $5"\t"$6}'`)
    disk_v01_use=`echo ${disk_v01[1]} | sed 's/%//'`
    disk_v02=(`sed -n "${disk_row_num[0]},${disk_row_num[1]}p" $log_path/diskinfo | grep "/data/v02" | awk '{print $5"\t"$6}'`)
    disk_v02_use=`echo ${disk_v01[1]} | sed 's/%//'`
    if [ $disk_v01_use -ge 40 ]; then
        sms_content+="${remotehost}的/data/v01可用${disk_v01[0]},使用百分比${disk_v01_use}%。"
    fi

    if [ $disk_v02_use -ge 40 ]; then
        sms_content+="${remotehost}的/data/v02可用${disk_v02[0]},使用百分比${disk_v02_use}%。"
    fi

    #kafka端口6667的网络连接数
    conn_row_num=(`cat -n $log_path/netconect | grep "6667" | tail -n 2 | awk '{print $1}'`)
    conn_count_arr=(`sed -n "$[${conn_row_num[0]}+1],$[${conn_row_num[1]}-1]p" $log_path/netconect | awk '{print $1}'`)
    conn_total=""
    for conn_count in ${conn_count_arr[@]}
    do
        conn_total=$[${conn_total}+${conn_count}]
    done
    if [ $conn_total -ge 10000 ]; then
        sms_content+="${remotehost}网络连接数报警:${conn_total}。"
    fi

    #负载
    uptime_row_num=(`cat -n $log_path/uptime | grep "uptime" | tail -n 2 | awk '{print $1}'`)
    load_aver_arr=(`sed -n "$[${uptime_row_num[0]}+1],$[${uptime_row_num[1]}-1]p" $log_path/uptime | sed "s/.*average://g" | awk -F , '{print $1"\t"$2"\t"$3}'`)
    if [ `echo ${load_aver_arr[0]}\>=10|bc` -eq 1 -o `echo ${load_aver_arr[1]}\>=10|bc` -eq 1 -o `echo ${load_aver_arr[2]}\>=10|bc` -eq 1 ]; then
        sms_content+="${remotehost}负载报警:${load_aver_arr[@]}。"
    fi

    #发送短信
    #interface_addr="http://10.161.11.182:8082/monitor/rest/message/sendMessage"
    #content_type="Content-Type:application/json"
    ##recivers="13120228321,17600908312,13001927192,17600196269,15510798997"
    #recivers="17600908312"
    #if [ ! -z "$content" ]; then
    #    curl $interface_addr -H $content_type -d "{\"recivers\":\"$recivers\",  \"content\": \"$content\"}"
    #    send_date_name=`date +"%Y_%m_%d"`
    #    send_time=`date +"%Y-%m-%d %H:%M:%S"`
    #    find $path -name "sms_message_*.log" -type f -mtime +7 -exec rm {} \;
    #    echo "{\"sendTime\":\"${send_time}\",\"content\":\"${content}\"}" >> $path/sms_message_${send_date_name}.log
    #fi
    echo "${remotehost}的短信内容：${sms_content}"
done < $hostsfile

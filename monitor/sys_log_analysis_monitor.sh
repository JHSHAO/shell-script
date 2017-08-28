#!/bin/bash
#分析监控日志，查看监控状态，超过正常值报警
cd "$(dirname "$0")"
path=`pwd`
hostsfile="/home/babel/wtf/script/hosts.txt"

#短信内容
#sms_content=""
while read remotehost
do
    #短信内容
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
    if [ $disk_v01_use -ge 90 ]; then
        sms_content+="${remotehost}的/data/v01可用${disk_v01[0]},使用百分比${disk_v01_use}%。"
        large_files=`sudo ssh -n $remotehost du --exclude="/data/v01/ProvincesDatas/*" --max-depth=3 /data/v01/ | sort -n | tail -n 8 | awk '{print $2}'`
        for large_file in $large_files; do
            large_file_size=`sudo ssh -n $remotehost du -h --exclude="/data/v01/ProvincesDatas/*" --max-depth=0 $large_file | awk '{print $1"="$2}'`
            sms_content+="$large_file_size。"
        done
    fi

    if [ $disk_v02_use -ge 90 ]; then
        sms_content+="${remotehost}的/data/v02可用${disk_v02[0]},使用百分比${disk_v02_use}%。"
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
       /home/babel/wangxuan/common/send_sms.sh $recivers $sms_content 250
    fi
done < $hostsfile
#发送短信
##recivers="13120228321,17600908312,13001927192,17600196269,15510798997"
#recivers="17600908312"
#if [ ! -z "$sms_content" ]; then
#    /home/babel/wangxuan/common/send_sms.sh $recivers $sms_content 250
#fi

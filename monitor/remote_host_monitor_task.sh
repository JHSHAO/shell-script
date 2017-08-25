#!/bin/bash
cd "$(dirname "$0")"
path=`pwd`
hostsfile="$path/hosts_remote.txt"

while read remotehost
do
    echo "******************************$remotehost***********************************"
    #短信内容
    content=""
    #判断主机是否正常，即能否ssh链接。
    sudo ssh -n $remotehost "df -TH" > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        content+="${remotehost}主机不能ssh链接，可能宕机。"
    fi
    #磁盘使用率
    v01=(`sudo ssh -n $remotehost "df -TH" | grep v01 | awk '{print $5"\t"$6}'`)
    v01_use=`echo ${v01[1]} | sed 's/%//'`
    v02=(`sudo ssh -n $remotehost "df -TH"  | grep v02| awk '{print $5"\t"$6}'`)
    v02_use=`echo ${v02[1]} | sed 's/%//'`
    if [ "$remotehost" == "inf13" ]; then
        v01=(`sudo ssh -n $remotehost "df -TH" | grep "/dev/sda3" | awk '{print $5"\t"$6}'`)
        v01_use=`echo ${v01[1]} | sed 's/%//'`
        v02=(`sudo ssh -n $remotehost "df -TH"  | grep "/dev/sda3" | awk '{print $5"\t"$6}'`)
        v02_use=`echo ${v02[1]} | sed 's/%//'`
    fi
    if [ $v01_use -ge 90 ]; then
        content+="${remotehost}的/data/v01可用${v01[0]},使用百分比${v01_use}%。"
        large_files=`sudo ssh -n $remotehost du --exclude="/data/v01/ProvincesDatas/*" --max-depth=3 /data/v01/ | sort -n | tail -n 8 | awk '{print $2}'`
        for large_file in $large_files; do
            large_file_size=`sudo ssh -n $remotehost du -h --exclude="/data/v01/ProvincesDatas/*" --max-depth=0 $large_file | awk '{print $1"="$2}'`
            content+="$large_file_size。"
        done
    fi

    if [ $v02_use -ge 90 ]; then
        content+="${remotehost}的/data/v02可用${v02[0]},使用百分比${v02_use}%。"
        large_files=`sudo ssh -n $remotehost du --exclude="/data/v02/ProvincesDatas/*" --max-depth=3 /data/v02/ | sort -n | tail -n 8 | awk '{print $2}'`
        for large_file in $large_files; do
            large_file_size=`sudo ssh -n $remotehost du -h --exclude="/data/v02/ProvincesDatas/*" --max-depth=0 $large_file | awk '{print $1"="$2}'`
            content+="$large_file_size。"
        done
    fi
    #网络连接数
#   netnumarr=`sudo ssh -n $remotehost netstat -an|grep 6667|awk '{print $5}'|awk -F: '{print $1}'|sort -r|uniq -c|sort -nr|awk '{print$1}'`
#   netcon=0
#   for num in $netnumarr; do
#       netcon=`expr $netcon + $num`
#   done
    netcon=`sudo ssh -n $remotehost netstat -an|grep 6667|wc -l`
    if [ $netcon -ge 15000 ]; then
        content+="${remotehost}网络连接数报警:${netcon}。"
    fi
    #负载
    load_aver_arr=(`sudo ssh -n $remotehost uptime | sed "s/.*average://g" | awk -F , '{print $1"\t"$2"\t"$3}'`)
    if [ `echo ${load_aver_arr[0]}\>=10|bc` -eq 1 -o `echo ${load_aver_arr[1]}\>=10|bc` -eq 1 -o `echo ${load_aver_arr[2]}\>=10|bc` -eq 1 ]; then
        content+="${remotehost}负载报警:${load_aver_arr[@]}。"
    fi
    #发送短信
    interface_addr="http://10.161.11.182:8082/monitor/rest/message/sendMessage"
    content_type="Content-Type:application/json"
    #recivers="13120228321,17600908312,13001927192,17600196269,15510798997"
    recivers="17600908312"
    if [ ! -z "$content" ]; then
        curl $interface_addr -H $content_type -d "{\"recivers\":\"$recivers\",  \"content\": \"$content\"}"
        send_date_name=`date +"%Y_%m_%d"`
        send_time=`date +"%Y-%m-%d %H:%M:%S"`
        find $path -name "monitor_sms_message_*.log" -type f -mtime +7 -exec rm {} \;
        echo "{\"sendTime\":\"${send_time}\",\"content\":\"${content}\"}" >> $path/monitor_sms_message_${send_date_name}.log
    fi
done < $hostsfile

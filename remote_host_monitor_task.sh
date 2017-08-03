#!/bin/bash
cd "$(dirname "$0")"
path=`pwd`
hostsfile="$path/hosts_remote.txt"

while read remotehost
do
#    echo "******************************$remotehost***********************************"
    #短信内容
    content=""
    #磁盘使用率
    v01=`sudo ssh -n $remotehost "df -TH" | grep v01 | awk '{print $6}' | tr -cd "[0-9]"`
    v01_arail=`sudo ssh -n $remotehost "df -TH" | grep v01 | awk '{print $5}'`
    v02=`sudo ssh -n $remotehost "df -TH"  | grep v02| awk '{print $6}' | tr -cd "[0-9]"`
    v02_arail=`sudo ssh -n $remotehost "df -TH"  | grep v02| awk '{print $5}'`
    if [ $v01 -ge 90 ]; then
        content+="${remotehost}的/data/v01可用${v01_arail},使用百分比${v01}%。"
        large_files=`sudo ssh -n $remotehost du --exclude="/data/v01/ProvincesDatas/*" --max-depth=3 /data/v01/ | sort -n | tail -n 8 | awk '{print $2}'`
        for large_file in $large_files; do
            large_file_size=`sudo ssh -n $remotehost du -h --exclude="/data/v01/ProvincesDatas/*" --max-depth=0 $large_file | awk '{print $1"="$2}'`
            content+="$large_file_size。"
        done
    fi

    if [ $v02 -ge 90 ]; then
        content+="${remotehost}的/data/v02可用${v02_arail},使用百分比${v02}%。"
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
    if [ $netcon -ge 5000 ]; then
        content+="${remotehost}网络连接数报警:${netcon}。"
    fi
    #负载
    load_ave=`sudo ssh -n $remotehost uptime`
    load_ave_1=`sudo ssh -n $remotehost uptime | sed "s/.*average://g" | awk -F , '{print $1}'`
    load_ave_5=`sudo ssh -n $remotehost uptime | sed "s/.*average://g" | awk -F , '{print $2}'`
    load_ave_15=`sudo ssh -n $remotehost uptime | sed "s/.*average://g" | awk -F , '{print $3}'`
    if [ `echo load_ave_1\>=10|bc` -eq 1 -o `echo $load_ave_5\>=10|bc` -eq 1 -o `echo $load_ave_15\>=10|bc` -eq 1 ]; then
        content+="${remotehost}负载报警:${load_ave}。"
    fi
    #发送短信
    interface_addr="http://10.161.11.182:8082/monitor/rest/message/sendMessage"
    content_type="Content-Type:application/json"
#    recivers="13120228321,17600908312,13001927192,17600196269,15510798997"
    recivers="17600908312"
    if [ ! -z "$content" ]; then
        curl $interface_addr -H $content_type -d "{\"recivers\":\"$recivers\",  \"content\": \"$content\"}"
    fi
done < $hostsfile

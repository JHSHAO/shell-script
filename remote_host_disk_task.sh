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
    if [ $v01 -ge 80 ]; then
        content+="${remotehost}的/data/v01可用${v01_arail},使用百分比${v01}%。"
        large_files=`sudo ssh -n $remotehost du --exclude="/data/v01/ProvincesDatas/*" --max-depth=3 /data/v01/ | sort -n | tail -n 8 | awk '{print $2}'`
        for large_file in $large_files; do
            large_file_size=`sudo ssh -n $remotehost du -h --exclude="/data/v01/ProvincesDatas/*" --max-depth=0 $large_file | awk '{print $1"="$2}'`
            content+="$large_file_size。"
        done
    fi

    if [ $v02 -ge 80 ]; then
        content+="${remotehost}的/data/v02可用${v02_arail},使用百分比${v02}%。"
        large_files=`sudo ssh -n $remotehost du --exclude="/data/v02/ProvincesDatas/*" --max-depth=3 /data/v02/ | sort -n | tail -n 8 | awk '{print $2}'`
        for large_file in $large_files; do
            large_file_size=`sudo ssh -n $remotehost du -h --exclude="/data/v02/ProvincesDatas/*" --max-depth=0 $large_file | awk '{print $1"="$2}'`
            content+="$large_file_size。"
        done
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

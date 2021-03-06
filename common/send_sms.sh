#!/bin/bash
#发送短信
cd "$(dirname "$0")"
path=`pwd`

interface_addr="http://10.161.11.182:8082/monitor/rest/message/sendMessage"
content_type="Content-Type:application/json"

recivers=$1
sms_content=$2
step=$3
if [ -z "$step" ]; then
    step=250
fi

if [ ! -z "$sms_content" ]; then
    len=${#sms_content}
    num=$[$len/$step]
    if [ $[$len%$step] -ne 0 ]; then
        num=$[$num+1]    
    fi

    for ((i=0;i<$num;i++))
    do
       sms_content_segment=${sms_content:$[$step*$i]:$step}
       curl $interface_addr -H $content_type -d "{\"recivers\":\"$recivers\",  \"content\": \"$sms_content_segment\"}" > /dev/null 2>&1
       #send_date_name=`date +"%Y_%m_%d"`
       #send_time=`date +"%Y-%m-%d %H:%M:%S"`
       #find $path -name "sms_message_*.log" -type f -mtime +7 -exec rm {} \;
       #echo "{\"sendTime\":\"${send_time}\",\"smsContent\":\"${sms_content_segment}\"}" >> $path/sms_message_${send_date_name}.log
    done
fi

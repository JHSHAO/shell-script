#!/bin/bash
#发送邮件
cd "$(dirname "$0")"
path=`pwd`

to_address=$1
cc_address=$2
if [ "$cc_address" == "null" ]; then
    cc_address=""
fi
subject=$3
user_name=$4
password=$5
email_content=$6
#echo "toAddress:${to_address}=====ccAddress:${cc_address}======subject:${subject}======userName:${user_name}======password:${password}======email_content:${email_content}"

interface_addr="http://10.161.11.182:8082/monitor/rest/email/emailService"
content_type="Content-Type:application/json"
data_json="{\"toAddress\":\"$to_address\",\"ccAddress\":\"$cc_address\",\"subject\":\"$subject\",\"userName\":\"$user_name\",\"password\":\"$password\",\"content\":\"$email_content\"}"
#echo "$data_json:${data_json}"

curl $interface_addr -H $content_type -d $data_json >/dev/null 2>&1

#send_date_name=`date +"%Y_%m_%d"`
#send_time=`date +"%Y-%m-%d %H:%M:%S"`
#find $path -name "email_message_*.log" -type f -mtime +7 -exec rm {} \;
#echo "{\"sendTime\":\"${send_time}\",\"emailContent\":\"${email_content}\"}" >> $path/email_message_${send_date_name}.log

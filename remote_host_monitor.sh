#!/bin/bash
cd "$(dirname "$0")"
path=`pwd`
hostsfile="$path/hosts_remote.txt"

#短信内容
content=""
while read remotehost
do
	echo "------------------------------------------------------------------------------------------------------------------------"
	echo "IP:$remotehost"
	echo "------------------------------------------------------------------------------------------------------------------"
	echo "内存"
	mem=`sudo ssh -n $remotehost "free - m"`
	memfree=`sudo ssh -n $remotehost "free - m" | grep Mem | awk '{print $4}'`
	if [ $memfree -le 1024 ]; then
		echo -e "\033[31m$mem\033[0m"
	else
		echo "$mem"
	fi
	echo "------------------------------------------------------------------------------------------------------------------"
	echo -e "磁盘\n一.磁盘使用率"
	v01=`sudo ssh -n $remotehost "df -TH" | grep v01 | awk '{print $6}' | tr -cd "[0-9]"`
	v01_arail=`sudo ssh -n $remotehost "df -TH" | grep v01 | awk '{print $5}'`
	v02=`sudo ssh -n $remotehost "df -TH"  | grep v02| awk '{print $6}' | tr -cd "[0-9]"`
	v02_arail=`sudo ssh -n $remotehost "df -TH"  | grep v02| awk '{print $5}'`
	if [ $v01 -ge 90 ]; then
		echo -e "\033[31m/data/v01 使用百分比: ${v01}%\033[0m"
		content+="${remotehost}的/data/v01磁盘可用${v01_arail} 使用百分比${v01}%。"
	else
		echo "/data/v01 使用百分比: ${v01}%"	
	fi

	if [ $v02 -ge 90 ]; then
		echo -e "\033[31m/data/v02 使用百分比: ${v02}%\033[0m"
		content+="${remotehost}的/data/v02磁盘可用${v02_arail} 使用百分比${v02}%。"
	else
		echo "/data/v02 使用百分比: ${v02}%"
	fi
	echo "二.磁盘读写io"
	device=`sudo ssh -n $remotehost "iostat | grep Device"`
	sda=`sudo ssh -n $remotehost "iostat | grep sda"`
	sda_read=`echo "$sda" | awk '{print $3}'`
	sda_wrt=`echo "$sda" | awk '{print $4}'`
	sdb=`sudo ssh -n $remotehost "iostat | grep sdb"`
	sdb_read=`echo "$sdb" | awk '{print $3}'`
	sdb_wrt=`echo "$sdb" | awk '{print $4}'`
	sdc=`sudo ssh -n $remotehost "iostat | grep sdc"`
	sdc_read=`echo "$sdc" | awk '{print $3}'`
	sdc_wrt=`echo "$sdc" | awk '{print $4}'`
	echo "$device"
	if [ `echo $sda_read \>= 300 | bc` -eq 1 -o `echo $sda_wrt \>= 400 | bc` -eq 1 ]; then
		echo -e "\033[31m$sda\033[0m"
	else
		echo "$sda"
	fi

	if [ `echo $sdb_read \>= 2000 | bc` -eq 1 -o `echo $sdb_wrt \>= 40000 | bc` -eq 1 ]; then
		echo -e "\033[31m$sdb\033[0m"
	else
		echo "$sdb"
	fi

	if [ `echo $sdc_read \>= 1000 | bc` -eq 1 -o `echo $sdc_wrt \>= 11000 | bc` -eq 1 ]; then
		echo -e "\033[31m$sdc\033[0m"
	else
		echo "$sdc"
	fi
	echo "------------------------------------------------------------------------------------------------------------------"
	echo -e "网络\n一.网络连接数\nIP地址\t\t连接数"
	sudo ssh -n $remotehost netstat -an |grep 6667 | awk '{print $5}' | awk -F: '{print $1}'|sort -r|uniq -c|sort -nr|awk 'NR <=10{print}'|awk '{print$2"\t",$1}'
	netnumarr=`sudo ssh -n $remotehost netstat -an |grep 6667 | awk '{print $5}' | awk -F: '{print $1}'|sort -r|uniq -c|sort -nr| awk '{print$1}'`
	netcon=0
	for num in $netnumarr; do
		netcon=`expr $netcon + $num`
	done
	if [ $netcon -ge 18000 ]; then
		echo -e "\033[31m总计共有${netcon}个连接.\033[0m"
		content+="${remotehost}的网络连接数为${netcon}，过大。"
	else
		echo "总计共有${netcon}个连接."
	fi
	echo -e "二.网络流量"
	sudo ssh -n $remotehost sar -n DEV | awk 'NR==3{print}'
	netrate_ave_3=`sudo ssh -n $remotehost sar -n DEV | grep bond0.100 | tail -1 | awk '{print $3}'`
	netrate_ave_5=`sudo ssh -n $remotehost sar -n DEV | grep bond0.100 | tail -1 | awk '{print $5}'`
	netrate=`sudo ssh -n $remotehost sar -n DEV | grep bond0.100 | tail -2`
	if [ `echo $netrate_ave_3 \>= 70000 | bc` -eq 1 -o `echo $netrate_ave_5 \>= 50000 | bc` -eq 1 ]; then
		echo -e "\033[31m$netrate\033[0m"
	else
		echo "$netrate"
	fi
	echo "------------------------------------------------------------------------------------------------------------------"
	echo -e "CPU"
	sudo ssh -n $remotehost sar -u | awk 'NR==3{print "time\t\t",$4"\t",$7,$9}'
	cpu_idle=`sudo ssh -n $remotehost sar -u | tail -2 | awk 'NR==2{print $8}'`
	cpu_1=`sudo ssh -n $remotehost sar -u | tail -2 | awk 'NR==1{print $1"\t",$4"\t",$7"\t",$9}'`
	cpu_2=`sudo ssh -n $remotehost sar -u | tail -2 | awk 'NR==2{print $1"\t",$3"\t",$6"\t",$8}'`
	if [ `expr $cpu_idle \<= 1` -eq 1 ]; then
		echo -e "\033[31m$cpu_1\033[0m"	
		echo -e "\033[31m$cpu_2\033[0m"
	else
		echo "$cpu_1"
		echo "$cpu_2"
	fi
	echo "------------------------------------------------------------------------------------------------------------------"
	echo  -e "进程消耗CPU\n一.CPU占用排名"
	sudo ssh -n $remotehost pidstat|grep UID|awk '{print $4"\t",$9"\t",$10}'
	sudo ssh -n $remotehost pidstat | sort -nr -k 9 | awk 'NR<=10{print $4"\t",$9"\t",$10}'
	echo "二.%CPU排名"
	sudo ssh -n $remotehost pidstat|grep UID|awk '{print $4"\t",$8"\t",$10}'
	sudo ssh -n $remotehost pidstat | sort -nr -k 8 | awk 'NR<=10{print $4"\t",$8"\t",$10}'
	echo "------------------------------------------------------------------------------------------------------------------"
done < $hostsfile
#发送短信
interface_addr="http://10.161.11.182:8082/monitor/rest/message/sendMessage"
content_type="Content-Type:application/json"
#recivers="13120228321,17600908312,13001927192,17600196269"
recivers="17600908312"
if [ ! -z "$content" ]; then
	curl $interface_addr -H $content_type -d "{\"recivers\":\"$recivers\",  \"content\": \"$content\"}"
fi
echo "scan over"

#!/bin/bash
cd "$(dirname "$0")"
path=`pwd`
hostsfile="$path/hosts_remote.txt"

while read remotehost
do
	echo "------------------------------------------------------------------------------------------------------------------------"
	echo "IP:$remotehost"
	echo "------------------------------------------------------------------------------------------------------------------"
	echo "内存"
	mem=`ssh -n $remotehost "free - m"`
	memfree=`ssh -n $remotehost "free - m" | grep Mem | awk '{print $4}'`
	if [ $memfree -le 1024 ]; then
		echo -e "\033[31m$mem\033[0m"
	else
		echo "$mem"
	fi
	echo "------------------------------------------------------------------------------------------------------------------"
	echo -e "磁盘\n一.磁盘使用率"
	v01=`ssh -n $remotehost "df -TH" | grep v01 | awk '{print $6}' | tr -cd "[0-9]"`
	v02=`ssh -n $remotehost "df -TH"  | grep v02| awk '{print $6}' | tr -cd "[0-9]"`
	if [ $v01 -ge 80 ]; then
		echo -e "\033[31m/data/v01 已经使用 : ${v01}%\033[0m"
	else
		echo "/data/v01 已经使用 : ${v01}%"	
	fi

	if [ $v02 -ge 80 ]; then
		echo -e "\033[31m/data/v02 已经使用 : ${v02}%\033[0m"
	else
		echo "/data/v02 已经使用 : ${v02}%"
	fi
	echo "二.磁盘读写io"
	device=`ssh -n $remotehost "iostat | grep Device"`
	sda=`ssh -n $remotehost "iostat | grep sda"`
	sda_read=`echo "$sda" | awk '{print $3}'`
	sda_wrt=`echo "$sda" | awk '{print $4}'`
	sdb=`ssh -n $remotehost "iostat | grep sdb"`
	sdb_read=`echo "$sdb" | awk '{print $3}'`
	sdb_wrt=`echo "$sdb" | awk '{print $4}'`
	sdc=`ssh -n $remotehost "iostat | grep sdc"`
	sdc_read=`echo "$sdc" | awk '{print $3}'`
	sdc_wrt=`echo "$sdc" | awk '{print $4}'`
	echo "$device"
	if [ `expr $sda_read \>= 50` -eq 1 -o `expr $sda_wrt \>= 70` -eq 1 ]; then
		echo -e "\033[31m$sda\033[0m"
	else
		echo "$sda"
	fi

	if [ `expr $sdb_read \>= 400` -eq 1 -o `expr $sdb_wrt \>= 6000` -eq 1 ]; then
		echo -e "\033[31m$sdb\033[0m"
	else
		echo "$sdb"
	fi

	if [ `expr $sdc_read \>= 400` -eq 1 -o `expr $sdc_wrt \>= 2000` -eq 1 ]; then
		echo -e "\033[31m$sdc\033[0m"
	else
		echo "$sdc"
	fi
	echo "------------------------------------------------------------------------------------------------------------------"
	echo -e "网络\n一.网络连接数\nIP地址\t\t连接数"
	ssh -n $remotehost netstat -an |grep 6667 | awk '{print $5}' | awk -F: '{print $1}'|sort -r|uniq -c|sort -nr|awk 'NR <=10{print}'|awk '{print$2"\t",$1}'
	netnumarr=`ssh -n $remotehost netstat -an |grep 6667 | awk '{print $5}' | awk -F: '{print $1}'|sort -r|uniq -c|sort -nr| awk '{print$1}'`
	netcon=0
	for num in $netnumarr; do
		netcon=`expr $netcon + $num`
	done
	if [ $netcon -ge 2000 ]; then
		echo -e "\033[31m总计共有${netcon}个连接.\033[0m"
	else
		echo "总计共有${netcon}个连接."
	fi
	echo -e "二.网络流量"
	ssh -n $remotehost sar -n DEV | awk 'NR==3{print}'
	netrate_ave_3=`ssh -n $remotehost sar -n DEV | grep bond0.100 | tail -1 | awk '{print $3}'`
	netrate_ave_5=`ssh -n $remotehost sar -n DEV | grep bond0.100 | tail -1 | awk '{print $5}'`
	netrate=`ssh -n $remotehost sar -n DEV | grep bond0.100 | tail -2`
	if [ `expr $netrate_ave_3 \>= 7000` -eq 1 -o `expr $netrate_ave_5 \>= 20000` -eq 1 ]; then
		echo -e "\033[31m$netrate\033[0m"
	else
		echo "$netrate"
	fi
	echo "------------------------------------------------------------------------------------------------------------------"
	echo -e "CPU"
	ssh -n $remotehost sar -u | awk 'NR==3{print "time\t\t",$4"\t",$7,$9}'
	cpu_idle=`ssh -n $remotehost sar -u | tail -2 | awk 'NR==2{print $8}'`
	cpu_1=`ssh -n $remotehost sar -u | tail -2 | awk 'NR==1{print $1"\t",$4"\t",$7"\t",$9}'`
	cpu_2=`ssh -n $remotehost sar -u | tail -2 | awk 'NR==2{print $1"\t",$3"\t",$6"\t",$8}'`
	if [ `expr $cpu_idle \<= 1` -eq 1 ]; then
		echo -e "\033[31m$cpu_1\033[0m"	
		echo -e "\033[31m$cpu_2\033[0m"
	else
		echo "$cpu_1"
		echo "$cpu_2"
	fi
	echo "------------------------------------------------------------------------------------------------------------------"
	echo  -e "进程消耗CPU\n一.CPU占用排名"
	ssh -n $remotehost pidstat|grep UID|awk '{print $4"\t",$9"\t",$10}'
	ssh -n $remotehost pidstat | sort -nr -k 9 | awk 'NR<=10{print $4"\t",$9"\t",$10}'
	echo "二.%CPU排名"
	ssh -n $remotehost pidstat|grep UID|awk '{print $4"\t",$8"\t",$10}'
	ssh -n $remotehost pidstat | sort -nr -k 8 | awk 'NR<=10{print $4"\t",$8"\t",$10}'
	echo "------------------------------------------------------------------------------------------------------------------"
done < $hostsfile
echo "scan over"

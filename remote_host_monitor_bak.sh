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
  ssh -n $remotehost "free - m"
  echo "------------------------------------------------------------------------------------------------------------------"
  echo -e "磁盘\n一.磁盘使用率"
  v01=`ssh -n $remotehost "df -TH" | grep v01 | awk '{print $6}' | tr -cd "[0-9]"`
  v02=`ssh -n $remotehost "df -TH"  | grep v02| awk '{print $6}' | tr -cd "[0-9]"`
  if [ $v01 -lt 50 -a $v02 -lt 50 ]
  then
    echo "$remotehost 磁盘使用率 : 正常"
  else
    if [ $v01 -ge 50 ]
    then
      echo -e "\033[31m /data/v01 已经使用 : ${v01}% \033[0m"
    fi
    if [ $v02 -ge 50 ]
    then
      echo -e "\033[31m /data/v02 已经使用 : ${v02}% \033[0m"
    fi
  fi
echo "二.磁盘读写io"
device=`ssh -n $remotehost "iostat | grep Device"`
sda=`ssh -n $remotehost "iostat | grep sda"`
sda_read=`echo "$sda" | awk '{print $3}'`
sda_wrt=`echo "$sda" | awk '{print $4}'`
sdb=`ssh -n $remotehost "iostat | grep sdb"`
sdc=`ssh -n $remotehost "iostat | grep sdc"`
echo "$device"
if [ $sda_read -ge "40" || $sda_wrt -ge "60" ]; then
	echo -e "\033[31m $sda \033[0m"
else
	echo "$sda"
fi
echo -e "\033[31m $sdb \033[0m"
echo -e "\033[31m $sdc \033[0m"
echo "------------------------------------------------------------------------------------------------------------------"
echo -e "网络\n一.网络连接数\nIP地址\t\t连接数"
ssh -n $remotehost netstat -an |grep 6667 | awk '{print $5}' | awk -F: '{print $1}'|sort -r|uniq -c|sort -nr|awk 'NR <=10{print}'|awk '{print$2"\t",$1}'
netcon=0
for num in `ssh -n $remotehost netstat -an |grep 6667 | awk '{print $5}' | awk -F: '{print $1}'|sort -r|uniq -c|sort -nr|awk '{print$1}'`
do
  netcon=`expr $netcon + $num`
done
echo "总计共有"$netcon"个连接."
echo -e "二.网络流量"
ssh -n $remotehost sar -n DEV | awk 'NR==3{print}'
ssh -n $remotehost sar -n DEV | grep bond0.100 | tail -2
echo "------------------------------------------------------------------------------------------------------------------"
echo -e "CPU"
ssh -n $remotehost sar -u | awk 'NR==3{print "time\t\t",$4"\t",$7,$9}'
ssh -n $remotehost sar -u | tail -2 | awk 'NR==1{print $1"\t",$4"\t",$7"\t",$9}'
ssh -n $remotehost sar -u | tail -2 | awk 'NR==2{print $1"\t",$3"\t",$6"\t",$8}'
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

#!/bin/bash
cd "$(dirname "$0")"
path=`pwd`
hosts_file="$path/hosts_disk_check.txt"
if [ -e "$path/disk_status" ]; then
	sed -i '/^.*$/d' $path/disk_status
fi

while read hosts_disk
do
	hosts_ip=`echo $hosts_disk | awk '{print $1}'`
	hosts_name=`echo $hosts_disk | awk '{print $3}'`
	disk_v01=`sudo ssh -n $hosts_ip "df -TH" | awk '$7=="/data/v01"{print $6}' | sed 's/%//'`
	disk_v01_avail=`sudo ssh -n $hosts_ip "df -TH" | awk '$7=="/data/v01"{print $5}'`
	disk_v02=`sudo ssh -n $hosts_ip "df -TH" | awk '$7=="/data/v02"{print $6}' | sed 's/%//'`
	disk_v02_avail=`sudo ssh -n $hosts_ip "df -TH" | awk '$7=="/data/v02"{print $5}'`
	echo "*****************************************************************" >> $path/disk_status
	echo "${hosts_name}" >> $path/disk_status
	if [ $disk_v01 -ge 80 -o $disk_v02 -ge 80 ]; then
		echo "******************************************************" 
		echo "${hosts_name}" 
	fi
	if [ $disk_v01 -ge 80 ]; then
		echo -en "\033[31m/data/v01\t${disk_v01}%\t${disk_v01_avail}\033[0m" >> $path/disk_status
		echo -e "\033[31m/data/v01\t${disk_v01}%\t${disk_v01_avail}\033[0m" 
	else	
		echo -en "/data/v01\t${disk_v01}%\t${disk_v01_avail}" >> $path/disk_status
	fi

	if [ $disk_v02 -ge 80 ]; then
		echo -e "\033[31m\t/data/v02\t${disk_v02}%\t${disk_v02_avail}\033[0m" >> $path/disk_status
		echo -e "\033[31m/data/v02\t${disk_v02}%\t${disk_v02_avail}\033[0m"
	else
		echo -e "\t/data/v02\t${disk_v02}%\t${disk_v02_avail}" >> $path/disk_status
	fi
done < $hosts_file

#!/bin/bash
cd "$(dirname "$0")"
path=`pwd`
hostsfile="$path/hosts.txt"

while read remotehost
do
	echo "[`date`] $remotehost system status >>>>>>>>>>>>"
	logPath=dkmonitor/${remotehost}_$(date +'%Y-%m-%d')
	echo "logPath:$logPath"
	if [ ! -d "$logPath"  ]; then
		mkdir -p "$logPath"
	fi

	echo "[`date`] connect to  $remotehost at port 6667 , info:" >> $logPath/netconect
	sudo ssh -n $remotehost "netstat -an |grep 6667 | awk '{print \$5}' | awk -F: '{print \$1}' | sort -r | uniq -c  | sort -nr  " >> $logPath/netconect
	echo "scan port 6667 @$remotehost finish!" >> $logPath/netconect
	echo "[`date`]===================system uptime begin============" >> $logPath/uptime
	sudo ssh -n $remotehost "uptime" >> $logPath/uptime
	echo "[`date`]=================== system uptime end ============" >> $logPath/uptime
	
	echo "[`date`]===================system vmstat begin============" >> $logPath/vmstat
	sudo ssh -n $remotehost "vmstat" >> $logPath/vmstat
	echo "[`date`]=================== system vmstat end ============" >> $logPath/vmstat
	
	echo "[`date`]===================system mpstat begin============" >> $logPath/mpstat
	sudo ssh -n $remotehost "mpstat -P ALL" >> $logPath/mpstat
	echo "[`date`]=================== system mpstat end ============" >> $logPath/mpstat

	echo "[`date`]===================system pidstat begin============" >> $logPath/pidstat
	sudo ssh -n $remotehost "pidstat" >> $logPath/pidstat
	echo "[`date`]=================== system pidstat end ============" >> $logPath/pidstat
	
	echo "[`date`]===================system iostat begin============" >> $logPath/iostat
        sudo ssh -n $remotehost "iostat -x" >> $logPath/iostat
        echo "[`date`]=================== system iostat end ============" >> $logPath/iostat

	echo "[`date`]===================system free  begin============" >> $logPath/free
        sudo ssh -n $remotehost "free –m" >> $logPath/free
        echo "[`date`]=================== system free  end ============" >> $logPath/free

	echo "[`date`]===================system sar  begin============" >> $logPath/sar
        sudo ssh -n $remotehost "sar -n DEV 1 1" >> $logPath/sar
        echo "[`date`]=================== system sar  end ============" >> $logPath/sar

	echo "[`date`]===================system dmesg begin============" >> $logPath/dmesg
        sudo ssh -n $remotehost "dmesg | tail -n 100" >> $logPath/dmesg
        echo "[`date`]=================== system dmesg end ============" >> $logPath/dmesg
	
	echo "[`date`]===================system  diskinfo begin============" >> $logPath/diskinfo
	sudo ssh -n $remotehost "df -TH" >> $logPath/diskinfo	
	echo "[`date`]=================== system diskinfo end ============" >> $logPath/diskinfo
	echo "[`date`] $remotehost system status <<<<<<<<<<<<"
done < $hostsfile
echo "finish port scan!"


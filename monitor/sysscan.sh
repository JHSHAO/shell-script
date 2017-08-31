#!/bin/bash
cd "$(dirname "$0")"
path=`pwd`
hostsfile="$path/hosts.txt"

while read remotehosts
do
	remotehost=`echo ${remotehosts} | awk '{print $1}'`
	echo "[`date`] $remotehost system status >>>>>>>>>>>>"
	echo "connect to  $remotehost at port 6667 , info:"
	ssh -n $remotehost "netstat -an |grep 6667 | awk '{print \$5}' | awk -F: '{print \$1}' | sort -r | uniq -c  | sort -nr  "
	echo "scan port 6667 @$remotehost finish!"
	echo "===================system uptime begin============"
	ssh -n $remotehost "uptime"
	echo "=================== system uptime end ============"
	
	echo "===================system vmstat begin============"
	ssh -n $remotehost "vmstat"
	echo "=================== system vmstat end ============"
	
	echo "===================system mpstat begin============"
	ssh -n $remotehost "mpstat -P ALL"
	echo "=================== system mpstat end ============"

	echo "===================system pidstat begin============"
	ssh -n $remotehost "pidstat"
	echo "=================== system pidstat end ============"
	
	echo "===================system iostat begin============"
        ssh -n $remotehost "iostat -x"
        echo "=================== system iostat end ============"

	echo "===================system free  begin============"
        ssh -n $remotehost "free –m"
        echo "=================== system free  end ============"

	echo "===================system sar  begin============"
        ssh -n $remotehost "sar -n DEV 1 1"
        echo "=================== system sar  end ============"

	#echo "===================system dmesg begin============"
        #ssh -n $remotehost "dmesg | tail -n 100"
        #echo "=================== system uptime end ============"
	echo "[`date`] $remotehost system status <<<<<<<<<<<<"
done < $hostsfile
echo "finish port scan!"


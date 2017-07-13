#!/bin/sh
if [ $# -lt 3 ];then
  echo "Usage:need options IP HostName CmdType"
  exit;
fi

cd "$(dirname "$0")"
path=`pwd`
echo "setup -> $1 $2"
range="all"
if [ $# = 4 ];then
	range=$4
fi

if [ $3 = "0" ];then
	ssh -n $1 "python client.py start $range"
fi
if [ $3 = "1" ];then
	ssh -n $1 "python client.py stop $range"
fi
if [ $3 = "2" ];then
	ssh -n $1 "python client.py info $range"
fi
if [ $3 = "3" ];then
	ssh -n $1 "python client.py list $range"
fi


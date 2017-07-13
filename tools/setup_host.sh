#!/bin/sh
if [ $# -lt 2 ];then
  echo "need options"
  exit;
fi

cd "$(dirname "$0")"
path=`pwd`
echo "setup -> $1 $2"


#scp -r ../kafka_ue/* $1:/data/v01/ogg12/kafka_ue/

#ssh -n $1 "cd /data/v01/ogg12/kafka_ue && make clean && make"


ssh -n $1 "cat /data/v01/ogg12/dirdef/* | grep TD_S_CUST_CLUSTER"

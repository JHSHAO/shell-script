#!/bin/sh
if [ $# -lt 2 ];then
  echo "need options"
  exit;
fi

cd "$(dirname "$0")"
path=`pwd`
echo "setup -> $1 $2"


declare -u tname=$3

ssh -n $1 "cat /data/v01/ogg12/dirdef/* | grep $tname"

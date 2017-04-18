#!/bin/bash 
cd "$(dirname "$0")"
path=`pwd`
deffile=act_tables.def
#list=`cat $deffile | grep '^Definition'| awk '{print $4}' | sed 's/\./ /g'`

count=0
table_names="$path/tables_act.txt"
while read line
do
  cat $deffile | grep -w $line > /dev/null 2>&1
  if [ $? == 0 ];then
        count=$[$count+1]
        echo "$count) $line"
  fi
done < $table_names
echo "finish search, has $count found!"
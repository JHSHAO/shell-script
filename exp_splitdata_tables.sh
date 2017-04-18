#!/bin/bash
cd "$(dirname "$0")"
path=`pwd`
if [ $# -lt 1 ];then
  echo "need database name,please input database name.."
  exit;
fi
dbname=$1

#generate scnValue
scnValue=`sqlplus -s uqry/xPgg4nTq16@$dbname <<EOF
set feedback off;
set pagesize 0;
spool scn.txt
select to_char(current_scn) from v\\$database;
spool off
exit;
EOF`

#putout scnValue
scnValue=`cat scn.txt`
echo scn:$scnValue
currentday=`date +%m%d`

tables_conf="$path/tables.txt"
while read line
do
  if [ ${line:0:1} != "#" ];then
        args=($line)
        #echo ${args[0]} ${args[1]} ${args[2]}
        echo ${args[0]}.${args[1]}
nohup ./sqluldr2.bin user='uqry_kfk/"UQk_1f$k#C"'@$dbname query="select * from ${args[0]}.${args[1]} as of scn `expr $scnValue`"  head=yes log=ecslog/${args[0]}.${args[1]}@$currentday.log field=0x01 charset=ZHS16GBK record=0x02 safe=yes file="ecsdata/${args[0]}.${args[1]}" 2>&1 &
  fi
done < $tables_conf
echo "exportdata finish!"
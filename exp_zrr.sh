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
spool scn_zrrdata.txt.$dbname
select to_char(current_scn) from v\\$database;
spool off
exit;
EOF`

#putout scnValue
scnValue=`cat scn_zrrdata.txt.$dbname`
echo scn:$scnValue
currentday=`date +%m%d`

tables_conf="$path/tables_zrrdata.txt"
while read line
do
  if [ ${line:0:1} != "#" ];then
        args=($line)
        #echo ${args[0]} ${args[1]} ${args[2]}
        echo ${args[0]}.${args[1]}
        mkdir log_zrrdata/$dbname -p
        mkdir data_zrrdata/$dbname -p
nohup ./sqluldr2.bin user='uqry_kfk/"UQk_1f$k#C"'@$dbname "alter=set nls_date_format='yyyy-mm-dd:hh24:mi:ss'"  query="select * from ${args[0]}.${args[1]} as of scn `expr $scnValue`" head=no log=log_zrrdata/$dbname/${args[0]}.${args[1]}@$currentday.log field=0x01 charset=ZHS16GBK record=0x02 safe=yes file="data_zrrdata/$dbname/${args[0]}.${args[1]}" > /dev/null 2>&1 &
  fi
done < $tables_conf
echo "exportdata finish!"
#!/bin/bash
rm -rf scn.txt
dbname=$1
expTableName=$2

scnValue=`sqlplus -s uqry/xPgg4nTq16@$dbname <<EOF
set feedback off;
set pagesize 0;
spool scn.txt
select to_char(current_scn) from v\\$database;
spool off
exit;
EOF`

scnValue=`cat scn.txt`
echo scn:$scnValue
currentday=`date +%m%d`

#echo "$ORACLE_HOME/sqluldr2.bin user='uqry_kfk/\"UQk_1f$k#C\"'@$dbname query=\"select * from $expTableName as of scn $scnValue\" head=yes field=0x01 charset=AL32UTF8 record=0x02 safe=yes file='exportdata/$expTableName@$currentday'"
#$ORACLE_HOME/sqluldr2.bin user='uqry_kfk/\"UQk_1f$k#C\"'@$dbname query=\"select * from $expTableName as of scn $scnValue\" head=yes field=0x01 charset=AL32UTF8 record=0x02 file='exportdata/$expTableName@$currentday'
./sqluldr2.bin user='uqry_kfk/"UQk_1f$k#C"'@$dbname query="select * from $expTableName as of scn `expr $scnValue`"  rows=100000000 batch=yes head=yes field=0x01 charset=AL32UTF8 record=0x02 safe=yes file="exportdata/$expTableName.%b@$currentday"
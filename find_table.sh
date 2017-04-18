#!/bin/bash
#将db2中已经存在的表存放在文件db2_list_tables.txt中
db2 connect to bigsql > /dev/null 2>&1
db2 <<EOF > db2_list_tables.txt
list tables
quit
EOF
#表类型参数，oracle表=N，hbase表=T
tableType=$1
#删除文件以免对比的表覆盖了
if [ -e find_exist_tables.txt ]
then
 rm -rf find_exist_tables.txt
fi
#循环对比
while read line
do
  #echo $line
  cat db2_list_tables.txt | awk '$3=="'$tableType'" {print $1}' | grep -w $line >> find_exist_tables.txt
done < db2_oracle_need_tables.txt
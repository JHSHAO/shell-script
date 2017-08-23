#!/bin/bash
cd "$(dirname "$0")"
path=`pwd`
table_def_file=$1
table_names_file=$2

while read table_name
do
    table_name_only=`echo $table_name | awk -F . '{print $2}'`
    grep -w $table_name $path/$table_def_file > /dev/null 2>&1 
    if [ $? -eq 0 ]; then
        echo -e "\033[31m${table_name}\033[0m"
    else
        echo "$table_name"
    fi    
done < $path/$table_names_file

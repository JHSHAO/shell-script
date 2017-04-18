#!/bin/bash
file_path=$1

for file in `ls $file_path`; do
	table_name=$(echo $file | sed 's/.cvs//g')
	#echo $file $table_name.csv
	mv $file_path$file $file_path$table_name.csv
done
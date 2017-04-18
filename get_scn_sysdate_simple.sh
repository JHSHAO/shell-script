#!/bin/bash
log_path=$1
file_suffix=$2
#echo $log_path $file_suffix

if [ -e scn_sysdate.txt ];then
 rm -rf scn_sysdate.txt
fi

if [ -e log_error_name.txt ];then
  rm -rf log_error_name.txt
fi

for file in `ls $log_path`;do
 #echo $file
 str_scn_tablename=$(cat $log_path$file | awk '$1=="output"{print $3}')
 #echo $str_scn_tablename

 if [ -n "$str_scn_tablename" ];then
  tablename=$(echo $str_scn_tablename | sed 's/.*\///g' | sed 's/@.*//g')
  scn=$(echo $str_scn_tablename | sed 's/.*@//g')
  if [ -n "$file_suffix" ];then
   scn=$(echo $scn | sed 's/'$file_suffix'//g')
  fi
  #echo $scn  $tablename
 
  log_file_num=$(cat $log_path$file | awk '$1=="output"{print NR}')
  cat $log_path$file | awk 'NR=="'$log_file_num'"-1{print "'$scn'" "\t" $5 " " $6 "\t" "'$tablename'"}' >> scn_sysdate.txt
 fi

 if [ -z "$str_scn_tablename" ];then
  echo $file >> log_error_name.txt
 fi
done

if [ -e scn_sysdate.txt ];then
 sed -i 's/,//g' scn_sysdate.txt
fi
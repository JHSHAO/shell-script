#!/bin/bash
log_path=$1

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
  tablename_start=$[$(expr index $str_scn_tablename ".")+1]
  scn_start=$[$(expr index $str_scn_tablename "@")+1]
  str_length_scn_tablename=$[$(expr length $str_scn_tablename)+1]
  #echo $tablename_start $scn_start $str_length_scn_tablename
 
  tablename_length=$[$scn_start-$tablename_start-1]
  scn_length=$[$str_length_scn_tablename-$scn_start]
  #echo $tablename_length $scn_length
 
  tablename=$(expr substr $str_scn_tablename $tablename_start $tablename_length)
  scn=$(expr substr $str_scn_tablename $scn_start $scn_length)
  #echo $scn  $tablename
 
  log_file_num=$(cat $log_path$file | awk '$1=="output"{print NR}')
  cat $log_path$file | awk 'NR=="'$log_file_num'"-1{print "'$scn'" "\t" $5 " " $6 "\t" "'$tablename'"}' >> scn_sysdate.txt
 fi

 if [ -z "$str_scn_tablename" ];then
  echo $file >> log_error_name.txt
 fi
done

if [ -e scn_sysdate.txt ];then
 sed -i 's/.csv//g' scn_sysdate.txt
 sed -i 's/,//g' scn_sysdate.txt
fi
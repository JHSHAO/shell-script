#!/bin/bash
clean_log_local="/home/babel/yunwei/clean_up_kf_log.sh"
clean_log_remote="/home/babel/clean_up_kf_log.sh"
del_filedump_path="/home/babel/Filedump/file_dump_outfile_x86_byname_20160607/log/"
del_inputhbase_path="/home/babel/Inputhbase/RealtimeList_new_batch_20160607/log/"
for i in {1..20};do
  scp $clean_log_local kf${i}.babel:/home/babel/ > /dev/null 2>&1
#ssh到kf主机并执行shell
  ssh -tt kf${i}.babel >/dev/null 2>&1 <<EOF
if [ -e clean_file.log ];then
 rm clean_file.log
fi
chmod 755 $clean_log_remote
$clean_log_remote $del_filedump_path $del_inputhbase_path >> clean_file.log 2>&1
exit
EOF
done
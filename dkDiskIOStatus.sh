#! /bin/bash
if [ -e dkDiskIOStatus ]
then
 echo > dkDiskIOStatus
fi
for dkPre in {1..8}
do
  for dkFix in {1..3}
  do 
   sda=`ssh -n dk${dkPre}0${dkFix} "iostat" | awk '$1=="sda"{print $2 "\t" $3 "\t" $4}'`
   sdb=`ssh -n dk${dkPre}0${dkFix} "iostat" | awk '$1=="sdb"{print $2 "\t" $3 "\t" $4}'`
   sdc=`ssh -n dk${dkPre}0${dkFix} "iostat" | awk '$1=="sdc"{print $2 "\t" $3 "\t" $4}'`
   echo "$sda
$sdb
$sdc">>  dkDiskIOStatus
  done
done
#! /bin/bash
if [ -e dkDiskSpaceStatus ]
then
 echo > dkDiskSpaceStatus
fi
for dkPre in {1..8}
do
  for dkFix in {1..3}
  do 
   sda3=`ssh -n dk${dkPre}0${dkFix} "df -TH" | awk '$1=="/dev/sda3"{print $6}'`
   sdb1=`ssh -n dk${dkPre}0${dkFix} "df -TH" | awk '$7=="/data/v01"{print $6}'`
   sdc1=`ssh -n dk${dkPre}0${dkFix} "df -TH" | awk '$7=="/data/v02"{print $6}'`
   echo "$sda3
$sdb1
$sdc1">>  dkDiskSpaceStatus
  done
done
#! /bin/bash
if [ -e $dkStatus ]
then
 echo > dkStatus
fi
for dkPre in {1..8}
do
  for dkFix in {1..3}
  do 
   cpu=` ssh -n dk${dkPre}0${dkFix} "iostat| awk 'NR==3,NR==4{print}'"`
   mem=`ssh -n dk${dkPre}0${dkFix} "free -h| awk 'NR==1,NR==2{print}'"`
   netcon=`ssh -n dk${dkPre}0${dkFix} "netstat | wc -l"`
   diskSpace1=`ssh -n dk${dkPre}0${dkFix} "df -TH | awk 'NR==1,NR==2{print}'" `
   diskSpace2=`ssh -n dk${dkPre}0${dkFix} "df -TH | grep data"`
   diskIO=`ssh -n dk${dkPre}0${dkFix} "iostat | awk 'NR==6,NR==9{print}'"`
   echo """dk${dkPre}0${dkFix}
Cpu
$cpu
Memory
$mem
DiskIO
$diskIO
netConnectionNum
$netcon
diskSpace
$diskSpace1
$diskSpace2""">>  dkStatus
  done
done

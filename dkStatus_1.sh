#! /bin/bash
if [ -e dkStatus1 ]
then
 echo > dkStatus1
fi
for dkPre in {1..8}
do
  for dkFix in {1..3}
  do 
   cpu=`ssh -n dk${dkPre}0${dkFix} "iostat" | awk 'NR==4{print $1}'`
   mem=`ssh -n dk${dkPre}0${dkFix} "free -m" | awk 'NR==2{print 100 - $7 / $2 * 100}'`
   swap=`ssh -n dk${dkPre}0${dkFix} "free -m" | awk 'NR==3{print 100 - $4 / $2 * 100}'`
   netcon=`ssh -n dk${dkPre}0${dkFix} "netstat | wc -l"`
   echo -e "$cpu \t $mem \t $swap \t $netcon

">>  dkStatus1
  done
done
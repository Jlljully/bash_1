#!/bin/bash

# Script: Morning check-list for Storage systems
# Version: 0.1

# Config
curdate=$(date +%Y%m%d)
filename="/home/sanadmin/Storage/storage_checklist_$curdate.txt"
mail_addresses="test@test.com"
# Check EMC VNX
echo "EMC VNX" > $filename
echo "" >> $filename
# LIST VNX:
VNXLIST="mhqvnxX"

# Run check in loop
for v in $VNXLIST
do

runcheck=`/home/sanadmin/Storage/include/check_vnx_faults.sh $v`
echo "$v: $runcheck"  >> $filename
done

# Check IBM DS5300
#echo -e "\nIBM DS5300\n"  >> $filename
#ControllerA="10.177.x.x"
#ControllerB="10.177.x.x"
#runcheck=`/home/sanadmin/Storage/include/check_ds5300.sh -a $ControllerA -b $ControllerB`
#echo -e "$runcheck"  >> $filename

# Check NetApp
messg='\nNetApp AFF A300\n:'
echo -e $messg >> $filename
NetAppList="10.177.x.x"

for NetApp in $NetAppList
do
  echo -e $NetApp >> $filename

  runcheck=`ssh -i /home/sanadmin/.ssh/id_rsa_monitor monitor@$NetApp system health subsystem show`
  echo -e $runcheck  >> $filename

  runcheck=`ssh -i /home/sanadmin/.ssh/id_rsa_monitor monitor@$NetApp aggr show -aggregate data* -fields size,usedsize,physical-used,physical-used-percent`
  echo -e $runcheck  >> $filename 

  runcheck=`ssh -i /home/sanadmin/.ssh/id_rsa_monitor monitor@$NetApp volume show -aggregate data* -percent-used \>85 -fields size,total,used,percent-used`
  echo -e $runcheck  >> $filename

done

# Check IBM Storwize V7000 Unified
echo -e "\nIBM Storwize V7000 Unified"  >> $filename
V7KULIST="mhqnasX"
# Run check in loop
for v7 in $V7KULIST
do

#runcheck=`/home/sanadmin/Storage/include/check_v7000.sh $v7`
runcheck=`/home/sanadmin/Storage/include/v7kU.py $v7`
echo -e "\n$v7: $runcheck"  >> $filename
done

# Check EMC RecoverPoint
#echo -e "\nEMC RecoverPoint"  >> $filename
#RP_Cluster="10.177.x.x"
#runcheck=`/home/sanadmin/Storage/include/check_rp.sh $RP_Cluster`
#echo -e "$runcheck"  >> $filename

# Check EMC DataDomain
echo -e "\nEMC DataDomain"  >> $filename
DDLIST="mhqddX"
# Run check in loop
for d in $DDLIST
do

runcheck=`/home/sanadmin/Storage/include/check_dd_alerts.sh $d`
echo "$d: $runcheck"  >> $filename
done

# Check VPLEX

# Windows line ending:
sed -i $'s/$/\r/' "$filename"

# Send result
echo -e "Доброе утро, Дежурный!\nЧек-лист по СХД во вложении." | /usr/bin/mail -s "Storage Check-list $curdate" -a "$filename" -r storage@monitor.ru "$mail_addresses"

# Delete temp file
rm -f "$filename"

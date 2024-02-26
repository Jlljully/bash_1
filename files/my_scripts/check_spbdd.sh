#!/bin/bash

# Script: Morning check-list for Storage systems
# Version: 0.1

# Config
curdate=$(date +%Y%m%d)
filename="/home/sanadmin/Storage/storage_checklist_$curdate.txt"
mail_addresses="test@test.com"

# Check EMC DataDomain
echo -e "\nEMC DataDomain"  >> $filename
DDLIST="spbdd01"
# Run check in loop
for d in $DDLIST
do

runcheck=`/home/sanadmin/Storage/include/check_dd_alerts.sh $d`
echo "$d: $runcheck"  >> $filename
done

# Windows line ending:
sed -i $'s/$/\r/' "$filename"

# Send result
echo -e "spbdd test check" | /usr/bin/mail -s "s Check-list $curdate" -a "$filename" -r storage@monitor.ru "$mail_addresses"

# Delete temp file
#rm -f "$filename"

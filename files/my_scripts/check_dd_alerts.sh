#!/bin/sh

runcode=`ssh -q -i /home/sanadmin/.ssh/id_rsa_monitor monitor@$1 alerts show current`

#echo $runcode

if [ "$runcode" = "No active alerts." ]; then
    status="OK"
else
    status="Failed:\n$runcode"
fi

echo -e "$status"

exit

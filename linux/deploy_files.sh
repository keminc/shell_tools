#!/bin/bash
# Kotov E.
# v1
# Deploy files. Usage: deploy_certs.sh FROM TO
# Hosts get from host.txt

fr=$1
to=$2
hf=$3

if [[ ${#fr} -lt 3 ]] || [[ ${#to} -lt 3 ]]; then
   echo "Usage: deploy_files.sh FROM_LOCAL_FILE  TO_REMOTE_FILE HOST_FILTER"
   exit 123
fi

if [[ ${#hf} -lt 1 ]] ; then
   hf='..'
fi


echo "### Start: `date`"

grep ....  ./hosts.txt |grep -v '#' | egrep  "$hf" | while read ln;  do
    echo "### $ln ###"
    scp -o LogLevel=error -r $fr ${ln}:${to}

done

echo "### Finish: `date`"
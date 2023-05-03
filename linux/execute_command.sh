#!/bin/bash
# Kotov E.
# v3
# Execure romote commands
# Hosts get from host.txt

cmd=$1
hf=$2

if [[ ${#cmd} -lt 3 ]] ; then
   echo "Usage: execute_cmd.sh 'my command' HOST_FILTER"
   exit 123
fi
if [[ ${#hf} -lt 1 ]] ; then
   echo "Filter set to: .."
   hf='..'
fi

echo "### Start: `date`"

grep ....  hosts.txt |grep -v '#' |egrep  "$hf"| while read ln;  do
    #echo $ln
    echo "$cmd && echo 'Result: ' $?" | ssh -q -o LogLevel=error  ${ln} |egrep -v '^ Red Hat'
    echo "Result: $?"
done

echo "### Finish: `date`"
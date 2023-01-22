#!/bin/bash
# 
# Check aveability hosts to from list
# by keminc 2020
#
# file structure:
# IP  port  descript

mkdir -p ./log/

#Check params
file_name=$1
[[ ${#file_name} -eq 0 ]] && \
	file_name='hosts.txt' && \
	echo "# Use default: hosts.txt, because no params was set."

[[ ! -f $file_name ]] &&  \
	echo "# File \""$file_name"\" not exist, it will be created, please fill it." && \
	echo -e "#host\tport\tdescript\n127.0.0.1\t80\tmy_host\n" > $file_name && \
	exit 1

echo "# Read hosts from: "$file_name
echo "# Hosts found: $(grep ... $file_name| grep -cv '#')"



grep ... $file_name | grep -v '^#' | while read ln; do
    host=`echo $ln | awk '{print $1}'`
	port=`echo $ln | awk '{print $2}' | egrep '[0-9]*'` #get only numbers
	desc=`echo $ln | awk '{print $3}'`
	
	################################
	#check by icmp
	timestamp=`date '+%F %T'`
    resp=$(ping -f -c 4 -W 3 $host 2>/dev/null|grep rtt | awk '{print $4}' | awk -F/ '{print $2}' | sed -e "s/\....//g") #responce in ms
    [[ "x$resp" == "x" ]] && resp=0 && available='no' || available='yes'
    echo -e "$timestamp\t$ln\ticmp_available=$available\ticmp_ms=$resp" 
	################################
	#check by port
	timestamp=`date '+%F %T'`
	if [[ ${#port} > 0 ]]; then
		resp=$(nmap -P0 -p $port $host 2>/dev/null | grep $port"/" | awk '{print $2}')
		[[ "x$resp" == "x" ]] && resp=0 && available='no' || available='yes'
		echo -e "$timestamp\t$ln\tport_available=$available\tport_status=$resp" 
	fi
	################################
		
done | tee -a ./log/check_host_availability.log



exit 0




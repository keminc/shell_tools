#!/bin/bash
# 
# Check access to the host
# Ping -> SSH -> Password
#
# USE :   ./check_access_to_host.sh 1.1.1.131 root 123456 00077777

#	Params:
#		$1 - ip \ hostname
#		$2 - user name for ssh - NOT USE
#		$3 - password\s for ssh Ex: "123 456 root"
#		$4 - Object code

# LOG
LOG="../log/check_access.log"

###########################################################################
#
check_ping(){
  [ "x" == "x$1" ] && echo "[ test_ping ] [ no parameters ]  [ ERROR ]" && return 100;
  ping -f -c 4 -W 11 $1 | grep -i '100% packet loss' &> /dev/null;
  [ "$?" == "0" ] && return 1 || return 0;
}

check_nmap(){
  [ "x" == "x$1" ] && echo "[ checj_nmap ] [ no parameters ]  [ ERROR ]" && return 100;
  nmap -P0 $1 -p 22 2>/dev/null | grep -i "22.*open" &> /dev/null;
  [ "$?" == "0" ] && return 0 || return 1;
}

###########################################################################
# $? - result ;  OnDisplay - currect password;
check_ssh(){
# $1 - ip
# $2 - password\S
#--------------
	[ "x" == "x$1" ] || [ "x" == "x$2" ] && echo "[ check_ssh ] [ no parameters ]  [ ERROR ]" && return 100;
   
    for pas_arr in ${2}
	do
		bash ./ssh_check.sh $1 $pas_arr &>/dev/null;
		reslt=$?;
		[ "$reslt" == "0" ]  && echo $pas_arr && return 0;		
	done
	#[ -z $wa ] && return 1
	return $reslt;
}

#########################################################################
# M A I N
#########################################################################

[ "x" == "x$1" ] || [ "x" == "x$2" ] && echo "[ check_access_to_host.sh ] [ no parameters ]  [ ERROR ]" && exit 100;

LOG_STR="`date '+%d.%m.%Y %T'`  OTU: $4  IP: $1 - ";
echo -n " Check host online - ";
check_ping $1 || check_nmap $1; 
	if [ $? == 0 ];
	then
		echo "YES" ;
		LOG_STR=$LOG_STR" ONLINE";
	else
		echo "NO"; 
		LOG_STR=$LOG_STR" OFFLINE";
		echo $LOG_STR >> $LOG;
		exit 1;
	fi 

echo -n " Check host ssh access - ";
curent_pass=`check_ssh $1 "$3"` ;
reslt=$?;
	if [ $reslt == 0 ];
	then
		echo "YES";
		LOG_STR=$LOG_STR" PASSWORD_OK" 
		echo  $LOG_STR >> $LOG;		
		echo "$4 $1 $curent_pass " >> ../online.lst  #   ECHO CURRENT PASSWORD
		
	else
		echo "NO" ;
		LOG_STR=$LOG_STR" PASSWORD_ERROR";
		[ "$reslt" == "2" ] && LOG_STR=$LOG_STR" NO_SSH";
		[ "$reslt" == "3" ] && LOG_STR=$LOG_STR" BAD_PASSWORD";
		echo  $LOG_STR >> $LOG;
		exit 2 ;
	fi 
	
exit 0;
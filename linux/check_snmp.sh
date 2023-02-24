#!/bin/bash
# 
# Execute command on remoute host
#
# USE: ./check_snmp.sh 1.1.1.1 root password  00077777  3
#
#	Params:
#		$1 - ip \ hostname
#		$2 - user name for ssh - NOT USE
#		$3 - password\s for ssh Ex: "123 456 root"
#		$4 - Object code
#		$5 - number in Q
#		
#


[ "x" == "x$5" ] && echo "No param" && exit 123 

LOG="../log/snmp_check.log";
PID_DIR="../log/snmp_check";
SNMPList="../list/ipSNMP.txt";

#----------------------------------------	
# Wait for queue
EXEC_PIDF_NAME="${PID_DIR}/`date +%F'_'%T`.$4.$$.$5.log";
echo "# Wait for queue on host: $4"
echo "`date '+%d.%m.%Y %T'` $4 $1 [ Execute_cmd ] Start_wait_for_queue " >> $LOG;

#----------------------------------------
# num_of_files=`ls ${PID_DIR}/*inwork 2>/dev/null |grep -c .`;
# let "noff=50-$num_of_files";
# next_queue_num=`ps -ef | grep check_snmp  | awk '{print $NF}' | egrep "^[0-9]" | sort -rg |tail -${noff} | grep -c $5`;
#--

#while [[ "$next_queue_num" == "0" ]]
#do
#	sleep 5;
#	echo -n ".";
#	 num_of_files=`ls ${PID_DIR}/*_inwork 2>/dev/null |grep -c .`;
#	 let "noff=50-$num_of_files";
#	 next_queue_num=`ps -ef | grep execute_cmd | grep -v grep |awk '{print $NF}' |sort -rg |tail -${noff} |  grep -c $5`;
#done
: > ${EXEC_PIDF_NAME}_inwork;
#echo "`date '+%d.%m.%Y %T'` $4 $1 [ Execute_cmd ] Finish_wait_for_queue " >> $LOG;
#----------------------------------------

    
    echo "# Check access to host: $4";
	./check_access_to_host.sh $1 root "$3" $4
	 # To log
		  rtv=$?; 
		  echo "`date '+%d.%m.%Y %T'` $4 $1 [ Execute_cmd ] Access_to_host RCode: $rtv " >> $LOG; #Можно добавлять "id операции"
#----------------------------------------	
# Exit if no access to host	 
		 [ "$rtv" != "0" ] && rm -f ${EXEC_PIDF_NAME}_inwork && exit $rtv;
#----------------------------------------
# Create command
SNMP_CMD="";
#echo "IP=$ip SNMPStatus=`snmpwalk -v1 -cpublic  10.90.2.1 system &> /dev/null; echo $?`"
i=0;
Code="$4"
for ln in `grep $Code $SNMPList`  ; do
    (( i++ ))
    (( $i == 1 )) && continue;

    SNMP_CMD="${SNMP_CMD} echo Code=$Code IP=$ln SNMPStatus=\`snmpwalk -v1 -cpublic  $ln system &> /dev/null; echo \$?\` ; "

done

#----------------------------------------
		  echo "# Execute command  on host: $4"
		  sleep 1; # if many jobs /dev/pty*  in not enoth
		   echo "`date '+%d.%m.%Y %T'` $4 $1 [ Execute_cmd ] Start_execute_cmd " >> $LOG;
		   echo "`date '+%d.%m.%Y %T'` $4 $1 [ Execute_cmd ] Command_is:  ${SNMP_CMD}" >> $LOG;
		SCP_TIMEOUT='5000';
		usrcmd="${SNMP_CMD}";
		usrrealpass=`grep $4 ../online.lst | tail -1 | awk '{print $3}'`;
		
		  expect -c "set timeout $SCP_TIMEOUT ; spawn   ssh root@$1 ; expect pass {send $usrrealpass\n}; \
                      expect \"root*#\" { send \"$usrcmd \n\"}; \
                      expect \"root*#\" { send \"echo Execute finish\n\"}; \
                      expect \"root*#\" { send exit\n;} \
                      "  &> "${EXEC_PIDF_NAME}_inwork" 

#---------------------------------------------------------------------------------------
	mv ${EXEC_PIDF_NAME}_inwork ${EXEC_PIDF_NAME};
	cat ${EXEC_PIDF_NAME}
	echo "`date '+%d.%m.%Y %T'` $4 $1 [ Execute_cmd ] Finish_execute_cmd " >> $LOG;
    
	
 exit 0;



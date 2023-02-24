#!/bin/bash
# 
# Execute command on remoute host
#
# USE: ./execute_cmd.sh 1.1.1.1 root password  00077777  'COMMAND' 3
#
#	Params:
#		$1 - ip \ hostname
#		$2 - user name for ssh - NOT USE
#		$3 - password\s for ssh Ex: "123 456 root"
#		$4 - Object code
#		$5 - Command
#		$6 - number
#


[ "x" == "x$6" ] && echo "No param" && exit 123 

LOG="../log/execute_cmd.log";
PID_DIR="../log/execute_cmd";

#----------------------------------------	
# Wait for queue
EXEC_PIDF_NAME="${PID_DIR}/`date +%F'_'%T`.$4.$$.$6.log";
echo "# Wait for queue on host: $4"
echo "`date '+%d.%m.%Y %T'` $4 $1 [ Execute_cmd ] Start_wait_for_queue " >> $LOG;

#----------------------------------------
 num_of_files=`ls ${PID_DIR}/*inwork 2>/dev/null |grep -c .`;
 let "noff=50-$num_of_files";
 next_queue_num=`ps -ef | grep execute_cmd  | awk '{print $NF}' | egrep "^[0-9]" | sort -rg |tail -${noff} | grep -c $6`; #[ -z $wa ] && exit;
#--

while [[ "$next_queue_num" == "0" ]]
do
	sleep 5;
	echo -n ".";
	 num_of_files=`ls ${PID_DIR}/*_inwork 2>/dev/null |grep -c .`;
	 let "noff=50-$num_of_files";
	 next_queue_num=`ps -ef | grep execute_cmd | grep -v grep |awk '{print $NF}' |sort -rg |tail -${noff} |  grep -c $6`;
done
: > ${EXEC_PIDF_NAME}_inwork;
echo "`date '+%d.%m.%Y %T'` $4 $1 [ Execute_cmd ] Finish_wait_for_queue " >> $LOG;
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

		  echo "# Execute command  on host: $4"
		  sleep 1; # if many jobs /dev/pty*  in not enoth
		   echo "`date '+%d.%m.%Y %T'` $4 $1 [ Execute_cmd ] Start_execute_cmd " >> $LOG;
		   echo "`date '+%d.%m.%Y %T'` $4 $1 [ Execute_cmd ] Command_is:  $5" >> $LOG;
		SCP_TIMEOUT='5000';
		usrcmd="$5";
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



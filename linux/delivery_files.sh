#!/bin/bash
#  
# Execute command on remoute host
#
# USE: ./delivery_files.sh 1.1.1.1 root password  00077777 /distr/  3
#
#	Params:
#		$1 - ip \ hostname
#		$2 - user name for ssh - NOT USE
#		$3 - password\s for ssh Ex: "123 456 root"
#		$4 - Object code
#		$5 - Dir
#		$6 - number
#
[ "x" == "x$1" ] || [ "x" == "x$2" ] || [ "x" == "x$3" ] || [ "x" == "x$4" ] || [ "x" == "x$5" ] || [ "x" == "x$6" ] && echo 'NO param! ' && exit 100;


 fip="$1";
 fpas="$3";
 fdir="$5";

 
 
LOG="../log/delivery_files.log";
PID_DIR="../log/delivery_files";
PIDF_NAME="${PID_DIR}/`date +%F'_'%T`.$4.$$.$6.log";
DELIVERY_FILESD="../delivery_folder"
SCP_TIMEOUT='129600';

#----------------------------------------	
# Wait for queue

echo "# Wait for queue on host: $4"
echo "`date '+%d.%m.%Y %T'` $4 $1 [ Delivery_files ] Start_wait_for_queue " >> $LOG;

#----------------------------------------
 num_of_files=`ls ${PID_DIR}/*inwork 2>/dev/null |grep -c .`;
 let "noff=50-$num_of_files";
 next_queue_num=`ps -ef | grep delivery_files  | awk '{print $NF}' | egrep "^[0-9]" | sort -rg |tail -${noff} | grep -c $6`;
#--

while [[ "$next_queue_num" == "0" ]]
do
	sleep 5;
	echo -n ".";
	 num_of_files=`ls ${PID_DIR}/*_inwork 2>/dev/null |grep -c .`;
	 let "noff=50-$num_of_files";
	 next_queue_num=`ps -ef | grep delivery_files | grep -v grep |awk '{print $NF}' |sort -rg |tail -${noff} |  grep -c $6`;
done
: > ${PIDF_NAME}_inwork;
echo "`date '+%d.%m.%Y %T'` $4 $1 [ Delivery_files ] Finish_wait_for_queue " >> $LOG;
#----------------------------------------

    
    echo "# Check access to host: $4";
	./check_access_to_host.sh $1 root "$3" $4
	rtv=$?; 
	usrrealpass=`grep $4 ../online.lst | tail -1 | awk '{print $3}'`;
	fpas="$usrrealpass";
	 # To log
		  
		  echo "`date '+%d.%m.%Y %T'` $4 $1 [ Delivery_files ] Access_to_host RCode: $rtv " >> $LOG; #Можно добавлять "id операции"
#----------------------------------------	
# Exit if no access to host	 
		 [ "$rtv" != "0" ] && rm -f ${PIDF_NAME}_inwork && exit $rtv;
#----------------------------------------

		  echo "# Start  delivery for host: $4"
		  sleep 1; # if many jobs /dev/pty*  in not enoth
		   echo "`date '+%d.%m.%Y %T'` $4 $1 [ Delivery_files ] Start_delivery_files " | tee -a $LOG

		   flst=""; for i in `ls $DELIVERY_FILESD`; do [ "$i" == "md5sum.txt" ] && continue; flst=$flst" $i"; done
		   echo "`date '+%d.%m.%Y %T'` $4 $1 [ Delivery_files ] Delivery_files_is:  $flst" | tee -a $LOG; #[ -z $wa ] && exit 13;
		
		
		
#----------------------------------------
		# Create md5 summ
			cd $DELIVERY_FILESD || (echo "  ERROR! Can not CD to delivery folder! " && return 123);
				rm -f ./md5sum.txt;
				flls=`ls ./*`; 
				 { [ `uname` == 'AIX' ] && (csum $flls > ./md5sum.txt) || (md5sum $flls > ./md5sum.txt) } &>/dev/null
			cd $OLDPWD ;
		
		flls=`ls -t $DELIVERY_FILESD/*`; flls=`echo $flls`;
#----------------------------------------


##########
flnum=10;
##########

if [[ $flnum > 0 ]];
then
###########
#nflls=${DELIVERY_FILESD}'/*'; 
nflls=`ls -t $DELIVERY_FILESD/`; nflls=`echo $nflls`;
echo -e "\n=======\n$PWD\n=====\n"$nflls
###########
    cd  $DELIVERY_FILESD
	expect -c "set timeout $SCP_TIMEOUT ; spawn   scp -r ${nflls}  root@$fip:$fdir  ; expect pass {send $fpas\n} ; expect sdad_vzff " &> ${PIDF_NAME}_inwork  ;
	cd $OLDPWD
	# insert files check (ls or md5)
	echo "`date '+%d.%m.%Y %T'` $4 $1 [ Delivery_files ] Finish_delivery_files "| tee -a $LOG
	mv ${PIDF_NAME}_inwork ${PIDF_NAME};
 exit 0; #---------
else
	echo "`date '+%d.%m.%Y %T'` $4 $1 [ Delivery_files ] Finish_NO_delivery_files"| tee -a $LOG
	rm -f ${PIDF_NAME}_inwork ;
 exit 115; #---------
fi

exit 0    
	




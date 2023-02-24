#!/bin/bash
#
# 1 - ip
# 2 - passw0rd
#
export LANG=C;
TMP_FILE="tmp/rsa_host_test_$$.txt";
RESLT=1;
#WTOUT=30;
#let "WTT = $WTOUT * 2";

  [ "x" == "x$1" ] || [ "x" == "x$2" ] && echo " [ ssh_check.sh ] [ no parameters ]  [ ERROR ]" && exit 100;
   
  : > $TMP_FILE 
	if [ $? != 0 ];
	then
		echo " [ ssh_check.sh ] [ no rule to create tmp file ]  [ ERROR ]" ; 
		exit 112;
	fi	

	  grep "$1" "$HOME/.ssh/known_hosts" &> /dev/null;  # THEN IF !!!!!!!!!!!!!!!!!     -> [ $? ] -->
		      if [ $? == 0 ]; # if you any time come to this host
		      then
				tm_vr="";
		      else
				tm_vr="expect onnecting {send yes\n} ;";
		      fi
  rip=$1; rpass=$2; ruser="root";
  expect -c "set timeout 40 ; spawn  ssh $ruser@$rip ; $tm_vr  expect assw {send $rpass\n} ; expect $ruser {send \"exit\n\"} ; " &> $TMP_FILE &
  pd=$! ;
  sleep 3;
  #let "tv = $WTOUT / 2";
  ps -a | grep -c $pd && sleep 8; #$tv;  
  ps -a | grep -c $pd && sleep 15 ; #$tv;

  kill -9 $pd &> /dev/null;
  kc=$? ;
  grep -i refu $TMP_FILE  &> /dev/null || grep -i route $TMP_FILE  &> /dev/null;
  gc1=$?;
  pw_w_c=`grep -ic "password" $TMP_FILE`;

#---------------------------------------------------------------

  [ "$kc" == "1" ] &&  RESLT=2; # no sshd
  [ "$kc" == "0" ] || (( $pw_w_c > 1 )) &&  RESLT=3; # bad passwd
  [ "$kc" == "1" ] && [ "$gc1" == "1" ] && [ "$pw_w_c" == "1" ] && RESLT=0; # passwd ok


#  echo "kc="$kc;
#  echo "gc1="$gc1;
#  echo "Res="$RESLT;
#  echo "pw_w_c="$pw_w_c
#cat $TMP_FILE;

rm -f $TMP_FILE;

exit $RESLT;


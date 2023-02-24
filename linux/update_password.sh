#!/bin/bash
# change password remote
# 2015
#

: > pass.lst
cd ..
user=$1

[[ ! -f execute_cmd.sh ]] && exit 123

while read ln; do 
 code=`echo $ln | awk '{print $1}'`
 RND="rpass"$RANDOM
 
 echo $code" "$RND >> $OLDPWD/pass.lst
 
 ip=`echo $ln | awk '{print $2}'`;
 /execute_cmd.sh $ip root $(echo $ln | awk '{print $4}') $code "echo -e \'$RND\\n$RND\\n\'| passwd $user" 1
  
 ip=`echo $ln | awk '{print $3}'`;
 ./execute_cmd.sh $ip root $(echo $ln | awk '{print $4}') $code "echo -e \'$RND\\n$RND\\n\'| passwd $user" 1
 
done < ../list/ipServ.txt
     
cd -
exit 0
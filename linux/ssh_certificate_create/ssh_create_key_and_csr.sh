#!/bin/bash
# Generate CSR (send to CA service for signing) and KEY file for certificare 
# After CA Service sign CSR - get sertificate in response and use it with KEY file
#
# Run: file.sh "config_file_with_certificate_details"
#

name_service="mysyte"
name_serv_cls=""
name_cluster="mycluster"

[[ ! -f $1 ]] && echo "no file" && exit 1


#Create close RSA key, 2048 bit:
openssl genrsa -out $name_cluster.key 2048
#Request for sign for open key:
openssl req -new -key $name_cluster.key -out $name_cluster.csr -subj "/CN=$(grep "CN = "  $1  | cut -d" " -f 3)" -config $1
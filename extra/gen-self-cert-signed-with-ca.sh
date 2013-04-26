#!/bin/bash

#Check your /etc/openssl.conf
#Copy the cacert.pem to certs/my-ca.pem
#Sign the new certs against it.
#Not required right know, used the gen-self-cert.sh only. 
if [ $# -ne 1 ]
then
echo "$0 [file_name]"
exit 0
fi
name=$1

#need /etc/openssl.cnf and ca created on /var/ssl or whatever...
openssl req -new -nodes -out req.pem -config /etc/openssl.cnf   
openssl req -in req.pem -text -verify -noout 
openssl ca -out cert.pem -config /etc/openssl.cnf -infiles req.pem
mv privkey.pem "$1-key.pem"
mv req.pem "$1-req.pem"
mv cert.pem "$1.pem"

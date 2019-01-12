#!/bin/bash
if [ $# -ne 1 ] ; then
    usage
else
    efsendpoint=$1
fi

usage()  
{  
	 echo "Usage: $0 efsendpoint"  
	 exit 1  
} 

# Get my region
region=`curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone`
region="`echo \"$region\" | sed -e 's:\([0-9][0-9]*\)[a-z]*\$:\\1:'`"

mkdir /efsbackup
echo "$efsendpoint.efs.$region.amazonaws.com:/	/efsbackup	nfs4 	nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2" >> /etc/fstab
mount /efsbackup

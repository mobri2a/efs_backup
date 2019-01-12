#!/bin/sh

if [ $# -ne 1 ] ; then
    usage
else
    topicarn=$1
fi

usage()  
{  
	 echo "Usage: $0 topicarn"  
	 exit 1  
} 

LANG=C DOW=$(date +"%a")
DATE=`date +%Y-%m-%d`

# pass the arn of the SNS topic as the first parm
topicarn=$1

# Get my region
region=`curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone`
region="`echo \"$region\" | sed -e 's:\([0-9][0-9]*\)[a-z]*\$:\\1:'`"

# Log to /var/log/backups.log. You may choose to include this log in your awslogs config
echo 'Starting site backups' > /var/log/backups.log
maxrc=0

#===========================================================================
# EFS Backups
# -----------
#
s3maxrc=0

aws s3 sync /webdata/www/example1/ s3://mybucket/web-sites/example1/efs-backup/ --storage-class STANDARD_IA --exclude "*/cache/*" >> /var/log/backups.log 2>&1
[[ $? > $s3maxrc ]] && s3maxrc=$?

aws s3 sync /webdata/www/example2/ s3://mybucket-com/web-sites/example2/efs-backup/ --storage-class STANDARD_IA --exclude "*/cache/*" >> /var/log/backups.log 2>&1
[[ $? > $s3maxrc ]] && s3maxrc=$?

echo S3 Sync maxrc=$s3maxrc >> /var/log/backups.log 2>&1

if [ $s3maxrc >  $maxrc ]; then maxrc=$s3maxrc; fi

#===========================================================================
# Finish up
#
# maxrc=255 = failure
# 1-254 = warnings
# 0 = success
#
# To Do: do something useful with logs
if [ $maxrc == 255 ]; then
	status='FAILED'
	cp /var/log/backups.log /webdata/backups/failed/backups-$DATE.log
elif [ $maxrc > 0 ]; then
	status='COMPLETED WITH WARNINGS'
	cp /var/log/backups.log /webdata/backups/failed/backups-$DATE.log
else
	status='SUCCEEDED'
fi

cat > /tmp/message.json <<EOD
{
	"Message": "Backups $status",
	"rc": "$maxrc"
}
EOD

aws sns publish --topic-arn $topicarn --subject 'Backup $status' --message file:///tmp/message.json --region us-west-2
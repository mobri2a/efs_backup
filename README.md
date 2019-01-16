# EFSBackup
CloudFormation template that sets up backups from EFS to S3 using a transient server on EC2.

## Installation

### Prerequisites
- An S3 bucket to store the efsbackup files
- An S3 bucket for your backups
- An EFS file system with an ingress SecurityGroup
- Your VPC and subnet IDs for each AZ with an EFS endpoint, name of the Security Group, S3 bucket name

### To Install
1. Extract the contents of this archive to an S3 folder
2. Edit dailybackup.sh
	- update the commands in the EFS Backups section as needed
	- in Finish Up, modify the log copy commands as desired (they will not work as written - left as examples)
3. Edit efsbackup.yaml: 
	- Update S3BackupRW (line 249) with the output S3 buckets for your backup script
4. Use the efsbackup.yaml template to launch a CloudFormation stack
5. Once the template loads, go to EC2->AutoScaling Groups. Select the new group. Add a Scheduled Action to bump Desired Capacity to 1 at the time you want to run backups. Ex "0 5 * * *" for daily at midnight. (will eventually make this part of the template) 

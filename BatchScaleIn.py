import boto3
import json
import os

clients_to_connect={
    'asg': { 'service': 'autoscaling' }
}

# =====================================================================
# connect_clients
# ---------------
# Connect to all the clients. We will do this once per instantiation of
# the Lambda function (not per execution)
# =====================================================================
def connect_clients(clients_to_connect):
    for c in clients_to_connect:
        try:
            if 'region' in clients_to_connect[c]:
                clients_to_connect[c]['handle']=boto3.client(clients_to_connect[c]['service'], region_name=clients_to_connect[c]['region'])
            else:
                clients_to_connect[c]['handle']=boto3.client(clients_to_connect[c]['service'])
        except Exception as e:
            print(e)
            print('Error connecting to ' + clients_to_connect[c]['service'])
            raise e
    return clients_to_connect

def getparm (parmname, defaultval):
    try:
        myval = os.environ[parmname]
        if isinstance(defaultval, int):
            return int(myval)
        else:
            return myval
    except:
        print('Environmental variable \'' + parmname + '\' not found. Using default [' + str(defaultval) + ']')
        return defaultval
        
def lambda_handler(event, context):
    # Unconditionally set Desired to 0 for the ASG
    ASG = getparm('ASG', 'error')
    if ASG == 'error':
            print('Error: ASG is not configured for the Lambda function')
            return
    
    response = client['asg']['handle'].set_desired_capacity(
        AutoScalingGroupName=ASG,
        DesiredCapacity=0
    )
    
    # print("Message event: " + json.dumps(event, indent=2))
    
###### M A I N ######
client = connect_clients(clients_to_connect)
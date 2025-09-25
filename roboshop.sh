#!/bin/bash
AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-03711d89ea0c3a77f"

for instance in $@
do
    INSTANCE_ID=$(aws ec2 run-instances --image-id ami-09c813fb71547fc4f --instance-type t3.micro --security-group-ids sg-03711d89ea0c3a77f --tag-specifications "ResourceType=instance,
    Tags=[{Key=Name,Value=Instance}]" --query 'Instances[0].InstanceId' --output text)

    if [ $instance != "frontend" ]; then
    ID=$(aws ec2 describe-instances --instance-ids i-0c9aa6b4b5444fd9b --query 
    'Reservations[0].Instances[0].PrivateIpAddress' --output text)
    else
    ID=$(aws ec2 describe-instances --instance-ids i-0c9aa6b4b5444fd9b --query 
    'Reservations[0].Instances[0].PublicIpAddress' --output text)
    fi
done
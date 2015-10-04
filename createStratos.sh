#!/usr/bin/env bash

if [ "$#" -ne 1 ];then
  echo "Usage: $0 team[][]" >&2
  exit 1
fi


source ./scripts/$1/team.conf

## Stratos creation
echo "Creating kubernetes master ..."
result=$(aws ec2 run-instances --image-id ${stratos_ami} --key-name ${deployment_key_name} \
--region ${region} --security-groups ${security_group} --instance-type m4.xlarge )

stratos_instance_id=$( echo ${result}|cut -d' ' -f9)
stratos_ip_address=$( echo ${result}|cut -d' ' -f14 )
tag=$(aws ec2 --region ${region} create-tags --resources ${stratos_instance_id} --tags Key=Team,Value=${team}  Key=Name,Value=${team}-stratos)

echo "Stratos instance created: [instance_id]:${stratos_instance_id} [ip address]:${stratos_ip_address}":


echo "Waiting for stratos to become running"
while state=$(aws ec2 describe-instances --instance-ids ${stratos_instance_id} --output text --query \
 'Reservations[*].Instances[*].State.Name');
 test "$state" = "pending"; do
  sleep 1;
  echo -n '.'
done; echo " stratos: $state"

stratos_public_ip=$(aws ec2 describe-instances --instance-ids ${stratos_instance_id} --output text \
--query 'Reservations[*].Instances[*].PublicIpAddress')
echo "Stratos [public ip]:${stratos_public_ip}";
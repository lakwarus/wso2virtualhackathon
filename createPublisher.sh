#!/usr/bin/env bash

if [ "$#" -ne 1 ];then
  echo "Usage: $0 team[][]" >&2
  exit 1
fi

source ./scripts/$1/team.conf

export AWS_ACCESS_KEY=''
export AWS_SECRET_KEY=''
export AWS_DEFAULT_REGION=${region}
export AWS_DEFAULT_OUTPUT="text"

## Stratos creation
echo "Creating publisher ..."

result=$(aws ec2 run-instances \
    --image-id ${publisher_ami} \
    --key-name ${publisher_key_name} \
    --region ${region} \
    --security-groups ${team}_${security_group} \
    --instance-type m4.xlarge \
    --block-device-mapping "[{\"DeviceName\":\"/dev/xvda\",\"Ebs\":{\"DeleteOnTermination\":true,\"VolumeSize\":100}}]" \
    )

publisher_instance_id=$( echo ${result}|cut -d' ' -f9)
publisher_ip_address=$( echo ${result}|cut -d' ' -f14 )
tag=$(aws ec2 --region ${region} create-tags --resources ${publisher_instance_id} --tags Key=Team,Value=${team}  Key=Name,Value=${team}-publisher)

echo "Publisher instance created: [instance_id]:${publisher_instance_id} [ip address]:${publisher_ip_address}":


echo "Waiting for publisher to become running"
while state=$(aws ec2 describe-instances --instance-ids ${publisher_instance_id} --output text --query \
 'Reservations[*].Instances[*].State.Name');
 test "$state" = "pending"; do
  sleep 1;
  echo -n '.'
done; echo " publisher: $state"

publisher_public_ip=$(aws ec2 describe-instances --instance-ids ${publisher_instance_id} --output text \
--query 'Reservations[*].Instances[*].PublicIpAddress')
echo "Publisher [public ip]:${publisher_public_ip}";
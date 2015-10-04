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

## Kuberntes Master creation
echo "Creating kubernetes master ..."
result=$(aws ec2 run-instances --image-id ${ami_id} --key-name ${deployment_key_name} \
--region ${region} --security-groups ${team}_${security_group} --instance-type m4.large \
--user-data file://./yaml/master.yaml)

master_instance_id=$( echo ${result}|cut -d' ' -f9)
master_ip_address=$( echo ${result}|cut -d' ' -f14 )
tag=$(aws ec2 --region ${region} create-tags --resources ${master_instance_id} --tags Key=Team,Value=${team}  Key=Name,Value=${team}-kub-master)

echo "Kubernetes master instance created: [instance_id]:${master_instance_id} [ip address]:${master_ip_address}":

sed  "s#<master-private-ip>#${master_ip_address}#g" ./yaml/node.yaml > ./scripts/${team}/node.yaml
echo "Waiting for master to become running"
while state=$(aws ec2 describe-instances --instance-ids ${master_instance_id} --output text --query \
 'Reservations[*].Instances[*].State.Name');
 test "$state" = "pending"; do
  sleep 1;
  echo -n '.'
done; echo " master: $state"

master_public_ip=$(aws ec2 describe-instances --instance-ids ${master_instance_id} --output text \
--query 'Reservations[*].Instances[*].PublicIpAddress')
echo "master [public ip]:${master_public_ip}";
echo "key=../../keys/${team}/${deployment_key_name}.pem" > ./scripts/${team}/details.conf
echo "km=${master_public_ip}" >> ./scripts/${team}/details.conf

## Minion Creation
echo "Starting to create minions ..."

for i in {1..6}
do
    minions=$(aws ec2 run-instances \
    --image-id ${ami_id} \
    --key-name ${deployment_key_name} \
    --region ${region} \
    --security-groups ${team}_${security_group} \
    --instance-type m4.2xlarge \
    --block-device-mapping "[{\"DeviceName\":\"/dev/xvda\",\"Ebs\":{\"DeleteOnTermination\":true,\"VolumeSize\":100}}]" \
    --user-data file://./scripts/${team}/node.yaml)

    minion_instance_id=$( echo ${minions}|cut -d' ' -f9)
    minion_ip_address=$( echo ${minions}|cut -d' ' -f14 )
    echo "minion ${i} created: [instance_id]:${minion_instance_id} [ip address]:${minion_ip_address}"
    echo "Waiting for minion ${i} to become running"
    while state=$(aws ec2 describe-instances --instance-ids ${minion_instance_id} --output text --query \
        'Reservations[*].Instances[*].State.Name');
         test "$state" = "pending"; do
               sleep 1;
               echo -n '.'
         done; echo " minion ${i}: $state"


    aws ec2 --region ${region} create-tags --resources ${minion_instance_id} --tags \
    Key=Team,Value=${team}  Key=Name,Value=${team}-kub-minion${i}
    minion_public_ip=$(aws ec2 describe-instances --instance-ids ${minion_instance_id} --output text \
     --query 'Reservations[*].Instances[*].PublicIpAddress')
    echo "minion ${i} [public ip]:${minion_public_ip}";
    #python -mwebbrowser http://${minion_public_ip}:4194/containers
    echo "k${i}=${minion_public_ip}" >> ./scripts/${team}/details.conf
done

echo "Kubernetes Cluster creation completed ...."


echo "Installing Kubernetes UI ...."
export KUBERNETES_MASTER=http://${master_public_ip}:8080
kubectl create -f ./yaml/kube-ui-rc.yaml --namespace=kube-system
kubectl create -f ./yaml/kube-ui-svc.yaml --namespace=kube-system

echo "Installing UI complete ...."
python -mwebbrowser http://${master_public_ip}:8080/ui
echo "Pulling images ......"
pushd ./scripts/${team}/
. ./upload.sh

echo "All done :) "
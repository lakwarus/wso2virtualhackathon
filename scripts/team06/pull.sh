#!/usr/bin/env bash
source details.conf
echo "Pulling $1 to minion-01"
ssh -o "StrictHostKeyChecking no" -i ${key} core@${k1} docker pull $1

echo "Pulling $1 to minion-02"
ssh -o "StrictHostKeyChecking no" -i ${key} core@${k2} docker pull $1

echo "Pulling $1 to minion-03"
ssh -o "StrictHostKeyChecking no" -i ${key} core@${k3} docker pull $1

echo "Pulling $1 to minion-04"
ssh -o "StrictHostKeyChecking no" -i ${key} core@${k4} docker pull $1

echo "Pulling $1 to minion-05"
ssh -o "StrictHostKeyChecking no" -i ${key} core@${k5} docker pull $1

echo "Pulling $1 to minion-06"
ssh -o "StrictHostKeyChecking no" -i ${key} core@${k6} docker pull $1




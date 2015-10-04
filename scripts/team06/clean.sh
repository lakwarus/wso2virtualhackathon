#!/usr/bin/env bash
source details.conf

ssh -o "StrictHostKeyChecking no" -i ${key} core@${k1} 'bash -s' < dockerClean.sh
ssh -o "StrictHostKeyChecking no" -i ${key} core@${k2} 'bash -s' < dockerClean.sh
ssh -o "StrictHostKeyChecking no" -i ${key} core@${k3} 'bash -s' < dockerClean.sh
ssh -o "StrictHostKeyChecking no" -i ${key} core@${k4} 'bash -s' < dockerClean.sh
ssh -o "StrictHostKeyChecking no" -i ${key} core@${k5} 'bash -s' < dockerClean.sh
ssh -o "StrictHostKeyChecking no" -i ${key} core@${k6} 'bash -s' < dockerClean.sh



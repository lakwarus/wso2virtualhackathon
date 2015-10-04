#!/usr/bin/env bash
source details.conf


t=`ssh -o "StrictHostKeyChecking no" -i ${key} core@${k1} docker images | grep $1`
echo "${k1} - ${t}"

t=`ssh -o "StrictHostKeyChecking no" -i ${key} core@${k2} docker images | grep $1`
echo "${k2} - ${t}"

t=`ssh -o "StrictHostKeyChecking no" -i ${key} core@${k3} docker images | grep $1`
echo "${k3} - ${t}"

t=`ssh -o "StrictHostKeyChecking no" -i ${key} core@${k4} docker images | grep $1`
echo "${k4} - ${t}"

t=`ssh -o "StrictHostKeyChecking no" -i ${key} core@${k5} docker images | grep $1`
echo "${k5} - ${t}"

t=`ssh -o "StrictHostKeyChecking no" -i ${key} core@${k6} docker images | grep $1`
echo "${k6} - ${t}"


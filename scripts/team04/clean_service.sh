#!/usr/bin/env bash
source details.conf

export KUBERNETES_MASTER=http://${km}:8080
kubectl delete services --all
kubectl delete pods --all
#!/usr/bin/env bash
source details.conf

ssh -t -t -i ${key} core@${km} "ssh -t -t root@$1"




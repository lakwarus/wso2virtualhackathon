#!/usr/bin/env bash
source details.conf

ssh -o "StrictHostKeyChecking no" -i ${key} core@$1

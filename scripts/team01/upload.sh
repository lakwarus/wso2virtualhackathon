#!/usr/bin/env bash

#. ./pull.sh wso2/hbase:1.0.1.1
#. ./pull.sh wso2/hadoop:2.6.0
#. ./pull.sh wso2/das:3.0.0

. ./pull.sh wso2/cep:4.0.0
. ./pull.sh wso2/apache-storm:0.9.5
. ./pull.sh wso2/zookeeper:3.4.6

#. ./verify_images.sh das
#. ./verify_images.sh hbase
#. ./verify_images.sh hadoop

. ./verify_images.sh cep
. ./verify_images.sh storm
. ./verify_images.sh zookeeper

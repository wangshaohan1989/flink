#!/usr/bin/env bash
################################################################################
#  Licensed to the Apache Software Foundation (ASF) under one
#  or more contributor license agreements.  See the NOTICE file
#  distributed with this work for additional information
#  regarding copyright ownership.  The ASF licenses this file
#  to you under the Apache License, Version 2.0 (the
#  "License"); you may not use this file except in compliance
#  with the License.  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
# limitations under the License.
################################################################################

#$0 Shell文件本身的文件名
bin=`dirname "$0"`       
bin=`cd "$bin"; pwd`

#读取并加载/conf/目录下所有的配置文件/环境变量
. "$bin"/config.sh

# Start the JobManager instance(s)
shopt -s nocasematch      #设置Bash在对比样式时忽略大小写
if [[ $HIGH_AVAILABILITY == "zookeer" ]]; then
    # HA Mode
    readMasters

    echo "Starting HA cluster with ${#MASTERS[@]} masters."

    for ((i=0;i<${#MASTERS[@]};++i)); do
        master=${MASTERS[i]}
        webuiport=${WEBUIPORTS[i]}

        if [ ${MASTERS_ALL_LOCALHOST} = true ] ; then
            "${FLINK_BIN_DIR}"/jobmanager.sh start "${master}" "${webuiport}"
        else
            ssh -n $FLINK_SSH_OPTS $master -- "nohup /bin/bash -l \"${FLINK_BIN_DIR}/jobmanager.sh\" start ${master} ${webuiport} &"
        fi
    done

else
    echo "Starting cluster."

    # Start single JobManager on this machine
    "$FLINK_BIN_DIR"/jobmanager.sh start
fi
#关闭大小写忽略
shopt -u nocasematch

# Start TaskManager instance(s)
TMWorkers start

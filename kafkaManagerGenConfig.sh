#!/usr/bin/env bash
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

KAFKA_MANAGER_HOME=${KAFKA_HOME:-"/opt/kafka-manager-1.3.3.21/"}
KAFKA_MANAGER_USERNAME=${KAFKA_MANAGER_USERNAME:-"admin"}
KAFKA_MANAGER_PASSWORD=${KAFKA_MANAGER_PASSWORD:-"password"}

function validate_env() {
    echo "Validating environment"

    if [ -z $ZOOKEEPER_CONNECT ]; then
        echo "ZOOKEEPER_CONNECT is a mandatory environment variable"
        exit 1
   else
        export ZK_HOSTS=$ZOOKEEPER_CONNECT
   fi
    
   if [ -z $KAFKA_MANAGER_USERNAME ]; then
        echo "KAFKA_MANAGER_USERNAME is a mandatory environment variable"
        exit 1
   fi
    
   if [ -z $KAFKA_MANAGER_PASSWORD ]; then
        echo "KAFKA_MANAGER_PASSWORD is a mandatory environment variable"
        exit 1
    fi
    
    echo "Environment validation successful"
}

validate_env 

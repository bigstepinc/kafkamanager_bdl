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

KAFKA_ZOOKEEPER_PORT_2181_TCP_PORT=${KAFKA_ZOOKEEPER_PORT_2181_TCP_PORT:-"2181"}
KAFKA_HEAP_OPTS=${KAFKA_HEAP_OPTS:-"-Xmx1G -Xms1G"}
KAFKA_PORT_9092_TCP_PORT=${KAFKA_PORT_9092_TCP_PORT:-"9092"}
KAFKA_ZOOKEEPER_SERVICE_PORT=${KAFKA_ZOOKEEPER_SERVICE_PORT:-"2181"}
KAFKA_PORT_9092_TCP_PROTO=${KAFKA_PORT_9092_TCP_PROTO:-"tcp"}
KAFKA_SERVICE_PORT_BROKER=${KAFKA_SERVICE_PORT_BROKER:-"9092"}
KAFKA_VERSION=${KAFKA_VERSION:-"2.0.0"}
KAFKA_LOG_DIRS=${KAFKA_LOG_DIRS:-"/opt/kafka/data/logs"}
KAFKA_ZOOKEEPER_PORT_2181_TCP_PROTO=${KAFKA_ZOOKEEPER_PORT_2181_TCP_PROTO:-"tcp"}
KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR=${KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR:-"3"}
KAFKA_ZOOKEEPER_SERVICE_PORT_CLIENT=${KAFKA_ZOOKEEPER_SERVICE_PORT_CLIENT:-"2181"}

#KAFKA_SERVICE_PORT is the container port for kafka broker
KAFKA_SERVICE_PORT=${KAFKA_SERVICE_PORT:-"9092"}
KAFKA_JMX_PORT=${KAFKA_JMX_PORT:-"5555"}
KAFKA_SERVICE_PORT_BROKER=${KAFKA_SERVICE_PORT_BROKER:-"9092"}
KAFKA_DEBUG_LEVEL=${KAFKA_DEBUG_LEVEL:-"INFO"}

function validate_env() {
    echo "Validating environment"

    if [ -z $KAFKA_SERVICE_HOST ]; then
        echo "KAFKA_SERVICE_HOST is a mandatory environment variable"
        exit 1
    else
        #KAFKA_SERVICE_HOST = ip that responds to nslookup for dns entry kafka_statefulset_name.namespace_name.domain
        echo "KAFKA_SERVICE_HOST=$KAFKA_SERVICE_HOST"
        echo "KAFKA_PORT_9092_TCP_ADDR=$KAFKA_SERVICE_HOST"
        
        export KAFKA_PORT_9092_TCP="tcp://$KAFKA_SERVICE_HOST:$KAFKA_SERVICE_PORT"
        echo "KAFKA_PORT_9092_TCP=$KAFKA_PORT_9092_TCP"
        
        export KAFKA_PORT="tcp://$KAFKA_SERVICE_HOST:$KAFKA_SERVICE_PORT"
        echo "KAFKA_PORT=$KAFKA_PORT"
   fi
    
   if [ -z $KAFKA_ZOOKEEPER_SERVICE_HOST ]; then
        echo "KAFKA_ZOOKEEPER_SERVICE_HOST is a mandatory environment variable"
        exit 1
    else
        #KAFKA_ZOOKEEPER_SERVICE_HOST = ip that responds to nslookup for dns entry zookeeper_statefulset_name.namespace_name.domain
        echo "KAFKA_ZOOKEEPER_SERVICE_HOST=$KAFKA_ZOOKEEPER_SERVICE_HOST"
        export KAFKA_ZOOKEEPER_PORT_2181_TCP_ADDR=$KAFKA_ZOOKEEPER_SERVICE_HOST
        echo "KAFKA_ZOOKEEPER_PORT_2181_TCP_ADDR=$KAFKA_ZOOKEEPER_SERVICE_HOST"

        export KAFKA_ZOOKEEPER_PORT_2181_TCP="tcp://$KAFKA_ZOOKEEPER_SERVICE_HOST:$KAFKA_ZOOKEEPER_SERVICE_PORT"
        echo "KAFKA_ZOOKEEPER_PORT_2181_TCP=tcp://$KAFKA_ZOOKEEPER_SERVICE_HOST:$KAFKA_ZOOKEEPER_SERVICE_PORT"
  
        export KAFKA_ZOOKEEPER_PORT="tcp://$KAFKA_ZOOKEEPER_SERVICE_HOST:$KAFKA_ZOOKEEPER_SERVICE_PORT"
        echo "KAFKA_ZOOKEEPER_PORT=tcp://$KAFKA_ZOOKEEPER_SERVICE_HOST:$KAFKA_ZOOKEEPER_SERVICE_PORT"

    fi
    
    if [ -z $KAFKA_ZOOKEEPER_CONNECT ]; then
        echo "KAFKA_ZOOKEEPER_CONNECT is a mandatory environment variable"
        exit 1
    else 
        echo "KAFKA_ZOOKEEPER_CONNECT=$KAFKA_ZOOKEEPER_CONNECT"
    fi
    
    
    if [ -z $POD_IP ]; then
        echo "POD_IP is a mandatory environment variable"
        exit 1
    else 
        echo "POD=$POD_IP"
        export KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://${POD_IP}:$KAFKA_PORT
        echo KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://${POD_IP}:$KAFKA_PORT
    fi
    
    export HOST=`hostname -s`
    if [[ $HOST =~ (.*)-([0-9]+)$ ]]; then
        NAME=${BASH_REMATCH[1]}
        ORD=${BASH_REMATCH[2]}
        export KAFKA_BROKER_ID=$ORD
        echo "KAFKA_BROKER_ID=$ORD"
    else
        echo "Failed to extract ordinal from hostname $HOST"
        exit 1
    fi

    echo "Environment validation successful"
}

function create_kafka_props () {
    rm -rf $KAFKA_CONF/kafka.properties
    echo "Creating Kafka properties file"
    echo "zookeeper.port.2181.tcp.addr=$KAFKA_ZOOKEEPER_PORT_2181_TCP_ADDR" >> $KAFKA_CONF/kafka.properties
    echo "zookeeper.port.2181.tcp.proto=$KAFKA_ZOOKEEPER_PORT_2181_TCP_PROTO" >> $KAFKA_CONF/kafka.properties
    echo "port.9092.tcp.proto=$KAFKA_PORT_9092_TCP_PROTO" >> $KAFKA_CONF/kafka.properties
    echo "zookeeper.service.port.client=$KAFKA_ZOOKEEPER_SERVICE_PORT_CLIENT" >> $KAFKA_CONF/kafka.properties
    echo "service.port=$KAFKA_SERVICE_PORT" >> $KAFKA_CONF/kafka.properties
    echo "advertised.listeners=$KAFKA_ADVERTISED_LISTENERS" >> $KAFKA_CONF/kafka.properties
    echo "zookeeper.connect=$KAFKA_ZOOKEEPER_CONNECT" >> $KAFKA_CONF/kafka.properties
    echo "port.9092.tcp=$KAFKA_PORT_9092_TCP" >> $KAFKA_CONF/kafka.properties
    echo "zookeeper.port.2181.tcp=$KAFKA_ZOOKEEPER_PORT_2181_TCP" >> $KAFKA_CONF/kafka.properties
    echo "port.9092.tcp.addr=$KAFKA_PORT_9092_TCP_ADDR" >> $KAFKA_CONF/kafka.properties
    echo "zookeeper.service.port=$KAFKA_ZOOKEEPER_SERVICE_PORT" >> $KAFKA_CONF/kafka.properties
    echo "zookeeper.port=$KAFKA_ZOOKEEPER_PORT" >> $KAFKA_CONF/kafka.properties
    echo "port.9092.tcp.port=$KAFKA_PORT_9092_TCP_PORT" >> $KAFKA_CONF/kafka.properties
    echo "zookeeper.service.host=$KAFKA_ZOOKEEPER_SERVICE_HOST" >> $KAFKA_CONF/kafka.properties
    echo "service.port.broker=$KAFKA_SERVICE_PORT_BROKER" >> $KAFKA_CONF/kafka.properties
    echo "zookeeper.port.2181.tcp.port=$KAFKA_ZOOKEEPER_PORT_2181_TCP_PORT" >> $KAFKA_CONF/kafka.properties
    echo "broker.id=$KAFKA_BROKER_ID" >> $KAFKA_CONF/kafka.properties
    echo "offsets.topic.replication.factor=$KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR" >> $KAFKA_CONF/kafka.properties
    echo "service.host=$KAFKA_SERVICE_HOST" >> $KAFKA_CONF/kafka.properties
    echo "log.dirs=$KAFKA_LOG_DIRS" >> $KAFKA_CONF/kafka.properties
    echo "listeners=PLAINTEXT://0.0.0.0:9092" >> $KAFKA_CONF/kafka.properties
    echo "Created Kafka properties file"
}


function add_java_env() {
    echo "Adding JVM configuration properties"
    echo "heap.opts=$KAFKA_HEAP_OPTS" >> $KAFKA_CONF/kafka.properties
    echo "jmx.port=$KAFKA_JMX_PORT" >> $KAFKA_CONF/kafka.properties
    echo "Wrote JVM configuration to $$KAFKA_CONF/kafka.properties"
}

function create_log_props () {
    rm -f $KAFKA_CONFIG/log4j.properties
    echo "Creating Kafka log4j configuration"
    echo "log4j.rootLogger=$KAFKA_DEBUG_LEVEL, stdout" >> $KAFKA_CONFIG/log4j.properties
    echo "log4j.appender.stdout=org.apache.log4j.ConsoleAppender" >> $KAFKA_CONFIG/log4j.properties
    echo "llog4j.appender.stdout.layout=org.apache.log4j.PatternLayout" >> $KAFKA_CONFIG/log4j.properties
    echo "log4j.appender.stdout.layout.ConversionPattern=[%d] %p %m \(%c\)%n" >> $KAFKA_CONFIG/log4j.properties
    echo "log4j.logger.kafka.authorizer.logger=WARN" >> $KAFKA_CONFIG/log4j.properties
    echo "log4j.logger.kafka.log.LogCleaner=INFO" >> $KAFKA_CONFIG/log4j.properties
    echo "log4j.logger.kafka.producer.async.DefaultEventHandler=DEBUG" >> $KAFKA_CONFIG/log4j.properties
    echo "log4j.logger.kafka.controller=TRACE" >> $KAFKA_CONFIG/log4j.properties
    echo "log4j.logger.kafka.network.RequestChannel$=WARN" >> $KAFKA_CONFIG/log4j.properties
    echo "log4j.logger.kafka.request.logger=WARN" >> $KAFKA_CONFIG/log4j.properties
    echo "log4j.logger.state.change.logger=TRACE" >> $KAFKA_CONFIG/log4j.properties
    echo "log4j.logger.kafka=$KAFKA_DEBUG_LEVEL" >> $KAFKA_CONFIG/log4j.properties
    
    echo "log4j.rootLogger=WARN, stderr" >> $KAFKA_CONFIG/log4j.properties
    echo "log4j.appender.stderr=org.apache.log4j.ConsoleAppender" >> $KAFKA_CONFIG/log4j.properties
    echo "log4j.appender.stderr.layout=org.apache.log4j.PatternLayout" >> $KAFKA_CONFIG/log4j.properties
    echo "log4j.appender.stderr.layout.ConversionPattern=[%d] %p %m \(%c\)%n" >> $KAFKA_CONFIG/log4j.properties
    echo "log4j.appender.stderr.Target=System.err" >> $KAFKA_CONFIG/log4j.properties

    echo "Wrote log4j configuriation to $KAFKA_CONFIG/log4j.properties"
}

validate_env && create_kafka_props && add_java_env && create_log_props

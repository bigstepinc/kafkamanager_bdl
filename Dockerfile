FROM ubuntu:16.04

ENV LANG="C.UTF-8"
ENV CUB_CLASSPATH=/etc/confluent/docker/docker-utils.jar
ENV COMPONENT=kafka
ENV SCALA_VERSION="2.11"
ENV KAFKA_MAJOR_VERSION="5"
ENV KAFKA_MINOR_VERSION="0"
ENV KAFKA_VERSION="2.0.0"
ENV KAFKA_HOME="/etc/kafka"
ENV KAFKA_CONF="/etc/kafka"

ARG KAFKA_ZOOKEEPER_CONNECT
ENV KAFKA_ZOOKEEPER_CONNECT=${KAFKA_ZOOKEEPER_CONNECT}
ARG KAFKA_ADVERTISED_LISTENERS
ENV KAFKA_ADVERTISED_LISTENERS=${KAFKA_ADVERTISED_LISTENERS}
ARG ALLOW_UNSIGNED=false
ENV ALLOW_UNSIGNED=$ALLOW_UNSIGNED

ADD init-docker.sh /opt 
RUN chmod 777 ./opt/init-docker.sh && \
  ./opt/init-docker.sh
  
ADD kafkaGenConfig.sh /opt
RUN chmod 777 ./opt/kafkaGenConfig.sh 

EXPOSE 9092
ENTRYPOINT ["/bin/bash", "-c" , "./opt/kafkaGenConfig.sh &&  kafka-server-start $KAFKA_CONF/kafka.properties"]

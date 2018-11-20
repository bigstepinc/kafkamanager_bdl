FROM centos

ARG ZOOKEEPER_CONNECT
ENV ZOOKEEPER_CONNECT=${ZOOKEEPER_CONNECT}
ARG KAFKA_MANAGER_USERNAME
ENV KAFKA_MANAGER_USERNAME=${KAFKA_MANAGER_USERNAME}
ARG KAFKA_MANAGER_PASSWORD
ENV KAFKA_MANAGER_PASSWORD=${KAFKA_MANAGER_PASSWORD}


ADD init-docker.sh /opt 
RUN chmod 777 ./opt/init-docker.sh && \
  ./opt/init-docker.sh
  
ADD kafkaGenConfig.sh /opt
RUN chmod 777 ./opt/kafkaGenConfig.sh

EXPOSE 9000
ENTRYPOINT ["/bin/bash", "-c" , "./opt/kafkaGenConfig.sh && /opt/kafka-manager-1.3.3.21/bin/kafka-manager -Dkafka-manager.zkhosts=$ZOOKEEPER_CONNECT -DbasicAuthentication.enabled=true -DbasicAuthentication.username=$KAFKA_MANAGER_USERNAME -DbasicAuthentication.password=$KAFKA_MANAGER_PASSWORD -Dapplication.home=/opt/kafka-manager-1.3.3.21/"]

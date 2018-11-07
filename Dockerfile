FROM centos

ARG ZOOKEEPER_CONNECT
ENV ZOOKEEPER_CONNECT=${ZOOKEEPER_CONNECT}

ADD init-docker.sh /opt 
RUN chmod 777 ./opt/init-docker.sh && \
  ./opt/init-docker.sh
  
#ADD kafkaGenConfig.sh /opt
#RUN chmod 777 ./opt/kafkaGenConfig.sh 

EXPOSE 9000
ENTRYPOINT ["/bin/bash", "-c" , "./bin/kafka-manager -Dkafka-manager.zkhosts=$ZOOKEEPER_CONNECT -DbasicAuthentication.enabled=true -DbasicAuthentication.username=$KAFKA_MANAGER_USERNAME -DbasicAuthentication.password=$KAFKA_MANAGER_PASSWORD"]

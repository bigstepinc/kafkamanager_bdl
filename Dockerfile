FROM centos

ARG ZK_HOSTS
ENV ZK_HOSTS=${ZK_HOSTS}
ARG KAFKA_MANAGER_USERNAME
ENV KAFKA_MANAGER_USERNAME=${KAFKA_MANAGER_USERNAME}
ARG KAFKA_MANAGER_PASSWORD
ENV KAFKA_MANAGER_PASSWORD=${KAFKA_MANAGER_PASSWORD}


ADD init-docker.sh /opt 
RUN chmod 777 ./opt/init-docker.sh && \
  ./opt/init-docker.sh
  
ADD kafkaManagerGenConfig.sh /opt
RUN chmod 777 ./opt/kafkaManagerGenConfig.sh

EXPOSE 9000
ENTRYPOINT ["/bin/bash", "-c" , "./opt/kafkaManagerGenConfig.sh && /opt/kafka-manager-1.3.3.21/bin/kafka-manager"]

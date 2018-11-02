FROM ubuntu:16.04

ADD init-docker.sh /opt 
RUN chmod 777 /opt/init-docker.sh && \
  /opt/init-docker.sh


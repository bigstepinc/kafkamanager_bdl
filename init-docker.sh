#!/bin/bash

echo "Installing basic packages"
apt-get update
apt-get install -y wget curl vim unzip  \
        apt-transport-https git \
        netcat python \
        software-properties-common
        
echo "Installing Python packages"
curl -fSL "https://bootstrap.pypa.io/get-pip.py" | python && \
pip install --no-cache-dir git+https://github.com/confluentinc/confluent-docker-utils@v0.0.26 && \
apt remove --purge -y git 

# Install Java 8
echo "Installing and configuring Java"
JAVA_HOME=$(JAVA_HOME:-/opt/jdk1.8.0_191)

cd /opt && \
wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u191-b12/2787e4a523244c269598db4e85c51e0c/jdk-8u191-linux-x64.tar.gz" &&\
tar xzf jdk-8u191-linux-x64.tar.gz && rm -rf jdk-8u191-linux-x64.tar.gz

echo 'export JAVA_HOME=$JAVA_HOME' >> ~/.bashrc && \
echo 'export PATH="$PATH:$JAVA_HOME/bin:$JAVA_HOME/jre/bin"' >> ~/.bashrc && \
bash ~/.bashrc 
cd $JAVA_HOME && update-alternatives --install /usr/bin/java java $JAVA_HOME/bin/java 1
    
#Add Java Security Policies
curl -L -C - -b "oraclelicense=accept-securebackup-cookie" -O http://download.oracle.com/otn-pub/java/jce/8/jce_policy-8.zip && \
unzip jce_policy-8.zip && \
cp UnlimitedJCEPolicyJDK8/US_export_policy.jar $JAVA_HOME/jre/lib/security/ && \
cp UnlimitedJCEPolicyJDK8/local_policy.jar $JAVA_HOME/jre/lib/security/ && \
rm -rf UnlimitedJCEPolicyJDK8  && \
rm -rf jce_policy-8.zip

# Add Confluent repository
echo "Add Confluent repository"

if [ "x$ALLOW_UNSIGNED" = "xtrue" ]; then
  echo "APT::Get::AllowUnauthenticated \"true\";" > /etc/apt/apt.conf.d/allow_unauthenticated; 
else 
  wget -qO - http://packages.confluent.io/deb/${KAFKA_MAJOR_VERSION}.${KAFKA_MINOR_VERSION}/archive.key | apt-key add - 
fi 

add-apt-repository "deb [arch=amd64] http://packages.confluent.io/deb/${KAFKA_MAJOR_VERSION}.${KAFKA_MINOR_VERSION} stable main"

# Install Kafka
echo "Installing Kafka"
#apt-get install -y confluent-kafka-${SCALA_VERSION}=${KAFKA_VERSION}${CONFLUENT_PLATFORM_LABEL}-${CONFLUENT_DEB_VERSION} && \
apt-get install -y confluent-kafka-${SCALA_VERSION}
apt-get clean && \
rm -rf /tmp/* /var/lib/apt/lists/* 

# Set up Kafka directories
echo "Setting up Kafka directories" && \
mkdir -p /var/lib/${COMPONENT}/data /etc/${COMPONENT}/secrets && \
mkdir -p /var/log/${COMPONENT} /var/log/confluent /var/lib/zookeeper && \
chmod -R ag+w /etc/${COMPONENT} /var/lib/${COMPONENT}/data /etc/${COMPONENT}/secrets && \
chown -R root:root /var/log/${COMPONENT} /var/log/confluent /var/lib/${COMPONENT} /var/lib/zookeeper

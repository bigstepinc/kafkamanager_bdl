#!/bin/bash

echo "Installing sbt, Java and other packages"
curl https://bintray.com/sbt/rpm/rpm |  tee /etc/yum.repos.d/bintray-sbt-rpm.repo
yum install -y java-1.8.0-openjdk.x86_64 java-devel wget curl git sbt unzip
cp /etc/profile /etc/profile_backup 
echo 'export JAVA_HOME=/usr/lib/jvm/jre-1.8.0-openjdk' | tee -a /etc/profile
echo 'export JRE_HOME=/usr/lib/jvm/jre' |tee -a /etc/profile
source /etc/profile
echo "Installed sbt, Java and other packages"

echo "Installing Scala"
cd /opt && \
wget https://downloads.lightbend.com/scala/2.12.2/scala-2.12.2.rpm
yum localinstall -y scala-2.12.2.rpm
rm -rf /opt/scala-2.12.2.rpm 
echo "Installed Scala"

echo "Installing kafka-manager"
git clone https://github.com/yahoo/kafka-manager.git && \
cd kafka-manager/ && \
sbt clean dist
mv ./target/universal/kafka-manager-1.3.3.21.zip /opt && \
rm -rf /opt/kafka-manager/ && \ 
cd /opt/ && \
unzip kafka-manager-1.3.3.21.zip 
rm -rf kafka-manager-1.3.3.21.zip 
cd /opt/kafka-manager-1.3.3.21/
echo "Installed kafka-manager" 

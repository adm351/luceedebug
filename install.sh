#!/bin/bash

cd ~/
wget https://corretto.aws/downloads/latest/amazon-corretto-11-x64-linux-jdk.rpm
yum localinstall -y amazon-corretto-11-x64-linux-jdk.rpm
rm -rf amazon-corretto-11-x64-linux-jdk.rpm

yum install -y procps less

# if we need to change lucee verisons...
# if [ ! -f /opt/tomcat/lucee/lucee.jar.bak ]; then
#   cp /opt/tomcat/lucee/lucee.jar /opt/tomcat/lucee/lucee.jar.bak
# fi
# wget https://cdn.lucee.org/lucee-5.3.10.120.jar
# mv lucee-5.3.10.120.jar /opt/tomcat/lucee/lucee.jar

cd /var/www/app/luceedebug
cp ./setenv.sh /opt/tomcat/bin/setenv.sh

sh build.sh
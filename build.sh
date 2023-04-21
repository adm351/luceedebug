#!/bin/bash

export JAVA_HOME=/usr/lib/jvm/java-11-amazon-corretto/

echo '' > /opt/tomcat/logs/catalina.out

./gradlew shadowjar

cp -f ./luceedebug/build/libs/luceedebug.jar /opt/tomcat/lucee/luceedebug.jar

TOMCAT_PID=$(ps -ef | grep -v grep | grep tomcat | awk '{print $2}')

if [ $TOMCAT_PID != "" ]; then
  kill -9 $(ps -ef | grep -v grep | grep tomcat | awk '{print $2}')
fi

/opt/tomcat/bin/catalina.sh start

exec less +F /opt/tomcat/logs/catalina.out
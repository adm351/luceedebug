# Tomcat memory settings
# -Xms<size> set initial Java heap size
# -Xmx<size> set maximum Java heap size
# -Xss<size> set java thread stack size
# -XX:MaxPermSize sets the java PermGen size

# Default memory settings if not specified in $LUCEE_JAVA_OPTS
: ${CF_JVM_ARGS:="-Xms256m -Xmx512m"}
: ${projectName:="lucee"}

uuid=$(uuidgen)
jvmconfig=""
jvmconfig+=" ${CF_JVM_ARGS}"
if [ "$TIMEZONE" != "" ]; then 
        jvmconfig+=" -Duser.timezone=${TIMEZONE}"
fi

echo $prewarm

# Datadog agent
#if [[ $prewarm != true ]]; then
        #host_ip=`curl --silent --max-time 10 --connect-timeout 5 http://169.254.169.254/latest/meta-data/local-ipv4`
        #jvmconfig+=" -javaagent:/opt/datadog/dd-java-agent.jar -Ddd.agent.host=${host_ip}"
        #jvmconfig+=" -javaagent:/opt/tomcat/lucee/apminsight-javaagent.jar -Dapminsight.application.name=${projectName}"
#fi

# signalfx agent
if [[ $prewarm != true && $useAPM == "true" ]]; then
        echo "configuring APM"
        host_ip=`curl --silent --max-time 10 --connect-timeout 5 http://169.254.169.254/latest/meta-data/local-ipv4`
        jvmconfig+=" -javaagent:/opt/apm/signalfx-tracing.jar -Dsignalfx.service.name='${projectName}' -Dsignalfx.agent.host=${host_ip} -Dsignalfx.tracing.enabled=true -Dsignalfx.span.tags='projectName:${projectName}'"
fi

# newrelic agent
if [[ $prewarm != true && $useAPM == "newrelic" ]]; then
        echo "configuring newrelic"
        jvmconfig+=" -javaagent:/opt/apm/newrelic/newrelic.jar -Dnewrelic.config.app_name='${projectName}' -Dnewrelic.config.license_key=${APMKEY}"
fi

jvmconfig+=" -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=localhost:9999 -javaagent:/opt/tomcat/lucee/luceedebug.jar=jdwpHost=localhost,jdwpPort=9999,debugHost=0.0.0.0,debugPort=10000,jarPath=/opt/tomcat/lucee/luceedebug.jar"

#echo $jvmconfig

# Use /dev/urandom for EGD (http://wiki.apache.org/tomcat/HowTo/FasterStartUp)
JAVA_OPTS="${jvmconfig} -Djava.security.egd=file:/dev/./urandom";

# additional JVM arguments can be added to the above line as needed, such as
# custom Garbage Collection arguments.

# file permission needed for 8.5 and above
UMASK=0022

export JAVA_OPTS;

# Add location of Apache Tomcat native library to the library path
LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/lib/x86_64-linux-gnu";
export LD_LIBRARY_PATH;
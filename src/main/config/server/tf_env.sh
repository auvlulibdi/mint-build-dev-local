#!/bin/bash
#
# this script sets the environment for other fascinator scripts
#

# export SERVER_URL="http://localhost/mint/"
export SERVER_URL="${server.url}"
export LOCAL_PORT="9001"
export PROJECT_HOME="${project.home}/"
export AMQ_PORT="9201"
export AMQ_STOMP_PORT="9202"
export SMTP_HOST="${smtp.host}"
export ADMIN_EMAIL="${admin.email}"
export NON_PROXY_HOSTS="localhost"

# set fascinator home directory
export TF_HOME="$PROJECT_HOME/home"
export REDBOX_VERSION="${mint.version}"

# java class path
export CLASSPATH="plugins/*:lib/*"

# jvm memory settings
JVM_OPTS="-XX:MaxPermSize=1024m -Xmx1024m"

# logging directories
export SOLR_LOGS=$TF_HOME/logs/solr
export JETTY_LOGS=$TF_HOME/logs/jetty
export ARCHIVES=$TF_HOME/logs/archives
if [ ! -d $ARCHIVES ]
then
    mkdir -p $ARCHIVES
fi
if [ ! -d $JETTY_LOGS ]
then
    mkdir -p $JETTY_LOGS
fi
if [ ! -d $SOLR_LOGS ]
then
    mkdir -p $SOLR_LOGS
fi

# use http_proxy if defined
if [ -n "$http_proxy" ]; then
	_TMP=${http_proxy#*//}
	PROXY_HOST=${_TMP%:*}
	_TMP=${http_proxy##*:}
	PROXY_PORT=${_TMP%/}
	echo " * Detected HTTP proxy host:'$PROXY_HOST' port:'$PROXY_PORT'"
	PROXY_OPTS="-Dhttp.proxyHost=$PROXY_HOST -Dhttp.proxyPort=$PROXY_PORT -Dhttp.nonProxyHosts=$NON_PROXY_HOSTS"
else
	echo " * No HTTP proxy detected"
fi

# jetty settings
JETTY_OPTS="-Djetty.port=$LOCAL_PORT -Djetty.logs=$JETTY_LOGS -Djetty.home=$PROJECT_HOME/server/jetty"

# solr settings
SOLR_OPTS="-Dsolr.solr.home=$PROJECT_HOME/solr"

# Geonames
GEONAMES="-Dgeonames.solr.home=$PROJECT_HOME/home/geonames/solr"

# directories
CONFIG_DIRS="-Dfascinator.home=$TF_HOME -Dportal.home=$PROJECT_HOME/portal -Dstorage.home=$PROJECT_HOME/storage"

# additional settings
EXTRA_OPTS="-Dserver.url.base=$SERVER_URL -Damq.port=$AMQ_PORT -Damq.stomp.port=$AMQ_STOMP_PORT -Dsmtp.host=$SMTP_HOST -Dadmin.email=$ADMIN_EMAIL -Dredbox.version=$REDBOX_VERSION"

# set options for maven to use
export JAVA_OPTS="$JVM_OPTS $JETTY_OPTS $SOLR_OPTS $PROXY_OPTS $CONFIG_DIRS $EXTRA_OPTS $GEONAMES"

#!/bin/bash

WATERFALL_JAR=$WATERFALL_HOME/Waterfall.jar

if [[ ! -e $WATERFALL_JAR ]]; then
    echo "Downloading ${WATERFALL_JAR_URL:=${WATERFALL_BASE_URL}/${WATERFALL_JOB_ID:-lastStableBuild}/artifact/Waterfall-Proxy/bootstrap/target/Waterfall.jar}"
    if ! curl -o $WATERFALL_JAR -fsSL $WATERFALL_JAR_URL; then
        echo "ERROR: failed to download" >&2
        exit 2
    fi
fi

if [ -d /plugins ]; then
    echo "Copying Waterfall plugins over..."
    cp -r /plugins $WATERFALL_HOME
fi

if [ $UID == 0 ]; then
  chown -R waterfall:waterfall $WATERFALL_HOME
fi

echo "Setting initial memory to ${INIT_MEMORY:-${MEMORY}} and max to ${MAX_MEMORY:-${MEMORY}}"
JVM_OPTS="-Xms${INIT_MEMORY:-${MEMORY}} -Xmx${MAX_MEMORY:-${MEMORY}} ${JVM_OPTS}"

if [ $UID == 0 ]; then
  exec sudo -u waterfall java $JVM_OPTS -jar $WATERFALL_JAR "$@"
else
  exec java $JVM_OPTS -jar $WATERFALL_JAR "$@"
fi
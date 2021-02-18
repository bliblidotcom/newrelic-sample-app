#!/bin/sh
set -e

. /jmx_options.sh
. /jvm_ram_options.sh
. /jvm_debug_options.sh

java -cp /app:/app/lib/* \
  ${JMX_OPTIONS} \
  ${JVM_RAM_OPTIONS} \
  ${JVM_DEBUG_OPTIONS} \
  ${JVM_USER_OPTIONS} \
  -javaagent:/app/jmx_exporter.jar=9091:jmx_exporter.yml \
  -javaagent:/app/newrelic/newrelic.jar \
  $(cat /app/mainclass.txt)

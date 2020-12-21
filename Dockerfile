FROM alpine:3.11

ENV JAVA_ALPINE_VERSION=8.252.09-r0 \
    NEWRELIC_VERSION=6.3.0 \
    JMX_VERSION=0.12.0

ENV NEWRELIC_DOWNLOAD_URL=https://download.newrelic.com/newrelic/java-agent/newrelic-agent/${NEWRELIC_VERSION}/newrelic-java-${NEWRELIC_VERSION}.zip \
    JMX_EXPORTER_DOWNLOAD_URL=https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/${JMX_VERSION}/jmx_prometheus_javaagent-${JMX_VERSION}.jar

RUN apk add --no-cache --update openjdk8="$JAVA_ALPINE_VERSION" tini \
    && apk add --no-cache --update ttf-dejavu

ENTRYPOINT ["/sbin/tini", "--"]

ENV PATH="/usr/lib/jvm/default-jvm/bin:${PATH}"

#updating time Zone and creating user

RUN apk add --no-cache tzdata \
    && touch /etc/timezone /etc/localtime \
    && cp /usr/share/zoneinfo/Asia/Jakarta /etc/localtime \
    && echo "Asia/Jakarta" > /etc/timezone \
    && apk del tzdata \
    && addgroup -S appuser -g 501  \
    && adduser -S appuser -G appuser -u 501 -s /bin/ash

# setup newrelic agent library
RUN wget -O newrelic.zip ${NEWRELIC_DOWNLOAD_URL} && \
        mkdir -p /app && \
        unzip newrelic.zip -d /app && \
        chown -R appuser:appuser /app && \
        rm /app/newrelic/newrelic.yml && \
        rm newrelic.zip && \
        # Download jmx exporter
        wget -O /app/jmx_exporter.jar ${JMX_EXPORTER_DOWNLOAD_URL}

COPY docker/newrelic.yml /app/newrelic/newrelic.yml
COPY docker/jmx_exporter.yml /app/jmx_exporter.yml

# to use jmx, you'll need to source /jmx_options.sh
# and it will create a ${JMX_OPTIONS} env var that you can use
# CMD /usr/bin/java ${JMX_OPTIONS} run.some.class
COPY docker/jmx_options.sh /

# to set up max ram for jvm based on cgroup limit
COPY docker/jvm_ram_options.sh /

# to set some java option for debugging purpose
COPY docker/jvm_debug_options.sh /

# Expose jmx port
EXPOSE 9090

# Expose jmx exporter port
EXPOSE 9091

USER appuser

CMD ["/usr/bin/java", "-version"]

## end java base image ##

EXPOSE 8080

COPY docker/springboot.sh /app

#####################################################################
### from here down, the commands get executed in the child container
#####################################################################

# move to tmp, so appuser can create and delete directories
WORKDIR /tmp

ARG JARFILE
COPY --chown=appuser:appuser ${JARFILE} app.jar
# Workaround for Jenkins CI / kaniko build
# see https://github.com/GoogleContainerTools/kaniko/issues/9
USER root
RUN \
  chown appuser:appuser app.jar /app/springboot.sh && \
  chmod 755 app.jar /app/springboot.sh
USER appuser

# expand out the jar file, put files in the right place, and remove jar
RUN  \
  # not sure why, but you need to specify the files to extract
  # otherwise nothing gets extracted.  corrupted jar index?
  jar xf app.jar BOOT-INF META-INF && \
  cp -r BOOT-INF/lib /app/lib && \
  cp -r META-INF /app/META-INF && \
  cp -r BOOT-INF/classes/* /app && \
  rm -rf app.jar BOOT-INF META-INF

# move back to the place where the app now lives
WORKDIR /app

# pull out the main class name at build time into a file
RUN \
  sed ':a; N; $!b a; s/\r\n\s\{1,\}//g' META-INF/MANIFEST.MF | \
  grep Start-Class | \
  cut -d':' -f2 | \
  awk '{$1=$1};1' > mainclass.txt

# using the CMD w/o ['cmd', 'arg'] syntax to get shell expansion for classname
CMD /app/springboot.sh

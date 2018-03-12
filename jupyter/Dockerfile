FROM jupyter/all-spark-notebook

# Set env vars for pydoop
ENV HADOOP_HOME /usr/local/hadoop-2.7.3
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
ENV HADOOP_CONF_HOME /usr/local/hadoop-2.7.3/etc/hadoop
ENV HADOOP_CONF_DIR  /usr/local/hadoop-2.7.3/etc/hadoop

USER root
# JAVA
ARG JAVA_MAJOR_VERSION=8
ARG JAVA_UPDATE_VERSION=131
ARG JAVA_BUILD_NUMBER=11
ENV JAVA_HOME /usr/jdk1.${JAVA_MAJOR_VERSION}.0_${JAVA_UPDATE_VERSION}

ENV PATH $PATH:$JAVA_HOME/bin
RUN curl -sL --retry 3 --insecure \
  --header "Cookie: oraclelicense=accept-securebackup-cookie;" \
  "http://download.oracle.com/otn-pub/java/jdk/${JAVA_MAJOR_VERSION}u${JAVA_UPDATE_VERSION}-b${JAVA_BUILD_NUMBER}/d54c1d3a095b4ff2b6607d096fa80163/server-jre-${JAVA_MAJOR_VERSION}u${JAVA_UPDATE_VERSION}-linux-x64.tar.gz" \
  | gunzip \
  | tar x -C /usr/ \
  && ln -s $JAVA_HOME /usr/java \
  && rm -rf $JAVA_HOME/man

# Add hadoop binaries
# INSTALL HADOOP
RUN wget http://apache.rediris.es/hadoop/common/hadoop-2.7.5/hadoop-2.7.5.tar.gz \
&& tar -xzf hadoop-2.7.5.tar.gz \
&& rm hadoop-2.7.5.tar.gz
RUN mv hadoop-2.7.5/ /usr/local/
RUN chown -R $NB_USER:users /usr/local/hadoop-2.7.5 && \
# Install os dependencies required for pydoop, pyhive
    apt-get update && \
    apt-get install --no-install-recommends -y build-essential python-dev libsasl2-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
# Remove the example hadoop configs and replace
# with those for our cluster.
# Alternatively this could be mounted as a volume
    rm -f /usr/local/hadoop-2.7.3/etc/hadoop/*

# Download this from ambari / cloudera manager and copy here
COPY ./hadoop-conf/ /usr/local/hadoop-2.7.3/etc/hadoop/

# Spark-Submit doesn't work unless I set the following
RUN echo "spark.driver.extraJavaOptions -Dhdp.version=2.5.3.0-37" >> /usr/local/spark/conf/spark-defaults.conf  && \
    echo "spark.yarn.am.extraJavaOptions -Dhdp.version=2.5.3.0-37" >> /usr/local/spark/conf/spark-defaults.conf && \
    echo "spark.master=yarn" >>  /usr/local/spark/conf/spark-defaults.conf && \
    echo "spark.hadoop.yarn.timeline-service.enabled=false" >> /usr/local/spark/conf/spark-defaults.conf && \
    chown -R $NB_USER:users /usr/local/spark/conf/spark-defaults.conf && \
    # Create an alternative HADOOP_CONF_HOME so we can mount as a volume and repoint
    # using ENV var if needed
    mkdir -p /etc/hadoop/conf/ && \
    chown $NB_USER:users /etc/hadoop/conf/

USER $NB_USER

# Install useful jupyter extensions and python libraries like :
# - Dashboards
# - PyDoop
# - PyHive
RUN pip install jupyter_dashboards faker && \
    jupyter dashboards quick-setup --sys-prefix # && \ 
   # pip2 install pyhive pydoop thrift sasl thrift_sasl faker

USER root
# Ensure we overwrite the kernel config so that toree connects to cluster
RUN jupyter toree install --sys-prefix --spark_opts="--master yarn --deploy-mode client --driver-memory 512m  --executor-memory 512m  --executor-cores 1 --driver-java-options -Dhdp.version=2.5.3.0-37 --conf spark.hadoop.yarn.timeline-service.enabled=false"
USER $NB_USER

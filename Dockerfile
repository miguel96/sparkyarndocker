# Use an official Python runtime as a parent image
FROM debian:jessie
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

RUN apt-get update \
    && apt-get install -y locales \
    && dpkg-reconfigure -f noninteractive locales \
    && locale-gen C.UTF-8 \
    && /usr/sbin/update-locale LANG=C.UTF-8 \
    && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
    && locale-gen \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
# Users with other locales should set this in their derivative image
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN apt-get update \
 && apt-get install -y curl unzip openssh-client openssh-server wget\
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# INSTALL HADOOP
RUN wget http://apache.rediris.es/hadoop/common/hadoop-2.7.5/hadoop-2.7.5.tar.gz \
&& tar -xzf hadoop-2.7.5.tar.gz \
&& rm hadoop-2.7.5.tar.gz
RUN mkdir /home/hadoop
RUN mv hadoop-2.7.5/ /home/hadoop/hadoop
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

# CREATE HADOOP USER
RUN useradd hadoop
COPY ./etc/ /etc/
#CONFIG SSH
COPY ./ssh/ /root/.ssh
##Override hadoop config files
COPY ./hadoop-conf/ /home/hadoop/hadoop/etc/hadoop/
#SET HADOOP USER PATH
COPY ./ssh/  /home/hadoop/.ssh
RUN chown -R hadoop /home/hadoop
ENV PATH $PATH:$JAVA_HOME/bin
ENV PATH /home/hadoop/hadoop/bin:/home/hadoop/hadoop/sbin:$PATH
RUN mkdir /var/run/sshd
RUN echo root:root | chpasswd
RUN echo export JAVA_HOME=$JAVA_HOME >> /home/hadoop/hadoop/etc/hadoop/hadoop-env.sh

RUN wget http://apache.rediris.es/spark/spark-2.2.0/spark-2.2.0-bin-hadoop2.7.tgz \
  && tar -xvf spark-2.2.0-bin-hadoop2.7.tgz \
  && rm spark-2.2.0-bin-hadoop2.7.tgz
RUN mv spark-2.2.0-bin-hadoop2.7 /home/hadoop/spark

RUN echo PATH=/home/hadoop/spark/bin:$PATH >> /home/hadoop/.profile
RUN echo export HADOOP_CONF_DIR=/home/hadoop/hadoop/etc/hadoop >> /home/hadoop/.profile
RUN echo export SPARK_HOME=/home/hadoop/spark >> /home/hadoop/.profile
RUN echo export LD_LIBRARY_PATH=/home/hadoop/hadoop/lib/native:$LD_LIBRARY_PATH >> /home/hadoop/.profile


ENV PATH=/home/hadoop/spark/bin:$PATH
ENV  HADOOP_CONF_DIR=/home/hadoop/hadoop/etc/hadoop
ENV  SPARK_HOME=/home/hadoop/spark
ENV  LD_LIBRARY_PATH=/home/hadoop/hadoop/lib/native:$LD_LIBRARY_PATH

COPY ./spark-conf /home/hadoop/spark/conf
RUN chown -R hadoop /home/hadoop/spark
COPY ./start.sh /usr/local/bin/start.sh
COPY ./startNodes.sh /usr/local/bin/startNodes.sh
RUN mkdir /tmp/hadoop-root
RUN mkdir /tmp/hadoop-root/nm-local-dir
RUN mkdir /home/hadoop/hadoop/logs
RUN mkdir /home/hadoop/hadoop/logs/userlogs


# PYTHON
RUN apt-get update \
 && apt-get install -y python python-pip   pandoc python-dev \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*
WORKDIR $SPARK_HOME/python
ENV PYTHON_ENV env
RUN pip install wheel pypandoc
RUN python setup.py sdist
RUN pip install virtualenv \
 && virtualenv $PYTHON_ENV \
 && source $SPARK_HOME/python/$PYTHON_ENV/bin/activate
RUN pip install Afinn py4j psycopg2-binary tabulate xlsxwriter kafka-python pandas boto3 httplib2
WORKDIR /
ENV PYSPARK_PYTHON $SPARK_HOME/$PYTHON_ENV/bin/python

#RUN echo export PYTHON_ENV=env >> /home/hadoop/.profile
#RUN echo export PYSPARK_PYTHON=$SPARK_HOME/$PYTHON_ENV/bin/python >> /home/hadoop/.profile

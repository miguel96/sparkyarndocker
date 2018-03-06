#!/bin/bash
## RUN SSH
service ssh start
##ADD All hosts to known hosts
ssh-keyscan spark-master >> ~/.ssh/known_hosts
ssh-keyscan spark-worker-1 >> ~/.ssh/known_hosts
ssh-keyscan spark-worker-2 >> ~/.ssh/known_hosts
## START HDFS
hdfs namenode -format
##chown -R hadoop /usr/local/hadoop
start-dfs.sh
## START YARN
start-yarn.sh
## START SPARK HISTORY SERVER
hdfs dfs -mkdir /spark-events
hdfs dfs -chmod -R 777 /
$SPARK_HOME/sbin/start-history-server.sh
top -b > logs.txt
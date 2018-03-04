#!/bin/bash
service ssh start
su -l hadoop
hdfs namenode -format
start-dfs.sh
start-yarn.sh
hdfs dfs -mkdir /spark-logs
echo Started
bash

 # (https://linode.com/docs/databases/hadoop/how-to-install-and-set-up-hadoop-cluster)[INSTALL HADOOP]
# ALL NODES
- service ssh start

# ON NODEMASTER
## START HDFS
- hdfs namenode -format
- start-dfs.sh -> stop-dfs.sh
- Monitor: http://node-master-IP:50070
## START YARN
- start-yarn.sh
- Monitor: http://node-master-IP:8088
## SPARK
- hdfs dfs -mkdir /spark-logs 

### COMMAND
- su -l hadoop
- hdfs namenode -format && start-dfs.sh && start-yarn.sh &&  hdfs dfs -mkdir /spark-logs

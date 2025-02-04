#!/bin/bash
# Start HDFS
$HADOOP_HOME/sbin/start-dfs.sh
# Start YARN
$HADOOP_HOME/sbin/start-yarn.sh
echo "Hadoop services started (HDFS + YARN)."

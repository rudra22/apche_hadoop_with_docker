#!/bin/bash
# Format HDFS (only the first time)
if [ ! -f /root/.hdfs_formatted ]; then
  echo "Formatting HDFS..."
  hdfs namenode -format
  touch /root/.hdfs_formatted
fi

# Start HDFS daemons
echo "Starting HDFS..."
start-dfs.sh

# Start YARN daemons
echo "Starting YARN..."
start-yarn.sh

# Check status
jps

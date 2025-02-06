#!/bin/bash
set -e

# Start SSH Daemon
service ssh start

# Initialize and start Hadoop (HDFS + YARN)
bash /scripts/start-hadoop.sh

# Start HBase
bash /scripts/start-hbase.sh

# Start Hive Metastore & HiveServer2
bash /scripts/start-hive.sh

# Start Oozie
bash /scripts/start-oozie.sh

# Start Hue
bash /scripts/start-hue.sh

# Keep container running
tail -f /dev/null

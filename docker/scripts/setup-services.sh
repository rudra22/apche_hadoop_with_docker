#!/bin/bash
set -e

# Start SSH (needed for Hadoop pseudo-distributed mode)
service ssh start

# Format HDFS if not already formatted
if [ ! -d "/opt/hadoop/data/namenode/current" ]; then
  echo "Formatting HDFS..."
  $HADOOP_HOME/bin/hdfs namenode -format
fi

# Start core Hadoop (HDFS + YARN)
bash /start-hadoop.sh

# (Optional) Initialize Hive Derby metastore
$HIVE_HOME/bin/schematool -dbType derby -initSchema || true

# Start HBase
$HBASE_HOME/bin/start-hbase.sh

# Start Oozie (optional minimal start)
# $OOZIE_HOME/bin/oozied.sh start || true

# Start Hue
bash /start-hue.sh

# Keep container running
tail -f /dev/null

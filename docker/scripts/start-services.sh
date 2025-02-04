#!/bin/bash
set -e
bash /start-hadoop.sh
$HIVE_HOME/bin/schematool -dbType derby -initSchema || true
$HBASE_HOME/bin/start-hbase.sh
# $OOZIE_HOME/bin/oozied.sh start || true
bash /start-hue.sh

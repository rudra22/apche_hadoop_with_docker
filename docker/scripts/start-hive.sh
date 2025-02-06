#!/bin/bash
echo "Initializing Hive Metastore..."
schematool -dbType derby -initSchema

echo "Starting Hive Metastore..."
hive --service metastore &

echo "Starting HiveServer2..."
hive --service hiveserver2 &

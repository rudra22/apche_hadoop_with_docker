#!/bin/bash
echo "Setting up Oozie..."
# You may need to build Oozie WAR file if not included, or place sharelib, etc.

# Example to create Oozie sharelib (required for many Oozie workflows)
# mkdir -p /opt/oozie/oozie-sharelib
# oozie-setup.sh sharelib create -fs hdfs://localhost:9000

echo "Starting Oozie..."
oozied.sh start

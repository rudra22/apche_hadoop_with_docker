#!/bin/bash
# Start Hue in the background
# By default, Hue runs on port 8888
echo "Starting Hue..."
$HUE_HOME/build/env/bin/supervisor &
sleep 5

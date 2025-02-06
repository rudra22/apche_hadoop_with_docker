#!/bin/bash
echo "Starting Hue..."
# Start Hue in the background (port usually 8888 by default)
cd $HUE_HOME
build/env/bin/supervisor &

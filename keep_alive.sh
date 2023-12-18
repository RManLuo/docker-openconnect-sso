#!/bin/bash

while true; do
    # Check if tun0 network card exists
    if ip link show tun0 &> /dev/null; then
        echo "tun0 exists, access the Internet to stay connected."
        curl https://www.google.com
        sleep 60
    else
        echo "tun0 does not exist, waiting..."
        sleep 10  # Wait 10 seconds and check again
    fi
done

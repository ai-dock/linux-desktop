#!/bin/bash

# Defer to init to control dbus.

SERVICE_NAME=dbus

trap cleanup EXIT

function cleanup() {
    /etc/init.d/dbus stop
    kill $(jobs -p) > /dev/null 2>&1
    wait -n
}

# todo improve this
function start() {
    source /opt/ai-dock/etc/environment.sh
    if [[ ${SERVERLESS,,} = "true" ]]; then
        printf "Refusing to start $SERVICE_NAME in serverless mode\n"
        exec sleep 10
    fi
    
    printf "Starting %s...\n" "$SERVICE_NAME"
   
    /etc/init.d/dbus start
    
    sleep infinity
}


start 2>&1
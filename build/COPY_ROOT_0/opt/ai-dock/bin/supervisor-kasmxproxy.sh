#!/bin/bash

trap cleanup EXIT

function cleanup() {
    kill $(jobs -p) > /dev/null 2>&1 &
    wait -n
}

# todo improve this
function start() {
    source /opt/ai-dock/etc/environment.sh
    if [[ ${SERVERLESS,,} = "true" ]]; then
        printf "Refusing to start $SERVICE_NAME in serverless mode\n"
        exec sleep 10
    fi
    
    until [[ -S "/tmp/.X11-unix/X${DISPLAY/:/}" && -S "/tmp/.X11-unix/X${VNC_DISPLAY/:/}" ]]; do
        printf "Waiting for X11 sockets...\n"
        sleep 1
    done
    
    
    source /opt/ai-dock/etc/environment.sh
    kasmxproxy -a "${DISPLAY}" -v "${VNC_DISPLAY}"
}

start 2>&1
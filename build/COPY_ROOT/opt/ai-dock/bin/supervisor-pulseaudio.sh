#!/bin/bash

trap cleanup EXIT

SERVICE_NAME="PulseAudio"

function cleanup() {
    kill $(jobs -p) > /dev/null 2>&1
}

function start() {
    if [[ ${SERVERLESS,,} = "true" ]]; then
        printf "Refusing to start $SERVICE_NAME in serverless mode\n"
        exec sleep 10
    fi
    
    printf "Starting ${SERVICE_NAME}...\n"
    
    if pulseaudio --check >/dev/null 2>&1; then 
        pulseaudio -k &
        wait -n
    fi
    
    until [ -S /run/dbus/system_bus_socket ]; do
        printf "Waiting for dbus socket...\n"
        sleep 1
    done
    
    exec pulseaudio \
        --system \
        --realtime=true \
        --disallow-exit \
        -L 'module-native-protocol-tcp auth-ip-acl=127.0.0.0/8 port=4713 auth-anonymous=1'
}

start 2>&1